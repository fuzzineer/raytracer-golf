
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
def intersect(sphere, ray_orig, ray_dir)
	l = sub_vec(sphere[0], ray_orig)
	tca = dot_vec(l, ray_dir)
	return 1e8 if tca < 0
	d2 = abs(l) - tca ** 2
	return 1e8 if d2 > sphere[1] ** 2
	thc = Math.sqrt(sphere[1] ** 2 - d2)
	[tca - thc, tca + thc].min
end
def color(sphere, intersect)
	(intersect[0].floor % 2) == (intersect[2].floor % 2) ? sphere[2] : sphere[3]
end

def raytrace(ray_orig, ray_dir, world, depth = 0)
	
	sphere, min_dist = world.to_h{|s| [s, intersect(s, ray_orig, ray_dir)]}.min_by{|k,v| v}
	
	return [0.5]*3 if min_dist >= 1e8
	
	intersect = add_vec(ray_orig, mul_vec(ray_dir, min_dist))
	normal = norm(div_vec(sub_vec(intersect, sphere[0]), sphere[1]))
	
	color = [0.05]*3
	
	light_pos = [0, 20, 10]
	
	light_dir = norm(sub_vec(light_pos, intersect))
	origin_dir = norm(sub_vec([0]*3, intersect))
	
	offset = add_vec(intersect, mul_vec(normal, 1e-4))
	
	light_distances = world.map {|s| intersect(s, offset, light_dir)}
	light_visible = light_distances[world.index(sphere)] == light_distances.min
	
	lv = [0, dot_vec(normal, light_dir)].max
	color = add_vec(color, mul_vec(color(sphere, intersect), lv)) if light_visible
	
	if sphere[4] > 0 && depth < 5
		reflect_ray_dir = norm(sub_vec(ray_dir, mul_vec(normal, 2 * dot_vec(ray_dir, normal))))
		color = add_vec(color, mul_vec(raytrace(offset, reflect_ray_dir, world, depth + 1), sphere[4]))
	end
	
	phong = dot_vec(normal, norm(add_vec(light_dir, origin_dir)))
	color = add_vec(color, mul_vec([1]*3, phong.clamp(0, 1) ** 50)) if light_visible
	
	color
end

world = [
	[[0, -10004, 20], 10000, [0.25]*3, [0]*3, 0.2],
	[[0, 0, 20], 4, [1, 0, 0], [1, 0, 0], 0.2],
	[[6, -1, 20], 2, [0, 0, 1], [0, 0, 1], 0.2],
]

aspect_ratio = 4/3.0
angle = 0.2679491924311227

puts "P3 640 480 255"

0.upto(479) do |row|
	0.upto(639) do |col|
		x = (2 * ((col + 0.5) / 640) - 1) * angle * aspect_ratio
		y = (1 - 2 * ((row + 0.5) / 480)) * angle
		
		raytrace([0]*3, norm([x, y, 1.0]), world).each{|c| $><<(c.clamp(0, 1) * 255).to_i<<" "}
	end
end