# frozen_string_literal: true

require 'erb'
require_relative 'game'

class Racker
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @game = Game.find(@request.cookies['sid'].to_i)
  end

  def response
    case @request.path
    when '/' then index
    when '/guess' then make_guess
    when '/hint' then give_hint
    when '/restart' then restart
    when '/save_score' then save_score
    when '/scoreboard' then scoreboard
    else
      Rack::Response.new('Not Found', 404)
    end
  end

  private

  def index
    @game ||= Game.new
    @game.update
    Rack::Response.new(render('index.html.erb'))
  end

  def make_guess
    @game.check(@request.params['guess'])
    @game.update
    Rack::Response.new do |response|
      response.set_cookie('sid', @game.game_id) unless @request.cookies['sid']
      response.redirect('/')
    end
  end

  def scoreboard
    Rack::Response.new(render('scoreboard.html.erb'))
  end

  def give_hint
    @game.hint
    @game.instance_eval { @hints -= 1 }
    @game.update
    Rack::Response.new do |response|
      response.redirect('/')
    end
  end

  def show_hint
    begin
      @game.hints_string.split('').join('')
    rescue
      ''
    end
  end

  def restart
    @game.delete_from_file
    Rack::Response.new do |response|
      response.delete_cookie('sid')
      response.redirect('/')
    end
  end

  def save_score
    @game.save_score(@request.params['player-name'])
    Rack::Response.new do |response|
      response.redirect('/scoreboard')
    end
  end

  def result
    @game.result
  end

  def game_status
    @game.game_status.to_s
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end
end
