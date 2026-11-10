# frozen_string_literal: true

require 'i18n'
require 'colorize'

I18n.load_path += Dir["#{File.expand_path('config/locales')}/*.yml"]
I18n.default_locale = :en # (note that `en` is already the default!)

require_relative 'app/signup'
require_relative 'app/login'
require_relative 'app/store'
require_relative 'app/admin-panel'

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

def run
  print_main_menu
  puts "\n"
  user_action = gets.chomp
  case user_action
  when '1'
    system('clear') || system('cls')
    user = log_in
    return 'user_not_found' if user.nil?

    case user['role']
    when 'user'
      if user
        system('clear') || system('cls')
        run_store_menu(user['phone'])
      end
    when 'admin'
      # викликаємо інтерфейс адміна
      admin_panel(user)
      loop do
        result_for_admin_panel = run_admin_panel(user)
        break if result_for_admin_panel == :back
      end
    else
      puts "\nНевідома роль користувача\n\n"
      exit
    end
    nil
  when '2'
    system('clear') || system('cls')
    sign_up
  when '3'
    I18n.locale = 'ua'
  when '4'
    system('clear') || system('cls')
    puts "Дякуємо, звертайтеся до нас ще!\n\n\n"
    exit
  end
end

def print_user_not_found
  puts "\n"
  puts '--------------------------------------------'
  puts '  Такого юзера не знайдено. Зареєструйтеся'
  puts '--------------------------------------------'
  puts "\n"
end

loop do
  result = run

  print_user_not_found if result == 'user_not_found'
end
