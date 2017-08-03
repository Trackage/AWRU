PRO ssa_disp2
files = findfile(filepath('*.nc', subdirectory = '/resource/datafile'))

;!p.multi = [0, 4, 5]


for n = 0, n_elements(files) - 1 do begin

	ssa_ext, files(n), area, lons, lats, woce_date

	bad = where(area GE 32766)
	area = area + abs(min(area))
	area(bad) = !values.f_nan

;	imdisp, rebin(area, 48, 20), /axis, title = files(n)
	area = rebin(area, 48, 20)
	IF n EQ 0 THEN BEGIN
		arrays = create_struct(string(woce_date), area)
	ENDIF ELSE BEGIN
		arrays = create_struct(arrays, strcompress(string(woce_date), /remove_all), area)
	ENDELSE


endfor

lons2 = rebin(lons, 48, /sample)
lats2 = rebin(lats, 20, /sample)
map_set, 0, min(lons2) +(max(lons2) - min(lons2))/2.0, $
	limit = [min(lats2), min(lons2), max(lats2), max(lons2)], $
	/stereographic,  xmargin = [0, 18], color = !d.n_colors - 1 ;,/stereographic

tags = tag_names(arrays)
for p = 0, n_tags(arrays) -1 do begin
	remap = map_image(arrays.(p), x0, y0, xsize, ysize, compress=1, lonmin = min(lons2), $
		lonmax = max(lons2), latmin = min(lats2), latmax = max(lats2))
	IF p EQ 0 THEN BEGIN
		remaps = create_struct(tags(p), remap)
	ENDIF ELSE BEGIN
		remaps = create_struct(remaps, tags(p),  remap)
	ENDELSE

endfor



	;;- Convert offset and size to position vector

pos = fltarr(4)
pos[0] = x0 / float(!d.x_vsize)
pos[1] = y0 / float(!d.y_vsize)
pos[2] = (x0 + xsize) / float(!d.x_vsize)
pos[3] = (y0 + ysize) / float(!d.y_vsize)

;imdisp, remap, pos = pos , /usepos, color = 0, ncolors = !d.table_size - 1, $
;	 background = !d.n_colors - 1, title = title, /axis

map_continents
for j = 0, 5 do begin
for m = 0, n_tags(arrays) -1  do begin

	imdisp, remaps.(m), pos = pos , /usepos, color = 0, ncolors = !d.table_size - 1, $
	 background = !d.n_colors - 1;, title = title, /axis
	map_continents
	map_grid
endfor
endfor
stop
end