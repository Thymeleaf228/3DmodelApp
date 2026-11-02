require 'yaml'

ORDERS_DB_FILE = 'orders.yml'

def orders_list
  orders = load_orders
  if orders && orders.any?
    orders.each do |order|
      puts "  ID замовлення: #{order['id']}"
      puts "  ID юзера: #{order['user_id']}"
      puts "  Колір: #{order['color']}"
      puts "  Розмір: #{order['size']}"
      puts "  Кількість: #{order['quantity']}"
      puts "  Фінальна ціна: #{order['final_price']}"
      puts "  Статус: #{order['status']}\n\n\n\n"
    end
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
  "  2 - зміна стутусів замовлення\n" +
  "  3 - повернутись у main menu"
end

def load_orders
  if File.exist?(ORDERS_DB_FILE)
    YAML.load_file(ORDERS_DB_FILE) || []
  else
    []
  end
end
