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
    @methods ||= {}

    mod.constants.each do |constant|
      @constants[constant] = ToCC.const_get(constant)
    end

    mod.public_instance_methods.each do |method|
      method_file, method_line = mod.instance_method(method).source_location
      file_text = File.read(method_file)
      method_text = []
      line_number = 0
      file_text.each_line do |line|
        # Skip everything before the first line of the actual method definition.
        line_number += 1
        next if line_number <= method_line
        break if line =~ /end/
        method_text.push line.strip
      end
      puts method_text
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
  end
end

rusche = Rusche.new
rusche.main
