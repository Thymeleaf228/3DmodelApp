# frozen_string_literal: true

class MaterialEntity
  MATERIALS_FILE = 'db/materials.yml'

  def self.all_materials
    if File.exist?(MATERIALS_FILE)
      data = YAML.load_file(MATERIALS_FILE)
      data.is_a?(Hash) ? (data['materials'] || []) : (data || [])
    else
      []
    end
  end

  def self.find_material_by_id(id)
    all_materials.find { |mat| mat['id'].to_s == id.to_s }
  end
end
