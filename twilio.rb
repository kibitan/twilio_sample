require 'sinatra'

TWILIO_NUMBER     = ENV['TWILIO_NUMBER']
TWILIO_SID        = ENV['TWILIO_SID']
TWILIO_AUTH_TOKEN = ENV['TWILIO_AUTH_TOKEN']


get '/' do
  'Hello world!'
end
