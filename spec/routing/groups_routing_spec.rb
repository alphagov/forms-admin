require "rails_helper"

RSpec.describe GroupsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/groups").to route_to("groups#index")
    end

    it "routes to #new" do
      expect(get: "/groups/new").to route_to("groups#new")
    end

    it "routes to #show" do
      expect(get: "/groups/1").to route_to("groups#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/groups/1/edit").to route_to("groups#edit", id: "1")
    end

    it "routes to #move" do
      expect(get: "/groups/1/move").to route_to("groups#move", id: "1")
    end

    it "routes to #create" do
      expect(post: "/groups").to route_to("groups#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/groups/1").to route_to("groups#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/groups/1").to route_to("groups#update", id: "1")
    end

    it "routes to #delete" do
      expect(get: "/groups/1/delete").to route_to("groups#delete", id: "1")
    end

    it "routes to #destroy via DELETE" do
      expect(delete: "/groups/1").to route_to("groups#destroy", id: "1")
    end
  end

  describe "path helpers" do
    it "uses the external ID" do
      group = create :group
      expect(get: group_path(group)).to route_to("groups#show", id: group.external_id)
    end
  end
end
