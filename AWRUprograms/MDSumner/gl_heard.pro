PRO gl_heard, files, area, jday0 = jday0, jday1 = jday1, years = years, limits = limits, $
	 sst = sst, col = col, height = height, nojpg = nojpg

IF n_elements(files) EQ 0 THEN BEGIN
	IF keyword_set(sst) THEN $
		files = findfile(filepath('*hdf*', root_dir = 'G:\', subdirectory = 'satdata\MCSST'))
	IF keyword_set(col) THEN $
		files = findfile(filepath('*CHLO*', root_dir = 'G:\', subdirectory = 'satdata\SW_chla'))
	IF keyword_set(height) THEN $
		files = findfile(filepath('*nc*', root_dir = 'G:\', subdirectory = 'satdata\topex'))
ENDIF

IF keyword_set(jday0) THEN BEGIN
	files = sat_day(files, jday0, jday1, years = years)
ENDIF

for n = 0, n_elements(files) - 1 do begin

	IF keyword_set(col) THEN BEGIN
		swext, files(n), arr, lons, lats
		lbl = 'col'
		offs = 7
	ENDIF
	IF keyword_set(sst) THEN BEGIN
		sstext, files(n), arr, lons, lats, /intp;, pal = pal
		lbl = 'sst'
		offs = 7
	ENDIF
	IF keyword_set(height) THEN BEGIN
		ssa_ext, files(n), arr, lons, lats, mask = mask
		bad = where(mask EQ 0)
		plus = where(arr GE 0 AND arr LT 32766)
		neg = where(arr LT 0)

		arr = arr + abs(min(arr)) + 1
		arr(bad) = 0
		lbl = 'ssa'
		color = !d.n_colors - 1
		offs = 8

	ENDIF
	;GREG limits = [-40, -70, 55, 80]
	;lim_area, arr, lons, lats, area, alons, alats, limits =  [-38.0, -44.0, 140.0, 146.0]
	lim_area, arr, lons, lats, area, alons, alats, limits =  limits
	;bad = where(area EQ 255)
	;area(bad) = 0

	spos = strpos(files(n), '.')
	nm = strmid(files(n), spos - offs, 7)

	nm = lbl + nm
	map_array, area, alons, alats, title = nm, pal = pal, col = color
	image = tvrd(true = 3)
	jpgnm = 'G:\satdata\images\' + nm + '.jpg'
	IF NOT keyword_set(nojpg) THEN write_jpeg, jpgnm, image, true = 3
	legend, area, title = lbl

endfor

end