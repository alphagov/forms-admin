describe('Edit a form page', () => {
  beforeEach(() => {
    cy.visit('/forms/2/edit')
  })

  it('contains a populated form field for the form title', () => {
    cy.get('form')
      .findByLabelText('What is the name of your form?')
      .should('exist')
      .should('have.value', 'Apply for a forms licence')
  })

  it('allows the user to navigate back to the form overview page', () => {
    cy.contains('Back').click()
    cy.url().should('eq', `${Cypress.config().baseUrl}/forms/2`)
  })
})
