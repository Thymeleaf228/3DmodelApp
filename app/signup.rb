# frozen_string_literal: true

require 'yaml'

require_relative 'console_helper.rb'
require_relative 'entities/user.rb'

def sign_up
  clear_console
  name = ask_promt('Введіть ваш юзенейм:')
  phone = ask_promt('Придумайте пароль:')
  password = ask_promt('Введіть ваш номер телефону:')
  clear_console

  users = load_users
  if users.any? { |user| user['phone'] == phone }
    puts "Помилка: Користувач із телефоном #{phone} вже зареєстрований!"
  else
    puts '--- Реєструємо... ---'
    create_user(users, name, phone, password)

    puts "Користувач #{name} успішно зареєстрований!\n\n"
  end
end
