# frozen_string_literal: true

require 'i18n'
require 'colorize'

I18n.load_path += Dir["#{File.expand_path('config/locales')}/*.yml"]
I18n.default_locale = :en # (note that `en` is already the default!)

require_relative 'app/signup.rb'
require_relative 'app/login.rb'
require_relative 'app/store.rb'
require_relative 'app/admin-panel.rb'
require_relative 'app/console_helper.rb'
require_relative 'app/database.rb'

def run
  print_main_menu
  puts "\n"
  user_action = gets.chomp
  case user_action
  when '1'
    login
  when '2'
    sign_up
  when '3'
    I18n.locale = 'ua'
  when '4'
    do_exit
  end
end

def login
  clear_console
  user = log_in
  return 'user_not_found' if user.nil?

  case user['role']
  when 'user'
    clear_console
    run_store_menu(user['phone'])
  when 'admin'
    admin_greeting(user)
    loop do
      admin_panel_result = run_admin_panel(user)
      break if admin_panel_result == MOVE_TO_PREV_PANEL
    end
  else
    puts "\nНевідома роль користувача\n\n"
    exit
  end
  nil
end

def do_exit
  clear_console
  puts "Дякуємо, звертайтеся до нас ще!\n\n\n"
  exit
end

def print_main_menu
  puts "Вітаємо у магазині PrintForge!\n\n" \
       "Різноманітні 3D-моделі та матеріали на ваш смак\n" \
       "Звертайтесь до PrintForge!\n\n" \
       "Оберіть дію:\n" \
       "  1 - log in\n" \
       "  2 - sign up\n" \
       "  3 - змінити мову на українську\n" \
       '  4 - exit'
end

def print_user_not_found
  puts "\n"
  puts '--------------------------------------------'
  puts '     Невірний номер телефону або пароль     '
  puts '--------------------------------------------'
  puts "\n"
end

def admin_greeting(user)
  clear_console
  puts 'Entering the admin mode...'
  puts "Logged in as 'admin' successfully."
  puts "#{user['name']} now can manage the program"
end

loop do
  result = run

  print_user_not_found if result == 'user_not_found'
end
