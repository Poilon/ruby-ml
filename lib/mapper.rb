$LOAD_PATH.unshift(File.expand_path('..', __FILE__))
module Mapper
  require_relative '../config/database'
  require 'mapper/processor'
  require 'mapper/kernel_processor'
  require 'mapper/keywords_generator'
  require 'mapper/models/engine_parameter'
  require 'mapper/models/article'
  require 'mapper/blacklist'
end
$LOAD_PATH.shift
