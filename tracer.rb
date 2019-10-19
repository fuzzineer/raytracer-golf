
ADD_VEC=->a,b{
	a.zip(b).map{|m,n|m+n}
}
SUB_VEC=->a,b{
	a.zip(b).map{|m,n|m-n}
}
MUL_VEC=->a,f{
	a.map{|m|m*f}
}
DIV_VEC=->a,f{
	MUL_VEC[a,1.0/f]
}
DOT_VEC=->a,b{
	a.zip(b).map{|m,n|m*n}.sum
}
ABS=->a{
	DOT_VEC[a,a]
}
NORM=->a{
	DIV_VEC[a,Math.sqrt(ABS[a])]
}
INTERSECT=->sphere,ray_orig,ray_dir{
	l=SUB_VEC[sphere[0],ray_orig]
	tca=DOT_VEC[l,ray_dir]
	return 1e8 if tca<0
	d2=ABS[l]-tca**2
	return 1e8 if d2>sphere[1]**2
	thc=Math.sqrt(sphere[1]**2-d2)
	[tca-thc,tca+thc].min
}
COLOR=->sphere,intersect{
	(intersect[0].floor%2)==(intersect[2].floor%2)?sphere[2]:sphere[3]
}

RAYTRACE=->ray_orig,ray_dir,world,depth{
	
	sphere,min_dist=world.to_h{|s|[s,INTERSECT[s,ray_orig,ray_dir]]}.min_by{|k,v|v}
	
	return [0.5]*3 if min_dist>=1e8
	
	intersect=ADD_VEC[ray_orig,MUL_VEC[ray_dir,min_dist]]
	normal=NORM[DIV_VEC[SUB_VEC[intersect,sphere[0]],sphere[1]]]
	
	color=[0.05]*3
	
	light_pos=[0,20,10]
	
	light_dir=NORM[SUB_VEC[light_pos,intersect]]
	origin_dir=NORM[SUB_VEC[[0]*3,intersect]]
	
	offset=ADD_VEC[intersect,MUL_VEC[normal,1e-4]]
	
	light_distances=world.map{|s|INTERSECT[s,offset,light_dir]}
	light_visible=light_distances[world.index(sphere)]==light_distances.min
	
	lv=[0,DOT_VEC[normal,light_dir]].max
	color=ADD_VEC[color,MUL_VEC[COLOR[sphere,intersect],lv]]if light_visible
	
	if sphere[4]>0&&depth<5
		reflect_ray_dir=NORM[SUB_VEC[ray_dir,MUL_VEC[normal,2*DOT_VEC[ray_dir,normal]]]]
		color=ADD_VEC[color,MUL_VEC[RAYTRACE[offset,reflect_ray_dir,world,depth+1],sphere[4]]]
	end
	
	phong=DOT_VEC[normal,NORM[ADD_VEC[light_dir,origin_dir]]]
	color=ADD_VEC[color,MUL_VEC[[1]*3,phong.clamp(0,1)**50]]if light_visible
	
	color
}

world=[
	[[0,-10004,20],10000,[0.25]*3,[0]*3,0.2],
	[[0,0,20],4,[1,0,0],[1,0,0],0.2],
	[[6,-1,20],2,[0,0,1],[0,0,1],0.2],
]

angle=0.2679491924311227

puts"P3 640 480 255"

0.upto(479)do|row|
	0.upto(639)do|col|
		x=(2*((col+0.5)/640)-1)*angle*4/3.0
		y=(1-2*((row+0.5)/480))*angle
		
		RAYTRACE[[0]*3,NORM[[x,y,1.0]],world,0].each{|c|$><<(c.clamp(0,1)*255).to_i<<" "}
	end
end