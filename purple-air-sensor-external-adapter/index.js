const { Requester, Validator } = require('@chainlink/external-adapter')

require('dotenv').config()

// Define custom error scenarios for the API.
// Return true for the adapter to retry.
const customError = (data) => {
  if (data.Response === 'Error') return true
  return false
}

// Define custom parameters to be used by the adapter.
// Extra parameters can be stated in the extra object,
// with a Boolean value indicating whether or not they
// should be required.
const customParams = {
  sensor_index: ['sensor_index', 'sensor_id', 'sensor'],
  endpoint: false,
}

const createRequest = (input, callback) => {
  // The Validator helps you validate the Chainlink request data
  const validator = new Validator(callback, input, customParams)
  const jobRunID = validator.validated.id
  const endpoint = validator.validated.data.endpoint || 'sensors'
  const sensor_index = validator.validated.data.sensor_index // sensor_index is a part of the URL
  const url = `https://api.purpleair.com/v1/${endpoint}/${sensor_index}`
  const apiReadKey = process.env.API_READ_KEY

  const params = {
    'api_key': apiReadKey
  }

  // This is where you would add method and headers
  // you can add method like GET or POST and add it to the config
  // The default is GET requests
  // method = 'get' 
  // headers = 'headers.....'
  const config = {
    url,
    params
  }

  // The Requester allows API calls be retry in case of timeout
  // or connection failure
  Requester.request(config, customError)
    .then(response => {
      // Confidence 100 means that the data from both counters inside the sensor 
      // is very close hence it is accurate. 
      // Lower confidence level indicate that the sensor needs maintenance. 
      response.data.air_quality_data_confidence = Requester.validateResultNumber(response.data, ["sensor", "confidence"])
     
      // TODO: The same call can get results for all the sensors that a particular host maintains. 
      // Hence the result should be the percentage of host's sensors that were not offline. 
      // i.e. apply the calculation below per sensor.
      time_stamp_seconds = Requester.validateResultNumber(response.data, ["data_time_stamp"])
      last_seen_seconds = Requester.validateResultNumber(response.data, ["sensor", "last_seen"])
      time_diff_seconds = time_stamp_seconds - last_seen_seconds
      time_diff_mins = Math.floor((time_diff_seconds)/60)
      response.data.sensor_offline_minutes = time_diff_mins
      
      // It's common practice to store the desired value at the top-level
      // result key. This allows different adapters to be compatible with
      // one another.
      
      //  If the sensor was offline for 10 minutes or more set the result to zero, i.e. no reward.
      response.data.result = time_diff_mins > 10 ? 0 : 100
     
      callback(response.status, Requester.success(jobRunID, response))
    })
    .catch(error => {
      callback(500, Requester.errored(jobRunID, error))
    })
}

// This is a wrapper to allow the function to work with
// GCP Functions
exports.gcpService = (req, res) => {
  requestInput = null
  switch (req.method) {
    case 'GET':
      // createRequest() expects input shape { id: 0, data: { sensor_index: '132143' } }
      requestInput = {
        id: req.query.id,
        data: { sensor_index: req.query.sensor_index },
      }
      break;
    case 'POST':
      // createRequest() expects input shape { id: 0, data: { sensor_index: '132143' } }
      requestInput = req.body
      break;
    case 'PUT':
      res.status(403).send('Forbidden!');
      break;
    default:
      res.status(405).send({error: 'Something blew up!'});
      break;
  }
  if (requestInput) {
    console.log('Input Data: ', requestInput)
    createRequest(requestInput, (statusCode, data) => {
      console.log('Result: ', data.result)
      res.status(statusCode).send(data)
    })
  } else {
    res.status(422).send({error: 'Something blew up!'});
  }
}

// This is a wrapper to allow the function to work with
// newer AWS Lambda implementations
exports.handlerV2 = (event, context, callback) => {
  createRequest(JSON.parse(event.body), (statusCode, data) => {
    callback(null, {
      statusCode: statusCode,
      body: JSON.stringify(data),
      isBase64Encoded: false
    })
  })
}

// This allows the function to be exported for testing
// or for running in express
module.exports.createRequest = createRequest
