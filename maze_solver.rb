require 'byebug'
require_relative 'node'

class Solver

  attr_reader :maze

  def initialize
    @maze = self.get_maze
    @start = Node.new(self.start_coords, nil, heuristic(self.start_coords))
    @open_list = []
    @closed_list = []
    @current_node = self.set_current
  end
  

  def run
    # debugger
    #print maze
    self.p_maze
    #add starting point to open list
    @open_list << @start
    # perform search loop
    self.search
    # draw path
    self.draw_path
    puts "closed = #{@closed_list.length}"
    puts "open = #{@open_list.length}"
    self.p_maze
  end


  def search
    if @closed_list.length == 0 
      self.set_current
      self.move_current
    end
    while @closed_list.none? {|n| n.coords == self.finish_coords}
      #check nodes adjacent to current node
      self.check_adjacent
      #set current node (least costly)
      self.set_current
      #move current node to closed list
      self.move_current
    end
  end

  def draw_path
    # debugger
    target = @current_node.parent_coords
    count = 0
    while target != @start.coords
      count +=1
      @maze[target[0]][target[1]] = "X"
      target = self.backtrack_current(target)
    end
    puts "length = #{count}"
  end

  def backtrack_current(target)
    @closed_list.each do |n|
      if  n.coords == target
        target = n.parent_coords 
      end
    end
    target
  end


  def set_current
    current = @open_list[0]
    @open_list.each do |node|
      current = node if node.final_score <= current.final_score
    end
    @current_node = current
  end


  def move_current
    @closed_list.push(@open_list.delete(@current_node)) if @open_list.length > 0
  end


  def check_adjacent
    adjacent_coords = get_adjacent_coords(@current_node)
    adjacent_coords.each do |coords|
      if valid_step?(coords)
        if @open_list.none? {|n| n.coords == coords}
          @open_list << make_node(coords)
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
    node = @open_list.select {|n| n.coords == coords}.first
    if node.get_step(@current_node.coords, @current_node.step_score) < node.step_score
      node.parent_coords = @current_node.coords
      node.parent_step_score = @current_node.step_score
    end
  end

  def valid_step?(pos)
    #valid coordinates (but there if a wall around the maze)
    #clean path
    return false if @maze[pos[0]][pos[1]] !=  " " &&  @maze[pos[0]][pos[1]] != "E" 
    #no other node
    @closed_list.each do |n|
      if n.coords == pos
        return false
      end
    end
    true
  end


  def get_maze
    maze = []
    maze_file = gets.chomp
    File.open(maze_file).each_line.with_index do |l, i|
    # File.open('m.txt').each_line.with_index do |l, i|
      # maze << []
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


  def heuristic(first)
    last = self.finish_coords
    xs = [first[0], last[0]].sort!
    x = xs[1] - xs[0]
    ys = [first[1], last[1]].sort!
    y = ys[1] - ys[0]      
    (x + y - 1) * 10
  end


  def p_maze
    @maze.each_with_index {|l, i| puts @maze[i].join("")}
  end

end



if __FILE__ == $PROGRAM_NAME
  s = Solver.new
  s.run
end
