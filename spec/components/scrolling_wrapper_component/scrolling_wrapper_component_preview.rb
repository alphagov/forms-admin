class ScrollingWrapperComponent::ScrollingWrapperComponentPreview < ViewComponent::Preview
  def default
    render(ScrollingWrapperComponent::View.new(aria_label: "A scrolling wrapper with no content"))
  end

  def with_overflowing_content
    render(ScrollingWrapperComponent::View.new(aria_label: "A scrolling wrapper containing something wide")) do
      tag.a("http://localhost:3000/preview/a_long_url_that_is_far_far_too_long_to_the_extent_that_it_is_almost_certainly_going_to_overflow_the_wrapper_horizontally_which_is_useful_for_demonstrating_the_scrolling_wrapper_component")
    end
  end
end
