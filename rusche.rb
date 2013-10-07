require 'ruby_parser'

class Rusche
  def bail(msg)
    puts msg
    exit
  end

  def reflect_nodes(nodes)
    for i in 0..nodes.length
      node = nodes[i]
      if node == :cdecl
        bail("Constants must be literals, for now.") if nodes[i+2][0] != :lit
        @constants[nodes[i+1]] = nodes[i+2][1]
      elsif node == :defn
        @methods[nodes[i+1]] = {
          :args => nodes[i+2][0],
          :defn => nodes[i+3]
        }
      elsif node.is_a?(Array)
        reflect_nodes(node)
      end
    end
  end

  def reflect_on_file(file)
    @constants ||= {}
    @methods ||= {}

    parsed = RubyParser.new.parse(File.read(file))
    bail("Invalid format. You must provide a module only.") if parsed[0] != :module

    puts parsed.inspect

    reflect_nodes(parsed)
    parsed
  end

  def generate_scheme
    code = ""
    @constants.each do |constant, val|
      code += "(define #{constant} (#{val}))\n"
    end
    #puts code
    puts @methods
  end

  def main
    reflect_on_file('test.rb')
    generate_scheme
  end
end

rusche = Rusche.new
rusche.main
