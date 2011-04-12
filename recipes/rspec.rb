# Application template recipe for the rails3_devise_wizard. Check for a newer version here:
# https://github.com/fortuity/rails3_devise_wizard/blob/master/recipes/rspec.rb

gem 'rspec-rails', '>= 2.5.0', :group => [:development, :test]
if recipes.include? 'mongoid'
  # use the database_cleaner gem to reset the test database
  gem 'database_cleaner', '>= 0.6.6', :group => :test
  # include RSpec matchers from the mongoid-rspec gem
  gem 'mongoid-rspec', ">= 1.4.1", :group => :test
end
if config['factory_girl']
  # use the factory_girl gem for test fixtures
  gem 'factory_girl_rails', ">= 1.1.beta1", :group => :test
end

# note: there is no need to specify the RSpec generator in the config/application.rb file

after_bundler do
  generate 'rspec:install'

  # remove ActiveRecord artifacts
  gsub_file 'spec/spec_helper.rb', /config.fixture_path/, '# config.fixture_path'
  gsub_file 'spec/spec_helper.rb', /config.use_transactional_fixtures/, '# config.use_transactional_fixtures'

  if recipes.include? 'mongoid'
    # reset your application database to a pristine state during testing
    inject_into_file 'spec/spec_helper.rb', :before => "\nend" do
    <<-RUBY
  \n
  # Clean up the database
  require 'database_cleaner'
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.orm = "mongoid"
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end
RUBY
    end
  end
  
  # remove either possible occurrence of "require rails/test_unit/railtie"
  gsub_file 'config/application.rb', /require 'rails\/test_unit\/railtie'/, "# require 'rails/test_unit/railtie'"
  gsub_file 'config/application.rb', /require "rails\/test_unit\/railtie"/, "# require 'rails/test_unit/railtie'"

  say_wizard "Removing test folder (not needed for RSpec)"
  run 'rm -rf test/'

  if recipes.include? 'mongoid'
    # configure RSpec to use matchers from the mongoid-rspec gem
    create_file 'spec/support/mongoid.rb' do 
    <<-RUBY
RSpec.configure do |config|
  config.include Mongoid::Matchers
end
RUBY
    end
  end

  if recipes.include? 'A0_devise'
    # add Devise test helpers
    create_file 'spec/support/devise.rb' do 
    <<-RUBY
RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
end
RUBY
    end
  end

end

__END__

name: RSpec
description: "Use RSpec for unit testing for this Rails app."
author: fortuity

run_after: [haml]
exclusive: unit_testing
category: testing

args: ["-T"]

config:
  - factory_girl:
      type: boolean
      prompt: Install the factory_girl gem for test fixtures?
