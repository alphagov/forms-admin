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
  cy.createForm()
    .its('id')
    .as('formId')
    .then(function () {
      cy.createPage(this.formId)
        .its('id')
        .as('pageId')
    })
})

after(function () {
  cy.request(
    'DELETE',
    `http://localhost:9292/api/v1/forms/${this.formId}/pages/${this.pageId}`
  )
  cy.request('DELETE', `http://localhost:9292/api/v1/forms/${this.formId}`)
})
