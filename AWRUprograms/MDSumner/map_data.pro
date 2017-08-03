PRO map_data, filt, cells, title = title, bathmap = bathmap, log = log, $
	trkonly = trkonly, track = track, noscale = noscale, fronts = fronts,nwin = nwin

celldisp = cells
IF keyword_set(log) THEN BEGIN

	logcells = cells
	notzeros = where(logcells.map_bins GT 0)
	logcells.map_bins(notzeros) = alog(logcells.map_bins(notzeros))
	logcells.map_bins(notzeros) = logcells.map_bins(notzeros) - min(logcells.map_bins(notzeros) )
	celldisp = logcells
	print, 'data has been log-scale for display, don''t trust the colorbar values '
ENDIF

good = where(filt.ok EQ 'Y')
lons = filt.lons(good)
lats = filt.lats(good)
title = string(filt.ptts(0))
IF keyword_set(nwin) THEN window, !d.window +1, title = title
IF keyword_set(trkonly) THEN BEGIN
P0lon = min(lons) + (min(lons) + max(lons))/2.0
limits = [min(lats), min(lons), max(lats), max(lons)]

map_set, 0, P0lon, limit = limits, $
	/isotropic, /mercator,  xmargin = [0, 18], color = !d.n_colors - 1 ;,/stereographic

oplot, lons, lats

map_continents, color = !d.n_colors - 1, /hires
map_grid, lonlab = min(lats), latlab = max(lons), /label, color = !d.n_colors - 1, $
	charsize = 1.0
ENDIF ELSE BEGIN
P0lon = min(celldisp.xgrid) +(max(celldisp.xgrid) - min(celldisp.xgrid))/2.0
limit = [min(celldisp.ygrid), min(celldisp.xgrid), max(celldisp.ygrid), max(celldisp.xgrid)]

map_set, 0, P0lon, limit = limit, $
	/isotropic, /mercator,  xmargin = [0, 18], color = !d.n_colors - 1 ;,/stereographic

remap = map_image(celldisp.map_bins, x0, y0, xsize, ysize, compress=1, lonmin = limit[0], $
	lonmax = limit[3], latmin = limit[0], latmax = limit[2])

	;;- Convert offset and size to position vector

pos = fltarr(4)
pos[0] = x0 / float(!d.x_vsize)
pos[1] = y0 / float(!d.y_vsize)
pos[2] = (x0 + xsize) / float(!d.x_vsize)
pos[3] = (y0 + ysize) / float(!d.y_vsize)

print, pos


imdisp, remap, pos = pos , /usepos, color = 0, ncolors = !d.table_size - 1, $
	 background = !d.n_colors - 1, title = title, noscale = noscale;, /axis
IF keyword_set(track) THEN oplot, lons, lats
IF keyword_set(fronts) THEN oplot_fronts, /pf, /saf, /sbdy, /saccf, /stf

map_continents, color = !d.n_colors - 1, /hires
map_grid, lonlab = min(celldisp.ygrid) + 1, latlab = max(celldisp.xgrid) -2, /label, color = !d.n_colors - 1, $
	charsize = 1.3
ENDELSE

;IF keyword_set(bathmap) THEN bathmap, cells, pos


   ;mark macca

;tv, replicate(!d.n_colors - 1, 3,7), 158.58,  -54.29, /data

   ;draw a color bar


;IF NOT keyword_set(trkonly) THEN colorbar, title = 'hours spent', ncolors = !d.table_size,  color = !d.n_colors - 1, $
;	/vertical,	 maxrange = max(celldisp.map_bins), position = [0.93, 0.15, 0.98, 0.95]



end