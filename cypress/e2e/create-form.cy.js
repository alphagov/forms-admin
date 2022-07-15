describe('Create a form page', function () {
  beforeEach(function () {
    cy.visit('/forms/new')
  })

  it('contains an empty form field for the form title', function () {
    cy.get('form')
      .findByLabelText('What is the name of your form?')
      .should('exist')
      .should('have.value', '')
  })

  it('allows the user to navigate back to the home page', function () {
    cy.contains('Back').click()
    cy.url().should('eq', `${Cypress.config().baseUrl}/`)
  })
})
