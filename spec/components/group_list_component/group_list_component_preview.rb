class GroupListComponent::GroupListComponentPreview < ViewComponent::Preview
  include FactoryBot::Syntax::Methods

  def default
    render(GroupListComponent::View.new(groups: [], title: "Your Groups", empty_message: "There are no groups to display"))
  end

  def with_groups
    render(GroupListComponent::View.new(groups: [build(:group), build(:group)], title: "Your active groups", empty_message: "There are no active groups to display"))
  end
end
