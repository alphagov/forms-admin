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

  it('contains the beta phase banner', function () {
    cy.findAllByText('Beta')
      .first()
      .should('be.visible')
    cy.findAllByText('feedback')
      .first()
      .should('be.visible')
      .should('have.attr', 'href')
      .and('equal', 'mailto:govuk-forms@digital.cabinet-office.gov.uk')
  })
})
