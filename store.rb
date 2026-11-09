# frozen_string_literal: true

require 'yaml'

ORDERS_DB_FILE = 'db/orders.yml'

def load_data(filename)
  if File.exist?(filename)
    YAML.load_file(filename) || []
  else
    []
  end
end

def save_order_to_file(order_items, user_id)
  orders = load_data(ORDERS_DB_FILE)
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
      'status' => 'new' # Статус маленькими английскими буквами
    }
    orders << order_record
    next_id += 1
  end

  File.open(ORDERS_DB_FILE, 'w') do |file|
    file.write(orders.to_yaml)
  end
end

def run_store_menu(username, cart = [])
  system('clear') || system('cls')
  puts "Привіт, #{username}!"
  puts 'Вітаємо у магазині PrintForge!'
  puts "\nОберіть дію та введіть її номер:"
  puts '1. Переглянути каталог моделей'
  puts '2. Переглянути каталог матеріалів'
  puts '3. Зібрати товар і додати в кошик'
  puts "4. Переглянути кошик та оформити замовлення (#{cart.size} тов.)"
  puts "5. Вийти в головне меню (змінити акаунт)\n"

  print 'Ваш вибір: '
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
    system('clear') || system('cls')
  else
    puts "\n[!] Невідома дія, введіть число від 1 до 5."
    sleep(1.5)
    run_store_menu(username, cart)
  end
end

def show_models_catalog
  system('clear') || system('cls')
  data = load_data('db/models.yml')
  models = data['models'] || []

  puts "\n--- КАТАЛОГ МОДЕЛЕЙ ---"
  models.each do |m|
    puts "ID: #{m['id']} | Назва: #{m['title']} | Базова ціна: #{m['base_price']} грн"
  end
  puts "\nНатисніть Enter, щоб повернутися в меню..."
  gets
end

def show_materials_catalog
  system('clear') || system('cls')
  data = load_data('db/materials.yml')
  materials = data['materials'] || []

  puts "\n--- КАТАЛОГ МАТЕРІАЛІВ ---"
  materials.each do |mat|
    puts "ID: #{mat['id']} | Назва: #{mat['name']} | Доплата: #{mat['extra_price']} грн"
  end
  puts "\nНатисніть Enter, щоб повернутися в меню..."
  gets
end

def add_to_cart(cart)
  system('clear') || system('cls')
  models_data = load_data('db/models.yml')['models'] || []
  materials_data = load_data('db/materials.yml')['materials'] || []

  puts '--- ДОДАВАННЯ ДО КОШИКА ---'

  print "Введіть ID моделі (або 'back' для виходу): "
  model_input = gets.chomp
  return cart if model_input.downcase == 'back'

  selected_model = models_data.find { |m| m['id'].to_s == model_input }
  unless selected_model
    puts "\n[!] Помилка: Модель з таким ID не знайдена!"
    sleep(1.5)
    return cart
  end

  print 'Введіть ID матеріалу: '
  material_input = gets.chomp
  selected_material = materials_data.find { |mat| mat['id'].to_s == material_input }

  unless selected_material
    puts "\n[!] Помилка: Матеріал з таким ID не знайдено!"
    sleep(1.5)
    return cart
  end

  print 'Введіть колір товару: '
  color_input = gets.chomp

  print 'Введіть розмір (наприклад, S, M, L): '
  size_input = gets.chomp.downcase
  incof_size = 1 if size_input == 's'
  incof_size = 1.5 if size_input == 'm'
  incof_size = 2 if size_input == 'l'

  system('clear') || system('cls')
  puts '----------------------------------------'
  puts 'Ви обрали:'
  puts "Модель: #{selected_model['title']} (#{selected_model['base_price']} грн)"
  puts "Матеріал: #{selected_material['name']} (+#{selected_material['extra_price']} грн)"
  puts "Колір: #{color_input} | Розмір: #{size_input}"
  puts '----------------------------------------'

  print 'Введіть кількість: '
  quantity_input = gets.chomp.to_i
  if quantity_input <= 0
    puts "\n[!] Помилка: Кількість має бути більше 0!"
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
  puts "\n[✓] Успішно додано до кошика!"
  sleep(1.5)
  cart
end

def manage_cart(cart, username)
  system('clear') || system('cls')
  if cart.empty?
    puts 'Ваш кошик порожній.'
    puts "\nНатисніть Enter, щоб повернутися в меню..."
    gets
    return cart
  end

  puts '--- ВАШ КОШИК ---'
  total_sum = 0
  cart.each_with_index do |item, index|
    subtotal = item['total']
    total_sum += subtotal
    puts "#{index + 1}. Модель: #{item['model']} | Матеріал: #{item['material']}"
    puts "   Колір: #{item['color']} | Розмір: #{item['size']} | Кількість: #{item['quantity']} шт."
    puts "   Сума: #{subtotal} грн"
    puts '----------------------------------------'
  end
  puts "ЗАГАЛЬНА СУМА КОШИКА: #{total_sum} грн"
  puts '========================================'
  puts 'Дії:'
  puts '1. Оформити замовлення'
  puts '2. Видалити товар з кошика за номером'
  puts '3. Повернутися в меню'

  print 'Оберіть дію: '
  action = gets.chomp

  case action
  when '1'
    save_order_to_file(cart, username)
    puts "\n[✓] Замовлення успішно оформлено!"
    puts 'Дякуємо за покупку в PrintForge!'
    sleep(2)
    []
  when '2'
    print 'Введіть номер товару для видалення: '
    idx = gets.chomp.to_i - 1
    if idx >= 0 && idx < cart.size
      removed = cart.delete_at(idx)
      puts "\n[!] Товар '#{removed['model']}' видалено з кошика."
    else
      puts "\n[!] Невірний номер товару."
    end
    sleep(1.5)
    manage_cart(cart, username)
  when '3'
    cart
  else
    puts "\n[!] Невідома дія."
    sleep(1)
    manage_cart(cart, username)
  end
end
