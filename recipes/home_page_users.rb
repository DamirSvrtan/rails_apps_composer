# Application template recipe for the rails3_devise_wizard. Check for a newer version here:
# https://github.com/fortuity/rails3_devise_wizard/blob/master/recipes/home_page_users.rb

after_bundler do

  if recipes.include? 'devise'

    # Modify the home controller
    gsub_file 'app/controllers/home_controller.rb', /def index/ do
    <<-RUBY
def index
  @users = User.all
RUBY
    end

    # Replace the home page
    if recipes.include? 'haml'
      remove_file 'app/views/home/index.html.haml'
      # There is Haml code in this script. Changing the indentation is perilous between HAMLs.
      # We have to use single-quote-style-heredoc to avoid interpolation.
      create_file 'app/views/home/index.html.haml' do 
      <<-'HAML'
%h3 Home
- @users.each do |user|
  %p User: #{user.name}
HAML
      end
    else
      append_file 'app/views/home/index.html.erb' do <<-ERB
<h3>Home</h3>
<% @users.each do |user| %>
  <p>User: <%= user.name %></p>
<% end %>
ERB
      end
    end

  end

end

__END__

name: HomePageUsers
description: "Display a list of users on the home page."
author: fortuity

requires: [devise]
run_after: [home_page]
category: other
tags: [utilities, configuration]
