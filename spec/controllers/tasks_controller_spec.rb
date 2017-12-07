require 'rails_helper'

RSpec.describe TasksController, type: :controller do
  let(:valid_attributes) do
    { name: "Dismantle the trash in the apartment.", slug: "cleaning" }
  end

  let(:invalid_attributes) do
    { name: '' }
  end

  let!(:task) { create(:task) }

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: {}
      expect(response).to be_success
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { slug: task.to_param }
      expect(response).to be_success
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Task" do
        expect {
          post :create, params: { task: valid_attributes }
        }.to change(Task, :count).by(1)
      end

      it "renders a JSON response with the new task" do
        post :create, params: { task: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(response.location).to eq(task_url(Task.last))
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new task" do
        post :create, params: { task: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) do
        { name: "Wash сlothes and snickers" }
      end

      it "updates the requested task" do
        put :update, params: { slug: task.to_param, task: new_attributes }
        task.reload
        expect(task.name).to eq("Wash сlothes and snickers")
      end

      it "renders a JSON response with the task" do
        put :update, params: { slug: task.to_param, task: valid_attributes }
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the task" do
        put :update, params: { slug: task.to_param, task: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested task" do
      expect {
        delete :destroy, params: { slug: task.to_param }
      }.to change(Task, :count).by(-1)
    end
  end
end
