require "chunky_png"

class Vec3
	attr_reader :x, :y, :z
	def initialize(x, y = x, z = x)
		@x, @y, @z = x, y, z
	end
	
	def +(vec)
		Vec3.new(x + vec.x, y + vec.y, z + vec.z)
	end
	def -@
		Vec3.new(-x, -y, -z)
	end
	def *(fac)
		Vec3.new(x * fac, y * fac, z * fac)
	end
	def /(fac)
		self * (1.0 / fac)
	end
	def abs
		dot(self)
	end
	def components
		[x, y, z]
	end
	def normalize
		self / Math.sqrt(abs)
	end
	def dot(vec)
		x * vec.x + y * vec.y + z * vec.z
	end
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
		dist = ray_orig + -center
		b = 2 * dist.dot(ray_dir)
		return 1e8 if b > 0
		c = dist.abs - radius ** 2
		disc = (b ** 2) - (4 * c)
		return 1e8 if disc < 0
		sq = Math.sqrt(disc)
		t0 = (-b - sq) / 2
		t1 = (-b + sq) / 2
		return t0 < t1 ? t0 : t1
	end
	def color(intersect)
		color_vec
	end
end

class CheckeredSphere < Sphere
	def color(intersect)
		checker = (intersect.x.floor % 2) == (intersect.z.floor % 2)
		color_vec * (checker ? 1 : 0)
	end
end

def raytrace(ray_orig, ray_dir, world, depth = 0)
	
	min_dist, nearest_obj = world.to_h{|s| [s.intersect(ray_orig, ray_dir), s]}.min_by{|k,v| k}
	
	return Vec3.new(0.5) if min_dist >= 1e8
	
	intersect = ray_orig + ray_dir * min_dist
	normal = ((intersect + -nearest_obj.center) / nearest_obj.radius).normalize
	
	color = Vec3.new(0.05)
	
	light_pos = Vec3.new(0, 20, 10)
	
	light_dir = (light_pos + -intersect).normalize
	origin_dir = (Vec3.new(0) + -intersect).normalize
	
	offset = intersect + normal * 1e-4
	
	light_distances = world.map { |obj| obj.intersect(offset, light_dir) }
	light_nearest = light_distances.min
	light_visible = light_distances[world.index(nearest_obj)] == light_nearest
	
	lv = [0, normal.dot(light_dir)].max
	color += nearest_obj.color(intersect) * lv if light_visible
	
	if nearest_obj.reflect > 0 && depth < 5
		reflect_ray_dir = (ray_dir + -normal * 2 * ray_dir.dot(normal)).normalize
		color += raytrace(offset, reflect_ray_dir, world, depth + 1) * nearest_obj.reflect
	end
	
	phong = normal.dot((light_dir + origin_dir).normalize)
	color += Vec3.new(1) * (phong.clamp(0, 1) ** 50) if light_visible
	
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
			
			ray_orig = Vec3.new(0)
			ray_dir = Vec3.new(x, y, 1).normalize
			
			color = raytrace(ray_orig, ray_dir, world)
			image[col, row] = ChunkyPNG::Color.rgb(*color.components.map{|c| (c.clamp(0, 1) * 255).to_i})
		end
	end
	
	image.save('out.png')
end

world = [
	CheckeredSphere.new(Vec3.new(0, -10004, 20), 10000, Vec3.new(0.25), 0.2),
	Sphere.new(Vec3.new(0, 0, 20), 4, Vec3.new(1, 0, 0), 0.2),
	Sphere.new(Vec3.new(6, -1, 20), 2, Vec3.new(0, 0, 1), 0.2),
]

render(world)