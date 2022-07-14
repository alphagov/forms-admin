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

Cypress.Commands.add('createForm', () => {
  return cy
    .request({
      method: 'POST',
      url: 'http://localhost:9292/api/v1/forms',
      headers: {
        'Content-Type': 'application/json; charset=utf-8'
      },
      body: JSON.stringify({
        name: 'Apply for a forms licence',
        submission_email: 'submission@email.com',
        start_page: 1,
        org: 'government-digital-service'
      })
    })
    .then(() => {
      return cy.request('http://localhost:9292/api/v1/forms').then(response => {
        return response.body.reverse()[0]
      })
    })
})

Cypress.Commands.add('createPage', formId => {
  return cy
    .request({
      method: 'POST',
      url: `http://localhost:9292/api/v1/forms/${formId}/pages`,
      headers: {
        'Content-Type': 'application/json; charset=utf-8'
      },
      body: JSON.stringify({
        question_text: 'What is your work address?',
        question_short_name: 'Work address',
        hint_text: 'This should be the location stated in your contract.',
        answer_type: 'address'
      })
    })
    .then(() => {
      return cy
        .request(`http://localhost:9292/api/v1/forms/${formId}/pages`)
        .then(response => {
          return response.body.reverse()[0]
        })
    })
})
