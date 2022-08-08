describe('Edit form name page', function () {
  beforeEach(function () {
    cy.visit(`/forms/${this.formId}/change-name`)
  })

  it('contains a populated form field for the form title', function () {
    cy.get('form')
      .findByLabelText('What is the name of your form?')
      .should('exist')
      .should('have.value', 'Apply for a forms licence')
  })

  it('allows the user to navigate back to the form overview page', function () {
    cy.contains('Back').click()

    cy.url().should('eq', `${Cypress.config().baseUrl}/forms/${this.formId}`)
  })
})
