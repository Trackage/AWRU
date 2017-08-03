PRO snake_key, limits,  scale, time0, time1, max_speed, loc_data, beasts = beasts, $
		file, 	dbllons = dbllons

limits = [-40.0, -71.0, 130.0, 215.0]

;scale = map_2points(0.0, 0.0, 3.0, 0.0, /meters)/1000.0
scale = 333.0
;cell_size = [scale, scale]
time0 = '19920000000000'
time1 = '19990000000000'
IF n_elements(file) EQ 0 THEN file = filepath('finallocations2.csv', subdirectory = '/resource/datafile')
max_speed = 12.5
IF keyword_set(dbllons) THEN BEGIN
	loc_data = snake2ptt(file, /dbllons)
ENDIF ELSE BEGIN
	loc_data = snake2ptt(file)
ENDELSE
IF n_elements(beasts) EQ 0 THEN beasts = loc_data.ptts(uniq(loc_data.ptts))


END