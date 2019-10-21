class Array
	def+v
		zip(v).map{|a,b|a+b}
	end
	def-v
		self+v*-1
	end
	def*f
		map{|a|a*f}
	end
	def/f
		self*f**-1
	end
	def%v
		zip(v).map{|a,b|a*b}.sum
	end
end

V=->n{
	[n,n,n]
}
N=->v{
	v/Math.sqrt(v%v)
}
I=->sphere,ray_orig,ray_dir{
	l=sphere[0]-ray_orig
	tca=l%ray_dir
	d2=l%l-tca**2
	return 1e9 if tca<0||d2>sphere[1]**2
	thc=Math.sqrt(sphere[1]**2-d2)
	[tca-thc,tca+thc].min
}

R=->ray_orig,ray_dir,depth{
	
	sphere,min_dist=WORLD.to_h{|s|[s,I[s,ray_orig,ray_dir]]}.min_by{|k,v|v}
	
	return[1,0.6,0.5]*(1-ray_dir[1])**5 if min_dist>1e8
	
	intersect=ray_orig+ray_dir*min_dist
	normal=N[(intersect-sphere[0])/sphere[1]]
	
	color=V[0.05]
	
	light_dir=N[[0,20,10]-intersect]
	
	offset=intersect+normal*1e-4
	
	light_distances=WORLD.map{|s|I[s,offset,light_dir]}
	
	color+=(!sphere[4]||intersect[0].floor%2==intersect[2].floor%2?sphere[2]:sphere[4])*[0,normal%light_dir].max+V[1]*(normal%N[light_dir+N[V[0]-intersect]]).clamp(0,1)**50 if light_distances[WORLD.index(sphere)]==light_distances.min
	
	color+=R[offset,N[ray_dir-normal*2*(ray_dir%normal)],depth+1]*sphere[3]if sphere[3]>0&&depth<3
	
	color
}

WORLD=[[0,-10004,20],10000,V[0.25],0.2,V[0]],[[0,0,20],4,[1,0,0],0.2],[[6,-1,20],2,[0,0,1],0.2]

angle=0.2679491924311227

puts"P3 640 480 255"

[*0..479].product([*0..639]){|row,col|
	R[V[0],N[[(2*((col+0.5)/640)-1)*angle*4/3,(1-2*((row+0.5)/480))*angle,1]],0].each{|c|$><<(c.clamp(0,1)*255).to_i<<" "}
}
