# frozen_string_literal: true

require 'bcrypt'
require 'yaml'

require_relative 'database.rb'

def log_in
  phone = ask_phone
  password = ask_password

  users = load_data(USERS_DB_FILE)
  user = users.find { |user| user['phone'] == phone }
  return nil if user.nil?

  return user if password_correct?(user, password)

  nil
end

def password_correct?(user, password)
  hash_from_db = user.nil? ? nil : user['password_digest']
  return false if hash_from_db.nil?

  bcrypt_object = BCrypt::Password.new(hash_from_db)
  bcrypt_object == password
end

def ask_password
  puts 'Введіть пароль:'
  gets.chomp
end
