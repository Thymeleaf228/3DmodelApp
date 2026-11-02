require_relative 'signup'
require_relative 'login'

require_relative 'admin-panel'
 
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
    user = log_in_user
    if user == nil       
      return "user_not_found"       
    end
    case user['role']
    when "user"  
       # показувати меню звичайного користувача
      puts "User panel..."
      return    
    when "admin"
      # викликаємо інтерфейс адміна
      admin_panel(user)
      run_admin_panel(user)
      return
    else
      puts "\nНевідома роль користувача\n\n"
      exit
    end
    return
  when "2"
    system('clear') || system('cls')
    sign_up_user
  when "3"
    system('clear') || system('cls')
    puts "Дякуємо, звертайтеся до нас ще!\n\n\n"
    exit
  end
end

def print_user_not_found
  puts "\n"
  puts "--------------------------------------------"
  puts "  Такого юзера не знайдено. Зареєструйтеся"
  puts "--------------------------------------------"
  puts "\n"      
end

def run_admin_panel(user)
  print_admin_menu(user)
  puts "\n"
  admin_action = gets.chomp
  case admin_action
  when "1"
    #переглянути усі замовлення
    system('clear') || system('cls')
    orders_list
  when "2"
    #зміна статусів замовлення
  when "3"
    #повернутись у main menu
    run
  end
end

loop do
  result = run 
  
  if result == "user_not_found"
    print_user_not_found
  end
end
