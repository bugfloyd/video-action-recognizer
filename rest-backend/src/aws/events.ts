import { EventBridgeClient, PutEventsCommand } from '@aws-sdk/client-eventbridge';
import { awsRegion, eventBusName } from '../variables';

// Create an EventBridge client
const client = new EventBridgeClient({ region: awsRegion });

export const putEvent = async (eventType: string, payload: object) => {
  const params = {
    Entries: [
      {
        Source: 'var.backend',
        DetailType: eventType,
        Detail: JSON.stringify(payload),
        EventBusName: eventBusName,
      },
    ],
  };

  const command = new PutEventsCommand(params);
  return client.send(command);
};