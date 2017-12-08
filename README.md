# Rails JSON API Example

[Using Rails for API-only Applications](http://edgeguides.rubyonrails.org/api_app.html)

## Create app

Generate app:

```bash
$ rails new todo --api --database=postgresql -T
$ cd todo
```

Flag `-T` is used to [skip test-unit tests](https://stackoverflow.com/questions/6728618/how-can-i-tell-rails-to-use-rspec-instead-of-test-unit-when-creating-a-new-rails)

## Add gems for tests

Add into Gemfile `:development, :test` group:

```ruby
gem 'rspec-rails'
gem 'factory_bot_rails'
```

Add into Gemfile `:test` group (create this group if it is not present):

```ruby
group :test do
  gem 'database_cleaner'
  gem 'shoulda-matchers', '~> 2.8'
end
```

Run

```bash
$ bundle
$ rails g rspec:install
```

## Configure database_cleaner

Add this into `spec/rails_helper.rb` configure section:

```ruby
RSpec.configure do |config|

  # ...

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
```

## Configure factory_bot

Add this into `spec/rails_helper.rb` configure section:

```ruby
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  # ...
end
```

And remove this lines:

```ruby
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
```

## Generate Task

```bash
$ rails g scaffold Task name:string:index slug:string:index state:string:index
```

Update migration to disallow NULL values, provide default values, and add unique index:

```ruby
class CreateTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :tasks do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :state, default: 'new', null: false

      t.timestamps
    end

    add_index :tasks, :name
    add_index :tasks, :slug, unique: true
    add_index :tasks, :state
  end
end
```

Indexes on name and state will be used for sorting and searching.

Attrribute `slug` will be used as ID in taks URL.

Create and migrate database:

```bash
$ RAILS_ENV=test rake db:create
$ RAILS_ENV=test rake db:migrate
```

## Model Tests

Update factory `spec/factories/tasks.rb`:

```ruby
FactoryBot.define do
  factory :task do
    name "Wash сlothes"
    slug "laundry"
    state "in progress"
  end
end
```

Create model validations tests in `spec/models/tasks_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe Task, type: :model do
  context 'validations' do
    subject { build(:task) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:slug) }
    it { should validate_uniqueness_of(:slug) }
  end
end
```

Add model validations in `app/models/task.rb`:

```ruby
class Task < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :slug
  validates_uniqueness_of :slug
end
```

## Use Task slug as ID in routes

Set ID param name to :slug in `config/routes.rb`
This will add `params[:slug]` instead of `params[:id]`

```ruby
Rails.application.routes.draw do
  resources :tasks, param: :slug
end
```

Add Task instance method `to_param` that returns slug in `app/models/task.rb`:
(Normally `to_param` returns id)

```ruby
class Task < ApplicationRecord
  def to_param
    slug
  end
end
```

BTW you can add model test for `to_param` method.

Change method `set_task` in `app/controllers/tasks_controller.rb`:

```ruby
def set_task
  @task = Task.find_by!(slug: params[:slug])
end
```

Update routing tests in `spec/routing/tasks_routing_spec.rb`:

```ruby
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
```

Update controller tests in `spec/controllers/tasks_controller_spec.rb`:

```ruby
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
```

## Request tests

Request tests cover controllers, models and routing. They can be considered as integration tests for the API.

Add gem `rspec-json_expectations` into Gemfile `:test` group:

```ruby
group :test do
  gem 'database_cleaner'
  gem 'shoulda-matchers', '~> 2.8'
  gem 'rspec-json_expectations'
end
```

Run

```bash
$ bundle install
```

Now add some tests into `spec/requests/tasks_spec.rb`:

```ruby
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
```

`include_json` matcher comes from gem `rspec-json_expectations`.
