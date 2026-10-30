require 'bcrypt'
require 'yaml'

def log_in_user
  phone = ask_phone
  password = ask_password

  users = load_users
  user = users.find { |user| user['phone'] == phone }
  hash_from_db = user.nil? ? nil : user['password_digest']

  if is_password_correct(hash_from_db, password) 
    return user
  end
  nil
end

def is_password_correct (hash_from_db, password)
  if hash_from_db == nil
    return false
  end
  bcrypt_object = BCrypt::Password.new(hash_from_db)
  bcrypt_object == password
end


def ask_password
  puts "Введіть пароль:"
  gets.chomp
end