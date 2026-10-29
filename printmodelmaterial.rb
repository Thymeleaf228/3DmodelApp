require 'yaml'

def print_report
  models_path = 'models.yml'
  materials_path = 'materials.yml'

  models_data = load_yaml(models_path)
  materials_data = load_yaml(materials_path)

  puts "========================================"
  puts "          ОТЧЕТ ПО РЕСУРСАМ             "
  puts "========================================"

  puts "\nМОДЕЛИ:"
  if models_data && models_data['models']
    models_data['models'].each do |model|
      puts "  - ID: #{model['id']}"
      puts "    Название: #{model['title']}"
      puts "    Базовая цена: #{model['base_price']}"
      puts "  --------------------"
    end
  else
    puts "  (Модели не найдены)"
  end

  puts "\nМАТЕРИАЛЫ:"
  if materials_data && materials_data['materials']
    materials_data['materials'].each do |mat|
      puts "  - ID: #{mat['id']}"
      puts "    Название: #{mat['name']}"
      puts "    Доплата: #{mat['extra_price']}"
      puts "  --------------------"
    end
  else
    puts "  (Материалы не найдены)"
  end

  puts "\n========================================"
  puts "          ГОТОВО! ВСЁ СЧИТАНО          "
  puts "========================================"
end

def load_yaml(filepath)
  if File.exist?(filepath)
    YAML.load_file(filepath)
  else
    puts "[!] Внимание: Файл #{filepath} не найден!"
    nil
  end
end

print_report