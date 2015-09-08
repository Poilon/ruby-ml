#encoding: UTF-8

module Mapper
  class Processor
    attr_reader :types,
                :global_types, :article,
                :global_weights, :scores,
                :keywords_found, :full_data_store, :full_body

    def initialize(full_data_store = Mapper::EngineParameter.full_data_store)
      @types = Mapper::EngineParameter.types
      @full_data_store = Marshal.load(Marshal.dump(full_data_store))
      @global_weights = {}
      @scores = {}
      @keywords_found = []
    end

    def run(article)
      @article = article
      @title = get_title
      @full_body = get_full_body
      @full_downcase_body = get_downcase_full_body
      unless article.blank?
        types.each do |type|
          scores[type] = find_matching(type)
        end
        scores.each do |type, name_weights|
          if name_weights.blank? || name_weights[0].blank? || name_weights[1] == 0
            article[type] = 'Undefined'
          elsif name_weights[0].count > 1
            article[type] = name_weights[0]
          else
            article[type] = name_weights[0].first
          end
        end
      end
      article
    end

    def find_matching(type)
        weights = {}
        if article.is_a?(Hash) && !article['keywords'].nil?
          @keywords_found = article['keywords']
        else
          data = @full_data_store[type].data
          data.each do |name, keywords|
            parse_text_filling_keywords(type, name, keywords)
          end
        end
        @keywords_found.each do |arr|
          if arr[0] == type
            weights[arr[1]] = weights[arr[1]].blank? ? arr[3] * arr[4] : weights[arr[1]] + (arr[3] * arr[4])
          end
        end
      global_weights[type] = weights
      [weights.select{|name, name_weight| name_weight == weights.values.max}.keys, weights.values.max]
    end

    def add_keyword(type, name, keyword)
      occurences = 0
      if keyword[:case_sensitive] == 1
        occurences = @full_body.scan(keyword[:keyword]).count
      else
        occurences = @full_downcase_body.scan(keyword[:keyword].downcase).count
      end
      @keywords_found << [type, name, keyword[:keyword], keyword[:weight], occurences] if occurences != 0
    end

    def parse_text_filling_keywords(type, name, keywords)
      keywords.each do |keyword|
        add_keyword(type, name, keyword)
      end
    end

    def get_description
      clean_field('description')
    end

    def get_title
      clean_field('title') + ' '
    end

    def get_full_body
      get_title + get_description
    end

    def get_downcase_full_body
      get_full_body.downcase
    end

    def set_weights(type, name)
      global_types[type][name].each do |val|
        changed = val[:weight]
        clean_keyword = clean_content(val[:keyword])
        if val[:case_sensitive] == 1
          val[:weight] += get_full_body.scan(clean_keyword).count
        else
          val[:weight] += get_downcase_full_body.scan(clean_keyword.downcase).count
        end
        if changed != val[:weight]
          puts "The weight of the keyword \"#{val[:keyword]}\" has been updated to #{val[:weight]}"
          sleep(0.3)
        end
      end
    end

    def clean_field(name)
      clean_content(Nokogiri::HTML(article[name]).text.gsub("\n", '').gsub("\t", '')) if name
    end

    def clean_content(string)
      I18n.transliterate(Sanitize.clean(string.strip)) if string
    end
  end
end
