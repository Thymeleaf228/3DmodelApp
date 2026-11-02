require_relative 'signup'
require_relative 'login'
require_relative 'store'

def print_main_menu
  puts "Вітаємо у магазині PrintForge!\n\n" +
  "Різноманітні 3D-моделі та матеріали на ваш смак\n" +
  "Звертайтесь до PrintForge!\n" +
  "Оберіть дію:\n" +
  "  1 - log in\n" +
  "  2 - sign up\n" +
  "  3 - exit"  
end

def run
  print_main_menu
  puts "\n"
  user_action = gets.chomp
  case user_action
  when "1"
    system('clear') || system('cls')  
    logged_user = log_in_user
    if logged_user
      system('clear') || system('cls')
      run_store_menu(logged_user['name'])
    else
      puts "\n"
      puts "--------------------------------------------"
      puts "  Такого юзера не знайдено або пароль невірний"
      puts "--------------------------------------------"
      puts "\n\n"
    end
  when "2"
    sign_up_user
  when "3"
    system('clear') || system('cls')
    puts "Дякуємо, звертайтеся до нас ще!\n\n\n"
    exit
  end
  run
end

run