const createRequest = require('./index').createRequest

const express = require('express')
const bodyParser = require('body-parser')
const app = express()
const port = process.env.EA_PORT || 8080

app.use(bodyParser.json())

app.post('/', (req, res) => {
  console.log('POST Data: ', req.body)
  createRequest(req.body, (status, result) => {
    console.log('Result: ', result)
    res.status(status).json(result)
  })
})

app.get('/', (req, res) => {
  console.log('Get Data: ', req.query)
  // createRequest() expects input shape { id: 0, data: { sensor_index: '132143' } }
  requestInput = {
    id: req.query.id,
    data: { sensor_index: req.query.sensor_index },
  }
  console.log('Input Data: ', requestInput)
  createRequest(requestInput, (status, result) => {
    console.log('Result: ', result)
    res.status(status).json(result)
  })
})

app.listen(port, () => console.log(`Listening on port ${port}!`))
