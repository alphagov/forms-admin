describe('Create a form page', () => {
  beforeEach(() => {
    cy.visit('/forms/new')
  })

  it('contains an empty form field for the form title', () => {
    cy.get('form')
      .findByLabelText('What is the name of your form?')
      .should('exist')
      .should('have.value', '')
  })

  it('allows the user to navigate back to the home page', () => {
    cy.contains('Back').click()
    cy.url().should('eq', `${Cypress.config().baseUrl}/`)
  })
})
