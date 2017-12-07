require "rails_helper"

RSpec.describe TasksController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/tasks").to route_to("tasks#index")
    end

    it "routes to #show" do
      expect(get: "/tasks/laundry").to route_to("tasks#show", slug: "laundry")
    end

    it "routes to #create" do
      expect(post: "/tasks").to route_to("tasks#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/tasks/laundry").to route_to("tasks#update", slug: "laundry")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/tasks/laundry").to route_to("tasks#update", slug: "laundry")
    end

    it "routes to #destroy" do
      expect(delete: "/tasks/laundry").to route_to("tasks#destroy", slug: "laundry")
    end
  end
end
