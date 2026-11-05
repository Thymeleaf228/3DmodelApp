require 'bcrypt'
require 'yaml'

USERS_DB_FILE = 'db/users.yml'


def sign_up_user
  name = ask_username
  phone = ask_phone
  password = ask_password
  system('clear') || system('cls')
  users = load_users
  if users.any? { |user| user['phone'] == phone }
    puts "Помилка: Користувач із телефоном #{phone} вже зареєстрований!"
  else
    puts "--- Реєструємо... ---"
    register_user(users, name, phone, password)
  end
end


def register_user(users, name, phone, password)
  next_id = users.empty? ? 1 : users.map { |user| user['id'] }.max + 1
  hashed_password = BCrypt::Password.create(password)

  new_user = {
    'id' => next_id,
    'name' => name,
    'phone' => phone,
    'password_digest' => hashed_password.to_s,
    'role' => "user"
  }

  users << new_user

  File.write(USERS_DB_FILE, users.to_yaml)

  puts "Користувач #{name} успішно зареєстрований!\n\n"
end






def load_users
  if File.exist?(USERS_DB_FILE)
    YAML.load_file(USERS_DB_FILE) || []
  else
    []
  end
end

def ask_username
  puts "Введіть ваш юзенейм:"
  gets.chomp
end

def ask_password
  puts "Придумайте пароль:"
  gets.chomp
end

def ask_phone
  puts "Введіть ваш номер телефону:"
  gets.chomp
end