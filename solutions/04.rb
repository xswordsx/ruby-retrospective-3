class Asm
  attr_reader :operations, :labels
  [:ax, :bx, :cx, :dx].each {|x| define_method x do x.to_s end}
  @@methods = %w(mov inc dec cmp jmp je jne jl jle jg jge)
  def initialize
    @line = -1
    @labels = {}
    @operations = []
  end

  def label(name)
    @labels[name.to_s] = @line + 1
  end

  def method_missing(name, *args)
    if @@methods.include? name.to_s
      @labels[@line += 1] = @line
      @operations << [name, *args]
    else
      name.to_s
    end
  end

  class Jumper

    def initialize(evaluator)
      @evaluator = evaluator
    end
    operations = {
      e: :==,
      ne: '!=',
      l: :<,
      le: :<=,
      g: :>,
      ge: :>=
    }
    def jmp(label, _)
      @evaluator.execute_operations @evaluator.labels[label]
    end

    operations.each do |name, symbol|
      define_method 'j' + name.to_s do |label, current_line|
        jump_with_compare(label, current_line, symbol)
      end
    end

    private
    def jump_with_compare(label, current_line, symbol)
      if @evaluator.last_cmp.send(symbol, 0)
        @evaluator.execute_operations(@evaluator.labels[label])
      else
        @evaluator.execute_operations current_line + 1
      end
    end
  end

  class Evaluator
    attr_accessor :ax, :bx, :cx, :dx, :last_cmp, :labels
    @@jumps = %w(jmp je jne jl jle jg jge)

    def initialize(operations, labels)
      @ax, @bx, @cx, @dx = 0, 0, 0, 0
      @operations = operations
      @operations << [:cmp, 0, 0]
      @last_cmp = 0
      @line_number = -1
      @labels = labels
      @jumper = Jumper.new self
    end

    def mov(register, source)
      send "#{register}=", value_of(source)
    end

    def inc(register, source = 1)
      send "#{register}=", value_of(register) + value_of(source)
    end

    def dec(register, source = 1)
      inc register, -value_of(source)
    end

    def cmp(register, source)
      @last_cmp = value_of(register) <=> value_of(source)
    end

    def execute_operations(from_line = 0)

      @operations[from_line..-1].each_with_index do |command, index|
        if @@jumps.include? command[0].to_s
          @jumper.send(command[0], *command[1..-1], index + from_line)
          break
        else
          send(command[0], *command[1..-1])
        end

      end

      return [@ax, @bx, @cx, @dx]
    end

    private

    def value_of(var)
      (var.class == Fixnum ? var : instance_variable_get("@#{var}"))
    end
  end

  def self.asm(&block)
    assembler = Asm.new
    assembler.instance_eval &block
    e = Evaluator.new assembler.operations, assembler.labels

    e.execute_operations
  end
end
