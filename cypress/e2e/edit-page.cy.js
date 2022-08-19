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

  it('allows the user to navigate back to the form pages', function () {
    cy.contains('Go to your questions').click()
    cy.url().should('eq', `${Cypress.config().baseUrl}/forms/${this.formId}/pages`)
  })
})
