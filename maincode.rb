require 'yaml'

user_profile = {
  "name" => "Alice",
  "age" => 30,
  "skills" => ["Ruby", "HTML", "SQL"],
  "settings" => {
    "theme" => "dark",
    "notifications" => true
  }
}

File.open("config.yml", "w") do |file|
  file.write(YAML.dump(user_profile))
end

puts "YAML file created successfully!"

#-----

data = YAML.load_file("config.yml")

puts "User Name: #{data['name']}"
puts "First Skill: #{data['skills'].first}"
puts "Theme Preference: #{data['settings']['theme']}"

#-----

data = YAML.load_file("config.yml")

data["age"] = 31
data["skills"] << "CSS"

File.open("config.yml", "w") do |file|
  file.write(YAML.dump(data))
end

puts "YAML file updated!sdfdsdsffsd"