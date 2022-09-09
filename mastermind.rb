# frozen_string_literal: true

module Mastermind
  COLORS = %w[r g b y m o].freeze
  CORRECT = 2
  ALMOST_CORRECT = 1

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
    def code
      4.times.map { COLORS.sample }
    end

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

  # Interface for a user to play as the codebreaker
  class User
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

    private

    def ask_guess
      loop do
        puts 'Enter a guess (r/g/b/y/m/o): '
        input = gets.chomp.strip
        match = input.downcase.match(/^[rgbymo]{4}$/)

        return match[0].chars unless match.nil?

        puts "Invalid guess: #{input}"
      end
    end

    def display_board
      lines = ['========+========']
      12.times { |i| lines << row_str(i) }
      lines << '========+========'

      puts
      puts lines.join("\n")
      puts
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

def play
  computer = Mastermind::Computer.new
  user = Mastermind::User.new
  game = Mastermind::Game.new(computer, user)

  game.play

  if game.winner == user
    puts 'You win!'
  else
    secret_code = game.code.join(' ').upcase
    puts "You Lose... Secret code: #{secret_code}"
  end
end

play
