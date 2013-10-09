module ToCC
  SOME_CONST = 5
  MY_CONSTANT = (SOME_CONST * (3 - SOME_CONST)) / 72

  def testme
    sleep
  end

  def othertest(myp)
    ham(MY_CONSTANT, sandwich(SOME_CONST, myp))
  end

  def test
    if a > 3
      1
    elsif b < 2
      2
    else
      3
    end
  end

  def dat_shit_cray
    if ((5 && 2 && 3) || 7) && !9
      8
    else
      5
    end
  end
end
