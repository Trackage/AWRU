PRO lonsgen, lons, lats, lons2, lats2

lons2 = fltarr(4096, 2048)

for n = 0, 2047 do begin

	lons2[*, n] = lons

endfor

lats = reform(lats, 1, 2048)
lats2 = fltarr(4096, 2048)
for m = 0, 4095 do begin
	lats2[m, *] = lats
endfor


END