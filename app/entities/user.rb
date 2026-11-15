# frozen_string_literal: true

require_relative '../database.rb'

USERS_DB_FILE = 'users.yml'

USER_ROLES = {
  user: 'user',
  admin: 'admin'
}.freeze

def create_user(users, name, phone, password)
  next_id = create_next_id(users)

  hashed_password = hash_password(password)

  new_user = {
    'id' => next_id,
    'name' => name,
    'phone' => phone.to_s,
    'password_digest' => hashed_password.to_s,
    'role' => USER_ROLES[:user]
  }

  users << new_user

  write_users(users)
end

def load_users
  load_data(USERS_DB_FILE)
end

def write_users(users)
  write_data(USERS_DB_FILE, users)
end
