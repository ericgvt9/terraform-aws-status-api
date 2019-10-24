const handler = require("..");

jest.mock("../db");

it("e2e works", async () => {
  const documentHash = "UNIQUE_DOCUMENT_HASH";
  let timestamp1;
  let timestamp2;

  // Status for unknown key should be 0 with no event logs
  const initialStatus = await handler.getStatus({
    pathParameters: { id: documentHash }
  });
  expect(JSON.parse(initialStatus.body)).toEqual({ status: 0, events: [] });

  // Updating the status of document should return the event log
  const event1 = await handler.updateStatus({
    body: { id: documentHash, status: 1 },
    pathParameters: { id: documentHash }
  });
  const event1Res = JSON.parse(event1.body);
  timestamp1 = event1Res.timestamp;
  expect(event1Res).toEqual({
    id: documentHash,
    status: 1,
    timestamp: timestamp1
  });

  // Getting the status of the document after one update should return the latest status and one event logs
  const intermediateStatus = await handler.getStatus({
    pathParameters: { id: documentHash }
  });
  expect(JSON.parse(intermediateStatus.body)).toEqual({
    status: 1,
    events: [{ id: documentHash, status: 1, timestamp: timestamp1 }]
  });

  // Updating the status of document should return the event log
  const event2 = await handler.updateStatus({
    body: { id: documentHash, status: 2 },
    pathParameters: { id: documentHash }
  });
  const event2Res = JSON.parse(event2.body);
  timestamp2 = event2Res.timestamp;
  expect(event2Res).toEqual({
    id: documentHash,
    status: 2,
    timestamp: timestamp2
  });

  // Getting the status of the document after two updates should return the latest status and two event logs
  const finalStatus = await handler.getStatus({
    pathParameters: { id: documentHash }
  });
  expect(JSON.parse(finalStatus.body)).toEqual({
    status: 2,
    events: [
      { id: documentHash, status: 2, timestamp: timestamp2 },
      { id: documentHash, status: 1, timestamp: timestamp1 }
    ]
  });
}, 5000);
