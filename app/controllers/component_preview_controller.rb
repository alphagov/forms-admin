class ComponentPreviewController < ApplicationController
  include ViewComponent::PreviewActions
  include Pundit::Authorization

  layout :component_layout

private

  def component_layout
    action_name == "index" ? "application" : "base"
  end
end
