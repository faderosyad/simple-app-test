import 'dotenv/config';
import { getRPSChoices,  } from './game.js';
import { getENVChoices,  } from './envi.js';
import { capitalize, InstallGlobalCommands } from './utils.js';

function createCommandENVChoices() {
  const choices = getENVChoices();
  const commandChoices = [];

  for (let choice of choices) {
    commandChoices.push({
      name: capitalize(choice),
      value: choice.toLowerCase(),
    });
  }

  return commandChoices;
}

// Simple test command
const TEST_COMMAND = {
  name: 'test',
  description: 'Basic command',
  type: 1,
};

const INFRASWITCH_COMMAND = {
  name: 'infraswitch',
  description: 'Infraswitch command',
  options: [
    {
      type: 3,
      name: 'object',
      description: 'Select Environment',
      required: true,
      choices: createCommandENVChoices(),
    },
  ],
  type: 1,
};

const ALL_COMMANDS = [TEST_COMMAND, INFRASWITCH_COMMAND];

InstallGlobalCommands(process.env.APP_ID, ALL_COMMANDS);