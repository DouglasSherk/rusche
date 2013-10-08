require 'ruby_parser'

class Rusche
  def bail(msg)
    puts msg
    exit
  end

  def block_out
    @indent -= 1
  end

  def block_in
    @indent += 1
  end

  def indent
    text = ""
    for i in 1..@indent
      text += "  "
    end
    text
  end

  def convert_operator(node)
    case node
    when :==
      # Bug with Ruby? I can't use |:=| here for some reason.
      "="
    else
      node
    end
  end

  def is_operator(node)
    node == :+ || node == :- || node == :* || node == :/ || node == :== || node == :< || node == :<= || node == :> || node == :>=
  end

  def defn(nodes)
    return nodes unless nodes.is_a?(Array)

    text = ""

    for i in 0..nodes.length
      node = nodes[i]

      def parseIf(nodes, i)
        text = ""
        text += "#{defn(nodes[i+1])} "
        text += "#{defn(nodes[i+2])}"
        text = "#{indent}[#{text}]\n"
        text
      end

      def get_args_from_nodes(nodes, i)
        args = []
        for j in i+1..nodes.length - 1
          next if nodes[j].nil?
          if nodes[j].is_a?(Array)
            args.push defn(nodes[j])
          else
            if is_operator(nodes[j])
              args.unshift convert_operator(nodes[j])
            else
              args.push nodes[j]
            end
          end
        end
        args
      end

      def special_case_cons_list(nodes, i)
        # Rearrange expression into the format Scheme wants.
        args = []
        args.push :cons
        args.push defn(nodes[i+3])
        args.push defn(nodes[i+1])
        args
      end

      def special_case_empty_list(nodes, i)
        args = []
        args.push :empty?
        args.push defn(nodes[i+1])
      end

      # This does weird behavior on |node|, be careful here.
      if node == :if
        text += "cond\n"
        block_in
        if_nodes = nodes
        if_node = node
        while if_node == :if
          text += parseIf(if_nodes, i)
          if_nodes = if_nodes[i+3]
          if_node = if_nodes[0]
          if !if_node.nil? && if_node != :if
            args = get_args_from_nodes(if_nodes, 0)
            text += "#{indent}[else (#{args * " "})]" unless args.empty?
          end
        end
        text = "(#{text})"
        block_out
        break
      end

      if node.is_a?(Array)
        text += "#{defn(node)}"
      elsif node == :and || node == :or
        args = get_args_from_nodes(nodes, i)
        args.unshift node
        text += "(#{args * " "})" unless args.empty?
        break
      elsif node == :const || node == :lit || node == :lvar
        text += "#{nodes[i+1]}"
      elsif node == :array
        args = get_args_from_nodes(nodes, i)
        text += args.length > 0 ? "'(#{args * " "})" : "empty"
        break
      elsif node == :call
        args =
          if nodes[i+2] == :push
            special_case_cons_list(nodes, i)
          elsif nodes[i+2] == :empty?
            special_case_empty_list(nodes, i)
          else
            get_args_from_nodes(nodes, i)
          end

        text += "(#{args * " "})" unless args.empty?
        break
      end
    end
    text
  end

  def append_cdecl(nodes)
    @text += "(define (#{nodes[1]} #{nodes[2][0] == :lit ? nodes[2][1] : defn(nodes[2])}))\n\n"
  end

  def append_defn(nodes)
    args = nodes[2] == s(:args) ? "" : " " + (nodes[2].slice(1, nodes[2].length - 1) * " ")
    block_in
    @text += "(define (#{nodes[1]}#{args})\n#{indent}#{defn(nodes[3])})\n\n"
    block_out
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
    @indent = 0

    parsed = RubyParser.new.parse(File.read(file))
    bail("Invalid format. You must provide a module only.") if parsed[0] != :module

    puts parsed.inspect

    reflect_nodes(parsed)
    puts @text
    parsed
  end

  def main
    reflect_on_file('list2.rb')
  end
end

rusche = Rusche.new
rusche.main
