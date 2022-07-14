describe('Create a page page', function () {
  beforeEach(function () {
    cy.visit(`/forms/${this.formId}/pages/new`)
  })

  it('contains an empty form field for the question text', function () {
    cy.get('form')
      .findByLabelText('Question text')
      .should('exist')
      .should('have.value', '')
  })

  it('allows the user to navigate back to the form overview page', function () {
    cy.contains('go to form overview').click()
    cy.url().should('eq', `${Cypress.config().baseUrl}/forms/${this.formId}`)
  })
})
