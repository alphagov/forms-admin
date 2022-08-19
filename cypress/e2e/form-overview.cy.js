describe('Form overview page', function () {
  beforeEach(function () {
    cy.visit(`/forms/${this.formId}`)
  })

  it('allows the user to edit the form', function () {
    cy.contains('Edit').click()
    cy.url().should(
      'eq',
      `${Cypress.config().baseUrl}/forms/${this.formId}/change-name`
    )
  })

  it('allows the user to navigate back to the home page', function () {
    cy.contains('Back').click()
    cy.url().should('eq', `${Cypress.config().baseUrl}/`)
  })

  it('contains a question section', function () {
    cy.findByRole('heading', {
      name: 'Your questions'
    }).should('be.visible')
  })

  it('contains a link to add/edit the forms questions', function () {
    cy.contains('Add and edit your questions').click()
    cy.url().should(
      'eq',
      `${Cypress.config().baseUrl}/forms/${this.formId}/pages`
    )
  })
})
