# frozen_string_literal: true

# Represent a tic-tac-toe board
class TicTacToeBoard
  attr_reader :winner

  def initialize
    @board = Array.new(3) { Array.new(3) }
    @turn = 1
    @done = false
    @winner = nil
  end

  def mark(x, y)
    return if @done
    return unless mark?(x, y)

    @board[y][x] = current_player
    @turn += 1

    update_status
  end

  def mark?(x, y)
    return false if @done
    return false unless x.is_a?(Integer) && y.is_a?(Integer)
    return false unless x.between?(0, 2) && y.between?(0, 2)

    @board[y][x].nil?
  end

  def done?
    @done
  end

  def current_player
    return nil if @done

    @turn.odd? ? 'X' : 'O'
  end

  def to_s
    lines = []

    lines << '   0     1     2'
    lines << '+=====+=====+=====+'
    lines << rows_string

    lines.join("\n")
  end

  private

  def update_status
    return if @done

    scan_rows
    scan_columns
    scan_diagonals

    is_full = @board.all?(&:all?)
    @done = true if is_full
  end

  def scan_rows
    return if @done

    scan_lines(@board)
  end

  def scan_columns
    return if @done

    columns = []

    0.upto(2) do |x|
      column = 0.upto(2).map { |y| @board[y][x] }
      columns << column
    end

    scan_lines(columns)
  end

  def scan_diagonals
    diagonal_ltr = 0.upto(2).map { |i| @board[i][i] }
    diagonal_rtl = 0.upto(2).map { |i| @board[i][2 - i] }

    scan_lines([diagonal_ltr, diagonal_rtl])
  end

  def scan_lines(lines)
    lines.each do |line|
      winner = line_winner(line)

      next if winner.nil?

      @winner = winner
      @done = true
      break
    end
  end

  def line_winner(line)
    1.upto(line.length - 1) do |i|
      cell = line[i]
      prev_cell = line[i - 1]

      return nil if cell.nil? || cell != prev_cell
    end

    line[0]
  end

  def rows_string
    lines = []

    @board.each_index do |i|
      lines << '║     ║     ║     ║'
      lines << row_string(i)
      lines << '║     ║     ║     ║'
      lines << '+=====+=====+=====+'
    end

    lines.join("\n")
  end

  def row_string(row_num)
    line = String.new('║')

    @board[row_num].each do |cell|
      cell = ' ' if cell.nil?
      line << "  #{cell}  ║"
    end

    line << " #{row_num}"
  end
end

def get_position(board)
  input_regex = /^(\d+)\s+(\d+)$/

  loop do
    print "[#{board.current_player}] Enter the mark position 'x y': "

    input = gets.chomp.strip
    match = input_regex.match(input)

    return match.captures.map(&:to_i) unless match.nil?

    puts "Invalid input format: #{input}"
  end
end

def get_valid_position(board)
  loop do
    x, y = get_position(board)

    unless board.mark?(x, y)
      puts "Cannot mark the board at position (#{x}, #{y})"
      next
    end

    return [x, y]
  end
end

def play
  board = TicTacToeBoard.new

  until board.done?
    puts board

    x, y = get_valid_position(board)
    board.mark(x, y)

    puts
  end

  message = board.winner.nil? ? 'Draw!' : "Winner: #{board.winner}"

  puts board
  puts message
end

play
