// Infraswitch Choices
const ENVChoices = {
    develop: {
      description: 'Company development environment'
    },
}

export function getENVChoices() {
    return Object.keys(ENVChoices);
}