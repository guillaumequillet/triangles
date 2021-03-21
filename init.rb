require 'gosu'

class Point
    attr_accessor :x, :y, :z
    def initialize(x = 0, y = 0, z = 0)
        @x, @y, @z = x, y, z
    end

    def draw(color = Gosu::Color::WHITE, size = 1)
        Gosu::draw_rect(@x - size / 2, @y - size / 2, size, size, color)
    end
end

class AABB
    def initialize(origin_point, size)
        @origin_point, @size = origin_point, size        
    end

    def includes_point?(point)
        ((point.x >= @origin_point.x && point.x <= @origin_point.x + @size.x) && (point.y >= @origin_point.y && point.y <= @origin_point.y + @size.y) && (point.z >= @origin_point.z && point.z <= @origin_point.z + @size.z))
    end

    def draw(color)
        Gosu::draw_rect(@origin_point.x, @origin_point.y, @size.x, @size.y, color)
    end
end

class Triangle
    def initialize(point_a = Point.new, point_b = Point.new, point_c = Point.new)
        @point_a, @point_b, @point_c = point_a, point_b, point_c

        min_x = [@point_a.x, @point_b.x, @point_c.x].min
        min_y = [@point_a.y, @point_b.y, @point_c.y].min
        min_z = [@point_a.z, @point_b.z, @point_c.z].min
        max_x = [@point_a.x, @point_b.x, @point_c.x].max
        max_y = [@point_a.y, @point_b.y, @point_c.y].max
        max_z = [@point_a.z, @point_b.z, @point_c.z].max

        @aabb = AABB.new(Point.new(min_x, min_y, min_z), Point.new(max_x - min_x, max_y - min_y, max_z - min_z))
        @font = Gosu::Font.new(24)
        calculate_plane
    end

    def calculate_plane
        # https://keisan.casio.com/exec/system/1223596129
        @a = (@point_b.y - @point_a.y) * (@point_c.z - @point_a.z) - (@point_c.y - @point_a.y) * (@point_b.z - @point_a.z)
        @b = (@point_b.z - @point_a.z) * (@point_c.x - @point_a.x) - (@point_c.z - @point_a.z) * (@point_b.x - @point_a.x)
        @c = (@point_b.x - @point_a.x) * (@point_c.y - @point_a.y) - (@point_c.x - @point_a.x) * (@point_b.y - @point_a.y)
        @d = -(@a * @point_a.x + @b * @point_a.y + @c * @point_a.z)
        p [@a, @b, @c, @d]
    end

    def draw(color = Gosu::Color::WHITE)
        @aabb.draw(Gosu::Color.new(128, 255, 0, 255))
        Gosu::draw_line(@point_a.x, @point_a.y, color, @point_b.x, @point_b.y, color)
        Gosu::draw_line(@point_b.x, @point_b.y, color, @point_c.x, @point_c.y, color)
        Gosu::draw_line(@point_c.x, @point_c.y, color, @point_a.x, @point_a.y, color)

        @font.draw_text('A', @point_a.x, @point_a.y, 1, 1, 1, Gosu::Color::GREEN)
        @font.draw_text('B', @point_b.x, @point_b.y, 1, 1, 1, Gosu::Color::GREEN)
        @font.draw_text('C', @point_c.x, @point_c.y, 1, 1, 1, Gosu::Color::GREEN)
    end

    def includes_point?(point)
        if @aabb.includes_point?(point)
            # https://www.youtube.com/watch?v=HYAgJN3x4GA&ab_channel=SebastianLague
            # https://gamedev.stackexchange.com/questions/47601/how-to-get-the-height-at-a-position-in-a-triangle
            # https://codeplea.com/triangular-interpolation
            w1_num = @point_a.x * (@point_c.y - @point_a.y) + (point.y - @point_a.y) * (@point_c.x - @point_a.x) - point.x * (@point_c.y - @point_a.y)
            w1_den = (@point_b.y - @point_a.y) * (@point_c.x - @point_a.x) - (@point_b.x - @point_a.x) * (@point_c.y - @point_a.y)
            w1 = w1_num.to_f / w1_den
            w2 = (point.y - @point_a.y - w1 * (@point_b.y - @point_a.y)).to_f / (@point_c.y - @point_a.y)
            return ((w1 >= 0) && (w2 >= 0) && (w1 + w2 <=1))
        end
        return false
    end

    def point_height(point)
        # ax + by + cz + d = 0
        (-@a * point.x - @c * point.z - @d) / @b
    end
end

class Window < Gosu::Window
    def initialize
        super(640, 480, false)
        temp = Triangle.new(
            Point.new(-1.04815, 1.40384, 0.13339),
            Point.new(0.30614, -1, -1),
            Point.new(0.96254, 1, -1)
        )
        p temp.point_height(Point.new(-0.14821, 0, -0.47791))
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
