describe('Form overview page', () => {
  beforeEach(() => {
    cy.visit('/forms/2')
  })

  it('allows the user to edit the form', () => {
    cy.contains('Edit').click()
    cy.url().should('eq', `${Cypress.config().baseUrl}/forms/2/change-name`)
  })

  it('allows the user to navigate back to the home page', () => {
    cy.contains('Back').click()
    cy.url().should('eq', `${Cypress.config().baseUrl}/`)
  })

  it('contains an add question button', () => {
    cy.contains('Add a question').click()
    cy.url().should('eq', `${Cypress.config().baseUrl}/forms/2/pages/new`)
  })
})
