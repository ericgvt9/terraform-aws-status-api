const AWS = require("aws-sdk");
const DynamoDbLocal = require("dynamodb-local");
const dynamoLocalPort = 8000;

const createTable = async () => {
  const db = new AWS.DynamoDB({
    region: "localhost",
    endpoint: "http://localhost:8000",
    accessKeyId: "MOCK_ACCESS_KEY_ID",
    secretAccessKey: "MOCK_SECRET_ACCESS_KEY"
  });
  const params = {
    TableName: process.env.DB_TABLE_NAME,
    KeySchema: [
      { AttributeName: "id", KeyType: "HASH" },
      { AttributeName: "timestamp", KeyType: "RANGE" }
    ],
    AttributeDefinitions: [
      { AttributeName: "id", AttributeType: "S" },
      { AttributeName: "timestamp", AttributeType: "N" }
    ],
    ProvisionedThroughput: {
      ReadCapacityUnits: 1,
      WriteCapacityUnits: 1
    }
  };
  await db.createTable(params).promise();
};

const startDb = async () => {
  console.log("Starting DynamoDB...");
  await DynamoDbLocal.launch(dynamoLocalPort, null, ["-sharedDb"]);
  try {
    await createTable();
  } catch (e) {}
};

const stopDb = async () => {
  console.log("Stopping DynamoDB...");
  await DynamoDbLocal.stop(dynamoLocalPort);
};

module.exports = { startDb, stopDb, createTable };
