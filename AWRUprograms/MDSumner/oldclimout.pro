; IDL Version 5.2.1 (Win32 x86)
; Journal File for user@DEFAULT
; Working directory: C:\PROGRAM FILES\IDL52
; Date: Thu Oct 11 21:58:57 2001

PRO oldclimout, files

;files = findfile(filepath('*18*', root_dir = 'G:\', subdirectory = 'satdata\MCSST_clim\valid'))

for n = 0, n_elements(files) - 1 do begin

	filename = files(n)

	mle = strpos(filename, 'interp')
	mle2 = strpos(filename, 'orig')
	IF mle GT 0 OR mle2 GT 0 THEN mle_flag = 1 else mle_flag = -1
	compZ = strpos(strupcase(filename), '.Z')
	compgz = strpos(filename, '.gz')
	MON_pos = rstrpos(filename, '\')

	MON = strmid(filename, MON_pos + 1, 3)
	file = filename
	IF compZ GT 0 OR compgz GT 0 THEN BEGIN

		IF compZ GT 0 THEN pthlen = compZ ELSE pthlen = compgz

		command = 'gzip -d ' + filename
		spawn, command
		file = strmid(filename, 0, pthlen)

	ENDIF
	scale = strmid(file, MON_pos + 4, strlen(file))

	openr, lun, file, /get_lun
	readf, lun, nx, ny
	lons = fltarr(nx)
	lats = fltarr(ny)
	readf, lun, lons, lats
	mean = fltarr(nx, ny)
	readf, lun, mean

	sdev = fltarr(nx, ny)
	sum = fltarr(nx, ny)
	SSQ = fltarr(nx, ny)
	nn = fltarr(nx, ny)
	stderr = fltarr(nx, ny)
	mle = fltarr(nx, ny)
	lnsdev = fltarr(nx, ny)
	lnmean = fltarr(nx, ny)
	lnsum = fltarr(nx, ny)
	lnSSQ = fltarr(nx, ny)
	lnSE = fltarr(nx, ny)
	mle = fltarr(nx, ny)
	header = 'This is a climatology of MCSST 11 November 1981 to 2 August 2000 for ' + MON + ' at ' + scale + ' km'

	IF mle_flag LT 0 THEN BEGIN
		readf, lun, sdev, sum, SSQ, nn, stderr, lnsdev, lnmean, lnsum, lnSSQ, lnSE
		struct = {header:header, nx:nx, ny:ny, lons:lons, lats:lats, mean:mean, sdev:sdev, sum:sum, SSQ:SSQ, nn:nn, stderr:stderr, $
			lnsdev:lnsdev, lnmean:lnmean, lnsum:lnsum, lnSSQ:lnSSQ, lnSE:lnSE}
	ENDIF

	IF mle_flag GT 0 THEN BEGIN
		readf, lun, sdev, sum, SSQ, nn, stderr, mle, lnsdev, lnmean, lnsum, lnSSQ, lnSE

		struct = {header:header, nx:nx, ny:ny, lons:lons, lats:lats, mean:mean, sdev:sdev, sum:sum, SSQ:SSQ, nn:nn, stderr:stderr, $
			lnsdev:lnsdev, lnmean:lnmean, lnsum:lnsum, lnSSQ:lnSSQ, lnSE:lnSE}
	ENDIF
	free_lun, lun

	;IF compZ GT 0 OR compgz GT 0 THEN BEGIN

		;IF compZ GT 0 THEN pthlen = compZ ELSE pthlen = compgz

		command = 'gzip -9 ' + file
		spawn, command
		;file = strmid(filename, 0, pthlen)

	;ENDIF

	strname = MON + scale
	IF n EQ 0 THEN MCSST_clim = create_struct(strname, struct)
	IF n GT 0 THEN MCSST_clim = create_struct(MCSST_clim, strname, struct)

ENDFOR
etontou
climname = 'MCSST' + scale + 'clim.xdr'
save, MCSST_clim, filename = climname
com = 'gzip -9 ' + climname
spawn, com






END