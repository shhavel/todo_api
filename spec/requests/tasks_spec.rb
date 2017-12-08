require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  let!(:task) { create(:task) }

  describe "GET /tasks" do
    it "returns list of tasks" do
      get tasks_path
      expect(response).to have_http_status(200)
      expect(response.body).to include_json([{
        id: task.id,
        name: task.name,
        slug: task.slug
      }])
    end
  end

  describe "GET /tasks/:slug" do
    it "returns list of tasks" do
      get task_path(task)
      expect(response).to have_http_status(200)
      expect(response.body).to include_json({
        id: task.id,
        name: task.name,
        slug: task.slug
      })
    end
  end
end
