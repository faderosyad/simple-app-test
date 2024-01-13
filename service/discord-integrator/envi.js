// Infraswitch Choices
const ENVChoices = {
    develop: {
      description: 'Company development environment'
    },
    staging: {
      description: 'Company staging environment'
    },
    production: {
      description: 'Company production environment'
    },
}

export function getENVChoices() {
    return Object.keys(ENVChoices);
}