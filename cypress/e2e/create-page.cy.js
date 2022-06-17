describe('Create a page page', () => {
  beforeEach(() => {
    cy.visit('/forms/19/pages/new')
  })

  it('contains an empty form field for the question text', () => {
    cy.get('form')
      .findByLabelText('Question text')
      .should('exist')
      .should('have.value', '')
  })

  it('allows the user to navigate back to the form overview page', () => {
    cy.contains('go to form overview').click()
    cy.url().should('eq', `${Cypress.config().baseUrl}/forms/19`)
  })
})
