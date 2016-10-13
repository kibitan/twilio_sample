require 'sinatra'
require 'pry'
require 'better_errors'
require 'slim'
require 'twilio-ruby'

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = __dir__
end

TWILIO_NUMBER     = ENV['TWILIO_NUMBER']
TWILIO_SID        = ENV['TWILIO_SID']
TWILIO_AUTH_TOKEN = ENV['TWILIO_AUTH_TOKEN']

Twilio.configure do |config|
  config.account_sid = TWILIO_SID
  config.auth_token  = TWILIO_AUTH_TOKEN
end

get '/' do
  slim :index
end

post '/call' do
  client = Twilio::REST::Client.new
  calling = client.account.calls.create(
    from: TWILIO_NUMBER,
    to:  params["to_number"],
    url: (host_name + '/callback').to_s,
    method: "GET" # default は POST
  )
end

get '/callback' do
end

private

def host_name
  URI.parse("#{request.env['rack.url_scheme']}://#{request.env["HTTP_HOST"]}")
end
