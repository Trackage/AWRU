;==============================================================================
; NAME:	CELL_TRACK
;
; PURPOSE:
;       	Output time spent data for marine beast location data
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
;
;==============================================================================

PRO cell_track, file, filt_out, cells, $
		time0 = time0, $
		time1 = time1, $
		beasts = beasts, $
		scale = scale, $
		max_speed = max_speed, $
		limits = limits, $
		map_data = map_data, $
		trkonly = trkonly, $
		snake = snake, $
		dbllons = dbllons, $
		tony = tony, $
		labl = labl, $
		aleks = aleks, $
		track = track, $
		noscale = noscale, $
		nwin = nwin

ON_ERROR, 2
;IF n_elements(filt_out) NE 0 THEN  message, 'named variable of filtered data already ' $
	;' exists, rename a new one or undefine it or new data will be concatenated to it'
   ;run snake or tony's params

IF keyword_set(snake) THEN snake_key, limits, scale, time0, time1, $
					max_speed, loc_data, beasts = beasts, file,  dbllons = dbllons
IF keyword_set(tony) THEN tony_key, limits, scale, time0, time1, $
					max_speed, loc_data, beasts, file
IF n_elements(file) EQ 0 THEN file = filepath('sealplex2.csv', subdirectory = '/resource/datafile')
IF n_elements(loc_data) EQ 0 and not keyword_set(aleks) THEN loc_data = gl2ptt(file)
IF keyword_set(aleks) THEN BEGIN

	loc_data = pen_gos(file)

	max_speed = 90.0
	scale = 50.0
	;limits = [-40.0, -70.0, 135.0, 210.0]
	limits = [max(loc_data.lats) + 1, min(loc_data.lats) -1, min(loc_data.lons) - 1, max(loc_data.lons) + 1]
ENDIF
IF n_elements(beasts) EQ 0 THEN beasts = loc_data.ptts(uniq(loc_data.ptts))
IF n_elements(limits) EQ 0 AND NOT keyword_set(tony) THEN limits = [-41.0, -69.0, 127.0, 219.0]
IF n_elements(time0) EQ 0 THEN time0 = min(loc_data.ut_times) -1
IF n_elements(time1) EQ 0 THEN 	time1 = max(loc_data.ut_times) + 1
IF n_elements(max_speed) EQ 0 THEN max_speed = 12.5
IF n_elements(scale) EQ 0 THEN scale = 350.0

IF n_elements(file) EQ 0 THEN BEGIN
	file = 'sealplex2.csv'
	file = filepath(file, subdirectory = '/resource/datafile')
ENDIF

;the filtering program will filter all the data in a structure
   ;appending each seal's data to the output structure with
   ;each successive call to read_filtppt

FOR si = 0, n_elements(beasts) -1 DO BEGIN

help, time0, time1
	read_filtptt, loc_data, filt_out, beasts(si), $
		time0,  time1, 3, delta_time = 0, $
		max_speed = max_speed, include_ref = 'N'

ENDFOR
stop
IF n_elements(filt_out) EQ 0 THEN BEGIN
	print, 'this should contain location data from file: '
	help, loc_data
	print, 'this should contain filtered data but none was returned from filter '
	help, filt_out
	message, 'No filtered data!! '
ENDIF

   ;the gridding program

cells = cell_multi(filt_out, cell_size = [scale, scale], /km, limits = limits)
save, filt_out, filename = 'filt.xdr'
save, cells, filename = 'cells.xdr'

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
ENDIF
IF keyword_set(map_data) THEN BEGIN
	   ;display map_bin data
	map_data,  filt_out, cells, trkonly = trkonly, track = track, noscale = noscale, nwin = nwin

	jpgfile = labl + '.jpg'
	image = tvrd(true = 3)
	write_jpeg, jpgfile, image, true = 3
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


;wset, 0




END

