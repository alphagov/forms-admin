require "rails_helper"

RSpec.describe GroupFormsController, type: :routing do
  describe "routing" do
    it "routes to #new" do
      expect(get: "/groups/1/forms/new").to route_to("group_forms#new", group_id: "1")
    end

    it "routes to #create" do
      expect(post: "/groups/1/forms").to route_to("group_forms#create", group_id: "1")
    end
  end

  describe "path helpers" do
    it "uses the group external ID" do
      group = create :group
      expect(get: new_group_form_path(group)).to route_to("group_forms#new", group_id: group.external_id)
    end
  end
end
