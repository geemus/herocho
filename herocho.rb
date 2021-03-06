require 'bundler'
Bundler.require

require 'json'

class Herocho < Sinatra::Base

  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    ENV['CREDENTIALS'].split(",").map {|cred| Rack::Utils.secure_compare(cred, "#{username}:#{password}")}.include?(true)
  end

  post '/' do
    data = JSON.parse(request.body.read)

    # ensure we are the intended skill recipient
    unless data['session']['application']['applicationId'] == ENV['ECHO_APPLICATION_ID']
      halt(400)
    end
    # ensure the request is within 2.5 minutes of now
    unless (Time.now - Time.parse(data['request']['timestamp'])).abs < 150
      halt(400)
    end

    puts data.inspect
    # requestId, timestamp, type, ...
    case data['request']['type']
    when 'LaunchRequest'
      status(200)
      body({
        version: '1.0',
        # session: {} # key/value pairs to set
        response: {
          card: {
            content:  'How may I be of service?',
            title:    'Alfred, at your service',
            type:     'Simple'
          },
          outputSpeech: {
            text: 'How may I be of service?',
            type: 'PlainText'
          },
          shouldEndSession: true
        }
      }).to_json
    when 'IntentRequest'
      # intent => { name, slots => { string => { name => string, value => string } } }
      status(200)
      body({
        version: '1.0',
        # session: {} # key/value pairs to set
        response: {
          card: {
            content:  'Hello World',
            title:    'Hello World',
            type:     'Simple'
          },
          outputSpeech: {
            text: 'Hello World',
            type: 'PlainText'
          },
          reprompt: {
            outputSpeech: {
              text: 'Can I help you with anything else?',
              type: 'PlainText'
            }
          },
          shouldEndSession: true
        }
      }).to_json
    when 'SessionEndedRequest'
      # reason
    end
  end

end
