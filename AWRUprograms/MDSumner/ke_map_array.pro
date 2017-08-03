;==============================================================================
; NAME:
;      	MAP_ARRAY.PRO
; PURPOSE:
;       	To display gridded data with map settings.
;
; CATEGORY:
; CALLING SEQUENCE:
;				map_array, array, lons, lats, [iters]
;
; INPUTS:
;			2-D array to display, with vectors of lons, lats
;			iters will cycle through different views of map projection
;
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;			This draws heavily on an example in IMDISP.PRO.
;
; MODIFICATION HISTORY:  Written 17Sep01 MDSumner.
;			Added wind_ratio operations to give sensible sized window
;			and correct scale for rectangular grid, MDS 5Oct01.
;==============================================================================


PRO ke_map_array, array, lons, lats, iters, pal = pal, title = title

;window, !window + 1
IF keyword_set(pal) THEN tvlct, pal(0, *), pal(1, *), pal(2, *)
P0lat = 0
P0lon = min(lons) +(max(lons) - min(lons))/2.0

scr_size = get_screen_size()
wind_ratio = (1.0*n_elements(lons))/(1.0*n_elements(lats))
IF wind_ratio GE 1 THEN $
	window, xsize = fix(scr_size(0)*.75), ysize = fix(fix(scr_size(1)*.75)/wind_ratio)
IF wind_ratio LT 1 THEN $
	window, xsize = fix(scr_size(0)*.75)*wind_ratio, ysize = fix(scr_size(1)*.75)
map_set, P0lat, P0lon, $
	limit = [min(lats), min(lons), max(lats), max(lons)], $
	 /cylindrical, xmargin = [0, 18], color = !d.n_colors - 1, title = title ;,/stereographic

	maparray = rotate(array, 7)    ;flip the array
	remap = map_image(maparray, x0, y0, xsize, ysize, compress=1, lonmin = min(lons), $
		lonmax = max(lons), latmin = min(lats), latmax = max(lats))
	;remap = map_patch(maparray, x0, y0, xsize, ysize, compress=1, lonmin = min(lons), $
	;	lonmax = max(lons), latmin = min(lats), latmax = max(lats))

	;;- Convert offset and size to position vector

pos = fltarr(4)
pos[0] = x0 / float(!d.x_vsize)
pos[1] = y0 / float(!d.y_vsize)
pos[2] = (x0 + xsize) / float(!d.x_vsize)
pos[3] = (y0 + ysize) / float(!d.y_vsize)


	  ;removing the ncolors from this enables SeaWiFS nodata to be black
	imdisp, remap, pos = pos , /usepos;, color = 0;, $;,  ncolors = !d.table_size - 1, $
		;background = !d.n_colors - 1;, title = title, /axis

map_continents, color = 0,  /hires
map_grid, lonlab = min(lats) + .5, latlab = max(lons) -.5, /label, color = 0, $;!d.n_colors - 1, $
	charsize = 1.5

legend, array
end