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
    url: host_name("/voice?say=#{params['say']}&forward_number=#{params['forward_number']}"),
    method: "GET" # default は POST
  )

  return "calling to #{params['to_number']}! forward to #{params['forward_number']}!"
end

get '/voice' do
  response = Twilio::TwiML::Response.new do |r|
    r.Say params['say'], voice: 'alice', language: 'ja-jp'
    r.Gather method: 'GET', action: host_name("/forward?number=#{params['forward_number']}") do |g|
      g.Say '数字をプッシュして下さい', voice: 'alice', language: 'ja-jp'
    end
    r.Say '番号が確認できませんでしたので、終了します', voice: 'alice', language: 'ja-jp'
  end
  render_xml response.text
end

get '/forward' do
  response = Twilio::TwiML::Response.new do |r|
    r.Say "電話を開始します", voice: 'alice', language: 'ja-jp'
    r.Dial callerId: TWILIO_NUMBER do |d|
      d.Number params["number"]
    end
    r.Say '通話が終了しました。またね！', voice: 'alice', language: 'ja-jp'
  end
  render_xml response.text
end

private

def host_name(str)
  ( URI("#{request.env['rack.url_scheme']}://#{request.env["HTTP_HOST"]}") + URI.encode(str) ).to_s
end

def render_xml(xml)
  content_type 'text/xml'
  return xml
end
