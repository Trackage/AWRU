PRO sstdisp, file, temp, lnSE, lons, lats
IF n_elements(file) EQ 0 THEN file = findfile('G:\satdata\MCSST_clim\JANinterp*')

zip, file, /unzip

openr, lun, file, /get_lun
readf, lun, x, y
lons = fltarr(x)
lats = fltarr(y)
mean = fltarr(x,y)
readf, lun, lons, lats, mean
readf, lun, sdev
readf, lun, sum
readf, lun, SSQ
readf, lun, nn
readf, lun, stderr
readf, lun, mle
readf, lun, lnsdev
readf, lun, lnmean
readf, lun, lnsum
readf, lun, lnSSQ
readf, lun, lnSE
FREE_LUN, lun
;temp = rotate(temp, 7)
zip, file
temp = mean
bad = where(temp LT -2)
temp(bad) = -2
;help, bad
window, xsize = 1048, ysize = 500
 ;loadct, 4
 map_set, 0.0, lons(740), /mercator, limit = [min(lats), min(lons), max(lats), max(lons) ]

 remap = map_image(temp, x0, y0, xsize, ysize, compress=1, latmin = min(lats), $
 	latmax = max(lats), lonmin = min(lons), lonmax = max(lons))
 imdisp, remap, pos = pos, /usepos, out_pos = out_pos
map_grid
map_continents
bad = where(remap LT - 1.95)
remap(bad) = !values.f_nan
remap = smooth(remap, 10, /nan)
;lons = reverse(lons)
lats = reverse(lats)
lons = congrid(lons, 1014)
lats = congrid(lats, 462)
contour, remap, /noerase, position = out_pos, xstyle = 1, $
	ystyle = 1, levels = [-1.0, 0.0, 2.0, 5.0, 8.0, 12.0, 15.0, 19.0], $; , /follow, $
	 min_value = -1.8, /closed, /c_annotation;, /overplot

END