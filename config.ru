require_relative './lib/racker'

app = Rack::Builder.new do
  use Rack::Reloader
  use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret', expire_after: 216_000
  use Rack::Static, urls: ['/stylesheets'], root: 'public'
  run Racker
end

run app