#encoding: UTF-8
require 'active_record'

module Mapper
  class EngineParameter < ActiveRecord::Base

    def self.types
      pluck(:name).uniq
    end

    def self.last_version(type)
      where(name: type).order('version DESC').first
    end

    def self.select_version(type, version)
      where(name: type, version: version).first
    end

    def self.versions(type)
      where(name: type).order('version DESC')
    end

    def self.from_file type
      matrix = {}
      key = ''

      lines = IO.readlines("data/engine_parameters/#{type}.keys", encoding: 'UTF-8')

      lines.each do |line|
        line.encode!('UTF-8')
        if line.split(',')[1].nil?
          key = line.split("\n")[0]
          matrix[key] = []
        else
          clean_line = line.split("\n")[0]
          split = clean_line.split(',')
          matrix[key] << {
            keyword: split[0],
            case_sensitive: split[1].to_i,
            weight: split[2].to_i
          }
        end
      end
      matrix
    end

    # While unserializing from the Hstore, it cannot be restored in a level 2 of deepness, so we have to eval it before
    def self.full_data_store
      full_data_store = {}
      types.each do |type|
        full_data_store[type] = last_version(type)
        full_data_store[type].data.each do |name, keywords|
          # I'm aware that this eval is unsafe. I don't know how to improve the
          # load of the hash. You may help ?
          full_data_store[type].data[name] = eval(keywords)
        end
      end
      full_data_store
    end

    def self.get_version(type, version)
      data_store = {}
      data_store = select_version(type, version)
      data_store.data.each do |name, keywords|
        data_store.data[name] = eval keywords
      end
      data_store
    end

    def self.new_type(type)
      Mapper::EngineParameter.create_param_version(1, type)
    end

    def self.generate_new_version_from_file(type)
      last_version = last_version(type)
      version = last_version ? last_version.version + 1 : 1
      Mapper::EngineParameter.create_param_version(version, type)
    end

    def self.reset_from_files_in_new_version
      types.each do |type|
        Mapper::EngineParameter.generate_new_version_from_file(type)
      end
    end

    def self.create_param_version(version, type)
      datastore = from_file type
      param = Mapper::EngineParameter.new
      param.data = datastore
      param.version = version
      param.name = type
      param.save
    end
  end
end
