require "chunky_png"

def add_vec(a, b)
	a.zip(b).map{|m,n|m+n}
end
def sub_vec(a, b)
	a.zip(b).map{|m,n|m-n}
end
def mul_vec(a, f)
	a.map{|m|m*f}
end
def div_vec(a, f)
	mul_vec(a,1.0/f)
end
def dot_vec(a, b)
	a.zip(b).map{|m,n|m*n}.sum
end
def abs(a)
	dot_vec(a,a)
end
def norm(a)
	div_vec(a,Math.sqrt(abs(a)))
end

class Sphere
	attr_reader :center, :radius, :color_vec, :reflect
	def initialize(center, radius, color_vec, reflect)
		@center = center
		@radius = radius
		@color_vec = color_vec
		@reflect = reflect
	end
	
	def intersect(ray_orig, ray_dir)
		l = sub_vec(center, ray_orig)
		tca = dot_vec(l, ray_dir)
		return 1e8 if tca < 0
		d2 = abs(l) - tca ** 2
		return 1e8 if d2 > radius ** 2
		thc = Math.sqrt(radius ** 2 - d2)
		return [tca - thc, tca + thc].min
	end
	def color(intersect)
		color_vec
	end
end

class CheckeredSphere < Sphere
	def color(intersect)
		checker = (intersect[0].floor % 2) == (intersect[2].floor % 2)
		mul_vec(color_vec, checker ? 1 : 0)
	end
end

def raytrace(ray_orig, ray_dir, world, depth = 0)
	
	nearest_obj, min_dist = world.to_h{|s| [s, s.intersect(ray_orig, ray_dir)]}.min_by{|k,v| v}
	
	return [0.5]*3 if min_dist >= 1e8
	
	intersect = add_vec(ray_orig, mul_vec(ray_dir, min_dist))
	normal = norm(div_vec(sub_vec(intersect, nearest_obj.center), nearest_obj.radius))
	
	color = [0.05]*3
	
	light_pos = [0, 20, 10]
	
	light_dir = norm(sub_vec(light_pos, intersect))
	origin_dir = norm(sub_vec([0]*3, intersect))
	
	offset = add_vec(intersect, mul_vec(normal, 1e-4))
	
	light_distances = world.map { |obj| obj.intersect(offset, light_dir) }
	light_visible = light_distances[world.index(nearest_obj)] == light_distances.min
	
	lv = [0, dot_vec(normal, light_dir)].max
	color = add_vec(color, mul_vec(nearest_obj.color(intersect), lv)) if light_visible
	
	if nearest_obj.reflect > 0 && depth < 5
		reflect_ray_dir = norm(sub_vec(ray_dir, mul_vec(normal, 2 * dot_vec(ray_dir, normal))))
		color = add_vec(color, mul_vec(raytrace(offset, reflect_ray_dir, world, depth + 1), nearest_obj.reflect))
	end
	
	phong = dot_vec(normal, norm(add_vec(light_dir, origin_dir)))
	color = add_vec(color, mul_vec([1]*3, phong.clamp(0, 1) ** 50)) if light_visible
	
	return color
end

def render(world)
	image = ChunkyPNG::Image.new(640, 480)
	
	aspect_ratio = 4/3.0
	angle = 0.2679491924311227
	
	0.upto(479) do |row|
		0.upto(639) do |col|
			x = (2 * ((col + 0.5) * (1.0 / 640)) - 1) * angle * aspect_ratio
			y = (1 - 2 * ((row + 0.5) * (1.0 / 480))) * angle
			
			color = raytrace([0]*3, norm([x, y, 1.0]), world)
			image[col, row] = ChunkyPNG::Color.rgb(*color.map{|c| (c.clamp(0, 1) * 255).to_i})
		end
	end
	
	image.save('out.png')
end

world = [
	CheckeredSphere.new([0, -10004, 20], 10000, [0.25]*3, 0.2),
	Sphere.new([0, 0, 20], 4, [1, 0, 0], 0.2),
	Sphere.new([6, -1, 20], 2, [0, 0, 1], 0.2),
]

render(world)