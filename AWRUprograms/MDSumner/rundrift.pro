;Rundrift - need matching input files of locations and drift data


;-----------------------------------------------------------------------------------------
PRO filt2cells, data, filt_out, cells, beasts, time0, time1, max_speed, scale, limits


IF n_elements(beasts) EQ 0 THEN beasts = data.ptts(uniq(data.ptts))


IF n_elements(time0) EQ 0 THEN time0 = min(data.ut_times)
IF n_elements(time1) EQ 0 THEN time1 = max(data.ut_times)
FOR si = 0, n_elements(beasts) -1 DO BEGIN


	read_filtptt, data, filt_out, beasts(si), $
		time0,  time1, 3, delta_time = 0, $
		max_speed = max_speed, include_ref = 'N'

ENDFOR

IF n_elements(filt_out) GT 0 THEN BEGIN

	cells = cell_multi(filt_out, cell_size = [scale, scale], /km, limits = limits, /cross)

ENDIF

IF min(cells.map_bins) LT 0 THEN stop

END
;-----------------------------------------------------------------------------------------
PRO rundrift, driftfile, locfile = locfile, skip = skip, beasts = beasts
;!p.multi = [0, 4, 5]
max_speed = 12.5
scale = 350.0
limits = [-41.0, -69.0, 127.0, 219.0]
;beasts = ['C163']
IF keyword_set(beasts) THEN seals = beasts
IF NOT keyword_set(locfile) THEN locfile = filepath('sealgeo.csv', subdirectory = '/resource/datafile')
data = gl2ptt(locfile)
IF NOT keyword_set(skip) THEN BEGIN
	filt2cells, data, filt_out, cells, seals, time0, time1, max_speed, scale, limits
	save, filt_out, filename = 'filtdrift.xdr'
	save, cells, filename = 'cellsdrift.xdr'

ENDIF ELSE BEGIN
	restore, 'filtdrift.xdr'
	restore, 'cellsdrift.xdr'

ENDELSE

map_dslope = fltarr(n_elements(cells.xgrid)-1,n_elements(cells.ygrid)-1)
map_drift= fltarr(n_elements(cells.xgrid)-1,n_elements(cells.ygrid)-1)
map_poslope = intarr(n_elements(cells.xgrid)-1,n_elements(cells.ygrid)-1)
map_negslope = intarr(n_elements(cells.xgrid)-1,n_elements(cells.ygrid)-1)
propos = intarr(n_elements(cells.xgrid)-1,n_elements(cells.ygrid)-1)
proneg = intarr(n_elements(cells.xgrid)-1,n_elements(cells.ygrid)-1)
sumpos = intarr(n_elements(cells.xgrid)-1,n_elements(cells.ygrid)-1)
sumneg = intarr(n_elements(cells.xgrid)-1,n_elements(cells.ygrid)-1)
maps = {map_dslope:map_dslope, map_drift:map_drift, map_poslope:map_poslope, $
	map_negslope:map_negslope, propos:propos, proneg:proneg, sumpos:sumpos, sumneg:sumneg}
;window, !d.window + 1
;plot, filt_out.lons, filt_out.lats
save, cells, filename = 'cells'
undefine, filt_out
undefine, cells

;driftfile = filepath('driftpred99.csv', subdirectory = '/resource/datafile')

divedata = get_dive_data(driftfile, /drift)
;help, divedata, /stru

IF n_elements(beasts) EQ 0 THEN beasts = divedata.seals(uniq(divedata.seals))
for j = 0, n_elements(beasts) - 1 do begin
	seal = beasts(j)
	filt2cells, data, filt_out, cells, seal, time0, time1, max_speed, scale, limits
	;stop
	drift = cell_drift(divedata, cells, seal, maps)
	IF j EQ 0 THEN BEGIN
		drift_sum = drift.drift
		dslope_sum = drift.dslope
		;pslope_sum = drift.map_poslope
		;nslope_sum = drift.map_negslope
		;propos_sum = drift.propos
		;proneg_sum = drift.proneg

		sumpos = drift.propos_m
		sumneg = drift.proneg_m
		;propos_t = drift.propos_t
		;proneg_t = drift.proneg_t
		nn = drift.seal_nn

	ENDIF ELSE BEGIN

		drift_sum = drift_sum + drift.drift
		dslope_sum = dslope_sum + drift.dslope
		;pslope_sum = pslope_sum + drift.map_poslope
		;nslope_sum = nslope_sum + drift.map_negslope
		;propos_sum = propos_sum + drift.propos
		;proneg_sum = proneg_sum + drift.proneg
		sumpos = sumpos + drift.propos_m
		sumneg = sumneg + drift.proneg_m
		;propos_t = propos_t + drift.propos_t
		;proneg_t = proneg_t + drift.proneg_t
		nn = nn + drift.seal_nn

	ENDELSE
	undefine, filt_out
	undefine, cells
	undefine, time0
	undefine, time1

endfor
;endfor
;window, !d.window + 1
mask = where((nn) GT 0)

;propos = sumpos*1.0
;propos(mask) = propos(mask)/(sumpos(mask) + sumneg(mask))

;proneg = sumneg*1.0
;proneg(mask) = proneg(mask)/(sumpos(mask) + sumneg(mask))

propos = sumpos*1.0
proneg = sumneg*1.0
propos(mask) = propos(mask)/nn(mask)
proneg(mask) = proneg(mask)/nn(mask)

wset, 0
!p.multi = [0, 2, 2]
imdisp, propos, title = 'propos', /axis
imdisp, proneg, title = 'proneg', /axis

propos_t = sumpos*0
propos_t(mask) = sumpos(mask)/(sumneg(mask)+ sumpos(mask))

imdisp, propos_t, title = 'propos_t', /axis
;imdisp, proneg_t, title = 'proneg_t', /axis
save, propos, filename = 'propos'
save, proneg, filename = 'proneg'
save, propos_t, filename = 'propos_t'


end

