# frozen_string_literal: true

require 'bcrypt'
require 'yaml'

require_relative 'database.rb'

USERS_DB_FILE = 'users.yml'

def sign_up
  name = ask_username
  phone = ask_phone
  password = ask_password
  system('clear') || system('cls')

  puts "DEBUG 1: Текущая папка выполнения: #{Dir.pwd}"
  puts "DEBUG 2: Полный путь к базе: #{get_path(USERS_DB_FILE)}"
  users = load_data(USERS_DB_FILE)
  puts "DEBUG 3: Что считано из файла: #{users.inspect}"

  users = load_data(USERS_DB_FILE)
  if users.any? { |user| user['phone'] == phone }
    puts "Помилка: Користувач із телефоном #{phone} вже зареєстрований!"
  else
    puts '--- Реєструємо... ---'
    register_user(users, name, phone, password)
  end
end

def register_user(users, name, phone, password)
  next_id = users.empty? ? 1 : users.map { |user| user['id'] }.max + 1

  hashed_password = BCrypt::Password.create(password)

  new_user = {
    'id' => next_id,
    'name' => name,
    'phone' => phone.to_s,
    'password_digest' => hashed_password.to_s,
    'role' => 'user'
  }

  users << new_user

  write_data(USERS_DB_FILE, users)

  puts "Користувач #{name} успішно зареєстрований!\n\n"
end

def ask_username
  puts 'Введіть ваш юзенейм:'
  gets.chomp
end

def ask_password
  puts 'Придумайте пароль:'
  gets.chomp
end

def ask_phone
  puts 'Введіть ваш номер телефону:'
  gets.chomp
end
