pro tony_sw, files, scale = scale

for n = 0, n_elements(files) - 1 do begin

	swext, files(n), arr, lons, lats
	IF keyword_set(scale) THEN BEGIN
		x = 4096
		y = 2048
		bad = where(arr EQ 255)
		arr(bad) = !values.f_nan
		arr = rebin(arr, x/scale, y/scale)
		lons = rebin(lons, x/scale)
		lats = rebin(lats, y/scale)
		good = where(finite(arr))
		mask = arr*0.0
		mask(good) = 1
		arr = arr * mask
	ENDIF
	lim_area, arr, lons, lats, area, alons, alats,  limits = [-51,  -55, 72, 84]
	;map_array, area, alons, alats
	map_array, arr, lons, lats


	sat_file, area, alons, alats, files(n) + '.csv', /nozero
	image = tvrd(true = 3)
	write_jpeg, files(n) + '.jpg', image, true = 3

endfor

end