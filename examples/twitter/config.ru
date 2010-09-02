require 'rubygems'
require 'yaml'
require 'sinatra'
require File.expand_path('../oauth10', __FILE__)

root_dir = File.dirname(__FILE__)

set :root,        root_dir
disable :run

require File.expand_path('../server', __FILE__)
run Server