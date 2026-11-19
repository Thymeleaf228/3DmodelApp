# frozen_string_literal: true

def load_data(filename)
  filepath = get_path(filename)

  if File.exist?(filepath)
    YAML.load_file(filepath) || []
  else
    []
  end
end

def write_data(filename, data)
  filepath = get_path(filename)
  File.write(filepath, data.to_yaml)
end

def get_path(filename)
  filename = "#{filename}.yml" unless filename.end_with?('.yml')
  File.expand_path("../db/#{filename}", __dir__)
end

def create_next_id(users)
  users.empty? ? 1 : users.map { |user| user['id'] }.max + 1
end

def hash_password(plain_password)
  BCrypt::Password.create(plain_password).to_s
end

def verify_password(hash_from_db, plain_password)
  BCrypt::Password.new(hash_from_db) == plain_password
end

