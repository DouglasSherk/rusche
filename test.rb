module ToCC
  SOME_CONST = 5
  MY_CONSTANT = (SOME_CONST * (3 - SOME_CONST)) / 72

  def testme
    sleep
  end

  def othertest(myp)
    ham(MY_CONSTANT, sandwich(SOME_CONST, myp))
  end
end
