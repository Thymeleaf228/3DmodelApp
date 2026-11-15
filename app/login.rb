# frozen_string_literal: true
require 'yaml'

require_relative 'console_helper.rb'
require_relative 'entities/user.rb'

def log_in
  phone = ask_promt('Введіть номер телефону:')
  password = ask_promt('Введіть пароль:')

  user = authenticate_user(phone, password)

  return nil if user.nil?

  return user if password_correct?(user, password)

  nil
end

def password_correct?(user, password)
  hash_from_db = user.nil? ? nil : user['password_digest']
  return false if hash_from_db.nil?

  verify_password(hash_from_db, password)
end

def authenticate_user(phone, password)
  load_users.find { |user| user['phone'] == phone }
end
