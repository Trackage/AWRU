;-----------------------------------------------------------------------------------------
PRO filt2cells, data, filt_out, cells, beasts, time0, time1, max_speed, scale, limits


IF n_elements(beasts)  EQ 0 THEN beasts = data.ptts(uniq(data.ptts))
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
;------------------------------------------------------------------------------------------