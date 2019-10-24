const AWS = require("aws-sdk");

module.exports = new AWS.DynamoDB.DocumentClient({
  region: "localhost",
  endpoint: "http://localhost:8000",
  accessKeyId: "MOCK_ACCESS_KEY_ID",
  secretAccessKey: "MOCK_SECRET_ACCESS_KEY"
});
