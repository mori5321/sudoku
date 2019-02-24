require "minitest/autorun"
require "./sudoku"

require "minitest/reporters"
Minitest::Reporters.use!

class BoardTest < Minitest::Test
  def setup
    @board = Sudoku::Field::Board.new
  end

  def test_board_has_9_blocks
    assert_equal @board.blocks.length, 9
    assert_equal @board.blocks.map {|block| block.class }.uniq, [Sudoku::Field::Block]
  end

  def test_board_can_fetch_cell
    point = Sudoku::Field::Point.new(1,1)
    assert_equal @board.fetch_cell(point).class, Sudoku::Field::Cell
    assert @board.fetch_cell(point).point.equals?(point)
  end

  def test_board_can_fetch_cells_of_same_x_line
    point = Sudoku::Field::Point.new(1,1)
    cells = @board.fetch_cells_of_same_x_line(point)
    unique_cell_x = cells.map {|cell| cell.point.x }.uniq
    assert_equal unique_cell_x, [point.x]
  end

  def test_board_can_fetch_cells_of_same_y_line
    point = Sudoku::Field::Point.new(1,2)
    cells = @board.fetch_cells_of_same_y_line(point)
    unique_cell_y = cells.map {|cell| cell.point.y }.uniq
    assert_equal unique_cell_y, [point.y]
  end

  def test_fetch_cells_of_same_block
    point = Sudoku::Field::Point.new(1,2)
    cells = @board.fetch_cells_of_same_block(point)
    target_block = @board.send(:fetch_block_which_has, point)
    cells.each do |cell|
      assert target_block.has_point?(cell.point)
    end
  end
end

class BlockTest < Minitest::Test
  def setup
    @point = Sudoku::Field::Point.new(1,1)
    @block = Sudoku::Field::Block.new(@point)
  end

  def test_block_has_base_point_1_1
    assert_equal @block.base_point, @point
  end

  def test_block_has_9_cells
    assert_equal @block.cells.length, 9
    assert_equal @block.cells.map {|cell| cell.class }.uniq, [Sudoku::Field::Cell]
  end

  def test_has_point?
    points_in_range = [Sudoku::Field::Point.new(1,1), Sudoku::Field::Point.new(2,2), Sudoku::Field::Point.new(3,3)]
    points_out_of_range = [Sudoku::Field::Point.new(1,4), Sudoku::Field::Point.new(4,1), Sudoku::Field::Point.new(3,4), Sudoku::Field::Point.new(4,3)]
    points_in_range.each {|point|
      assert @block.has_point?(point)
    }
    points_out_of_range.each {|point|
      refute @block.has_point?(point)
    }
  end
end


class CellTest < Minitest::Test
  def setup
    @point = Sudoku::Field::Point.new(1,1)
    @cell = Sudoku::Field::Cell.new(@point)
  end

  def test_same_x_line?
    point_with_same_x = Sudoku::Field::Point.new(1,2)
    point_with_different_x = Sudoku::Field::Point.new(2,1)
    assert @cell.same_x_line?(point_with_same_x)
    refute @cell.same_x_line?(point_with_different_x)
  end

  def test_same_y_line?
    point_with_same_y = Sudoku::Field::Point.new(2,1)
    point_with_different_y = Sudoku::Field::Point.new(1,2)
    assert @cell.same_y_line?(point_with_same_y)
    refute @cell.same_y_line?(point_with_different_y)
  end
end

class PointTest < Minitest::Test
  def setup
    @point = Sudoku::Field::Point.new(1,1)
  end
  
  def test_equals?
    assert @point.equals?(Sudoku::Field::Point.new(1,1))
    refute @point.equals?(Sudoku::Field::Point.new(1,2))
    refute @point.equals?(Sudoku::Field::Point.new(2,1))
  end

  def test_move_to
    assert @point.move_to(1,1).equals? Sudoku::Field::Point.new(2,2)
    assert @point.move_to(2,2).equals? Sudoku::Field::Point.new(3,3)
    refute @point.move_to(2,2).equals? Sudoku::Field::Point.new(3,1)
    refute @point.move_to(1,1).equals? Sudoku::Field::Point.new(1,2)
  end
end