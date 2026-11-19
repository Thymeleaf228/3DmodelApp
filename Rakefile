# frozen_string_literal: true

require 'rake'
require_relative 'signup'
require 'ffaker'

namespace :seeds do
  desc 'Create user'
  task :create_user do
    users = load_users
    register_user(users, 'Aura', FFaker::InternetSE.login_user_name, '45')
  end
end
