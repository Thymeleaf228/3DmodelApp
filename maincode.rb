require 'yaml'
require_relative 'signup'
require_relative 'login'

ORDERS_FILE = 'orders.yml'

# Загрузка каталогов или заказов
def load_data(filename)
  if File.exist?(filename)
    YAML.load_file(filename) || []
  else
    []
  end
end

# Сохранение заказов в файл
def save_order_to_file(order_data)
  orders = load_data(ORDERS_FILE)
  orders = [] unless orders.is_a?(Array)
  
  # Генерируем ID для заказа
  next_id = orders.empty? ? 1 : (orders.map { |o| o['id'] || 0 }.max + 1)
  order_data['id'] = next_id
  order_data['date'] = Time.now.strftime("%Y-%m-%d %H:%M:%S")

  orders << order_data

  File.open(ORDERS_FILE, 'w') do |file|
    file.write(orders.to_yaml)
  end
end

def run_store_menu(username)
  cart = [] # Корзина для хранения выбранных товаров

  loop do
    system('clear') || system('cls')
    puts "Привіт, #{username}!"
    puts "Вітаємо у магазині PrintForge!"
    puts "\nОберіть дію та введіть її номер:"
    puts "1. Переглянути каталог моделей"
    puts "2. Переглянути каталог матеріалів"
    puts "3. Зібрати товар і додати в кошик"
    puts "4. Переглянути кошик та оформити замовлення (#{cart.size} тов.)"
    puts "5. Вийти в головне меню (змінити акаунт)\n"

    print "Ваш вибір: "
    choice = gets.chomp

    case choice
    when "1"
      show_models_catalog
    when "2"
      show_materials_catalog
    when "3"
      cart = add_to_cart(cart)
    when "4"
      cart = manage_cart(cart, username)
    when "5"
      system('clear') || system('cls')
      break
    else
      puts "\n[!] Невідома дія, введіть число від 1 до 5."
      sleep(1.5)
    end
  end
end

def show_models_catalog
  system('clear') || system('cls')
  data = load_data('models.yml')
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
  data = load_data('materials.yml')
  materials = data['materials'] || []

  puts "\n--- КАТАЛОГ МАТЕРІАЛІВ ---"
  materials.each do |mat|
    puts "ID: #{mat['id']} | Назва: #{mat['name']} | Доплата: #{mat['extra_price']} грн"
  end
  puts "\nНатисніть Enter, щоб повернутися в меню..."
  gets
end

# Додавання товару в кошик із захистом від помилок введення
# Додавання товару в кошик із виведенням короткого опису та захистом від помилок
def add_to_cart(cart)
  system('clear') || system('cls')
  models_data = load_data('models.yml')['models'] || []
  materials_data = load_data('materials.yml')['materials'] || []

  puts "--- ДОДАВАННЯ ДО КОШИКА ---"
  
  # Вибір моделі
  print "Введіть ID моделі (або 'back' для виходу): "
  model_input = gets.chomp
  return cart if model_input.downcase == 'back'

  selected_model = models_data.find { |m| m['id'].to_s == model_input }
  unless selected_model
    puts "\n[!] Помилка: Модель з таким ID не знайдена!"
    sleep(1.5)
    return cart
  end

  # Вибір матеріалу
  print "Введіть ID матеріалу: "
  material_input = gets.chomp
  selected_material = materials_data.find { |mat| mat['id'].to_s == material_input }
  
  unless selected_material
    puts "\n[!] Помилка: Матеріал з таким ID не знайдено!"
    sleep(1.5)
    return cart
  end

  # Виводимо коротку інформацію про обраний товар перед введенням кількості
  system('clear') || system('cls')
  puts "----------------------------------------"
  puts "Ви обрали:"
  puts "Модель: #{selected_model['title']} (#{selected_model['base_price']} грн)"
  puts "Матеріал: #{selected_material['name']} (+#{selected_material['extra_price']} грн)"
  puts "----------------------------------------"

  # Кількість
  print "Введіть кількість: "
  quantity_input = gets.chomp.to_i
  if quantity_input <= 0
    puts "\n[!] Помилка: Кількість має бути більше 0!"
    sleep(1.5)
    return cart
  end

  item_total = (selected_model['base_price'] + selected_material['extra_price']) * quantity_input

  cart_item = {
    'model' => selected_model['title'],
    'model_price' => selected_model['base_price'],
    'material' => selected_material['name'],
    'material_price' => selected_material['extra_price'],
    'quantity' => quantity_input,
    'total' => item_total
  }

  cart << cart_item
  puts "\n[✓] Успішно додано до кошика!"
  sleep(1.5)
  cart
end

# Робота з кошиком (перегляд, видалення, оформлення)
def manage_cart(cart, username)
  loop do
    system('clear') || system('cls')
    if cart.empty?
      puts "Ваш кошик порожній."
      puts "\nНатисніть Enter, щоб повернутися в меню..."
      gets
      return cart
    end

    puts "--- ВАШ КОШИК ---"
    total_sum = 0
    cart.each_with_index do |item, index|
      subtotal = item['total']
      total_sum += subtotal
      puts "#{index + 1}. Модель: #{item['model']} + Матеріал: #{item['material']}"
      puts "   Кількість: #{item['quantity']} шт. | Сума: #{subtotal} грн"
      puts "----------------------------------------"
    end
    puts "ЗАГАЛЬНА СУМА КОШИКА: #{total_sum} грн"
    puts "========================================"
    puts "Дії:"
    puts "1. Оформити замовлення"
    puts "2. Видалити товар з кошика за номером"
    puts "3. Повернутися в меню"
    
    print "Оберіть дію: "
    action = gets.chomp

    case action
    when "1" # Оформити замовлення
      order_data = {
        'username' => username,
        'items' => cart,
        'total_price' => total_sum
      }
      save_order_to_file(order_data)
      puts "\n[✓] Замовлення успішно оформлено та збережено у файл orders.yml!"
      puts "Дякуємо за покупку!"
      sleep(2)
      return [] # Очищуємо кошик після оформлення
    when "2"
      print "Введіть номер товару для видалення: "
      idx = gets.chomp.to_i - 1
      if idx >= 0 && idx < cart.size
        removed = cart.delete_at(idx)
        puts "\n[!] Товар '#{removed['model']}' видалено з кошика."
      else
        puts "\n[!] Невірний номер товару."
      end
      sleep(1.5)
    when "3"
      return cart
    else
      puts "\n[!] Невідома дія."
      sleep(1)
    end
  end
end

def print_main_menu
  puts "Вітаємо у магазині PrintForge!\n\n" +
  "Різноманітні 3D-моделі та матеріали на ваш смак\n" +
  "Звертайтесь до PrintForge!\n" +
  "Оберіть дію:\n" +
  "  1 - log in\n" +
  "  2 - sign up\n" +
  "  3 - exit"  
end

def run
  print_main_menu
  puts "\n"
  user_action = gets.chomp
  case user_action
  when "1"
    system('clear') || system('cls')  
    logged_user = log_in_user
    if logged_user
      system('clear') || system('cls')
      run_store_menu(logged_user['name'])
    else
      puts "\n"
      puts "--------------------------------------------"
      puts "  Такого юзера не знайдено або пароль невірний"
      puts "--------------------------------------------"
      puts "\n\n"
    end
  when "2"
    sign_up_user
  when "3"
    system('clear') || system('cls')
    puts "Дякуємо, звертайтеся до нас ще!\n\n\n"
    exit
  end
  run
end

run