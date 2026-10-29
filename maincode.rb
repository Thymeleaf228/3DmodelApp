require_relative 'signup'
require_relative 'login'
 
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
    unless log_in_user
      puts "\n"
      puts "--------------------------------------------"
      puts "  Такого юзера не знайдено. Зареєструйтеся"
      puts "--------------------------------------------"
      puts "\n\n"
    end
    
    # показувати меню користувача
  when "2"
    sign_up_user
    # system('clear') || system('cls')

  when "3"
    system('clear') || system('cls')
    puts "Дякуємо, звертайтеся до нас ще!\n\n\n"
    exit
  end
  run
end

run