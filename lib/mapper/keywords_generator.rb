module Mapper
  class KeywordsGenerator
    attr_accessor :gram, :text, :type, :keywords_array

    MAX_WORDS ||= 100

    def initialize(text, type, gram = 3)
      @text = cleaned_text(text)
      @gram = gram
      @type = type
      @blacklist = Mapper::Blacklist.new(gram, type).blacklist
      @keywords_array = generate_all_n_gram_keywords
    end

    # Return a hash with keywords as keys, and percentage of occurence as value
    def result_percentage
      result_percentage = {}
      found_keywords_count = [MAX_WORDS, keywords_array.count].min
      keywords_array.each do |el|
        result_percentage[el.join(' ')] = Float(keywords_array.count(el)) / Float(found_keywords_count)
      end
      result_percentage.sort_by{ |k, v| -v }.first(MAX_WORDS)
    end

    private

    # generate an array of all n-gram keywords of the text
    def generate_all_n_gram_keywords
      usable_keywords_array = []
      gram.times do |n|
        usable_keywords_array << generate_single_n_gram_keywords(n + 1)
      end
      usable_keywords_array.flatten!(1)
      increase_keywords_weight(usable_keywords_array)
    end

    #@param keywords => the keywords array
    # duplicate n times the n-gram words in the keywords array to increase its weights
    def increase_keywords_weight(keywords)
      array = []
      keywords.each do |keyword|
        keyword.count.times{ array << keyword}
      end
      array
    end

    #@param gram => the current gram value
    #  Generate all the keywords of the text for the passed gram parameter
    def generate_single_n_gram_keywords(gram)
      text.split(/[\s|,|.|"]/).reject{ |token| token.blank? }.each_cons(gram).to_a.reject do |n_gram_word|
        is_a_blacklisted_word?(n_gram_word, gram)
      end
    end

    #@param n_gram_word => a n-gram word array
    #@param gram => the current gram value
    #  Will check if the n-gram word does not contain any blacklisted word or any too short (< 3 chars) word
    def is_a_blacklisted_word?(n_gram_word, gram)
      n_gram_word.any? do |word|
        word.length < 3 || @blacklist[gram].any?{ |bl_word| bl_word == word }
      end
    end

    #@param text => a text
    #  the text is cleaned by the deletion of all html or punctuations related characters,
    #  the downcasing, and the deletion of all the accents
    def cleaned_text(text)
      Sanitize.clean(I18n.transliterate(text.downcase)).tr(".,;:&\n\t?!()[]{}\"", '                  ')
    end
  end
end
