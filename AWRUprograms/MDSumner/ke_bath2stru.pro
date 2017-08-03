PRO frontsout, files
;file = findfile(filepath('ke_bath.csv', subdirectory = '/resource/datafile'))

count = 0L
for n=0, n_elements(files) - 1 do begin

	pos = strpos(files(n), '.')
	name = strmid(files(n), 0, pos - 1)
	openr, unit, files(n), /get_lun
	maxlines = 1000000

		   ;a will contain strings of each line from the file

	a = strarr(maxlines)

	   ;read the file into a, goto label if i/o error

	on_ioerror, done_reading
	readf, unit, a
	done_reading: s = fstat(unit)		;Get # of lines actually read, null the error
	a = a[1: (s.transfer_count-1) > 0]
	on_ioerror, null
	FREE_LUN, unit

	lines = n_elements(a)
	lons = fltarr(lines)
	lats = fltarr(lines)

	for n = 0L, n_elements(a) -1 do begin

		bits = str_sep(a(n), ' ')
		IF n_elements(bits) GT 1 THEN BEGIN
			lons(n) = bits(0)
			lats(n) = bits(1)
			count = count + 1
		ENDIF

	endfor
	struct = create_struct(name, lons:lons, lats:lats)
	IF n EQ 0 THEN front_str = create_struct('orsi_fronts', struct) ELSE $
		front_str = create_struct(front_str, name, lons:lons, lats:lats)


endfor

stop

end
