// describe('Form overview page', function () {
//   beforeEach(function () {
//     cy.visit(`/forms/${this.formId}`)
//   })
//
//   it('allows the user to navigate back to the home page', function () {
//     cy.contains('Back').click()
//     cy.url().should('eq', `${Cypress.config().baseUrl}/`)
//   })
//
//   it('allows the user to edit the form name', function () {
//     cy.contains('Edit the name of your form').click()
//     cy.url().should(
//       'eq',
//       `${Cypress.config().baseUrl}/forms/${this.formId}/change-name`
//     )
//   })
//
//   it('contains a link to add/edit the forms questions', function () {
//     cy.contains('Add and edit your questions').click()
//     cy.url().should(
//       'eq',
//       `${Cypress.config().baseUrl}/forms/${this.formId}/pages`
//     )
//   })
//
//   describe('Task list for new forms without pages', function () {
//     beforeEach(function () {
//       // Create test form in database
//       cy.fixture('seed-data').then(function (seedDataJSON) {
//         const { form } = seedDataJSON
//
//         cy.createForm(form)
//           .its('id')
//           .as('formId')
//           .then(function () {
//             cy.visit(`/forms/${this.formId}`)
//           })
//       })
//     })
//     after(function () {
//       cy.deleteForm(this.formId)
//     })
//
//     it('add/edit the forms questions directs user to create new question page', function () {
//       cy.contains('Add and edit your questions').click()
//       cy.url().should(
//         'eq',
//         `${Cypress.config().baseUrl}/forms/${this.formId}/pages/new`
//       )
//     })
//   })
// })
