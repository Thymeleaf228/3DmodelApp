# frozen_string_literal: true

require 'yaml'
require 'terminal-table'

require_relative 'entities/order.rb'
require_relative 'console_helper.rb'

MOVE_TO_PREV_PANEL = :back

def run_admin_panel(user)
  print_admin_menu(user)
  admin_action = gets.chomp
  case admin_action
  when '1'
    clear_console
    show_orders_list
  when '2'
    # меню зміна статусів замовлення
    clear_console
    loop do
      result_for_status = run_status_overall_work
      break if result_for_status == MOVE_TO_PREV_PANEL
    end
  when '3'
    # повернутись у main menu
    clear_console
    puts "Leaving the admin mode...\n\n\n"
    MOVE_TO_PREV_PANEL
  end
end

def run_status_overall_work
  print_status_overall_menu
  puts "\n"
  admin_action = gets.chomp
  case admin_action
  when '1'
    # переглянути усі статуси замовлення коротко
    clear_console
    status_show
  when '2'
    # зміна статусів замовлення
    run_change_status_work
  when '3'
    # повернутись у admin-panel
    clear_console
    puts "Returning to the admin-panel...\n\n\n"
    MOVE_TO_PREV_PANEL
  end
end

def status_show
  orders = load_data(ORDERS_DB_FILE)
  if orders.any?
    title = 'Зручний та короткий список статусів замовлень'
    headings = ['ID замовлення', 'Вартість', 'Статус']

    rows = orders.map do |order|
      [
        order['id'],
        order['final_price'],
        order['status']
      ]
    end

    puts render_table(title, headings, rows)
  else
    puts 'Нажаль, замовлень від користувачів ще немає.'
  end
end

def status_change(orders, order)
  puts "\nПоточний статус замовлення: #{order['status']}"

  case order['status']
  when 'new'
    update_order_status(orders, order, 'printing')

  when 'printing'
    update_order_status(orders, order, 'ready')

  else
    puts "Для статусу '#{order['status']}' немає доступних дій."
  end
end

#------------------------------------------------------

def run_change_status_work
  puts "\n\n\nОберіть замовлення по його id:"
  id = gets.chomp.strip
  orders = load_data(ORDERS_DB_FILE)

  if orders.any?
    order = find_order_by_id(orders, id)

    if order
      clear_console
      puts "\n\nЗамовлення з ID #{id} знайдено."
      status_change(orders, order)
    else
      puts 'Замовлення з таким ID не знайдено.'
    end
  else
    puts 'Нажаль, замовлень від користувачів ще немає.'
  end
end

def show_orders_list
  orders = load_data(ORDERS_DB_FILE)
  if orders.any?
    title = 'Повний список замовлень'
    headings = ['ID замовлення', 'ID юзера', 'Колір', 'Розмір', 'Кількість', 'Фінальна ціна', 'Статус']
    rows = orders.map do |order|
      [
        order['id'],
        order['user_id'],
        order['color'],
        order['size'],
        order['quantity'],
        order['final_price'],
        order['status']
      ]
    end

    puts render_table(title, headings, rows)
  else
    puts 'Нажаль, замовлень від користувачів ще немає.'
  end
end

def print_admin_menu(user)
  puts "\n\nВітаємо, #{user['name']}!\n" \
       "Оберіть дію:\n" \
       "  1 - переглянути усі замовлення\n" \
       "  2 - зміна статусів замовлення\n" \
       "  3 - повернутись у main menu\n"
end

def print_status_overall_menu
  puts "\n\n\nМеню зміни orders status.\n" \
       "Оберіть дію:\n" \
       "  1 - статуси замовлень\n" \
       "  2 - зміна статусів\n" \
       "  3 - повернення до admin-panel\n"
end
