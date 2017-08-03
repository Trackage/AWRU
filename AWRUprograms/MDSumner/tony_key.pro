PRO tony_key, limits,  scale, time0, time1, max_speed, loc_data, beasts, file

	scale = 10.0

	max_speed = 10.0
;	time0 = '19901116000000'
;	time1 = '20100331000000'
	;file = filepath('mac2000filt1(2).csv', subdirectory = '/resource/datafile')
	file = filepath('rightdist2.csv', subdirectory = '/resource/datafile')
	loc_data = tony_gos(file)
	time0 = '20001200000000'
	time1 = '20010331000000'
	;js2ymds, time0, yy, mm, dd, ss
	;time0 = strcompress(string(fix(yy)) + string(fix(mm)) + string(fix(dd)) + string(fix(ss)), /remove_all)
	;js2ymds, time1, yy, mm, dd, ss
	;time1 = strcompress(string(fix(yy)) + string(fix(mm)) + string(fix(dd)) + string(fix(ss)), /remove_all)
	IF n_elements(beasts) EQ 0 THEN beasts = string(loc_data.ptts(uniq(loc_data.ptts)))
	limits =   [-52.1058,  -53.8157, 73.0450, 82.0075]

END
