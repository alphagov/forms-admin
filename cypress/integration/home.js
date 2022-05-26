describe('Home screen', () => {
  beforeEach(() => {
    cy.visit('/')
  })

  it('allows the user to create a new form', () => {
    cy.contains('Create a form').click()
    cy.url().should('eq', `${Cypress.config().baseUrl}/forms/new`)
  })

  it('allows the user to edit an existing form', () => {
    cy.contains('Edit').click()
    cy.url().should('match', /\/forms\/\d+/)
  })
})
