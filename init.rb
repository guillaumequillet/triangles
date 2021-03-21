require 'gosu'

class Point
    attr_accessor :x, :y, :z
    def initialize(x = 0, y = 0, z = 0)
        @x, @y, @z = x, y, z
    end

    def draw(color = Gosu::Color::WHITE, size = 1)
        Gosu::draw_rect(@x, @y, size, size, color)
    end
end

class Triangle
    def initialize(point_a = Point.new, point_b = Point.new, point_c = Point.new)
        @point_a, @point_b, @point_c = point_a, point_b, point_c
        @font = Gosu::Font.new(24)
    end

    def draw(color = Gosu::Color::WHITE)
        Gosu::draw_line(@point_a.x, @point_a.y, color, @point_b.x, @point_b.y, color)
        Gosu::draw_line(@point_b.x, @point_b.y, color, @point_c.x, @point_c.y, color)
        Gosu::draw_line(@point_c.x, @point_c.y, color, @point_a.x, @point_a.y, color)

        @font.draw_text('A', @point_a.x, @point_a.y, 1, 1, 1, Gosu::Color::GREEN)
        @font.draw_text('B', @point_b.x, @point_b.y, 1, 1, 1, Gosu::Color::GREEN)
        @font.draw_text('C', @point_c.x, @point_c.y, 1, 1, 1, Gosu::Color::GREEN)
    end

    def includes_point?(point)
        # https://www.youtube.com/watch?v=HYAgJN3x4GA&ab_channel=SebastianLague
        w1_num = @point_a.x * (@point_c.y - @point_a.y) + (point.y - @point_a.y) * (@point_c.x - @point_a.x) - point.x * (@point_c.y - @point_a.y)
        w1_den = (@point_b.y - @point_a.y) * (@point_c.x - @point_a.x) - (@point_b.x - @point_a.x) * (@point_c.y - @point_a.y)
        w1 = w1_num.to_f / w1_den
        w2 = (point.y - @point_a.y - w1 * (@point_b.y - @point_a.y)).to_f / (@point_c.y - @point_a.y)
        ((w1 >= 0) && (w2 >= 0) && (w1 + w2 <=1))
    end
end

class Window < Gosu::Window
    def initialize
        super(640, 480, false)
    end

    def button_down(id)
        super
        close! if id == Gosu::KB_ESCAPE

        generate_triangle if id == Gosu::KB_SPACE
    end

    def needs_cursor?; false; end

    def generate_triangle
        a = Point.new(Gosu::random(0, self.width), Gosu::random(0, self.height))
        b = Point.new(Gosu::random(0, self.width), Gosu::random(0, self.height))
        c = Point.new(Gosu::random(0, self.width), Gosu::random(0, self.height))
        @triangle = Triangle.new(a, b, c)
    end

    def update
        @cursor ||= Point.new(self.mouse_x, self.mouse_y)
        @cursor.x = self.mouse_x
        @cursor.y = self.mouse_y
    end

    def draw
        generate_triangle unless defined?(@triangle) 
        @triangle.draw
        color = @triangle.includes_point?(@cursor) ? Gosu::Color::RED : Gosu::Color::WHITE
        @cursor.draw(color, 4)
    end
end

Window.new.show
