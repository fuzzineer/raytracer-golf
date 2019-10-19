
class Array
	def +v
		zip(v).map{|a,b|a+b}
	end
	def -v
		zip(v).map{|a,b|a-b}
	end
	def *f
		map{|a|a*f}
	end
	def /f
		map{|m|m/f}
	end
	def %v
		zip(v).map{|a,b|a*b}.sum
	end
end

N=->v{
	v/Math.sqrt(v%v)
}
INTERSECT=->sphere,ray_orig,ray_dir{
	l=sphere[0]-ray_orig
	tca=l%ray_dir
	return 1e8 if tca<0
	d2=l%l-tca**2
	return 1e8 if d2>sphere[1]**2
	thc=Math.sqrt(sphere[1]**2-d2)
	[tca-thc,tca+thc].min
}

RAYTRACE=->ray_orig,ray_dir,world,depth{
	
	sphere,min_dist=world.to_h{|s|[s,INTERSECT[s,ray_orig,ray_dir]]}.min_by{|k,v|v}
	
	return [0.5,0.5,0.5] if min_dist>=1e8
	
	intersect=ray_orig+ray_dir*min_dist
	normal=N[(intersect-sphere[0])/sphere[1]]
	
	color=[0.05,0.05,0.05]
	
	light_pos=[0,20,10]
	
	light_dir=N[light_pos-intersect]
	origin_dir=N[[0,0,0]-intersect]
	
	offset=intersect+normal*1e-4
	
	light_distances=world.map{|s|INTERSECT[s,offset,light_dir]}
	light_visible=light_distances[world.index(sphere)]==light_distances.min
	
	lv=[0,normal%light_dir].max
	color+=((intersect[0].floor%2==intersect[2].floor%2)?sphere[2]:sphere[3])*lv if light_visible
	
	if sphere[4]>0&&depth<5
		reflect_ray_dir=N[ray_dir-normal*2*(ray_dir%normal)]
		color+=RAYTRACE[offset,reflect_ray_dir,world,depth+1]*sphere[4]
	end
	
	phong=normal%N[light_dir+origin_dir]
	color+=[1,1,1]*phong.clamp(0,1)**50 if light_visible
	
	color
}

world=[
	[[0,-10004,20],10000,[0.25,0.25,0.25],[0,0,0],0.2],
	[[0,0,20],4,[1,0,0],[1,0,0],0.2],
	[[6,-1,20],2,[0,0,1],[0,0,1],0.2],
]

angle=0.2679491924311227

puts"P3 640 480 255"

0.upto(479)do|row|
	0.upto(639)do|col|
		x=(2*((col+0.5)/640)-1)*angle*4/3.0
		y=(1-2*((row+0.5)/480))*angle
		
		RAYTRACE[[0,0,0],N[[x,y,1]],world,0].each{|c|$><<(c.clamp(0,1)*255).to_i<<" "}
	end
end