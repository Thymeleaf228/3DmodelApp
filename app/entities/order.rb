require_relative '../database.rb'
require_relative '../console_helper.rb'

ORDERS_DB_FILE = 'orders.yml'

def update_order_status(orders, order, new_status)
  puts "\nПеревести замовлення у статус #{new_status}?\n\n(yes/no)"
    action = gets.chomp.downcase

    if action == YES_ANSWER
      order['status'] = new_status
      write_data(ORDERS_DB_FILE, orders)
      puts "Статус успішно змінено на #{new_status}!"
    else
      puts 'Зміну статусу скасовано.'
    end
end

def find_order_by_id(orders, id)
  orders.find { |order| order['id'].to_s == id.to_s }
end

def load_orders
  load_data(ORDERS_DB_FILE)
end

def write_orders(orders)
  write_data(ORDERS_DB_FILE, orders)
end
