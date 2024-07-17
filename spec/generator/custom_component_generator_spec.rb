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

  it "creates the component files" do
    expect(File.read(File.join(destination_root, "app/components/my_component/view.rb"))).to include("module MyComponent")
    expect(File.read(File.join(destination_root, "app/components/my_component/view.html.erb"))).to include("<%# Add HTML here %>")
  end

  it "creates the spec files" do
    expect(File.read(File.join(destination_root, "spec/components/my_component/my_component_preview.rb"))).to include("class MyComponent::MyComponentPreview < ViewComponent::Preview")
    expect(File.read(File.join(destination_root, "spec/components/my_component/view_spec.rb"))).to include("RSpec.describe MyComponent::View, type: :component do")
  end

  context "when the css argument is supplied" do
    arguments ["my", "--css"]

    it "creates the sass partial" do
      expect(File.read(File.join(destination_root, "app/components/my_component/_index.scss"))).to include("// Add styles here")
    end
  end

  context "when the javascript argument is supplied" do
    arguments ["my", "--javascript"]

    it "creates the js file and test" do
      expect(File.read(File.join(destination_root, "app/components/my_component/index.js"))).to include("// Add JS here")
      expect(File.read(File.join(destination_root, "app/components/my_component/index.test.js"))).to include("// Add JS tests here")
    end
  end
end
