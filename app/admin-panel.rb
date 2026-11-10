# frozen_string_literal: true

require 'yaml'
require 'terminal-table'

ORDERS_FILE = 'db/orders.yml'

def run_admin_panel(user)
  print_admin_menu(user)
  puts "\n"
  admin_action = gets.chomp
  case admin_action
  when '1'
    # переглянути усі замовлення
    system('clear') || system('cls')
    orders_list
  when '2'
    # зміна статусів замовлення
    system('clear') || system('cls')
    loop do
      result_for_status = run_status_overall_work
      break if result_for_status == :back
    end
  when '3'
    # повернутись у main menu
    system('clear') || system('cls')
    puts "Leaving the admin mode...\n\n\n"
    :back
  end
end

def run_status_overall_work
  print_status_overall_menu
  puts "\n"
  admin_action = gets.chomp
  case admin_action
  when '1'
    # переглянути усі статуси замовлення
    system('clear') || system('cls')
    status_show
  when '2'
    # зміна статусів замовлення
    run_change_status_work
  when '3'
    # повернутись у admin-panel
    system('clear') || system('cls')
    puts "Returning to the admin-panel...\n\n\n"
    :back
  end
end

def status_show
  orders = load_orders
  if orders&.any?
    table = Terminal::Table.new do |t|
      t.title = 'Зручний та короткий список статусів замовлень'
      t.headings = ['ID замовлення', 'Вартість', 'Статус']

      orders.each do |order|
        t << [order['id'], order['final_price'], order['status']]
      end
    end

    puts table
  else
    puts 'Нажаль, замовлень від користувачів ще немає.'
  end
end

def status_change(id)
  orders = load_data(ORDERS_DB_FILE)
  order = orders.find { |order| order['id'].to_s == id.to_s }
  return puts 'Помилка: замовлення не знайдено!' if order.nil?

  puts "\nПоточний статус замовлення: #{order['status']}"

  case order['status']
  when 'new'
    puts "\nПеревести замовлення у статус printing?\n\n(yes/no)"
    action = gets.chomp.downcase

    if action == 'yes'
      order['status'] = 'printing'
      write_data(ORDERS_DB_FILE, orders)
      puts "Статус успішно змінено на 'printing'!"
    else
      puts 'Зміну статусу скасовано.'
    end

  when 'printing'
    puts "\nПеревести замовлення у статус ready?\n\n(yes/no)"
    action = gets.chomp.downcase

    if action == 'yes'
      order['status'] = 'ready'
      write_data(ORDERS_DB_FILE, orders)
      puts "Статус успішно змінено на 'ready'!"
    else
      puts 'Зміну статусу скасовано.'
    end

  else
    puts "Для статусу '#{order['status']}' немає доступних дій."
  end
end

#------------------------------------------------------

def run_change_status_work
  puts "\n\n\nОберіть замовлення по його id:"
  id = gets.chomp
  orders = load_data(ORDERS_DB_FILE)

  if orders&.any?
    if orders.any? { |order| id.to_s == order['id'].to_s }
      system('clear') || system('cls')
      puts "\n\nДобре, замовлення з ID #{id} знайдено."
      status_change(id)
    else
      puts 'Замовлення з таким ID не знайдено.'
    end
  else
    puts 'Нажаль, замовлень від користувачів ще немає.'
  end
end

def orders_list
  orders = load_data(ORDERS_DB_FILE)
  if orders&.any?
    table = Terminal::Table.new do |t|
      t.title = 'Повний список замовлень'
      t.headings = ['ID замовлення', 'ID юзера', 'Колір', 'Розмір', 'Кількість', 'Фінальна ціна', 'Статус']
      orders.each do |order|
        t << [order['id'], order['user_id'], order['color'], order['size'], order['quantity'], order['final_price'],
              order['status']]
      end
    end

    puts table
  else
    puts 'Нажаль, замовлень від користувачів ще немає.'
  end
end

def admin_panel(user)
  system('clear') || system('cls')
  puts 'Entering the admin mode...'
  puts "Logged in as 'admin' successfully."
  puts "#{user['name']} now can manage the program"
end

def print_admin_menu(user)
  puts "\n\nВітаємо, #{user['name']}!\n" \
       "Оберіть дію:\n" \
       "  1 - переглянути усі замовлення\n" \
       "  2 - зміна статусів замовлення\n" \
       '  3 - повернутись у main menu'
end

def print_status_overall_menu
  puts "\n\n\nМеню зміни orders status.\n" \
       "Оберіть дію:\n" \
       "  1 - статуси замовлень\n" \
       "  2 - зміна статусів\n" \
       "  3 - повернення до admin-panel\n"
end
