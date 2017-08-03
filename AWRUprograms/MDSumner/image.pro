;This program displays SeaWiFS and MCSST data together, with contours of SST
;and filled contours in the colour gaps.  It loads the colour table 'pc28.pse'
;with the program 'coltbl_load.pro', and tvs the colour data with G.Hyland's program
;'dframe.pro'.  


;===================================================================================
PRO image, tfile, cfile
;===================================================================================
   
	;set environment to remember display

device, retain = 2

   ;create a window

window, xsize = 1280, ysize = 600

   ;open the temperature file, create array, read out data

openr, lun, tfile, /get_lun
readf, lun, tx, ty
lons = fltarr(tx)
lats = fltarr(ty)
readf, lun, lons, lats
temps = fltarr(1480,444)
readf, lun, temps
free_lun, lun

   ;create mask for null data (assigned as -99 in files)
   ;this ought be something other than -2!

bad = where(temps LT -2 or temps GE 36)
temps(bad) = -99

   ;open colour file, create arrays from size, lon/lats data
   ;within

openr, lun, cfile, /get_lun

readf, lun, tx, ty
lons = fltarr(tx)
lats = fltarr(ty)
readf, lun, lons, lats
chla = bytarr(tx, ty)
readf, lun, chla
free_lun, lun

  ;set display to mercator projection using the lat lon limits

print, 'setting map . . .'
map_set, 0, lons[tx/2], /stereographic, $
	limit=[lats[ty-1], lons[0], lats[0], lons[tx-1]], /noborder,$
	xmargin = 0, ymargin = 0, color = 0

   ;define mask for colour data (no data or land is 255 in SeaWiFS)

data = where(chla LT 255)
no_data = where(chla EQ 255)

   ;define colour array to display, NANing out no data areas - this
   ;leaves the gaps for contour to display in (overkill as contour
   ;uses the mask as well)

col = chla
col(no_data) = !values.F_NAN
col(data) = chla(data)

   ;orient the colour array (machine reads from bottom left)

col =rotate(col, 7)

  ;warp the colour array to the map projection

warp = map_image(col, xx, yy, latmin = lats[ty-1], lonmin = lons[0], $
		latmax = lats[0], lonmax = lons[tx -1],comp=1)

  ;load the seawifs colour table (from Chris Rathbone, CSIRO)
print, 'loading colour table pc28.pse'
coltbl_load, 'pc28.pse'

  ;dframe shoots the map-warped colour array to the screen, tving
  ;separately for red, green and blue (G.Hyland procedure, dframe.pro)

print, 'tving map-warped colour data . . .'
dframe, warp, xx, yy

  ;this stuff was just mucking around with FFTs

	;nofilt = where(temps LT -2)

	;freq = dist(1480, 444)
	;filter = freq LT 200
	;conts = FFT(FFT(temps, -1)*filter, 1)

   ;median smooth the image, define fill array with colour data masked out
   ;for contour

conts = median(temps, 25)
fill = conts
fill(data) = !values.F_NAN

   ;define temperatures to display in contour, -99 is no data/land/sea-ice

levels = [-99, -1.95, -0.5, 0, 2, 4, 6, 8, 10, 12,  14, 16, 18, 20]

   ;define 13 grey colours for contour filling - greys are cubes in true colour

grey = [28L, 48,  69, 82, 99, 112, 120,  140, 161, 173, 199, 219,  245]

   ;define colours array, first one is a blue, last 15 are the greys (cubed),
   ;and subtracted from 16M to reverse order (L is used to make long integers)
colors = lonarr(14)
colors[0] = 0L + 154L*256 + 205L*256*256L 			;deep sky blue3

colors[1:13] = grey + grey*256L + grey*256*256L

   ;contour the temperatures, filling cells with above greys and blue

contour, fill, lons, lats, levels = levels, $
	c_colors = colors, $
	xstyle = 4, ystyle = 4, xmargin = [0,0], max_value = 90,  $
	 /cell_fill, $
	 ymargin = [0,0], /overplot

   ;add contour lines over entire image, with every second level chosen

contour, conts, lons, lats, /overplot, levels = findgen(10)*2.0  , c_charsize = 1.5, $
	charthick = 2.0, max_value = 30.0, $
	c_colors = [0], c_thick = 1.8,  xstyle = 4, ystyle = 4

;contour, conts, lons, lats, /overplot, levels =  (findgen(11)*2.0 - 2), c_charsize = 1.5, $
;	charthick = 1.5, max_value = 30.0, $
;	c_colors = [200], c_thick = 1.5, xstyle = 4, ystyle = 4

   ;add continents map to display in purple

map_continents, color = 0, thick = 3
map_continents, /fill_continents, color = 50L + 5L*256 + 129L*256*256L   ;blue purple
;240L + 248L*256 + 255L*256*256L

nlats = [ -80, -75, -70, -65, -60, -55, -50, -45, -40]
nlons = [90, 100, 110, 120, 130, 140, 150, 160, 170, 180, -170, -160, -150, -140]

latnames = strtrim(nlats, 2)	;Create string equivalents of latitudes.
latnames[0] = ' '
latnames[8] = ' '
lonnames = strtrim(nlons, 2)	;Create string equivalents of latitudes.
lonnames[0] = ' '
lonnames[13] = ' '

MAP_GRID, color = 256L*256*256-1, charsize=1.0, charthick = 1.0, LABEL=1, LATS=nlats, LATNAMES=latnames, LONLAB=-79, $
	LONS=nlons, LONNAMES=lonnames, LATLAB=-137




;-1.95, -0.5, 0, 2, 4, 6, 8, 10, 12, 13, 14, 15, 16, 18, 20]
labels = ['-1.95',  '0',  '4',  '8',  '12',    '16',  '20']
	;draw a grey scale color bar

for j = 0, 12 DO BEGIN $
	greybar = (grey[12 - j]) & $
	TV, replicate(greybar, 20, 15), 1162, (231 - 15*j) & ENDFOR
for j = 0, 6 DO BEGIN $
	xyouts, 1185, (231 - 30*j), labels[6 - j], color=0, charsize = 0.7, charthick = 0.7, /device & ENDFOR
xyouts, 1165 -50, 231-15*13, 'degrees celsius', color = 0, charsize = 0.8, charthick = 0.7, /device

	;mark macca
a = bytarr(5,5) + 250
;tv, a, 158.55, -54.27, /data
tvlct, r, g, b, /get
tv, [ [[r[a]]], [[g[a]]], [[b[a]]] ], 158.58, -54.29, true=3, /data

;54º 30'S, 158º 57'E 

;xyouts, 158, -55.5, 'MACCA', color = 0, charsize = 0, charthick = 0.7, /data

xyouts, 100, -72, 'ANTARCTICA', color = 256l*256*256-1, charsize = 0.8, charthick = 0.7, /data
xyouts, 145, -42.5, 'TAS', color = 256l*256*256-1, charsize = 0.8, charthick = 0.7, /data
xyouts, 169, -45, 'NZ', color = 256l*256*256-1, charsize = 0.8, charthick = 0.7, /data


	;draw a colour color bar

;colors = indgen(15)*256/15
;clabels = 10^((0.015 * colors) - 2.0 )

 ;[0.01,   0.0179887  0.0323594    0.0582103     0.104713     0.188365     0.338844     0.609537
      ;1.09648      1.97242      3.54813      6.38263      11.4815      20.6538      37.1535]

;colors = indgen(12)*256/12 + 15

;clabels = 10^((0.015 * colors) - 2.0 )
;IDL> print, clabels
 ;   0.0167880    0.0346737    0.0716143     0.153109     0.316228     0.653130      1.39637      2.88403      5.95662
  ;    12.7350      26.3027      54.3250

colors = indgen(12)*256/12 + 15

   ;need to check these colour levels and labels, have cheated for moment and put no label
   ;where I had 0.02 as clabels[0] before

;clabels = ['', '0.03',  '0.07',  '0.15', '0.32', '0.65', '1.40', '2.88', '5.96', '12.7', $
;	'26.7', '54.33']
;for j= 0, 11 DO BEGIN $
;	colors = (256/12)*j & $
;	dframe, replicate(colors, 20, 15), (1265-1192), (231 - 15*j) & ENDFOR
;for j = 0, 11 DO BEGIN $
	;xyouts, 1265-1170,  (231 - 15*j), clabels[j], color=256L*256*256-1, charsize = 0.7, charthick = 0.7, /device  & ENDFOR

clabels = ['', '0.03',  '0.15',   '0.65', '2.88',  '12.7', $
	'54.33']
for j= 0, 11 DO BEGIN $
	colors = (256/12)*j & $
	dframe, replicate(colors, 20, 15), (1265-1192), (231 - 15*j) & ENDFOR
for j = 0, 6 DO BEGIN $
	xyouts, 1265-1170,  (246 - 30*j), clabels[j], color=0, charsize = 0.7, charthick = 0.7, /device  & ENDFOR


xyouts, 1265 -1215, 231-15*13, 'chlA mg/m^3', color = 0, charsize = 0.8, charthick = 0.7, /device


   ;read the display data, specifying true interleaved (n, m, 3)

image = tvrd(true = 3)

   ;output a jpeg file of the display

jpeg_name = tfile + cfile + '.jpeg'
write_jpeg, jpeg_name, image, true = 3






stop

END