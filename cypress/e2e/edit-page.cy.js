describe('Edit a form page', function () {
  beforeEach(function () {
    cy.visit(`/forms/${this.formId}/pages/${this.pageId}/edit`)
  })

  it('contains a populated form field for the form title', function () {
    cy.get('form')
      .findByLabelText('Question text')
      .should('exist')
      .should('have.value', 'What is your work address?')
  })

  it('allows the user to navigate back to the form overview page', function () {
    cy.contains('go to form overview').click()
    cy.url().should('eq', `${Cypress.config().baseUrl}/forms/${this.formId}`)
  })
})
