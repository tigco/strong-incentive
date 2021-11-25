# Purple Air API

http://api.purpleair.com

Get Sensor Data from PurpleAir
https://api.purpleair.com/v1/sensors/:sensor_index?api_key=your-api-key

API READ key can be in URL, Header, or in the body of a post request
{
    "api_key": "your-api-key"
}

# Frankyants NodeJS External Adapter for PurpleAir

This adapter is based on a template for external adapters in NodeJS provided by Chainlink. This is still work in progress.
FYI there is no need to use any additional frameworks or to run a Chainlink node in order to test the adapter.

## Purple Air API key

This adapter requires a read API key from PurpleAir. It is configured to read the key from the environment variable API_READ_KEY.
You can read more about node.js and API key management here https://dev.to/jabermudez11/hide-your-api-key-in-nodejs-16b5

## Input Params

- `sensor_index`, `sensor_id`, or `sensor`: The index of the sensor to query

## Output

```json
{
 "jobRunID": "278c97ffadb54a5bbb93cfec5f7b5503",
 "data": {
  "pm2.5":5.8,
  .....
  "air_quality_data_confidence": 100,
  "sensor_offline_minutes": 0,
  "result": 100
 },
 "result": 100, // Percentage of sensors online
 "statusCode": 200
}
```

## Install Locally

Install dependencies:

```bash
yarn
```

### Test

Run the local tests:

```bash
yarn test
```

Natively run the application (defaults to port 8080):

### Run

```bash
yarn start
```

## Call the external adapter/API server
"132143" is the sensor_index of my PurpleAir sensor that is usually online.

```bash
curl -X GET -H "content-type:application/json" "http://localhost:8080?id=0&sensor_index=132143"
```

```bash
curl -X POST -H "content-type:application/json" "http://localhost:8080/" --data '{ "id": 0, "data": {"sensor_index": "132143"} }'
```

## Docker

If you wish to use Docker to run the adapter, you can build the image by running the following command:

```bash
docker build . -t external-adapter
```

Then run it with:

```bash
docker run -p 8080:8080 -it external-adapter:latest
```

## Serverless hosts

After [installing locally](#install-locally):

### Create the zip

```bash
zip -r external-adapter.zip .
```

### Install to AWS Lambda

- In Lambda Functions, create function
- On the Create function page:
  - Give the function a name
  - Use Node.js 12.x for the runtime
  - Choose an existing role or create a new one
  - Click Create Function
- Under Function code, select "Upload a .zip file" from the Code entry type drop-down
- Click Upload and select the `external-adapter.zip` file
- Handler:
    - index.handler for REST API Gateways
    - index.handlerv2 for HTTP API Gateways
- Add the environment variable (repeat for all environment variables):
  - Key: API_KEY
  - Value: Your_API_key
- Save

#### To Set Up an API Gateway (HTTP API)

If using a HTTP API Gateway, Lambda's built-in Test will fail, but you will be able to externally call the function successfully.

- Click Add Trigger
- Select API Gateway in Trigger configuration
- Under API, click Create an API
- Choose HTTP API
- Select the security for the API
- Click Add

#### To Set Up an API Gateway (REST API)

If using a REST API Gateway, you will need to disable the Lambda proxy integration for Lambda-based adapter to function.

- Click Add Trigger
- Select API Gateway in Trigger configuration
- Under API, click Create an API
- Choose REST API
- Select the security for the API
- Click Add
- Click the API Gateway trigger
- Click the name of the trigger (this is a link, a new window opens)
- Click Integration Request
- Uncheck Use Lamba Proxy integration
- Click OK on the two dialogs
- Return to your function
- Remove the API Gateway and Save
- Click Add Trigger and use the same API Gateway
- Select the deployment stage and security
- Click Add

### Install to GCP

- In Functions, create a new function, choose to ZIP upload
- Click Browse and select the `external-adapter.zip` file
- Select a Storage Bucket to keep the zip in
- Function to execute: gcpservice
- Click More, Add variable (repeat for all environment variables)
  - NAME: API_KEY
  - VALUE: Your_API_key
