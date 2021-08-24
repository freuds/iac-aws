const AWSXRay = require('aws-xray-sdk-core')
const AWS = AWSXRay.captureAWS(require('aws-sdk'))

// Create client outside of handler to reuse
const lambda = new AWS.Lambda()

// Handler
exports.handler = async function(event, context) {
  event.Records.forEach(record => {
    console.log(record.body)
  })
  console.log('## ENVIRONMENT VARIABLES: ' + serialize(process.env))
  console.log('## CONTEXT: ' + serialize(context))
  console.log('## EVENT: ' + serialize(event))

  return getAccountSettings()
}

// Use SDK client
var getAccountSettings = function(){
  return lambda.getAccountSettings().promise()
}

var serialize = function(object) {
  return JSON.stringify(object, null, 2)
}

// hello-world
// Lambda function code
// module.exports.handler = async (event) => {
//   console.log('Event: ', event);
//   let responseMessage = 'Hello, World!';

//   if (event.queryStringParameters && event.queryStringParameters['Name']) {
//     responseMessage = 'Hello, ' + event.queryStringParameters['Name'] + '!';
//   }
//   return {
//     statusCode: 200,
//     headers: {
//       'Content-Type': 'application/json',
//     },
//     body: JSON.stringify({
//       message: responseMessage,
//     }),
//   }
// }