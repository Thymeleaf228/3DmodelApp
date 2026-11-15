# frozen_string_literal: true

require 'yaml'
require_relative 'entities/order'
require_relative 'entities/model'
require_relative 'entities/material'

SIZE_COEFFICIENTS = {
  's' => 1.0,
  'm' => 1.5,
  'l' => 2.0
}.freeze

def run_store_menu(logged_user, cart = [])
  system('clear') || system('cls')
  username = logged_user.is_a?(Hash) ? (logged_user['name'] || logged_user[:name]) : logged_user

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
  get_store_action(choice, logged_user, cart)
end

def get_store_action(action, logged_user, cart)
  case action
  when '1'
    show_models_catalog
    run_store_menu(logged_user, cart)
  when '2'
    show_materials_catalog
    run_store_menu(logged_user, cart)
  when '3'
    updated_cart = add_to_cart(cart)
    run_store_menu(logged_user, updated_cart)
  when '4'
    updated_cart = manage_cart(cart, logged_user)
    run_store_menu(logged_user, updated_cart)
  when '5'
    system('clear') || system('cls')
  else
    puts "\n[!] Невідома дія, введіть число від 1 до 5."
    sleep(1.5)
    run_store_menu(logged_user, cart)
  end
end

def show_models_catalog
  system('clear') || system('cls')
  models = ModelEntity.all_models

  puts "\n--- КАТАЛОГ МОДЕЛЕЙ ---"
  models.each do |model|
    puts "ID: #{model['id']} | Назва: #{model['title']} | Базова ціна: #{model['base_price']} грн"
  end
  puts "\nНатисніть Enter, щоб повернутися в меню..."
  gets
end

def show_materials_catalog
  system('clear') || system('cls')
  materials = MaterialEntity.all_materials

  puts "\n--- КАТАЛОГ МАТЕРІАЛІВ ---"
  materials.each do |mat|
    puts "ID: #{mat['id']} | Назва: #{mat['name']} | Доплата: #{mat['extra_price']} грн"
  end
  puts "\nНатисніть Enter, щоб повернутися в меню..."
  gets
end

def add_to_cart(cart)
  system('clear') || system('cls')
  puts '--- ДОДАВАННЯ ДО КОШИКА ---'

  print "Введіть ID моделі (або 'back' для виходу): "
  model_input = gets.chomp
  return cart if model_input.downcase == 'back'

  selected_model = ModelEntity.find_model_by_id(model_input)
  unless selected_model
    puts "\n[!] Помилка: Модель з таким ID не знайдена!"
    sleep(1.5)
    return cart
  end

  print 'Введіть ID матеріалу: '
  material_input = gets.chomp
  selected_material = MaterialEntity.find_material_by_id(material_input)

  unless selected_material
    puts "\n[!] Помилка: Матеріал з таким ID не знайдено!"
    sleep(1.5)
    return cart
  end

  print 'Введіть колір товару: '
  color_input = gets.chomp

  print 'Введіть розмір (S, M, L): '
  size_input = gets.chomp.downcase
  
  unless SIZE_COEFFICIENTS.key?(size_input)
    puts "\n[!] Помилка: Невірний розмір! Оберіть S, M або L."
    sleep(1.5)
    return cart
  end

  size_coef = SIZE_COEFFICIENTS[size_input]

  system('clear') || system('cls')
  puts '----------------------------------------'
  puts 'Ви обрали:'
  puts "Модель: #{selected_model['title']} (#{selected_model['base_price']} грн)"
  puts "Матеріал: #{selected_material['name']} (+#{selected_material['extra_price']} грн)"
  puts "Колір: #{color_input} | Розмір: #{size_input.upcase}"
  puts '----------------------------------------'

  print 'Введіть кількість: '
  quantity_input = gets.chomp.to_i
  if quantity_input <= 0
    puts "\n[!] Помилка: Кількість має бути більше 0!"
    sleep(1.5)
    return cart
  end

  item_total = (selected_model['base_price'] * size_coef + selected_material['extra_price']) * quantity_input

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

def manage_cart(cart, logged_user)
  system('clear') || system('cls')
  if cart.empty?
    puts 'Ваш кошик порожній.'
    puts "\nНатисніть Enter, щоб повернутися в меню..."
    gets
    return cart
  end

  puts '--- ВАШ КОШИК ---'
  total_items_count = 0
  total_sum = 0

  cart.each_with_index do |item, index|
    subtotal = item['total']
    total_sum += subtotal
    total_items_count += item['quantity']
    puts "#{index + 1}. Модель: #{item['model']} | Матеріал: #{item['material']}"
    puts "   Колір: #{item['color']} | Розмір: #{item['size'].upcase} | Кількість: #{item['quantity']} шт."
    puts "   Сума: #{subtotal} грн"
    puts '----------------------------------------'
  end

  if total_items_count >= 5
    discount_sum = total_sum * 0.1
    total_sum -= discount_sum
    puts "[!] Знижка 10% за покупку від 5 виробів застосована! (Знижка: -#{discount_sum.round(2)} грн)"
  end

  puts "ЗАГАЛЬНА СУМА КОШИКА: #{total_sum.round(2)} грн"
  puts '========================================'
  puts 'Дії:'
  puts '1. Оформити замовлення'
  puts '2. Видалити товар з кошика за номером'
  puts '3. Повернутися в меню'

  print 'Оберіть дію: '
  action = gets.chomp

  case action
  when '1'
    OrderEntity.create_order(cart, logged_user)
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
    manage_cart(cart, logged_user)
  when '3'
    cart
  else
    puts "\n[!] Невідома дія."
    sleep(1)
    manage_cart(cart, logged_user)
  end
end