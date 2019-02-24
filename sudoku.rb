require "pry"

# USAGE
# gen = Sudoku::Generator.new
# gen.reset_number_on_board
# puts gen.display

# 5|2|8|7|4|9|6|1|3
# 7|3|6|5|1|2|8|4|9
# 9|4|1|8|6|3|5|7|2
# 8|1|2|3|9|5|4|6|7
# 6|5|7|2|8|4|9|3|1
# 3|9|4|1|7|6|2|8|5
# 1|7|9|6|5|8|3|2|4
# 2|6|5|4|3|1|7|9|8
# 4|8|3|9|2|7|1|5|6

module Sudoku
  module Field
    class Generator
      def initialize
        @board = Sudoku::Field::Board.new
      end

      attr_reader :board

      def generate
        reset_number_on_board
      end

      def display
        Sudoku::Field::Display.new(@board).display
      end

      def display!
        puts Sudoku::Field::Display.new(@board).display
      end

      private
        def reset_number_on_board
          @board.cells.each {|cell| cell.number = nil }

          @board.cells.each do |cell|
            number = @board.return_valid_number(cell.point)
            cell.number = number
          end

          numbers = @board.cells.map {|cell| cell.number}
          unless numbers.uniq.include?(nil)
            puts "Done with it!"
            return self
          end
          reset_number_on_board 
        end
    end

    class Display
      def initialize(board)
        @board = board
      end

      def display
        lines = (1..9).to_a.map {|num| @board.fetch_cells_of_same_y_line(Sudoku::Field::Point.new(1, num)) }
        lines.map { |line|
          line.map {|cell| cell.number }.join("|")
        }.join("\n")
      end
    end

    class Board
      def initialize
        @blocks = block_points.map {|point| Sudoku::Field::Block.new(point) }
      end

      def cells #tested #TODO: delegation
        @blocks.map {|block| block.cells }.flatten
      end

      def blocks
        @blocks
      end

      def fetch_cell(point) #tested
        self.cells.find {|cell| cell.point.equals? point }
      end

      # Usage
      # board.fetch_cells_of_same_x_line(Sudoku::Field::Point.new(2,1))
      def fetch_cells_of_same_x_line(point) #tested
        self.cells.select {|cell| cell.same_x_line?(point) }
      end

      # Usage
      # board.fetch_cells_of_same_y_line(Sudoku::Field::Point.new(2,1))
      def fetch_cells_of_same_y_line(point) #tested
        self.cells.select {|cell| cell.same_y_line?(point) }
      end

      # Usage
      # board.fetch_cells_of_same_block(Sudoku::Field::Point.new(2,1))
      def fetch_cells_of_same_block(point) #tested
        block = fetch_block_which_has(point)
        block.cells if block
      end

      # return Int or nil
      def return_valid_number(point)
        valid_numbers = fetch_valid_numbers(point)
        random_index = rand(valid_numbers.length)
        return valid_numbers[random_index]
      end

      private
        def fetch_block_which_has(point) #NEED to test. Important!
          self.blocks.find {|block| block.has_point?(point) }
        end

        NUMBERS = (1..9).to_a.freeze
        def fetch_valid_numbers(point) #NEED to test. Important!
          same_x_numbers = fetch_cells_of_same_x_line(point).map {|cell| cell.number }
          same_y_numbers = fetch_cells_of_same_y_line(point).map {|cell| cell.number }
          same_block_numbers = fetch_cells_of_same_block(point).map {|cell| cell.number }
          invalid_numbers = [same_x_numbers, same_y_numbers, same_block_numbers].flatten.compact.uniq
          valid_numbers = NUMBERS.select {|number| !invalid_numbers.include?(number) }
        end

        def block_points
          [ Sudoku::Field::Point.new(1,1), Sudoku::Field::Point.new(1,4), Sudoku::Field::Point.new(1,7),
            Sudoku::Field::Point.new(4,1), Sudoku::Field::Point.new(4,4), Sudoku::Field::Point.new(4,7),
            Sudoku::Field::Point.new(7,1), Sudoku::Field::Point.new(7,4), Sudoku::Field::Point.new(7,7),
          ]
        end

        def validate_axis(axis)
          raise StandardError.new("Invalid Axis: #{axis}") unless [:x, :y].include?(axis)
        end
    end

    # 9マスのBlock
    class Block
      def initialize(point)
        @base_point = point
        @cells = x_range.map {|x| #TODO: Need to refactor doubled loop.
                    y_range.map {|y|
                      point = @base_point.move_to(x, y)
                      Cell.new(point)
                    }
                }.flatten
      end

      attr_reader :cells, :base_point

      def has_point?(target_point) #tested
        cells.any? {|cell| cell.point.equals?(target_point) }
      end

      private 
        BLOCK_RANGE = (0..2).freeze
        def x_range
          BLOCK_RANGE.to_a
        end

        def y_range
          BLOCK_RANGE.to_a
        end
    end

    # 各Cell
    class Cell
      def initialize(point)
        @point = point
        @number = nil
      end

      attr_reader :point
      attr_accessor :number

      def same_x_line?(target_point) #tested
        self.point.x == target_point.x
      end

      def same_y_line?(target_point) #tested
        self.point.y == target_point.y
      end
    end

    # 座標を表すValueObject
    class Point
      def initialize(x, y)
        validate_point_range(x, y)
        @x = x
        @y = y
      end

      POINT_RANGE = (1..9).to_a

      attr_reader :x, :y

      def equals?(point) #tested
        self.x == point.x && self.y == point.y
      end

      def move_to(x, y) #tested
        self.class.new(@x + x, @y + y)
      end

      private
        def validate_point_range(x, y)
          raise ArgumentError.new("Invalid point range: (#{x}, #{y}). Valid Range is #{POINT_RANGE}") unless POINT_RANGE.include?(x)
          raise ArgumentError.new("Invalid point range: (#{x}, #{y}). Valid Range is #{POINT_RANGE}") unless POINT_RANGE.include?(y)
          return
        end
    end
  end
end

