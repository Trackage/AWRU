PRO movie, lons, lats
plot, lons, lats, color = 0
oplot, lons(0:1), lats(0:1)
for n = 0, n_elements(lons) - 1 do begin

	oplot, lons(n:n+1), lats(n:n+ 1)
	stop
endfor

end