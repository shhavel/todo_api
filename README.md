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
