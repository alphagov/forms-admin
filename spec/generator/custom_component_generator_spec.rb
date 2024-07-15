# frozen_string_literal: true

require "rails_helper"
require "generators/custom_component/custom_component_generator"

RSpec.describe "CustomComponentGenerator", type: :generator do
  tests CustomComponentGenerator
  destination Rails.root.join("tmp/generators")
  arguments %w[my]

  before do
    run_generator
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  context "when no arguments are supplied" do
    it "creates the component files" do
      expect(File.read(File.join(destination_root, "app/components/my_component/view.rb"))).to include("module MyComponent")
      expect(File.read(File.join(destination_root, "app/components/my_component/view.html.erb"))).to include("<%# Add HTML here %>")
    end

    it "creates the spec files" do
      expect(File.read(File.join(destination_root, "spec/components/my_component/my_component_preview.rb"))).to include("class MyComponent::MyComponentPreview < ViewComponent::Preview")
      expect(File.read(File.join(destination_root, "spec/components/my_component/view_spec.rb"))).to include("RSpec.describe MyComponent::View, type: :component do")
    end
  end
end
