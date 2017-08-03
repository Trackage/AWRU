;==============================================================================
; NAME:	FILTCELLFILE
;
; PURPOSE:
;       	Output time spent data for marine beast location data
;			This 'big' version is an attempt to seamlessly incorporate
;			user-defined .csv or ARGOS .dat files.
;
; CATEGORY:
; CALLING SEQUENCE:
; INPUTS:		file - location data file, needs appropriate format
;				E.G. Aleks
;				files = findfile(filepath('*.dat', subdirectory = '/resource/datafile/aleks'))
;				{  filt_out - named variable to receive filtered locations
;				{  cells - named variable to receive gridded time spent
;
; KEYWORD PARAMETERS:
;
;				time0 - start time (set to min time in file)
;				time1 - end time  (set to max time in file)
;				beasts - string array of animals from file to use (set to all in file)
;				scale - resolution required (set to 350.0 km)
;				max_speed - speed to filter locations by (set to 12.5 km/hr)
;				limits - array of geog limits [latmin, lonmin, latmax, lonmax] (set for ellies)
;				map_data - produce image of time spent data
;				trkonly - produce image of tracks only
;				label - label to delimit this group of beasts (e.g. 'creche' - for file output)
;				no_undef - otherwise filt_out as input will be undefined, not added to
;
; OUTPUTS:
;			These are saved to file, 'filt.xdr', and 'cells.xdr' in IDL format for convenience.
;			filt_out - filtered locations
;			cells - gridded time spent data
;
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;			Written 27Aug01 by MDSumner - previous version was seal_track.pro
;			Changed to cell_track2 to incorporate ARGOS files, changed to 'big'
;			version to cope with both types.
;
;==============================================================================

PRO filtcellfile2, files, filt_out, cells, $
		time0 = time0, $
		time1 = time1, $
		beasts = beasts, $
		scale = scale, $
		max_speed = max_speed, $
		limits = limits, $
		ellies = ellies, $
		snake = snake, $
		aleks = aleks, $
	   	royal = royal, $
	   	grid = grid, $
	   	file_out = file_out, $
		map_data = map_data, $
		trkonly = trkonly, $
		labl = labl, $
		track = track, $
		noscale = noscale, $
		nwin = nwin, $
		no_undef = no_undef, $
		colour = colour, $
		mcsst = mcsst, $
		jpg = jpg

;ON_ERROR, 2

IF NOT keyword_set(no_undef) THEN undefine, filt_out

IF keyword_set(ellies) THEN BEGIN
	IF n_elements(files) EQ 0 THEN files = filepath('sealplex2.csv', subdirectory = '/resource/datafile')
	IF n_elements(max_speed) EQ 0 THEN max_speed = 12.5
	IF n_elements(scale) EQ 0 THEN scale = 350.0
	IF n_elements(limits) EQ 0 THEN limits = [-41.0, -69.0, 127.0, 219.0]
ENDIF

IF keyword_set(aleks) THEN BEGIN

	IF n_elements(files) EQ 0 THEN BEGIN
		CASE !version.os OF
		 'Win32': files = findfile(filepath('*.dat', subdirectory = '/resource/datafile/aleks'))
		ELSE: MESSAGE, 'Need files definition input '
		ENDCASE
	ENDIF
	IF n_elements(max_speed) EQ 0 THEN max_speed = 90.0
	IF n_elements(scale) EQ 0 THEN	scale = 50.0

ENDIF

;the filtering program will filter all the data in a structure
   ;appending each seal's data to the output structure with
   ;each successive call to read_filtppt

FOR nn = 0, n_elements(files) - 1 DO BEGIN
	file = files(nn)
	len = strlen(file)
	type = strmid(file, len - 4, len)

	CASE type OF
		'.csv':  loc_data = gl2ptt(file)
		'.dat':  BEGIN
			loc_data = argos_data(file)
			IF nn EQ 0 AND n_elements(beasts) NE 0 THEN $
				MESSAGE, 'Specified beasts option not supported for ARGOS.dat file format'
				END
	ELSE:  MESSAGE, file + ' not a supported file type:  .csv, or .dat '
	ENDCASE
	IF n_elements(beasts) EQ 0 THEN beasts = loc_data.ptts(uniq(loc_data.ptts))
	IF n_elements(time0) EQ 0 THEN time0 = min(loc_data.ut_times) -1
	IF n_elements(time1) EQ 0 THEN 	time1 = max(loc_data.ut_times) + 1

	FOR si = 0, n_elements(beasts) -1 DO BEGIN

		;help, time0, time1

		read_filtptt, loc_data, filt_out, beasts(si), $
			time0,  time1, 3, delta_time = 0, $
			max_speed = max_speed, include_ref = 'N'
		;ewprint, filt_out.npts

	ENDFOR

ENDFOR

IF n_elements(filt_out) EQ 0 THEN BEGIN
	print, 'this should contain location data from file: '
	help, loc_data
	print, 'this should contain filtered data but none was returned from filter: '
	help, filt_out
	message, 'No filtered data!! '
ENDIF

good = where(filt_out.ok EQ 'Y')
IF n_elements(limits) EQ 0 THEN $
	limits = [max(loc_data.lats(good)) + 1, min(loc_data.lats(good)) -1, min(loc_data.lons(good)) - 1, max(loc_data.lons(good)) + 1]
CASE n_elements(scale) OF
	2: cell_size = scale
	1: cell_size = [scale, scale]
	0: MESSAGE, 'Scale for gridding program is not specified '
ENDCASE

   ;the gridding program

cells = cell_multi(filt_out, cell_size = [scale, scale], /km, limits = limits)
save, filt_out, filename = 'filt_out.xdr'
save, cells, filename = 'cells.xdr'
print, 'The filtered structure and the time cells structure are saved in IDL format as ''filt.xdr'' and ''cells.xdr''

   ;map the cell data a text file


IF n_elements(labl) EQ 0 THEN BEGIN
	filnm = strmid(file, 0, strlen(file) -4)  + 'cell.csv'
	filtfilnm = strmid(file, 0, strlen(file) -4)  + 'filt.csv'
	gridfilnm = strmid(file, 0, strlen(file) -4)  + 'grid.csv'
	labl = 'data'
ENDIF ELSE BEGIN
	filnm = labl + 'cell.csv'
	filtfilnm = labl + 'filt.csv'
	gridfilnm = labl + 'grid.csv'
	filnm = filepath(filnm, subdirectory = '/resource/datafile')
	filtfilnm = filepath(filtfilnm, subdirectory = '/resource/datafile')
	gridfilnm = filepath(gridfilnm, subdirectory = '/resource/datafile')
ENDELSE

IF keyword_set(file_out) THEN BEGIN

	cell_out, loc_data, cells, to_file = filnm, title = labl
	filt_file, filt_out, filename = filtfilnm
	PRINT, 'Cell data saved as ', filnm
	PRINT, 'Filtered data saved as ', filtfilnm

ENDIF
IF keyword_set(map_data) THEN BEGIN
	;MESSAGE, 'Having trouble with map_data.pro '
	   ;display map_bin data
	;map_data,  filt_out, cells, trkonly = trkonly, track = track, noscale = noscale, nwin = nwin
	map_array, cells, /fronts
	IF keyword_set(jpg) THEN BEGIN
		jpgfile = labl + '.jpg'
		image = tvrd(true = 3)
		write_jpeg, jpgfile, image, true = 3
	ENDIF
ENDIF


  ;output grid data
IF keyword_set(grid) THEN BEGIN
openw, wlun, gridfilnm, /get_lun
	printf, wlun, 'Cell corners grid '
	printf, wlun, 'Longitude ', ',', 'latitude'
	for n = 0, n_elements(cells.xgrid) - 1 do begin
		for m = 0, n_elements(cells.ygrid) - 1 do begin

			printf, wlun, cells.xgrid(n), ',', cells.ygrid(m)
		endfor
	endfor

free_lun, wlun
ENDIF

good = where(filt_out.ok EQ 'Y')
lons = filt_out.lons(good)
lats = filt_out.lats(good)
IF n_elements(limits) EQ 0 THEN limits = [max(lats), min(lats), min(lons), max(lons)]

	 js2ymds, time0, y0, m0, d0, s0
	 sdoy1 = ymd2jd(y0, m0, d0)
	 sdoy0 = ymd2jd(y0, 1, 1)
	 sdoy = sdoy1 - sdoy0
	 js2ymds, time1, y1, m1, d1, s1
	 edoy1 = ymd2jd(y1, m1, d1)
	 edoy0 = ymd2jd(y1, 1, 1)

	 edoy = edoy1 - edoy0


IF keyword_set(colour) THEN BEGIN


	SWfiles = findfile(filepath('*CHLO*', root_dir = 'G:\', subdirectory = 'satdata\SW_chla'))
	files = sat_day(SWfiles, sdoy, edoy, years = [y0], weights = wei)
	sat_sum, files, colmean, alons, alats, limits = limits, label = labl,  weights = wei

	IF keyword_set(map_data) THEN map_array, colmean, alons, alats, /nwin
ENDIF

IF keyword_set(mcsst) THEN BEGIN

	SSTfiles = findfile(filepath('*hdf*', root_dir = 'G:\', subdirectory = 'satdata\mcsst'))
	files = sat_day(SSTfiles, sdoy, edoy, years = [y0], weights = wei2)
	sat_sum, files, sstmean, alons, alats, /orig, limits = limits, label = labl,  weights = wei
	IF keyword_set(map_data) THEN map_array, sstmean, alons, alats, /nwin
ENDIF





END

