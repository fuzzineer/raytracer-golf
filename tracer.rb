include Math
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
		zip(v).sum{|a,b|a*b}
	end
end

V=->n{
	[n,n,n]
}
N=->v{
	v/sqrt(v%v)
}
I=->sphere,ray_orig,ray_dir{
	l=sphere[0]-ray_orig
	tca=l%ray_dir
	d2=l%l-tca**2
	return 1e9 if tca<0||d2>sphere[1]**2
	thc=sqrt sphere[1]**2-d2
	[tca-thc,tca+thc].min
}
C=->x{
	x.clamp 0,1
}

R=->ray_orig,ray_dir,depth{
	
	sphere,min_dist=WORLD.map{|s|[s,I[s,ray_orig,ray_dir]]}.min_by{|k,v|v}
	
	return[0.4,0.8,1]*(1-ray_dir[1])**3 if min_dist>1e8
	
	intersect=ray_orig+ray_dir*min_dist
	normal=N[(intersect-sphere[0])/sphere[1]]
	
	color=V[0.05]
	
	light_dir=N[[-20,40,10]-intersect]
	
	offset=intersect+normal*1e-4
	
	light_distances=WORLD.map{|s|I[s,offset,light_dir]}
	
	light_distances[WORLD.index(sphere)]==light_distances.min&&color+=sphere[!sphere[3]||intersect[0].ceil%2==intersect[2].ceil%2?2:3]*[0,normal%light_dir].max+V[1]*C[normal%N[light_dir+N[V[0]-intersect]]]**50
	
	depth<3&&color+=R[offset,N[ray_dir-normal*2*(ray_dir%normal)],depth+1]*0.3
	
	color
}

WORLD=[[[0,-10002,20],1e4,V[0.25],V[0]]]

0.step(25,PI/4){|t|
	WORLD<<[[t-14.5,2**(-0.1*t)*sin(t/2).abs*10-1.35,37-t],0.7,[0,2,4].map{|i|C[cos(t/PI+i)]}]
}

angle=15/56r

$><<"P3 640 480 255"

[*0..479].product([*0..639]){|row,col|
	R[V[0],N[[(2.*(col+0.5)/640-1)*angle*4/3,(1-2.*(row+0.5)/480)*angle,1]],0].map{|c|$><<" "<<(C[c]*255).to_i}
}
