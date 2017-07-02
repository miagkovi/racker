# frozen_string_literal: true

require 'yaml'
require 'codebreaker'

class Game
  attr_reader :hints, :game_id, :result, :hints_string, :result
  attr_accessor :input, :attempts, :game, :game_status

  FILE_NAME = 'session.yaml'.freeze
  SCOREBOARD_FILE = 'scoreboard.yaml'.freeze

  def self.find(id)
    session = File.exist?(FILE_NAME) ? YAML.load_file(FILE_NAME) : []
    session.find { |element| element.game_id == id }
  end

  def initialize
    @attempts = Codebreaker::MAX_ATTEMPTS
    @secret_code = Code.new
    @hints = 1
    @hints_string = ''
    @session = File.exist?(FILE_NAME) ? YAML.load_file(FILE_NAME) : []
  end

  def hint
    @hints_string << @secret_code.to_s[rand(0..3)]
  end

  def check(input)
    @input = input
    @attempts -= 1
    @result = @secret_code.compare_with(@input)
    @game_status = :lost if @attempts <= 0
    @game_status = :won if @result == '++++'
  end

  def save
    @session = File.exist?(FILE_NAME) ? YAML.load_file(FILE_NAME) : []
    @game_id = @session.last ? (@session.last.game_id + 1) : 0
    @session.push(self)
    save_session(@session)
  end

  def update
    @session = File.exist?(FILE_NAME) ? YAML.load_file(FILE_NAME) : []
    index = @session.index { |element| element.game_id == @game_id }
    return save unless index
    @session[index] = self
    save_session(@session)
  end

  def delete_from_file
    @session = File.exist?(FILE_NAME) ? YAML.load_file(FILE_NAME) : []
    index = @session.index { |element| element.game_id == @game_id }
    @session.delete_at(index)
    save_session(@session)
  end

  def save_score(name)
    player = Player.new(name, @attempts, @secret_code)
    scores = get_scores
    scores << player
    File.open(SCOREBOARD_FILE, 'w') { |f| f.write(scores.to_yaml) }
  end

  def get_scores
    return [] unless File.exist?(SCOREBOARD_FILE)
    YAML.load_file(SCOREBOARD_FILE)
  end

  private

  def save_session(session)
    File.open(FILE_NAME, 'w') { |f| f.write(session.to_yaml) }
  end
end
