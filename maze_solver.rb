require 'byebug'
require_relative 'node'

class Solver

  def initialize
    @maze = get_maze_from_file
    @starting_node = Node.new(start_coords, nil, heuristic(start_coords))
    @nodes_to_check = []
    @nodes_checked = []
    @current_node = set_current_node
  end
  

  def run
    print_maze
    @nodes_to_check << @starting_node
    search_path
    draw_path
    print_maze
  end


  def search_path
    if @nodes_checked.length == 0 
      set_current_node
      move_current_to_checked
    end
    while @nodes_checked.none? {|n| n.coords == finish_coords}
      check_nodes_adjacent_to_current
      set_current_node
      move_current_to_checked
    end
  end

  def draw_path
    previous_node_coords = @current_node.parent_coords
    step_count = 0
    while previous_node_coords != @starting_node.coords
      step_count += 1
      @maze[previous_node_coords[0]][previous_node_coords[1]] = "X"
      previous_node_coords = backtrack_path(previous_node_coords)
    end
    puts
    puts "Path length = #{step_count}"
  end

  def backtrack_path(previous_node_coords)
    @nodes_checked.each do |n|
      if  n.coords == previous_node_coords
        previous_node_coords = n.parent_coords 
      end
    end
    previous_node_coords
  end


  def set_current_node
    current = @nodes_to_check.first
    @nodes_to_check.each do |node|
      current = node if node.final_score <= current.final_score
    end
    @current_node = current
  end


  def move_current_to_checked
    @nodes_checked.push(@nodes_to_check.delete(@current_node)) if @nodes_to_check.length > 0
  end


  def check_nodes_adjacent_to_current
    adjacent_coords = get_adjacent_coords(@current_node)
    adjacent_coords.each do |coords|
      if valid_step?(coords)
        if @nodes_to_check.none? {|n| n.coords == coords}
          @nodes_to_check << make_node(coords)
        else
          parent_switch(coords)
        end
      end
    end
  end

  def get_adjacent_coords(node)
    coords_arr = []
    (-1..1).each do |i|
      (-1..1).each do |j|
        coords_arr << [node.coords[0] + i, node.coords[1] + j] if !(i == 0 && j == 0)
      end
    end
    coords_arr
  end

  def make_node(coords)
    node = Node.new(coords, @current_node, heuristic(coords))
  end

  def parent_switch(coords)
    node = @nodes_to_check.select {|n| n.coords == coords}.first
    if node.get_step(@current_node.coords, @current_node.step_score) < node.step_score
      node.parent_coords = @current_node.coords
      node.parent_step_score = @current_node.step_score
    end
  end

  def valid_step?(pos)
    return false if @maze[pos[0]][pos[1]] !=  " " &&  @maze[pos[0]][pos[1]] != "E" 
    @nodes_checked.each do |n|
      if n.coords == pos
        return false
      end
    end
    true
  end


  def get_maze_from_file
    puts "Enter maze file name: "
    maze = []
    maze_file = gets.chomp
    File.open(maze_file).each_line.with_index do |l, i|
      maze << l.chomp.split("")
    end
    maze
  end


  def start_coords
    coords_s = []
    @maze.each_with_index do |ele, idx|
      ele.each_with_index do |e, i|
        if e == "S"
          coords_s << idx
          coords_s << i
        end
      end
    end 
    coords_s
  end


  def finish_coords
    coords_e = []
    @maze.each_with_index do |ele, idx|
      ele.each_with_index do |e, i|
        if e == "E"
          coords_e << idx
          coords_e << i
        end
      end
    end 
    coords_e
  end


  def heuristic(coords)
    target = finish_coords
    x_coords = [coords[0], target[0]].sort
    x_distance = x_coords[1] - x_coords[0]
    y_coords = [coords[1], target[1]].sort
    y_distance = y_coords[1] - y_coords[0]      
    (x_distance + y_distance - 1) * 10
  end


  def print_maze
    @maze.each_with_index {|l, i| puts @maze[i].join("")}
  end

end



if __FILE__ == $PROGRAM_NAME
  s = Solver.new
  s.run
end
