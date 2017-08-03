for n = 0, n_elements(files) - 1 do begin

 	data = pen_gos(files(n))
 	window, n
 	plot, data.lons, data.lats

endfor

end