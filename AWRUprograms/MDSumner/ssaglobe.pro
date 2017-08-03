PRO ssaglobe, area, lons, lats, files = files, wsz = wsz


;If n_elements(files) EQ 0 THEN files = findfile('./satdata/*CHLO')
If n_elements(files) EQ 0 THEN files = findfile(filepath('/*CHLO', subdirectory = '/resource/datafile'))


IF n_elements(wsz) EQ 0 THEN wsz = 350
window,xs=wsz,ys=wsz            ; Visible window.
window,1,xs=wsz,ys=wsz,/pixmap  ; Hidden window.

IF n_elements(xx) EQ 0 THEN xx = 120
IF n_elements(yy) EQ 0 THEN yy = 60


;area = rebin(area, xx, yy)
for n = 0, n_elements(files) - 1 do begin
file = files(n)
ssa_ext, file, area, lons, lats
bad = where(area EQ -9999)
area(bad) = max(area)
lim_area, area, lons, lats, area, lons, lats, limits = [-30, -89, 70, 220]
area = rotate(area, 7)
;for x=0,350,10 do begin $
x = 159
  wset,1 &$                                       ; Work in hidden window.
  ;map_set,/iso,/hor,/cont,/orth,/nobord,-60,x &$
  map_set,/cont,/orth,/nobord, -60, x &$
  remap = map_image(area, x0, y0, xsize, ysize, compress = 1, lonmin = min(lons), $
		lonmax = max(lons), latmin = min(lats), latmax = max(lats)) &$
 pos = fltarr(4)
pos[0] = x0 / float(!d.x_vsize)
pos[1] = y0 / float(!d.y_vsize)
pos[2] = (x0 + xsize) / float(!d.x_vsize)
pos[3] = (y0 + ysize) / float(!d.y_vsize)

  imdisp, remap, pos = pos, /usepos , /noscale &$   ; Do graphics.
  map_grid
  map_continents, color = 0
  wset,0 &$                                       ; Now set to visible window.
  device, copy=[0,0,wsz,wsz,0,0,1] &$
  ;stop           ; Copy contents of hidden.

;endfor
endfor
END
