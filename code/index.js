const middy = require("middy");
const { jsonBodyParser, httpErrorHandler } = require("middy/middlewares");
const db = require("./db");

const DB_TABLE_NAME = process.env.DB_TABLE_NAME;

const successResponse = data => ({
  statusCode: 200,
  body: JSON.stringify(data)
});

const getStatus = async event => {
  console.log(event);
  const { id } = event.pathParameters;

  const query = {
    TableName: DB_TABLE_NAME,
    KeyConditionExpression: "id = :id",
    ExpressionAttributeValues: {
      ":id": id
    },
    ScanIndexForward: false
  };

  const { Items } = await db.query(query).promise();

  if (Items && Items.length > 0) {
    return successResponse({
      status: Items[0].status,
      events: Items
    });
  } else {
    return successResponse({
      status: 0,
      events: []
    });
  }
};

const updateStatus = async event => {
  console.log(event);
  const { id } = event.pathParameters;
  const { body } = event;

  // TODO Validate body

  const updatedStatus = {
    id: id,
    status: body.status,
    timestamp: Date.now()
  };

  await db
    .put({
      TableName: DB_TABLE_NAME,
      Item: updatedStatus
    })
    .promise();

  return successResponse(updatedStatus);
};

module.exports.getStatus = getStatus;
module.exports.updateStatus = updateStatus;
module.exports.getStatusHandler = middy(getStatus)
  .use(jsonBodyParser())
  .use(httpErrorHandler());
module.exports.updateStatusHandler = middy(updateStatus)
  .use(jsonBodyParser())
  .use(httpErrorHandler());
