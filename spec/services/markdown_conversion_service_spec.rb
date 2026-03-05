require "rails_helper"

RSpec.describe MarkdownConversionService do
  describe "#initialize" do
    it "accpets text" do
      service = described_class.new("Some text")
      expect(service.text).to eq("Some text")
    end
  end

  describe "#to_markdown" do
    context "with simple text and newlines" do
      it "converts double newlines to paragraphs" do
        text = "First paragraph.\n\nSecond paragraph."
        service = described_class.new(text)
        expect(service.to_markdown).to eq("First paragraph.\n\nSecond paragraph.\n\n")
      end

      it "converts single newlines to line breaks" do
        text = "First line.\nSecond line."
        service = described_class.new(text)
        expect(service.to_markdown).to eq("First line.  \nSecond line.\n\n")
      end

      it "handles multiple paragraphs and line breaks" do
        text = "Line 1\nLine 2\n\nLine 3"
        service = described_class.new(text)
        expect(service.to_markdown).to eq("Line 1  \nLine 2\n\nLine 3\n\n")
      end
    end

    context "with allowed HTML tags" do
      it "keeps paragraphs" do
        text = "<p>Hello</p><p>World</p>"
        service = described_class.new(text)
        expect(service.to_markdown.strip).to eq("Hello\n\nWorld")
      end

      it "keeps links" do
        text = 'Check out this <a href="https://example.com" title="Example">link</a>.'
        service = described_class.new(text)
        expect(service.to_markdown).to eq("Check out this [link](https://example.com \"Example\").\n\n")
      end

      it "keeps unordered lists" do
        text = "<ul><li>Item 1</li><li>Item 2</li></ul>"
        service = described_class.new(text)
        expect(service.to_markdown).to eq("* Item 1\n* Item 2\n\n")
      end

      it "keeps ordered lists" do
        text = "<ol><li>First</li><li>Second</li></ol>"
        service = described_class.new(text)
        expect(service.to_markdown).to eq("1. First\n2. Second\n\n")
      end
    end

    context "with disallowed HTML tags" do
      it "strips script tags" do
        text = "Hello <script>alert('world')</script>"
        service = described_class.new(text)
        expect(service.to_markdown).to eq("Hello alert('world')\n\n")
      end

      it "strips div tags" do
        text = "<div>Some content</div>"
        service = described_class.new(text)
        expect(service.to_markdown).to eq("Some content\n\n")
      end

      it "strips inline styles" do
        text = '<p style="color: red;">Red text</p>'
        service = described_class.new(text)
        expect(service.to_markdown).to eq("Red text\n\n")
      end
    end

    context "with headings" do
      it "strips h2 and h3 tags" do
        text = "<h2>A main title</h2>\n\nSome text.\n\n<h3>A subtitle</h3>"
        service = described_class.new(text)
        # h2 and h3 are stripped, but their content remains.
        # simple_format wraps them in <p> tags.
        expect(service.to_markdown).to eq("A main title\n\nSome text.\n\nA subtitle\n\n")
      end
    end
  end
end
