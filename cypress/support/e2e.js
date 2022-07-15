// ***********************************************************
// This example support/index.js is processed and
// loaded automatically before your test files.
//
// This is a great place to put global configuration and
// behavior that modifies Cypress.
//
// You can change the location of this file or turn off
// automatically serving support files with the
// 'supportFile' configuration option.
//
// You can read more here:
// https://on.cypress.io/configuration
// ***********************************************************

// Import commands.js using ES2015 syntax:
import './commands'

// Alternatively you can use CommonJS syntax:
// require('./commands')

before(function () {
  // Create test form and page in database
  cy.fixture('seed-data').then(function (seedDataJSON) {
    const { form, page } = seedDataJSON

    cy.createForm(form)
      .its('id')
      .as('formId')
      .then(function () {
        cy.createPage(this.formId, page)
          .its('id')
          .as('pageId')
      })
  })
})

after(function () {
  // Delete test form and page
  cy.deletePage(this.formId, this.pageId)
  cy.deleteForm(this.formId)
})
