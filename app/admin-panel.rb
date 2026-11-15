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
    clear_console
    loop do
      result_for_status = run_status_overall_work
      break if result_for_status == MOVE_TO_PREV_PANEL
    end
  when '3'
    clear_console
    puts I18n.t('admin.main_menu.leaving')
    MOVE_TO_PREV_PANEL
  end
end

def run_status_overall_work
  print_status_overall_menu
  puts "\n"
  admin_action = gets.chomp
  case admin_action
  when '1'
    clear_console
    status_show
  when '2'
    run_change_status_work
  when '3'
    clear_console
    puts I18n.t('admin.status_menu.returning')
    MOVE_TO_PREV_PANEL
  end
end

def status_show
  orders = load_data(ORDERS_DB_FILE)
  if orders.any?
    title = I18n.t('admin.orders.short_table.title')
    headings = I18n.t('admin.orders.short_table.headings')

    rows = orders.map do |order|
      [
        order['id'],
        order['final_price'],
        I18n.t("admin.statuses.#{order['status']}", default: order['status'])
      ]
    end

    puts render_table(title, headings, rows)
  else
    puts I18n.t('admin.orders.empty')
  end
end

def status_change(orders, order)
  translated_status = I18n.t("admin.statuses.#{order['status']}", default: order['status'])
  puts I18n.t('admin.change_status.current_status', status: translated_status)

  case order['status']
  when 'new'
    update_order_status(orders, order, 'printing')
  when 'printing'
    update_order_status(orders, order, 'ready')
  else
    puts I18n.t('admin.change_status.no_actions', status: translated_status)
  end
end

def run_change_status_work
  puts I18n.t('admin.change_status.prompt_id')
  id = gets.chomp.strip
  orders = load_data(ORDERS_DB_FILE)

  if orders.any?
    order = find_order_by_id(orders, id)

    if order
      clear_console
      puts I18n.t('admin.change_status.order_found', id: id)
      status_change(orders, order)
    else
      puts I18n.t('admin.change_status.order_not_found')
    end
  else
    puts I18n.t('admin.orders.empty')
  end
end

def show_orders_list
  orders = load_data(ORDERS_DB_FILE)
  if orders.any?
    title = I18n.t('admin.orders.full_table.title')
    headings = I18n.t('admin.orders.full_table.headings')
    rows = orders.map do |order|
      [
        order['id'],
        order['user_id'],
        order['color'],
        order['size'],
        order['quantity'],
        order['final_price'],
        I18n.t("admin.statuses.#{order['status']}", default: order['status'])
      ]
    end

    puts render_table(title, headings, rows)
  else
    puts I18n.t('admin.orders.empty')
  end
end

def print_admin_menu(user)
  puts I18n.t('admin.main_menu.greeting', name: user['name'])
  puts I18n.t('admin.main_menu.body')
end

def print_status_overall_menu
  puts I18n.t('admin.status_menu.body')
end
