describe('Home screen', function () {
  beforeEach(function () {
    cy.visit('/')
  })

  it('allows the user to create a new form', function () {
    cy.contains('Create a form').click()
    cy.url().should('eq', `${Cypress.config().baseUrl}/forms/new`)
  })

  it('allows the user to edit an existing form', function () {
    cy.contains('Edit').click()
    cy.url().should('match', /\/forms\/\d+/)
  })
})
