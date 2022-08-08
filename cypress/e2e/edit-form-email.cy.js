describe('Edit form email page', function () {
  beforeEach(function () {
    cy.visit(`/forms/${this.formId}/change-email`)
  })

  it('contains a populated form field for the form email', function () {
    cy.get('form')
      .findByLabelText('What email address should form responses be sent to?')
      .should('exist')
      .should('have.value', 'submission@email.com')
  })

  it('allows the user to navigate back to the form overview page', function () {
    cy.contains('Back').click()

    cy.url().should('eq', `${Cypress.config().baseUrl}/forms/${this.formId}`)
  })
})
