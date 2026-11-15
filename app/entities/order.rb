# frozen_string_literal: true

require_relative '../database.rb'
require_relative '../console_helper.rb'

ORDERS_DB_FILE = 'orders.yml'

def update_order_status(orders, order, new_status)
  translated_status = I18n.t("admin.statuses.#{new_status}", default: new_status)
  puts I18n.t('admin.change_status.confirm_prompt', new_status: translated_status)
  action = gets.chomp.downcase

  if action == YES_ANSWER
    order['status'] = new_status
    write_data(ORDERS_DB_FILE, orders)
    puts I18n.t('admin.change_status.success', new_status: translated_status)
  else
    puts I18n.t('admin.change_status.cancelled')
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
