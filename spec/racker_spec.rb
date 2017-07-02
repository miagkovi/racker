require 'rack/test'
require 'rspec'
require_relative '../lib/game'

OUTER_APP = Rack::Builder.parse_file('./config.ru').first

describe 'Racker' do
  include Rack::Test::Methods

  def app
    OUTER_APP
  end

  let(:response_200) { expect(last_response.status).to eq 200 }
  let(:response_302) { expect(last_response.status).to eq 302 }

  it 'visits /' do
    get '/'
    response_200
  end

  it 'visits /scoreboard' do
    get '/scoreboard'
    response_200
  end

  it 'visits /restart' do
    get '/restart'
    response_302
  end
end