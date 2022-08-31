describe('Home screen', function () {
  beforeEach(function () {
    cy.visit('/')
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
