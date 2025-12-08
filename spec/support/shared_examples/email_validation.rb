RSpec.shared_examples "a field that rejects invalid email addresses" do
  [
    "email@***************",
    "email@[***************]",
    "plainaddress",
    "@no-local-part.com",
    "Outlook Contact <outlook-contact@domain.com>",
    "no-at.domain.com",
    "no-tld@domain",
    ";beginning-semicolon@domain.co.uk",
    "middle-semicolon@domain.co;uk",
    "trailing-semicolon@domain.com;",
    '"email+leading-quotes@domain.com',
    'email+middle"-quotes@domain.com',
    '"quoted-local-part"@domain.com',
    '"quoted@domain.com"',
    "lots-of-dots@domain..gov..uk",
    "two-dots..in-local@domain.com",
    "dot-at-end@domain.com.",
    "multiple@domains@domain.com",
    "spaces in local@domain.com",
    "spaces-in-domain@dom ain.com",
    "underscores-in-domain@dom_ain.com",
    "pipe-in-domain@example.com|gov.uk",
    "comma,in-local@gov.uk",
    "comma-in-domain@domain,gov.uk",
    "pound-sign-in-local£@domain.com",
    "local-with-\u2018-apostrophe@domain.com",
    "local-with-\u201c-quotes@domain.com",
    "domain-starts-with-a-dot@.domain.com",
    "brackets(in)local@domain.com",
    "email-too-long-#{'a' * 320}@example.com",
    "incorrect-punycode@xn---something.com",
    " email@domain.com ",
    "\temail@domain.com",
    "\temail@domain.com\n",
    "\u200bemail@domain.com\u200b",
  ].each do |invalid_email_address|
    context "with #{invalid_email_address.dump}" do
      it "raises for invalid email address" do
        model.send("#{attribute}=", invalid_email_address)
        expect(model).to be_invalid
        expect(model.errors.map(&:type)).to include :invalid_email_address
      end
    end
  end
end
