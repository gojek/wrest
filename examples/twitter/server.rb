# frozen_string_literal: true

class Server < Sinatra::Application
  get '/authenticate'

  get '/authenticated'
end
