PRO homedist, filt_out


	heard = [73.4, -53.0]
filename = 'homedist.txt'
	;good_speed = where(filt_out.ok EQ 'Y')
	lons = filt_out.lons;(good_speed)
	lats = filt_out.lats;(good_speed)

FOR n = 0, n_elements(lons) - 1 DO BEGIN

		;get distances

	ll2rb, heard[0],heard[1], lons[n], lats[n], dist, azi

			;ll2rb, last_lon, last_lat, lon, lat, dist, azi
			;print, last_lon, last_lat, lon, lat, dist, azi

	direction = azi
	range = dist * !radeg * 60.0 * 1.852  ; km


	IF n EQ 0 THEN distances = range ELSE distances = [distances, range]

	;get ranges and bearings


	IF n EQ 0 THEN brs = azi ELSE brs = [brs, azi]

ENDFOR

	openw, lun, filename, /get_lun
	printf, lun, 'distance', ',', 'bearing'
	;dates = data.dates(good_speed)
	;times = data.times(good_speed)
	;birds = data.birds(good_speed)
	;speeds = filt_out.rms(good_speed)
	FOR n = 0, n_elements(distances) - 1 DO BEGIN

		printf, lun, distances(n), ',', brs(n)
		;printf, lun, birds(n), ',', dates(n),  ',', times(n), ',', lats(n), ',', lons(n), ',', distances(n), ',', brs(n)

	ENDFOR
	free_lun, lun
END
