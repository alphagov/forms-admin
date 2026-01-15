RSpec.shared_examples "validates markdown" do |validation_context|
  it "is invalid if markdown contains unsupported tags" do
    model.send("#{attribute}=", "# Heading level 1")
    expect(model).to be_invalid(validation_context)
    expect(model.errors.map(&:type)).to include :unsupported_markdown_syntax
  end

  it "is invalid if markdown is over 5000 characters" do
    model.send("#{attribute}=", "A" * 5001)
    expect(model).to be_invalid(validation_context)
    expect(model.errors.map(&:type)).to include :too_long
  end
end

RSpec.shared_examples "a markdown field with headings allowed" do |validation_context|
  it_behaves_like "validates markdown", validation_context

  it "is valid if markdown contains supported headings" do
    model.send("#{attribute}=", "## Heading level 2")
    expect(model).to be_valid(validation_context)
  end
end

RSpec.shared_examples "a markdown field with headings disallowed" do |validation_context|
  it_behaves_like "validates markdown", validation_context

  it "is invalid if markdown contains level 2 headings" do
    model.send("#{attribute}=", "## Heading level 2")
    expect(model).to be_invalid(validation_context)
    expect(model.errors.map(&:type)).to include :unsupported_markdown_syntax
  end

  it "is invalid if markdown contains level 3 headings" do
    model.send("#{attribute}=", "### Heading level 3")
    expect(model).to be_invalid(validation_context)
    expect(model.errors.map(&:type)).to include :unsupported_markdown_syntax
  end
end
