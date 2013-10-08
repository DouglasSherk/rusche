module ToCC
  def how_is_arr_formed
    [].push(1).push(2)
  end

  def check_empty
    if [].empty?
      5
    else
      2
    end
  end
end
