require 'test/unit'
require 'rack/test'

class TestRacker < Test::Unit::TestCase
  include Rack::Test::Methods
  OUTER_APP = Rack::Builder.parse_file('../config.ru').first

  def app
    OUTER_APP
  end

  def test_root
    get '/'
    assert last_response.ok?
    assert_equal 200, last_response
  end

  def test_scoreboard
    get '/scoreboard'
    assert last_response.ok?
    assert_equal 200, last_response
  end

  def test_unknown_path
    get '/weird_path_foo_bar'
    assert last_response.ok?
    assert_equal 404, last_response
  end

  def test_guess
    get '/guess'
    assert last_response.ok?
    assert_equal 302, last_response
  end

  def test_restart
    get '/restart'
    assert last_response.ok?
    assert_equal 302, last_response
  end

  def test_hint
    get '/hint'
    assert last_response.ok?
    assert_equal 302, last_response
  end

  def test_save_score
    get '/save_score'
    assert last_response.ok?
    assert_equal 302, last_response
  end
end