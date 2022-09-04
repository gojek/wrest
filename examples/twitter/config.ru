# frozen_string_literal: true

require 'rubygems'
require 'yaml'
require 'sinatra'
require File.expand_path('oauth10', __dir__)

root_dir = __dir__

set :root, root_dir
disable :run

require File.expand_path('server', __dir__)
run Server
