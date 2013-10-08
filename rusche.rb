require 'ruby_parser'

class Rusche
  def bail(msg)
    puts msg
    exit
  end

  def defn(nodes)
    #bail("Not a function call.") if nodes[0] == :lit
    return nodes unless nodes.is_a?(Array)
    text = ""
    for i in 0..nodes.length
      node = nodes[i]
      if node.is_a?(Array)
        text += "(#{defn(node)})"
      elsif node == :const || node == :lit
        text += "#{nodes[i+1]}"
      elsif node == :* || node == :== || node == :+ || node == :- || node == :< || node == :> || node == :<= || node == :>=
        text += node.to_s
      end
    end
    text
  end

  def append_cdecl(nodes)
    #bail("Constants must be literals, for now.") if nodes[2][0] != :lit
    @text += "(define #{nodes[1]} (#{nodes[2][0] == :lit ? nodes[2][1] : defn(nodes[2])}))\n"
  end

  def append_defn(nodes)
    @text += "ohai"
  end

  def reflect_nodes(nodes)
    for i in 0..nodes.length
      node = nodes[i]
      if node == :cdecl
        append_cdecl(nodes.slice(i, 3))
      elsif node == :defn
        append_defn(nodes.slice(i, nodes.length - i))
      elsif node.is_a?(Array)
        reflect_nodes(node)
      end
    end
  end

  def reflect_on_file(file)
    @text = ""

    parsed = RubyParser.new.parse(File.read(file))
    bail("Invalid format. You must provide a module only.") if parsed[0] != :module

    puts parsed.inspect

    reflect_nodes(parsed)
    puts @text
    parsed
  end

  def main
    reflect_on_file('test.rb')
  end
end

rusche = Rusche.new
rusche.main
