require 'sinatra'
require 'sinatra/reloader' if development?
require 'pry'
require 'tapp'
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

get '/calling_detail' do
  client = Twilio::REST::Client.new
  # https://jp.twilio.com/docs/api/rest/call
  calling_detail = client.account.calls(params['sid']).fetch
  content_type 'text/plain'
  return calling_detail.pretty_inspect
end

post '/call' do
  client = Twilio::REST::Client.new
  calling = client.account.calls.create(
    from: TWILIO_NUMBER,
    to:  params["to_number"],
    url: url_for("/voice?say=#{params['say']}&forward_number=#{params['forward_number']}"),
    method: :post,
    status_callback: url_for("/result"),
    status_callback_method: :post,
    status_callback_event: [:completed],
    fallback_url: url_for("/error"),
    fallback_method: :post
  )

  content_type 'text/plain'
  return <<-EOS
  calling to #{params['to_number']}! forward to #{params['forward_number']}!

  #{calling.pretty_inspect}
  EOS
end

post '/error' do
  response = Twilio::TwiML::Response.new do |r|
    r.Say "エラーコード#{params['ErrorCode']}が発生しました", voice: 'alice', language: 'ja-jp'
  end

  render_xml response.text
end

post '/result' do
  params.tapp
end

post '/voice' do
  response = Twilio::TwiML::Response.new do |r|
    r.Say params['say'], voice: 'alice', language: 'ja-jp'
    # https://jp.twilio.com/docs/api/twiml/gather#attributes
    r.Gather method: :post, numDigits: 1, action: url_for("/forward?number=#{params['forward_number']}") do |g|
      g.Say '番号をダイヤルして下さい', voice: 'alice', language: 'ja-jp'
    end
    # https://jp.twilio.com/docs/api/twiml/redirect#attributes
    r.Redirect '/failuer', method: :post
  end
  render_xml response.text
end

post '/failuer' do
  response = Twilio::TwiML::Response.new do |r|
    r.Say '番号が確認できませんでしたので、終了します', voice: 'alice', language: 'ja-jp'
  end

  render_xml response.text
end

post '/forward' do
  response = Twilio::TwiML::Response.new do |r|
    r.Say "電話を開始します", voice: 'alice', language: 'ja-jp'
    r.Dial callerId: TWILIO_NUMBER, timeLimit: 10 do |d|
      d.Number params["number"]
    end
    # it will execute even when speaker finished the call
    r.Redirect '/success', method: :post
  end
  render_xml response.text
end

post '/success' do
  response = Twilio::TwiML::Response.new do |r|
    r.Say '通話が終了しました。またね！', voice: 'alice', language: 'ja-jp'
  end

  render_xml response.text
end

post '/error_call' do
  client = Twilio::REST::Client.new
  calling = client.account.calls.create(
    from: TWILIO_NUMBER,
    to:  params["to_number"],
    url: url_for("/invalid_twiml"),
    method: :post,
    status_callback: url_for("/result"),
    status_callback_method: :post,
    status_callback_event: [:completed],
    fallback_url: url_for("/error"),
    fallback_method: :post
  )

  content_type 'text/plain'
  return <<-EOS
  calling to #{params['to_number']}!

  #{calling.pretty_inspect}
  EOS
end

post '/invalid_twiml' do
  return render_xml 'hoge hoge'
end

private

def url_for(str)
  ( URI("#{request.env['rack.url_scheme']}://#{request.env["HTTP_HOST"]}") + URI.encode(str) ).to_s
end

def render_xml(xml)
  content_type 'text/xml'
  return xml
end
