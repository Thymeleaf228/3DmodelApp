require 'yaml'
require 'terminal-table'

ORDERS_DB_FILE = 'orders.yml'

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
    system('clear') || system('cls')
    loop do
      result_for_status = run_status_overall_work
      break if result_for_status == :back
    end
  when "3"
    #повернутись у main menu
    system("clear") || system("cls")
    puts "Leaving the admin mode...\n\n\n"
    return :back
  end
end









def run_status_overall_work
  print_status_overall_menu
  puts "\n"
  admin_action = gets.chomp
  case admin_action
  when "1"
    #переглянути усі статуси замовлення
    system('clear') || system('cls')
    status_show
  when "2"
    #зміна статусів замовлення
    run_change_status_work
  when "3"
    #повернутись у admin-panel
    system("clear") || system("cls")
    puts "Returning to the admin-panel...\n\n\n"
    return :back
  end
end










def status_show
  orders = load_orders
  if orders && orders.any?
    table = Terminal::Table.new do |t|
      t.title = "Зручний на короткий список статусів замовлень"
      t.headings = 'User-ID', 'Вартість', 'Статус'

      orders.each do |order|
        t << [order['user_id'], order['final_price'], order['status']]
      end
    end

    puts table
  else
    puts "Нажаль, замовлень від користувачів ще немає."
  end
end








def status_change(user_id)
  orders = load_orders
  order = orders.find { |order| order['user_id'] == user_id }
  return puts "Помилка: замовлення не знайдено!" if order.nil?

  puts "\nСтатус замовлення юзера: #{order['status']}"

  case order['status']
  when 'new'
    puts "\nПеревести замовлення у статус printing?\n\n(yes/no)"
    action = gets.chomp.downcase
    
    if action == 'yes'
      order['status'] = 'printing'
      save_orders(orders)
      puts "Статус успішно змінено на 'printing'!"
    end

  when 'printing'
    puts "\nПеревести замовлення у статус ready?\n\n(yes/no)"
    action = gets.chomp.downcase
    
    if action == 'yes'
      order['status'] = 'ready'
      save_orders(orders)
      puts "Статус успішно змінено на 'ready'!"
    end

  else
    puts "Для статусу '#{order['status']}' немає доступних дій."
  end
end
#------------------------------------------------------
def next_status_for(current_status, action)
  return current_status unless action == 'так'

  case current_status
  when 'new'      then 'printing'
  when 'printing' then 'ready' # припустимо, наступний крок такий
  else current_status
  end
end
#------------------------------------------------------
def save_orders(orders)
  File.open(ORDERS_DB_FILE, 'w') do |file|
    file.write(orders.to_yaml)
  end
end
#------------------------------------------------------
def run_change_status_work
  puts "\n\n\nОберіть юзера по його user-id:\n\n"
  user_id = gets.chomp
  orders = load_orders
  if orders && orders.any?
    if orders.any? { |order| user_id == order['user_id'] }
      system('clear') || system('cls')
      puts "\n\nДобре, такий юзер знайдений"
      status_change(user_id)
    else 
      puts "Такого юзера не знайдено"
    end
  else 
    puts "Нажаль, замовлень від користувачів ще немає."
  end
end











def orders_list
  orders = load_orders
  if orders && orders.any?
    table = Terminal::Table.new do |t|
      t.title = "Повний список замовлень"
      t.headings = ['ID замовлення', 'ID юзера', 'Колір', 'Розмір', 'Кількість', 'Фінальна ціна', 'Статус']
      orders.each do |order|
        t << [order['id'], order['user_id'], order['color'], order['size'], order['quantity'], order['final_price'], order['status']]
      end
    end
  
    puts table
  else
    puts "Нажаль, замовлень від користувачів ще немає."
  end
end







def admin_panel(user)
  system('clear') || system('cls')
  puts "Entering the admin mode..."
  puts "Logged in as 'admin' successfully."
  puts "#{user['name']} now can manage the program"
end







def print_admin_menu(user)
  puts "\n\nВітаємо, #{user['name']}!\n" +
  "Оберіть дію:\n" +
  "  1 - переглянути усі замовлення\n" +
  "  2 - зміна статусів замовлення\n" +
  "  3 - повернутись у main menu"
end








def print_status_overall_menu
  puts "\n\n\nМеню зміни orders status.\n" + 
  "Оберіть дію:\n" +
  "  1 - статуси замовлень\n" +
  "  2 - зміна статусів\n" +
  "  3 - повернення до admin-panel\n"
end





def load_orders
  if File.exist?(ORDERS_DB_FILE)
    YAML.load_file(ORDERS_DB_FILE) || []
  else
    []
  end
end
