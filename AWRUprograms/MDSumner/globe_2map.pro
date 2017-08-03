PRO globe_2map, area1, area2, lons, lats


IF n_elements(wsz) EQ 0 THEN wsz = 300
window,xs=wsz,ys=wsz            ; Visible window.
window,1,xs=wsz,ys=wsz,/pixmap  ; Hidden window.

area11 = rotate(area1, 7)
area22 = rotate(area2, 7)
lats = reverse(lats)

IF n_elements(xx) EQ 0 THEN xx = 120
IF n_elements(yy) EQ 0 THEN yy = 60
set_display
tvlct, r, g, b, /get

;area = rebin(area, xx, yy)
for x=0,350,10 do begin $
  wset,1 &$                                       ; Work in hidden window.
  map_set,/iso,/hor,/cont,/orth,/nobord,-60,x &$
  remap1 = map_image(area11, x0, y0, xsize, ysize, compress = 1, lonmin = min(lons), $
		lonmax = max(lons), latmin = min(lats), latmax = max(lats)) &$
  remap2 = map_image(area22, x0, y0, xsize, ysize, compress = 1, lonmin = min(lons), $
		lonmax = max(lons), latmin = min(lats), latmax = max(lats)) &$
 pos = fltarr(4)
pos[0] = x0 / float(!d.x_vsize)
pos[1] = y0 / float(!d.y_vsize)
pos[2] = (x0 + xsize) / float(!d.x_vsize)
pos[3] = (y0 + ysize) / float(!d.y_vsize)

  ; Do graphics.



 bad = where(remap1 LT 1)
 good = where(remap1)
 remap2(good) = !values.f_nan
 remap1(bad) = !values.f_nan
 tvlct, r, g, b
  tv, remap1, 0
  ;imdisp, remap1, pos = pos, /usepos &$
  loadct, 0
  imdisp, remap2, pos = pos, /usepos, /noerase &$
  ;contour, remap2, /cell_fill, /overplot

  map_grid
  map_continents

  wset,0 &$                                       ; Now set to visible window.
  device, copy=[0,0,wsz,wsz,0,0,1] &$
  ;stop           ; Copy contents of hidden.



endfor
end