require 'sinatra'
require 'sinatra/reloader' if development?
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
    url: (host_name + URI.encode("/voice?say=#{params['say']}&forward_number=#{params['forward_number']}")).to_s,
    method: "GET" # default は POST
  )

  return "calling to #{params['to_number']}! forward to #{params['forward_number']}!"
end

get '/voice' do
  response = Twilio::TwiML::Response.new do |r|
    r.Say params['say'], voice: 'alice', language: 'ja-jp'
    r.Dial callerId: TWILIO_NUMBER do |d|
      d.Number params["forward_number"]
    end
  end
  render_xml response.text
end

private

def host_name
  URI("#{request.env['rack.url_scheme']}://#{request.env["HTTP_HOST"]}")
end

def render_xml(xml)
  content_type 'text/xml'
  return xml
end
