PRO frontsout, files
;file = findfile(filepath('ke_bath.csv', subdirectory = '/resource/datafile'))

count = 0L
names = ['pf', 'saccf', 'saf', 'sbdy', 'stf']
for n=0, n_elements(files) - 1 do begin

	pos = strpos(files(n), '.')
	pos2 = rstrpos(files(n), '\')
	name = strmid(files(n), pos2+1, pos - pos2-1)
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

	for p = 0L, n_elements(a) -1 do begin

		bits = str_sep(a(p), ' ')
		IF n_elements(bits) GT 2 THEN BEGIN
			lons(p) = bits(1)*1.0
			lats(p) = bits(4)*1.0
			count = count + 1
		ENDIF

	endfor
	struct = {lons:lons, lats:lats}

	IF n EQ 0 THEN orsi_fronts = create_struct(names(n), struct) ELSE $
		orsi_fronts = create_struct(orsi_fronts, names(n), struct)


endfor

stop

end
