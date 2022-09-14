# frozen_string_literal: true

require 'set'

module Mastermind
  COLORS = %w[r g b y m o].freeze
  CORRECT = 2
  ALMOST_CORRECT = 1

  # Provides an ability to give a feedback from the given code and guess
  module Feedback
    def feedback(code, guess)
      correct_hints(code, guess) + almost_correct_hints(code, guess)
    end

    private

    def correct_hints(code, guess)
      hints = []

      code.each_index do |i|
        hints << CORRECT if code[i] == guess[i]
      end

      hints
    end

    def almost_correct_hints(code, guess)
      code_count = Hash.new(0)
      guess_count = Hash.new(0)

      code.zip(guess).each do |c1, c2|
        next if c1 == c2

        code_count[c1] += 1
        guess_count[c2] += 1
      end

      [ALMOST_CORRECT] * guess_count.keys.reduce(0) do |total, k|
        total + [code_count[k], guess_count[k]].min
      end
    end
  end

  # Represent a Mastermind game between two players
  class Game
    attr_reader :winner, :code

    def initialize(codemaker, codebreaker)
      @codemaker = codemaker
      @codebreaker = codebreaker
      @winner = nil
      @code = nil
    end

    def play
      @code = @codemaker.code.freeze

      12.times do
        play_turn

        return unless @winner.nil?
      end

      @winner = @codemaker
    end

    private

    def play_turn
      guess = @codebreaker.guess
      feedback = @codemaker.feedback(code, guess)

      @codebreaker.add_feedback(feedback)

      @winner = @codebreaker if guess == code
    end
  end

  # Represent a computer as a codemaker
  class Computer
    include Feedback

    def initialize
      @guesses = []
      @feedbacks = []
    end

    def guess
      @guesses <<
        if @guesses.empty?
          @possible_str_codes = all_codes.map(&:join).to_set
          [COLORS[0], COLORS[0], COLORS[1], COLORS[1]]
        else
          filter_possible_str_codes
          next_guess
        end

      @guesses.last
    end

    def add_feedback(feedback)
      @feedbacks << feedback
    end

    def code
      4.times.map { COLORS.sample }
    end

    private

    def filter_possible_str_codes
      @possible_str_codes.filter! do |str_code|
        code = str_code.chars
        feedback(code, @guesses.last) == @feedbacks.last
      end
    end

    def next_guess
      score_guesses = Hash.new { |hash, key| hash[key] = Set.new }

      all_codes.each do |guess|
        max_score = guess_max_score(guess)
        score_guesses[max_score] << guess.join
      end

      _min_score, guesses = score_guesses.min_by { |score, _guesses| score }
      guesses &= @possible_str_codes if guesses.intersect?(@possible_str_codes)

      guesses.min.chars
    end

    def guess_max_score(guess)
      feedback_counts = Hash.new(0)

      @possible_str_codes.each do |str_code|
        code = str_code.chars
        feedback = self.feedback(code, guess)
        feedback_counts[feedback] += 1
      end

      feedback_counts.values.max
    end

    def all_codes
      codes = []

      6.times do |a|
        6.times do |b|
          6.times do |c|
            6.times { |d| codes << [a, b, c, d].map { |n| COLORS[n] } }
          end
        end
      end

      codes
    end
  end

  # Interface for a user to play as the codebreaker
  class User
    include Feedback

    CODE_PATTERN = /^[#{COLORS.join}]{4}$/.freeze
    FEEDBACK_PATTERN = /^[+\-]{0,4}$/.freeze

    def initialize
      @guesses = []
      @feedbacks = []
    end

    def guess
      @guesses << ask_guess
      @guesses.last
    end

    def add_feedback(feedback)
      @feedbacks << feedback

      display_board
    end

    def code
      loop do
        puts 'Enter a code (r/g/b/y/m/o): '
        input = gets.chomp.strip
        match = input.downcase.match(CODE_PATTERN)

        return match[0].chars unless match.nil?

        puts "Invalid code: #{input}"
      end
    end

    def feedback(code, guess)
      @guesses << guess
      display_board_with_code(code)

      correct_feedback = super(code, guess)

      @feedbacks << ask_correct_feedback(correct_feedback)
      @feedbacks.last
    end

    private

    def ask_correct_feedback(correct_feedback)
      loop do
        user_feedback = ask_feedback

        return user_feedback if user_feedback == correct_feedback

        user_feedback_str = user_feedback.map { |n| n == 2 ? '+' : '-' }.join
        puts "Incorrect feedback: '#{user_feedback_str}'"
      end
    end

    def ask_feedback
      loop do
        puts 'Enter the feedback for the last guess (+/-): '
        input = gets.chomp.strip
        match = input.match(FEEDBACK_PATTERN)

        unless match.nil?
          guess = match[0].chars.map { |c| c == '+' ? 2 : 1 }
          return guess.sort { |a, b| b <=> a }
        end

        puts "Invalid feedback: '#{input}'"
      end
    end

    def ask_guess
      loop do
        puts 'Enter a guess (r/g/b/y/m/o): '
        input = gets.chomp.strip
        match = input.downcase.match(CODE_PATTERN)

        return match[0].chars unless match.nil?

        puts "Invalid guess: #{input}"
      end
    end

    def display_board
      puts
      puts board_str
      puts
    end

    def display_board_with_code(code)
      puts
      puts board_str
      puts "#{code.join(' ').upcase} |"
      puts '========+'
      puts
    end

    def board_str
      lines = ['========+========']
      12.times { |i| lines << row_str(i) }
      lines << '========+========'
      lines.join("\n")
    end

    def row_str(i)
      guess = @guesses[i] || ([' '] * 4)
      feedback = @feedbacks[i] || []

      guess_str = guess.join(' ').upcase
      feedback_str = (feedback.map { |n| n == 2 ? '+' : '-' }).join(' ')

      "#{guess_str} | #{feedback_str}"
    end
  end
end

def play_as_codemaker
  computer = Mastermind::Computer.new
  user = Mastermind::User.new
  game = Mastermind::Game.new(user, computer)

  game.play

  if game.winner == user
    puts 'You win!'
  else
    puts 'You lose...'
  end
end

def play_as_codebreaker
  computer = Mastermind::Computer.new
  user = Mastermind::User.new
  game = Mastermind::Game.new(computer, user)

  game.play

  if game.winner == user
    puts 'You win!'
  else
    secret_code = game.code.join(' ').upcase
    puts "You lose... Secret code: #{secret_code}"
  end
end

def play
  puts 'Would you like to play as the codemaker? (y/n): '
  input = gets.chomp.strip

  puts

  if input.downcase == 'y'
    play_as_codemaker
  else
    play_as_codebreaker
  end
end

play
