module Mapper
  class Blacklist
    attr_accessor :gram, :type, :words, :blacklist

    BLACKLIST_PATH ||= 'data/engine_parameters/'

    def initialize(gram, type = 'feeling')
      @gram = gram
      @type = type
      @blacklist = blacklisted_words_by_gram
    end

    private

    def blacklisted_words_by_gram
      words_blacklist = {}
      gram.times do |n|
        gram_name = get_gram_name(n + 1)
        words_blacklist[n + 1] = get_blacklisted_words(gram_name)
      end
      words_blacklist
    end

    def get_blacklisted_words gram_name
      file_stream = File.read("#{BLACKLIST_PATH}#{gram_name}_#{type}_blacklist")
      file_stream.split("\n").map(&:strip).map { |word| I18n.transliterate(word) }
    end

    def get_gram_name(gram)
      "#{gram.to_s}-gram"
    end
  end
end
