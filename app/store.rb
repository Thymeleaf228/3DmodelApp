# frozen_string_literal: true

require 'yaml'

require_relative 'console_helper.rb'

def save_order_to_file(order_items, user_id)
  orders = load_orders
  orders = [] unless orders.is_a?(Array)

  next_id = orders.empty? ? 1 : (orders.map { |o| o['id'] || 0 }.max + 1)

  order_items.each do |item|
    order_record = {
      'id' => next_id,
      'user_id' => user_id,
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

  write_orders(orders)
end

def run_store_menu(username, cart = [])
  clear_console
  puts I18n.t('user.store_menu.greeting', username: username)
  puts I18n.t('user.store_menu.body', count: cart.size)
  print I18n.t('user.store_menu.prompt')
  choice = gets.chomp
  get_store_action(choice, username, cart)
end

def get_store_action(action, username, cart)
  case action
  when '1'
    show_models_catalog
    run_store_menu(username, cart)
  when '2'
    show_materials_catalog
    run_store_menu(username, cart)
  when '3'
    updated_cart = add_to_cart(cart)
    run_store_menu(username, updated_cart)
  when '4'
    updated_cart = manage_cart(cart, username)
    run_store_menu(username, updated_cart)
  when '5'
    clear_console
  else
    puts I18n.t('user.store_menu.invalid_action')
    sleep(1.5)
    run_store_menu(username, cart)
  end
end

def show_models_catalog
  clear_console
  data = load_data('models.yml')
  models = data['models'] || []

  puts I18n.t('user.catalog.models_header')
  models.each do |m|
    puts I18n.t('user.catalog.model_item', id: m['id'], title: m['title'], price: m['base_price'])
  end
  puts I18n.t('user.catalog.press_enter')
  gets
end

def show_materials_catalog
  clear_console
  data = load_data('materials.yml')
  materials = data['materials'] || []

  puts I18n.t('user.catalog.materials_header')
  materials.each do |mat|
    puts I18n.t('user.catalog.material_item', id: mat['id'], name: mat['name'], price: mat['extra_price'])
  end
  puts I18n.t('user.catalog.press_enter')
  gets
end

def add_to_cart(cart)
  clear_console
  models_data = load_data('models.yml')['models'] || []
  materials_data = load_data('materials.yml')['materials'] || []

  puts I18n.t('user.add_to_cart.header')

  print I18n.t('user.add_to_cart.prompt_model')
  model_input = gets.chomp
  return cart if model_input.downcase == 'back'

  selected_model = models_data.find { |m| m['id'].to_s == model_input }
  unless selected_model
    puts I18n.t('user.add_to_cart.model_not_found')
    sleep(1.5)
    return cart
  end

  print I18n.t('user.add_to_cart.prompt_material')
  material_input = gets.chomp
  selected_material = materials_data.find { |mat| mat['id'].to_s == material_input }

  unless selected_material
    puts I18n.t('user.add_to_cart.material_not_found')
    sleep(1.5)
    return cart
  end

  print I18n.t('user.add_to_cart.prompt_color')
  color_input = gets.chomp

  print I18n.t('user.add_to_cart.prompt_size')
  size_input = gets.chomp.downcase
  incof_size = case size_input
               when 's' then 1
               when 'm' then 1.5
               when 'l' then 2
               else 1
               end

  clear_console
  puts I18n.t(
    'user.add_to_cart.summary',
    model_title: selected_model['title'],
    model_price: selected_model['base_price'],
    material_name: selected_material['name'],
    material_price: selected_material['extra_price'],
    color: color_input,
    size: size_input
  )

  print I18n.t('user.add_to_cart.prompt_quantity')
  quantity_input = gets.chomp.to_i
  if quantity_input <= 0
    puts I18n.t('user.add_to_cart.invalid_quantity')
    sleep(1.5)
    return cart
  end

  item_total = (selected_model['base_price'] * incof_size + selected_material['extra_price']) * quantity_input

  cart_item = {
    'model_id' => selected_model['id'],
    'model' => selected_model['title'],
    'material_id' => selected_material['id'],
    'material' => selected_material['name'],
    'color' => color_input,
    'size' => size_input,
    'quantity' => quantity_input,
    'total' => item_total
  }

  cart << cart_item
  puts I18n.t('user.add_to_cart.success')
  sleep(1.5)
  cart
end

def manage_cart(cart, username)
  clear_console
  if cart.empty?
    puts I18n.t('user.cart.empty')
    puts I18n.t('user.catalog.press_enter')
    gets
    return cart
  end

  puts I18n.t('user.cart.header')
  total_sum = 0
  cart.each_with_index do |item, index|
    subtotal = item['total']
    total_sum += subtotal
    puts I18n.t(
      'user.cart.item_details',
      index: index + 1,
      model: item['model'],
      material: item['material'],
      color: item['color'],
      size: item['size'],
      quantity: item['quantity'],
      subtotal: subtotal
    )
  end
  puts I18n.t('user.cart.total_sum', total: total_sum)
  puts I18n.t('user.cart.actions')

  print I18n.t('user.cart.prompt_action')
  action = gets.chomp

  case action
  when '1'
    save_order_to_file(cart, username)
    puts I18n.t('user.cart.order_success')
    sleep(2)
    []
  when '2'
    print I18n.t('user.cart.prompt_delete_index')
    idx = gets.chomp.to_i - 1
    if idx >= 0 && idx < cart.size
      removed = cart.delete_at(idx)
      puts I18n.t('user.cart.item_deleted', model: removed['model'])
    else
      puts I18n.t('user.cart.invalid_index')
    end
    sleep(1.5)
    manage_cart(cart, username)
  when '3'
    cart
  else
    puts I18n.t('user.cart.invalid_action')
    sleep(1)
    manage_cart(cart, username)
  end
end
