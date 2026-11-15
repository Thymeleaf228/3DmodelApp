# frozen_string_literal: true

require 'yaml'

class ModelEntity
  MODELS_FILE = 'db/models.yml'

  def self.all_models
    if File.exist?(MODELS_FILE)
      data = YAML.load_file(MODELS_FILE)
      data.is_a?(Hash) ? (data['models'] || []) : (data || [])
    else
      []
    end
  end

  def self.find_model_by_id(id)
    all_models.find { |m| m['id'].to_s == id.to_s }
  end
end