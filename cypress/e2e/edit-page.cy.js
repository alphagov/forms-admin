describe('Edit a form page', () => {
  beforeEach(() => {
    cy.visit('/forms/19/pages/10/edit')
  })

  it('contains a populated form field for the form title', () => {
    cy.get('form')
      .findByLabelText('Question text')
      .should('exist')
      .should('have.value', 'What is your work address?')
  })

  it('allows the user to navigate back to the form overview page', () => {
    cy.contains('go to form overview').click()
    cy.url().should('eq', `${Cypress.config().baseUrl}/forms/19`)
  })
})
