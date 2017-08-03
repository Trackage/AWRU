PRO globe_map, sst = sst, ssa = ssa


IF keyword_set(ssa) THEN files = findfile(filepath('*.nc', subdirectory = '/resource/datafile'))
IF keyword_set(sst) THEN get_sst, area, lons, lats, /orig & files = 1


	;ssa_ext, files(0), area, lons, lats, wocedate, /nolimit

	;bad = where(area GE 32766)
	;area = area + abs(min(area))
	;area(bad) = !values.f_nan
	;remap = map_image(area) ;, x0, y0, xsize, ysize, compress=1 ;, lonmin = min(lons2), $
		;lonmax = max(lons2), latmin = min(lats2), latmax = max(lats2))

;pos = fltarr(4)
;pos[0] = x0 / float(!d.x_vsize)
;pos[1] = y0 / float(!d.y_vsize)
;pos[2] = (x0 + xsize) / float(!d.x_vsize)
;pos[3] = (y0 + ysize) / float(!d.y_vsize)

;imdisp, remap, pos = pos , /usepos, color = 0, ncolors = !d.table_size - 1, $
;	 background = !d.n_colors - 1, title = title, /axis


IF n_elements(wsz) EQ 0 THEN wsz = 300
window,xs=wsz,ys=wsz            ; Visible window.
window,1,xs=wsz,ys=wsz,/pixmap  ; Hidden window.

for n = 0, n_elements(files) - 1 do begin

IF keyword_set(ssa) THEN ssa_ext, files(n), area, lons, lats, wocedate, /nolimit

IF n_elements(xx) EQ 0 THEN xx = 120
IF n_elements(yy) EQ 0 THEN yy = 60
area = rebin(area, xx, yy)
for x=0,350,10 do begin $
  wset,1 &$                                       ; Work in hidden window.
  map_set,/iso,/hor,/cont,/orth,/nobord,-60,x &$
  remap = map_image(area, x0, y0, xsize, ysize, compress = 1, lonmin = min(lons), $
		lonmax = max(lons), latmin = min(lats), latmax = max(lats)) &$
 pos = fltarr(4)
pos[0] = x0 / float(!d.x_vsize)
pos[1] = y0 / float(!d.y_vsize)
pos[2] = (x0 + xsize) / float(!d.x_vsize)
pos[3] = (y0 + ysize) / float(!d.y_vsize)

  imdisp, remap, pos = pos, /usepos &$   ; Do graphics.
  map_grid
  map_continents
  wset,0 &$                                       ; Now set to visible window.
  device, copy=[0,0,wsz,wsz,0,0,1] &$
  ;stop           ; Copy contents of hidden.

endfor
stop
endfor
end