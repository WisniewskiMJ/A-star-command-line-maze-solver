class Node

  attr_reader :final_score, :coords, :step_score
  attr_accessor :parent_coords, :parent_step_score
  
  def initialize(coordinates, parent, h_score)
    @coords = coordinates
    @parent_coords = get_coords(parent)
    @parent_step_score = get_score(parent)
    @step_score = get_step(@parent_coords, @parent_step_score)
    @heuristic_score = h_score
    @final_score = get_final
  end

  def get_coords(parent)
    return nil if parent == nil
    parent.coords
  end

  def get_score(parent)   
    return nil if parent == nil
    parent.step_score
  end

  def get_step(prev_coords, prev_score)
    if prev_coords == nil
      0
    elsif prev_coords[0] != @coords[0] && prev_coords[1] != @coords[1]
      prev_score + 14
    else
      prev_score + 10
    end
  end

  def get_final
    @step_score + @heuristic_score
  end

end
