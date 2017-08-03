PRO master_drift, file, filt_out, cells

IF n_elements(limits) EQ 0 THEN limits = [-41.0, -69.0, 127.0, 219.0]

IF  n_elements(time0) EQ 0 THEN BEGIN
	time0 = '19991016000000'
	time1 = '20000131000000'
ENDIF
IF n_elements(max_speed) EQ 0 THEN max_speed = 12.5
IF n_elements(scale) EQ 0 THEN scale = 350.0
beasts = 'B362'
loc_data = gl2ptt(filepath('sealplex2.csv', subdirectory = '/resource/datafile'))
FOR si = 0, n_elements(beasts) -1 DO BEGIN


	read_filtptt, loc_data, filt_out, beasts(si), $
		time0,  time1, 3, delta_time = 0, $
		max_speed = max_speed, include_ref = 'N'

ENDFOR

;undefine, limits
IF n_elements(filt_out) GT 0 THEN BEGIN

	cells = cell_multi(filt_out, cell_size = [scale, scale], /km, /crossing_data)

ENDIF

driftmap = cell_drift( filt_out, cells, seals = beasts, divefile = 'driftpred99.txt'    )


stop
end