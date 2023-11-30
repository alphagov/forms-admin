require "rails_helper"

class MarkdownModelWithHeadingsAllowed
  include ActiveModel::Model
  attr_accessor :markdown

  validates :markdown, markdown: { allow_headings: true }
end

class MarkdownModelWithHeadingsDisallowed
  include ActiveModel::Model
  attr_accessor :markdown

  validates :markdown, markdown: { allow_headings: false }
end

RSpec.describe MarkdownValidator do
  it_behaves_like "a markdown field with headings allowed" do
    let(:model) { MarkdownModelWithHeadingsAllowed.new }
    let(:attribute) { :markdown }
  end

  context "with headings disallowed" do
    it_behaves_like "a markdown field with headings disallowed" do
      let(:model) { MarkdownModelWithHeadingsDisallowed.new }
      let(:attribute) { :markdown }
    end
  end
end
