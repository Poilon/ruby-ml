#encoding: UTF-8
require 'sanitize'
require 'i18n'

module Mapper
  class KernelProcessor

    attr_accessor :type, :file_names

    # file_names: file names corresponding to type
    # type: type of mapped data
    def initialize(type = 'feeling', file_names = nil)
      @type = type
      @file_names = file_names || find_file_names(type)
    end

    # Goes through kernel and write all keywords found on the .keys file
    # Generate a new version of the EngineParameter for the current type
    # With the new keywords
    def generate_new_keyword_set_from_kernel
      write_keywords_on_file(find_keywords_in_kernel)
      Mapper::EngineParameter.generate_new_version_from_file(type)
    end


    def find_keywords_in_kernel
      hash = {}
      @file_names.each do |file_name|
        json = JSON.parse(File.read(file_name))
        hash[json[@type]] = '' if hash[json[@type]].blank?
        hash[json[@type]] += Sanitize.clean(json['title'] + ' ' + json['description'])
      end
      hash.each do |name, text|
        hash[name] = KeywordsGenerator.new(text, @type, 3).result_percentage.map do |el|
          "#{el[0]},0,#{(el[1] * 1000).to_i}"
        end
      end
      hash
    end

    def write_keywords_on_file(hash)
      page = ''
      hash.each do |name, keywords|
        page << "-\n"
        page << "#{name}\n"
        keywords.each { |k| page << "#{k}\n" }
      end
      File.write("data/engine_parameters/#{type}.keys", page)
      puts "pushed on file data/engine_parameters/#{type}.keys"
    end

    private

    def find_file_names(type)
      Dir.glob("data/kernel/#{@type}/*")
    end
  end
end
