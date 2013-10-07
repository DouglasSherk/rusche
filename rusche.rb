module ToCC
  SOME_CONST = 5
  SOME_OTHER_CONST = 5

  def public_function
    puts "hello world"
  end
end

class Rusche
  def reflect_on_module(mod)
    @constants ||= {}
    mod.constants.each do |constant|
      @constants[constant] = ToCC.const_get(constant)
    end
  end

  def generate_scheme
    code = ""
    @constants.each do |constant, val|
      code += "(define #{constant} (#{val}))\n"
    end
    puts code
  end

  def main
    reflect_on_module(ToCC)
    generate_scheme
    #ToCC.public_instance_methods.each do |method|
    #  ToCC.send(method)
    #end
  end
end

rusche = Rusche.new
rusche.main
