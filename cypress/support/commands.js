// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add('login', (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add('drag', { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add('dismiss', { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This will overwrite an existing command --
// Cypress.Commands.overwrite('visit', (originalFn, url, options) => { ... })
import '@testing-library/cypress/add-commands'

Cypress.Commands.add('createForm', formData => {
  return cy
    .request({
      method: 'POST',
      url: 'http://localhost:9292/api/v1/forms',
      headers: {
        'Content-Type': 'application/json; charset=utf-8'
      },
      body: formData
    })
    .then(() => {
      return cy
        .request(
          'http://localhost:9292/api/v1/forms?org=government-digital-service'
        )
        .then(response => {
          return response.body.reverse()[0]
        })
    })
})

Cypress.Commands.add('createPage', (formId, pageData) => {
  return cy
    .request({
      method: 'POST',
      url: `http://localhost:9292/api/v1/forms/${formId}/pages`,
      headers: {
        'Content-Type': 'application/json; charset=utf-8'
      },
      body: pageData
    })
    .then(() => {
      return cy
        .request(`http://localhost:9292/api/v1/forms/${formId}/pages`)
        .then(response => {
          return response.body.reverse()[0]
        })
    })
})

Cypress.Commands.add('deleteForm', formId => {
  cy.request('DELETE', `http://localhost:9292/api/v1/forms/${formId}`)
})

Cypress.Commands.add('deletePage', (formId, pageId) => {
  cy.request(
    'DELETE',
    `http://localhost:9292/api/v1/forms/${formId}/pages/${pageId}`
  )
})
