include Math;class Array;def+v;zip(v).map{|a,b|a+b};end;def-v
self+v*-1;end;def*f;map{|a|a*f};end;def/f;self*f**-1;end;def%v
zip(v).sum{|a,b|a*b};end;end;V=->f{[f,f,f]};N=->v{v/sqrt(v%v)}
I=->s,o,d{l=s[0]-o;t=l%d;u=l%l-t**2;return 1e9 if t<0||u>s[1]\
**2;h=sqrt s[1]**2-u;[t-h,t+h].min};C=->f{f.clamp 0,1};R=->o,\
d,b{s,t=W.map{|s|[s,I[s,o,d]]}.min_by{|s,t|t};return[0.4,0.8,1
]*(1-d[1])**3 if t>1e8;i=o+d*t;n=N[(i-s[0])/s[1]];c=V[0.05];l=
N[[-20,40,10]-i];k=i+n*1e-4;m=W.map{|s|I[s,k,l]};m[W.index(s)
]==m.min&&c+=s[!s[3]||i[0].ceil%2==i[2].ceil%2?2:3]*[0,n%l]
.max+V[1]*C[n%N[l+N[V[0]-i]]]**50;b<3&&c+=R[k,N[d-n*2*(d%n)],
b+1]*0.3;c};W=[[[0,-10002,20],1e4,V[0.25],V[0]]];0.step(25,PI/
4){|t|W<<[[t-14.5,2**(-0.1*t)*sin(t/2).abs*10-1.35,37-t],0.7,[
0,2,4].map{|i|C[cos(t/PI+i)]}]};A=15/56r;$><<"P3 640 480 255"
[*0..479].product([*0..639]){|r,c|R[V[0],N[[(2.*(c+0.5)/640-1
)*A*4/3,(1-2.*(r+0.5)/480)*A,1]],0].map{|c|$><<" %d"%(C[c]*255
)}} # usage: ruby tracer.rb > out.ppm
