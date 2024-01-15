import 'dotenv/config';
import express from 'express';
import {
  InteractionType,
  InteractionResponseType,
  MessageComponentTypes,
  ButtonStyleTypes,
} from 'discord-interactions';
import { VerifyDiscordRequest, callForTurnOff, callForTurnOn } from './utils.js';

// Create an express app
const app = express();
// Get port, or default to 3000
const PORT = process.env.PORT || 3000;
// Parse request body and verifies incoming requests using discord-interactions package
app.use(express.json({ verify: VerifyDiscordRequest(process.env.PUBLIC_KEY) }));

const activeInput = {};

/**
 * Interactions endpoint URL where Discord will send HTTP requests
 */
app.post('/interactions', async function (req, res) {
  // Interaction type and data
  const { type, id, data } = req.body;

  /**
   * Handle verification requests
   */
  if (type === InteractionType.PING) {
    return res.send({ type: InteractionResponseType.PONG });
  }

  /**
   * Handle slash command requests
   * See https://discord.com/developers/docs/interactions/application-commands#slash-commands
   */
  if (type === InteractionType.APPLICATION_COMMAND) {
    const { name } = data;

    // "Infraswitch" command
    if (name === 'infraswitch' && id) {
      const userId = req.body.member.user.id;
      const objectName = req.body.data.options[0].value;

      activeInput[id] = {
        id: userId,
        objectName,
      };
      return res.send({
      type: InteractionResponseType.CHANNEL_MESSAGE_WITH_SOURCE,
      data: {
          content: `Infraswitch Command Trigger from <@${userId}>`,
          components: [
          {
              type: MessageComponentTypes.ACTION_ROW,
              components: [
              {
                type: MessageComponentTypes.BUTTON,
                // Append the game ID to use later on
                custom_id: `on_button_${req.body.id}`,
                label: 'Turn on CloudSQL',
                style: ButtonStyleTypes.SUCCESS,
              },
              {
                type: MessageComponentTypes.BUTTON,
                // Append the game ID to use later on
                custom_id: `off_button_${req.body.id}`,
                label: 'Turn off CloudSQL',
                style: ButtonStyleTypes.DANGER,
              },
              ],
          },
          ],
      },
      });
    }
  }

    /**
   * Handle requests from interactive components
   * See https://discord.com/developers/docs/interactions/message-components#responding-to-a-component-interaction
   */
    if (type === InteractionType.MESSAGE_COMPONENT) {
      // custom_id set in payload when sending message component
      const componentId = data.custom_id;

      if (componentId.startsWith('on_button_')) {
        const commandId = componentId.replace('on_button_', '');
        try {
          callForTurnOn()
          await res.send({
            type: InteractionResponseType.CHANNEL_MESSAGE_WITH_SOURCE,
            data: {
              // Fetches a random emoji to send from a helper function
              content: `Turning on CloudSQL for <@${activeInput[commandId].id}>` + ' on ' + activeInput[commandId].objectName + ' environment',
            },
          });
        } catch (err) {
          console.error('Error sending message:', err);
        }
        delete activeInput[commandId];
      } else if (componentId.startsWith('off_button_')) {
        const commandId = componentId.replace('off_button_', '');
        try {
          callForTurnOff()
          await res.send({
            type: InteractionResponseType.CHANNEL_MESSAGE_WITH_SOURCE,
            data: {
              // Fetches a random emoji to send from a helper function
              content: `Turning off CloudSQL for <@${activeInput[commandId].id}>` + ' on ' + activeInput[commandId].objectName + ' environment',
            },
  
          });
        } catch (err) {
          console.error('Error sending message:', err);
        }
        delete activeInput[commandId];
      }
  }
});

app.listen(PORT, () => {
  console.log('Listening on port', PORT);
});
