module Graphics

  class Canvas
    attr_reader :width, :height

    def initialize(width, height)
      @width = width.to_i
      @height = height.to_i
      @canvas = [[false] * width] * height
    end

    def set_pixel(x, y)
      @canvas[x] = @canvas[x].each_with_index.map {|elem, ind| y == ind ? true : elem}
    end

    def pixel_at?(x, y)
      @canvas[x][y]
    end

    def draw(shape)
      shape.draw_on self
    end

    def to_s
      @canvas.each {|x| puts x.join(' ')}
    end

    def render_as(render_engine)
      render_engine.render @canvas
    end
  end

  class Point
    attr_reader :x, :y

    def min_x(other)
      return @x < other.x ? self : other
    end

    def min_y(other)
      return @y < other.y ? self : other
    end

  def max_x(other)
      return @x > other.x ? self : other
    end

    def max_y(other)
      return @y > other.y ? self : other
    end

    def initialize(x, y)
      @x = x.to_i
      @y = y.to_i
    end

    def ==(other)
      return (other.x == @x and other.y == @y)
    end

    def eql?(other)
      return (self.inspect == other.inspect)
    end

    def draw_on(canvas)
      canvas.set_pixel(@x, @y)
    end
  end

  class Line
    attr_reader :from, :to

    def initialize(from, to)
        @from = from.freeze
        @to = to.freeze
    end

    def ==(other)
      return [@from, @to] - [other.from, other.to] == []
    end

    def eql?(other)
      return self.inspect == other.inspect
    end

    def draw_on(canvas)
    end

    def straight?
      return (@from.x == @to.x or @from.y == @to.y)
    end
  end

  class Rectangle
    attr_reader :left, :right
    def initialize(point_1, point_2)
      @left = point_1.min_x point_2
      @right = point_1.max_y point_2
    end

    def draw_on(canvas)
    end

    def eql?(other)
      return self.inspect == other.inspect
    end

    def ==(other)
      return [@left, @right] - [other.left, other.right] == 0
    end
  end

  module Renderers
    HEAD_HTML = %w(
      <!DOCTYPE html>
      <html>
      <head>
        <title>Rendered Canvas</title>
        <style type="text/css">
          .canvas {
            font-size: 1px;
            line-height: 1px;
          }
          .canvas * {
            display: inline-block;
            width: 10px;
            height: 10px;
            border-radius: 5px;
          }
          .canvas i {
            background-color: #eee;
          }
          .canvas b {
            background-color: #333;
          }
        </style>
      </head>
      <body>
        <div class="canvas">
    ).freeze
    END_HTML = %w(
      </div>
     </body>
     </html>).freeze

    class BasicRenderer

      def BasicRenderer.render_row(row, yes, no)
        row.map {|x| x ? yes : no}
      end

      def BasicRenderer.render(canvas, start='', yes='#', no='@', newline="\n", post='')
        result = start.dup
        canvas.each do |row|
          result << render_row(row, yes, no).join('')
          result << newline
        end
        result << post
        result
      end
    end

    class Html < BasicRenderer
      @@begin, @@true, @@false, @@newline, @@end =
      HEAD_HTML, "<b></b>", "<i></i>", "<br />", END_HTML
      def Html.render(canvas)
        BasicRenderer.render canvas, @@begin, @@true, @@false, @@newline, @@end
      end
    end

    class Ascii < BasicRenderer
      @@begin, @@true, @@false, @@newline, @@end = '', '@', '-', "\n", ''
      def Ascii.render(canvas)
        BasicRenderer.render canvas, @@begin, @@true, @@false, @@newline, @@end
      end
    end
  end
end
