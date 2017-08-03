;==============================================================================
; NAME:	FILTCELLARC
;
; PURPOSE:
;       	Output time spent data for marine beast location data, along with the
;				filtered data, the grid values and corresponding SST and ocean colour
;				mean values.
;
; CATEGORY:
; CALLING SEQUENCE:
; INPUTS:		file - location data file, needs appropriate format of .csv
;				 	comma delimited columns,
;						beast, , , , , , , class, time, date, lon, lat
;						'beast',',',',',',',',',',',',','CLASS',',','TIME',',','DATE',',','LON',',','LAT'
;				{  filt_out - named variable to receive filtered locations
;				{  cells - named variable to receive gridded time spent
;
; KEYWORD PARAMETERS:
;
;				time0 - start time (set to min time in file)
;				time1 - end time  (set to max time in file)
;				beasts - string array of animals from file to use (set to all in file)
;				scale - resolution required (set to 1 degree if not specified (CELL_MULTI)
;				max_speed - speed to filter locations by (set to no filter by default if
;					not specified (READ_FILTPTT)
;				min_class - class of hit for which to filter (all 3 for geolocation)
;				limits - array of geog limits [latmin, lonmin, latmax, lonmax] (set for ellies)
;				map_data - produce image of time spent data (also if /mcsst, /colour set)
;
;				labl - label to delimit this group of beasts (e.g. 'creche' - for file output)
;					-(output files are written to the directory of input file)
;				mcsst - output MCSST data averaged over filtered period
;				colour - ditto for SeaWiFS data
;				topex05 - returns height anomaly data (raw and gradient of smoothed) for the middle of the period
;				arc - if specified, then filtered data is written to file, and time spent data
;					written to arcinfo files
;				cellzero - if specified will produce cell time output with all the zeroes as well, see Aleks Terauds
;				hlp - return some info
;
;
;
; OUTPUTS:
;			These are saved to file, 'filt.xdr', and 'cells.xdr' in IDL format for convenience.
;			filt_out - filtered locations
;			cells - gridded time spent data
;			gridfile
;			time spent file
;			colour and sst files
;			.jpg file of time spent
;
;
; COMMON BLOCKS:
; NOTES:
;		The filtered structure is undefined if it is passed in with value.
;
; MODIFICATION HISTORY:
;			Written 27Aug01 by MDSumner - previous version was seal_track.pro
;			Changed to cell_track2 to incorporate ARGOS files, changed to 'big'
;			version to cope with both types.
;			Filtcellfile becomes filtcellarc, removed the .dat file option to force
;				.csv format, MDSumner23Oct01.
;			Completed topex option, to output the file for the middle time, I
;			don't have time to make SAT_SUM do all this MDS 1Nov01.
;			Added cellzero to output zero cell times from cell_file for ARCinfo, MDS7Nov01.
;			Added crossing_data option for cell drift, MDS 25Mar02
;==============================================================================

PRO filtcellarc, file, filt_out, cells, $
		time0 = time0, $
		time1 = time1, $
		beasts = beasts, $
		scale = scale, $
		max_speed = max_speed, $
		min_class = min_class, $
		limits = limits, $
	   	colour = colour, $
		mcsst = mcsst, $
		topex05 = topex05, $
		arc = arc, $
		map_data = map_data, $
		labl = labl, $
		cellzero = cellzero, $
		crossing_data = crossing_data, $
		hlp = hlp


;ON_ERROR, 2
IF n_elements(file) EQ 0 OR size(file, /type) NE 7 OR keyword_set(hlp) THEN BEGIN
	PRINT, 'Need file input.  Optional are variable names for filtered data and cell time data.'
	PRINT, ''
	PRINT, 'Usage:  filtcellarc, file [, filt, cells, time0 = time0, time1 = time1, beasts = beasts, scale = scale, ' + $
			 'max_speed = max_speed, min_class = min_class, limits = limits, colour = colour, mcsst = mcsst,  ' + $
				' arc = arc, map_data = map_data, labl = labl] '
	PRINT, ''
	PRINT, 'Keyword options:  '
	PRINT, '	time0 = start_time (time0 = ''yyyymmddhhmmss'', e.g. ''20010101000000''
	PRINT, '	time1 = end_time
	PRINT, '	beasts = beasts (e.g. beasts = [''B362'', ''A041''] '
	PRINT, '	scale = scale  (e.g. either scale = 100.0 OR scale = [100.0, 50.0] (i.e [E-W, N-S] in km)) '
	PRINT, '	max_speed = max_speed (e.g. max_speed = 12.5  (km/hr))
	PRINT, '	min_class = min_class (e.g. min_class = ''3'', (one of Z,B,A,0,1,2,3) '
	PRINT, '	limits = limits (limits = [nlat, slat, wlat, elat] e.g. limits = [-40.0, -65.0, 90.0, 220.0]),  '
	PRINT, ''
	PRINT, 'but these limits must be greater than the max extent of the good location data (if not set '
	PRINT, 'they are set automatically by this max extent '
	PRINT, ''
	PRINT, '	labl = labl (e.g. ''G:\user\filturd\arc_ ''',  'this label added to file names so you know what  '
	PRINT, 'group of beasts or what season they are.  Otherwise they will be named solely from the input file name '
	PRINT, ''
	PRINT, 'These remaining options have no value, e.g. filtcellarc, file, /mcsst, /seawifs, /arc, /map_data '
	PRINT, '  they are just switches '
	PRINT, ''
	PRINT, '	mcsst = mcsst  (return ARC text file MCSST data for the filtered period see http://podaac.jpl.nasa.gov/mcsst/ '
	PRINT, '	seawifs = seawifs ',  '(return ARC text file SeaWiFS weekly Level 3 SMI chlorophyll A data for the filtered period '
	PRINT, ''
	PRINT, 'SEE http://seawifs.gsfc.nasa.gov/SEAWIFS.html
	PRINT, 'AND Campbell, J., Blaisdell, JM, and Darzi, M, (1995). Level-3 SeaWiFS Data Products:
	PRINT, '	  Spatial and Temporal Binning Algorithms. In: Hooker, SB, Firestone, ER, and Acker,
	PRINT, '	  JG, (Eds.).  SeaWiFS Project Technical Report Series, NASA Technical Memo.
	PRINT, '	  104566, Vol. 32  NASA Goddard Space Flight Center, Greenbelt, Maryland.
	PRINT, 'AND Sumner, M.D., (2000).  Remote sensing of ocean surface properties: implications
	PRINT, '	  for biological processes. Honours Thesis, Institute of Antarctic and Southern
	PRINT, '	  Ocean Studies, University of Tasmania, Hobart.
	PRINT, ''
	PRINT, '	arc = arc  (return text files of filtered data, cell time spent and cell grid corners for GIS (time spent and
	PRINT, '		satellite data have lons/lats for centres of cells)) '
	PRINT, 'map_data = map_data (provide graphical relief throughout this process '

	RETURN
ENDIF

   ;undefine the filtered structure if input, so as to avoid adding to an old one
undefine, filt_out


   ;first check that file is .csv, extract data if so

exten = strmid(file, strlen(file) - 4, strlen(file))   ;exten is the last 4 characters of the file string
CASE exten OF
	'.csv':  loc_data = readcsv(file)   ;if .csv then extract the data
	ELSE:  MESSAGE, file + ' not a supported file type:  .csv'
ENDCASE

	;make the file label from the input file, else add the specific group tag if provided
IF n_elements(labl) EQ 0 THEN labl = strmid(file, 0, strlen(file) -4) ELSE $
	labl = strmid(file, 0, strlen(file) -4) + labl

openw, hlun, labl + 'help.txt', /get_lun		;open a file to write readme stuff
printf, hlun, 'This file contains a record of what happened when you implemented FILTCELLARC '

   ;check that this produced a structure
IF size(loc_data, /type) NE 8 THEN BEGIN
	printf, hlun, 'Can''t extract data from ' + file
	free_lun, hlun  ;free the help file
	MESSAGE, 'Can''t extract data from ' + file
ENDIF
   ;define the animals, start and end times and filter class from data if not entered
IF n_elements(beasts) EQ 0 THEN beasts = loc_data.ptts(uniq(loc_data.ptts))
IF n_elements(time0) EQ 0 THEN time0 = min(loc_data.ut_times) -1
IF n_elements(time1) EQ 0 THEN 	time1 = max(loc_data.ut_times) + 1
IF n_elements(min_class) EQ 0 THEN min_class = 3
IF n_elements(max_speed) EQ 0 THEN print, 'No max speed filtering will be ', $
 'performed; specify max_speed if required'

   ;filter for animals, times, class, speed
FOR si = 0, n_elements(beasts) -1 DO BEGIN

	mdsread_filtptt, loc_data, filt_out, beasts(si), $
		time0,  time1, min_class, delta_time = 0, max_speed = max_speed, include_ref = 'N'

ENDFOR

   ;check that some filtered data now exists

IF n_elements(filt_out) EQ 0 THEN BEGIN
	printf, hlun,  'this should contain location data from file: '
	print, 'this should contain location data from file: '
	help, loc_data
	printf, hlun,  'this should contain filtered data but none were returned from filter: '
	print, 'this should contain filtered data but none were returned from filter: '
	help, filt_out
	printf, hlun,  'No filtered data!! Check ',   file,  ' contents and filtering specifications '
	free_lun, hlun
	return
	;message, 'No filtered data!! Check ' +  file + ' contents and filtering specifications '
ENDIF

   ;find all the good locations to set limits if not specified, this forces the gridding
   ;program to set an area which is also used for the satellite ocean data output


IF n_elements(limits) EQ 0 THEN BEGIN
	good = where(filt_out.ok EQ 'Y')
	lons = filt_out.lons(good)
	lats = filt_out.lats(good)
	neg = where(lons LT 0.0)
	IF neg(0) NE - 1 THEN lons(neg) = lons(neg) + 360.0
	limits = [max(lats) + 1, min(lats) -1, min(lons) - 1, max(lons) + 1]
	print, 'Limits weren''t specified so ',  limits,  ' determined from data '
	printf, hlun, 'Limits weren''t specified so ',  limits,  ' determined from data '
ENDIF

   ;convert scale to cell_size = [scale, scale] if required

CASE n_elements(scale) OF
	2: cell_size = scale
	1: cell_size = [scale, scale]

	0: BEGIN
		print, 'Scale for gridding program is not specified '
		printf, hlun,  'Scale for gridding program is not specified '
		  ;pick something sensible
		ll2rb, limits(2), limits(0), limits(2), limits(1), cell, azi
		cell_km = fix( (cell/15.0) * !radeg * 60.0 * 1.852) ; km
		cell_size = [cell_km, cell_km]
		print, 'Calculated first guess scale of',  cell_km, '  by', cell_km, ' km grid'
		print, 'If this is silly, then input scale = x (km), or scale = [x, y] (km) '
		printf, hlun, 'Calculated first guess scale of',  cell_km, '  by', cell_km, ' km grid'
		printf, hlun, 'If this is silly, then input scale = x (km), or scale = [x, y] (km) '
	END
ENDCASE

   ;the gridding program, this program's own copy - compare to DJW's cell_multi before I messed with it MDS

cells = mdscell_multi(filt_out, cell_size = cell_size, /km, limits = limits, $
	crossing_data = crossing_data)

	;if not label set then the input file name is used i.e. wherever that file is is where
	;output files will be saved

save, filt_out, filename = labl + 'filt.xdr'
save, cells, filename = labl + 'cells.xdr'
print, 'The filtered structure and the time cells structure are saved in IDL format as ',  $
	strcompress(labl + 'filt.xdr'),  ' and ',  strcompress(labl + 'cells.xdr')
printf,  hlun, 'The filtered structure and the time cells structure are saved in IDL format as ',  $
	strcompress(labl + 'filt.xdr'),  ' and ',  strcompress(labl + 'cells.xdr')

IF keyword_set(arc) THEN BEGIN

	filnm =  labl + 'cell.txt'
	filtfilnm = labl + 'filt.txt'
	gridfilnm = labl + 'grid.txt'

	cell_file, loc_data, cells, to_file = filnm, title = labl, cellzero = cellzero
	filt_file, filt_out, file, filename = filtfilnm
	grid_file, cells, gridfilnm

	PRINT, 'Cell data saved as ', filnm
	PRINT, 'Filtered data saved as ', filtfilnm
	PRINT, 'Grid corners data saved as ', gridfilnm
	PRINTF, hlun,  'Cell data saved as ', filnm
	PRINTF, hlun, 'Filtered data saved as ', filtfilnm
	PRINTF, hlun, 'Grid corners data saved as ', gridfilnm
ENDIF

IF keyword_set(map_data) THEN BEGIN

	map_array, cells, /fronts

		jpgfile = labl + '.jpg'
		image = tvrd(true = 3)
		write_jpeg, jpgfile, image, true = 3
		printf, hlun, 'Image is saved as ',  jpgfile

ENDIF


IF keyword_set(colour) THEN BEGIN

	SWfiles = find_sat_files(time0, time1, /seawifs)

	IF size(SWfiles(0), /type) NE 2 THEN BEGIN
		sat_sum, SWfiles, colmean, alons, alats,  limits = limits, labl = labl
		IF keyword_set(map_data) THEN map_array, colmean, alons, alats, $
			title = 'seawifs - filtered period', /nwin
	ENDIF

	yrfile = find_sat_files(time0, time1, /seawifs, /annual)
	swext, yrfile, yrcol, ylons, ylats, conv = conv
	lim_area, conv, ylons, ylats, ayrcol, aylons, aylats, limits = limits
	sat_file, ayrcol, aylons, aylats, labl + 'YRCOL.txt'
	printf, hlun, 'Colour files for period and for previous year saved as ',  labl,  '**COL.txt'
ENDIF

IF keyword_set(mcsst) THEN BEGIN

	SSTfiles = find_sat_files(time0, time1, /mcsstday)

	IF size(SSTfiles(0), /type) NE 2 THEN BEGIN
		sat_sum, SSTfiles, sstmean, alons, alats, /orig, limits = limits, labl = labl
		IF keyword_set(map_data) THEN map_array, sstmean, alons, alats, /nwin
		printf, hlun, 'SST data for period saved as ',  labl,  '**SST.txt'
	ENDIF
ENDIF


IF keyword_set(topex05) OR keyword_set(topex05) THEN BEGIN
	SSAfiles = find_sat_files(time0, time1,  /topex05)
	IF SSAfiles(0) NE -1 THEN BEGIN
;		sat_sum, SSAfiles, ssamean, alons, alats, /topex, limits = limits, label = labl

		IF n_elements(files) EQ 1 THEN file = SSAfiles(0) ELSE file = SSAfiles(fix(n_elements(files)/2.0))
		ssa_ext, file, harr, hlons, hlats, land = land
		bad = where(harr LT - 9998)
		lim_area, harr, hlons, hlats, harea, halons, halats, limits = limits
 		sat_file, harea, halons, halats, labl + 'ssh.txt', val = 'height'
		printf, hlun, 'Topex data for middle of period saved as ',  labl,  '**ssh.txt'
		;lim_area, landkeep, hlons, hlats, landarea, halons, halats, limits = limits
		;land = where(landarea EQ -9998)
		;bad = where(harea LE -9998)
	;arr(bad) = 0

		;now get the topex gradient
		harrg = harr
		IF not bad(0) EQ -1 THEN harrg(bad) = !values.f_nan
		harrg = smooth(harrg, 5, /nan)
		harrg = sobel(harrg)
		IF not land(0) EQ 0 THEN harrg(land) = -9999
		lim_area, harrg, hlons, hlats, harea, halons, halats, limits = limits
		sat_file, harea, halons, halats, labl + 'gradssh.txt', val = 'grheight'
		IF keyword_set(map_data) THEN map_array, harea, halons, halats, /nwin, title = 'height gradient'
 		printf, hlun, 'SOBEL Gradient of Topex data for middle of period saved as ',  labl,  '**gradssh.txt'
	ENDIF ;ELSE BEGIN

ENDIF

free_lun, hlun

END

