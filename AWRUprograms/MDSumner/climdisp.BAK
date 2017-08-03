

PRO greybar, mean = mean, var = var, nn = nn

TV, replicate(0, 150, 180), 95, -78, /data
labels = ['-1.95',  '0',  '4',  '8',  '12',    '16',  '20']
title = 'deg C'
IF keyword_set(var) THEN BEGIN
	labels =  ['0',  '0.01',  '0.02',  '0.03',  '0.04',    '0.06',  '0.08', '0.1', '0.12', '0.14', '0.15']
	title = 'SE of monthly lnMCSST'
ENDIF
IF keyword_set(nn) THEN BEGIN
	labels = strcompress(string([0, 1, 3, 5, 8, 15,  25]))
	title = 'Sample size of monthly MCSST'
ENDIF
	;draw a grey scale color bar
grey = [255, 28L, 48,  69, 82, 99, 112, 120,  140, 161, 173, 199, 219,  245]
for j = 0, 12, 2 DO BEGIN $
	greybar = (grey[13 - j]) & $
	TV, replicate(greybar, 20, 15), 96, (-66 - 0.95*j), /data & ENDFOR
for j = 0, 6 DO BEGIN $
	xyouts, 100, (-65.5 - 2*j), labels[6 - 0.95*j], color=!d.n_colors -1 , charsize = 1.5, charthick = 0.7, /data & ENDFOR
xyouts, 104.5, -62-1*13, title , color = !d.n_colors -1, charsize = 1.5, charthick = 1.0, /data

END

PRO climout, file, mean, lnSE, nn, lons, lats

;file = findfile('G:\satdata\MCSST_clim\intp_mth\ninek\JANinterp*')

zip, file, /unzip

openr, lun, file, /get_lun
readf, lun, x, y
lons = fltarr(x)
lats = fltarr(y)
mean = fltarr(x,y)
sdev= fltarr(x,y)
sum = fltarr(x,y)
SSQ = fltarr(x,y)
nn = fltarr(x,y)
stderr = fltarr(x,y)
mle = fltarr(x,y)
lnsdev = fltarr(x,y)
lnmean = fltarr(x,y)
lnsum = fltarr(x,y)
lnSSQ = fltarr(x,y)
lnSE = fltarr(x,y)
readf, lun, lons, lats, mean
readf, lun, sdev
readf, lun, sum
readf, lun, SSQ
readf, lun, nn
readf, lun, stderr
IF x GT 800 THEN readf, lun, mle
readf, lun, lnsdev
readf, lun, lnmean
readf, lun, lnsum
readf, lun, lnSSQ
readf, lun, lnSE
FREE_LUN, lun
;temp = rotate(temp, 7)
zip, file

END

PRO climdisp, file, disparr, lons, lats, mean = mean, var = var, nwin = nwin, nn = nn, $
	skip = skip, debug = debug, orig = orig
loadct, 0


IF not keyword_set(skip) THEN BEGIN
	climout, file, mean, lnSE, nn, lons, lats
	IF keyword_set(mean) THEN disparr = mean
	IF keyword_set(var) THEN disparr =  var
	IF keyword_set(nn) THEN disparr = nn
ENDIF
displons = lons
displats = lats
IF max(disparr) EQ 255 THEN BEGIN
	bad = where(disparr GT 254)
	disparr(bad) = -2
ENDIF ELSE bad = where(disparr LT - 2)
tx = n_elements(displons)
ty = n_elements(displats)
;IF tx GT 800 THEN BEGIN
	;tx = 1100
	;ty = 850
	;disparr = congrid(disparr, tx, ty)
	;displons = congrid(displons, tx)
	;displats = congrid(displats, ty)
;ENDIF


scr_size = get_screen_size()
wind_ratio = (1.0*n_elements(lons))/(1.5*n_elements(lats))
IF keyword_set(nwin) THEN wnum = !d.window + 1 ELSE wnum = 0
IF wind_ratio GE 1 THEN $
	window, wnum, xsize = fix(scr_size(0)), ysize = fix(fix(scr_size(1))/wind_ratio)
IF wind_ratio LT 1 THEN $
	window, wnum, xsize = fix(scr_size(0))*wind_ratio, ysize = fix(scr_size(1))
IF keyword_set(debug) THEN window, xsize = 300, ysize = 200
;window, ysize = ty, xsize = tx
map_set, 0, displons[tx/2], /cylindrical, $
	limit=[displats[ty-1], displons[0], displats[0], displons[tx-1]], /noborder,$
	xmargin = 0, ymargin = 0, color = 0

   ;define temperatures to display in contour, -99 is no data/land/sea-ice

levels = [min(disparr), -1.95, -0.5, 0, 2, 4, 6, 8, 10, 12,  14, 16, 18, 20]

   ;define 13 grey colours for contour filling - greys are cubes in true colour

grey = [255, 28L, 48,  69, 82, 99, 112, 120,  140, 161, 173, 199, 219,  245]

IF keyword_set(var) THEN levels = [min(disparr),  0, 0.005, 0.01, 0.015, 0.02, 0.025, 0.03, 0.035, 0.04, 0.05, 0.06, 0.07, 0.08,  0.1, 0.12, 0.14, 0.15]

   ;define 13 grey colours for contour filling - greys are cubes in true colour

IF keyword_set(var) THEN grey = [255, 28L, 38, 48, 58, 69, 79, 88, 99, 109, 119, 139, 149, 161, 173, 199, 219,  245]




   ;define colours array, first one is a blue, last 15 are the greys (cubed),
   ;and subtracted from 16M to reverse order (L is used to make long integers)

colors = lonarr(14)
;colors[0] = 0L + 154L*256 + 205L*256*256L 			;deep sky blue3
colors = grey + grey*256L + grey * 256 * 256L
;colors[1:13] = grey + grey*256L + grey*256*256L
fill = disparr
IF Keyword_set(nn) THEN BEGIN
	levels = [0, 1, 3, 5, 8, 15,  25]
	colors = [0, 10, 50, 100, 150, 200, 254]
	;colors = [!d.n_colors - 1, !d.n_colors - 1000, 95, 25000 , 3050 ]
	;colors = [0, 110L*256*256, 180L*256*256, 240L*256*256, 1600000L, 300000L, 240]
	;bad = where(fill LT 1)

	;fill = smooth(fill, 35, /edge_truncate)
	;fill(bad) = 0
	fill = median(fill, 40)
ENDIF
IF keyword_set(orig) THEN BEGIN
	bad = where(fill LT -2)
	fill(bad) = !values.f_nan
	fill = smooth(fill, 35, /nan, /edge_truncate)
	fill(bad) = -99
	min_value = -2
ENDIF
   ;contour the temperatures, filling cells with above greys and blue


IF keyword_set(var) THEN BEGIN
	fill(bad) = !values.f_nan
	fill = smooth(fill, 15, /nan)
ENDIF

contour, fill, displons, displats, levels = levels, $
	c_colors = colors, $
	xstyle = 4, ystyle = 4, xmargin = [0,0], max_value = 90,  $
	 /cell_fill, ymargin = [0,0], /overplot, min_value = min_value

   ;add contour lines over entire image, with every second level chosen
contlevels = findgen(10)*2.0
IF keyword_set(var) THEN contlevels = [0,  0.01, 0.02,  0.03,  0.04,  0.06,  0.08,  0.12, 0.15]
IF keyword_set(nn) THEN contlevels = levels
contour, fill, displons, displats, /overplot, levels = contlevels , c_charsize = 1.5, $
	charthick = 1.5, max_value = 30.0, $
	c_colors = [0], c_thick = 1.0,  xstyle = 4, ystyle = 4


   ;add continents map to display in purple

map_continents, color = 0, thick = 3
;map_continents, /fill_continents, color = 50L + 5L*256 + 129L*256*256L   ;blue purple
IF keyword_set(nn) THEN map_col = 120 ELSE map_col = colors(7)
map_continents, /fill_continents, color = map_col
  ;define lat lon labels

nlats = [ -76, -72, -68, -64, -60, -56, -52, -48, -44]
;nlons = [90, 100, 110, 120, 130, 140, 150, 160, 170, 180, -170, -160, -150, -140]

   ;Create string equivalents of latitudes, with extremes left unlabeled

latnames = strtrim(nlats, 2)
latnames[0] = ' '
latnames[8] = ' '
;lonnames = strtrim(nlons, 2)
;lonnames[0] = ' '
;lonnames[13] = ' '

   ;draw map grid on image

;MAP_GRID, color = 256L*256*256-1, charsize=1.0, charthick = 1.0, LABEL=1, LATS=nlats, LATNAMES=latnames, LONLAB=-79, $
;	LONS=nlons, LONNAMES=lonnames, LATLAB=-137

 map_grid, lonlab = min(displats) + 5, latlab = max(displons) -4, LATS = nlats, LATNAMES = latnames,  $
 	/label, color = col, charsize = 1.5
xyouts, max(lons) - 6, -77, '-76', charsize = 1.5
   ;define labels for color bar

;-1.95, -0.5, 0, 2, 4, 6, 8, 10, 12, 13, 14, 15, 16, 18, 20]

place_names, /auck, /camp, /antip, /chath, /nz, /tas, /ross, /anta, /macq
oplot_fronts, /pf, /saf, /saccf, /sbdy, /apf87_99

greybar,mean = mean, var = var, nn = nn



END
