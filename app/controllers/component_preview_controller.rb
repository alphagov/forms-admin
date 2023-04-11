class ComponentPreviewController < ApplicationController
  include ViewComponent::PreviewActions
  include Pundit::Authorization

  layout "application"
end
