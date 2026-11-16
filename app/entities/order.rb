# frozen_string_literal: true

require 'yaml'

class OrderEntity
  ORDERS_DB_FILE = 'db/orders.yml'

  def self.load_orders
    if File.exist?(ORDERS_DB_FILE)
      YAML.load_file(ORDERS_DB_FILE) || []
    else
      []
    end
  end

  def self.save_orders(orders)
    File.open(ORDERS_DB_FILE, 'w') do |file|
      file.write(orders.to_yaml)
    end
  end

  def self.create_order(order_items, current_user)
    orders = load_orders
    orders = [] unless orders.is_a?(Array)

    next_id = orders.empty? ? 1 : (orders.map { |o| o['id'] || 0 }.max + 1)

    if current_user.is_a?(Hash)
      user_id = current_user['id'] || current_user[:id]
      username = current_user['name'] || current_user[:name] || current_user['username'] || current_user[:username] || 'Unknown'
      phone = current_user['phone'] || current_user[:phone] || 'N/A'
    else
      user_id = current_user
      username = 'User'
      phone = 'N/A'
    end

    order_items.each do |item|
      order_record = {
        'id' => next_id,
        'user_id' => user_id,
        'username' => username,
        'phone' => phone,
        'user_info' => "#{username}, #{phone}",
        'model_id' => item['model_id'],
        'material_id' => item['material_id'],
        'color' => item['color'],
        'size' => item['size'],
        'quantity' => item['quantity'],
        'final_price' => item['total'],
        'status' => 'new'
      }
      orders << order_record
      next_id += 1
    end

    save_orders(orders)
  end
end