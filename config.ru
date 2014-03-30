#path = File.expand_path "../", __FILE__

require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
require 'pry'
require './activitiesapp'

run AcApp
