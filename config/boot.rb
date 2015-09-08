# encoding: UTF-8
# boot.rb
ENV['RACK_ENV'] ||= 'development'
# Load dependencies
require 'rubygems'
require 'bundler/setup'
require 'active_support/all'
require 'net/http'
require 'yaml'
require 'active_record'

Bundler.require(:default)
APP_ROOT ||= File.expand_path(File.join(File.dirname(__FILE__), '..'))


require File.expand_path('../../lib/mapper', __FILE__)
