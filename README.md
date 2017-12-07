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
