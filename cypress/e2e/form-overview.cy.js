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

  it('contains an add question button', function () {
    cy.contains('Add a question').click()
    cy.url().should(
      'eq',
      `${Cypress.config().baseUrl}/forms/${this.formId}/pages/new`
    )
  })

  it('contains a list of questions', function () {
    cy.findByRole('heading', {
      name: 'Your questions'
    }).should('be.visible')

    cy.findAllByText('What is your work address?')
      .first()
      .should('be.visible')

    cy.findByRole('link', {
      name: 'Edit What is your work address?'
    }).click()
    cy.url().should(
      'eq',
      `${Cypress.config().baseUrl}/forms/${this.formId}/pages/${
        this.pageId
      }/edit`
    )
  })
})
