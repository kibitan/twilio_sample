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


get '/' do
  'Hello world!'
end
