# frozen_string_literal: true

require 'yaml'

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
  filename = "#{filename}.yml" unless filename.end_with?(".yml")
  File.expand_path("../db/#{filename}", __dir__)
end
