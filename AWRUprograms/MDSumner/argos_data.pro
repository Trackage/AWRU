;==============================================================================
; NAME:
;       ARGOS_DATA
;
; PURPOSE:
;       Read argos location data
;
; CATEGORY:
; CALLING SEQUENCE:
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;				Renamed version of PEN_GOS, see its history:
;
;;;;; Modified from gl2ptt.pro, which was a program produced by KJM by
;;;;; modifying one by DJW MDS 02Jul01
;;;;; Record quality is saved in 'classes', not sure if this is what DJW
;;;;; intended, gl2ptt defaults this as '3' MDS16Jul01
;
;   Michael Sumner, 4Oct01
;==============================================================================

FUNCTION argos_data, filename

ON_ERROR, 2
   ;if filename not entered then use default

;if n_elements(filename) eq 0 then filename = 'mac01201.log'

   ;open the file, returning nonzero error value to i if it occurs

openr, unit, filename, /get_lun, ERROR=i

   ;if error occurs

if i lt 0 then begin
	return, [ !err_string, ' Can not display ' + filename]

endif else begin

	   ;Maximum # of lines in file

	maxlines = 5000

	   ;a will contain strings of each line from the file

	a = strarr(maxlines)

	   ;read the file into a, goto label if i/o error

	on_ioerror, done_reading
	readf, unit, a

	done_reading: s = fstat(unit)		;Get # of lines actually read, null the error

	a = a[0: (s.transfer_count-1) > 0]
	on_ioerror, null
	FREE_LUN, unit

endelse

;ID_start = strpos(filename, '_') -2
;ID_end = strlen(filename) -8
;ID = strmid(filename,ID_start, ID_end)

lines = n_elements(a)
i=0
;b = strarr(1)
FOR y = 1, lines DO BEGIN
	bite = str_sep(a(i), ' ')


	IF n_elements(bite) EQ 21 THEN BEGIN
		;IF i EQ 0 THEN b = a(i) ELSE b = [b, a(i)]
		IF n_elements(b) EQ 0 THEN b = a(i) ELSE b = [b, a(i)]
	ENDIF
	i = i+1
ENDFOR


   ;determine which file lines contain location data

;loc_data = where(strlen(a(*)) EQ 76, lines)
;argos_data = a(loc_data)

;stop

  ;define arrays to accept data from file
IF n_elements(b) EQ 0 THEN MESSAGE, 'No valid data extracted from ' + filename
argos_data = b
lines = n_elements(argos_data)

ut_times = dblarr(lines)
lats   = fltarr(lines)
lons   = fltarr(lines)
classes = strarr(lines)
ptts = strarr(lines)
birds = strarr( lines)
dates = strarr(lines)
times = strarr(lines)

   ;define anchor value

ik=-1

FOR i=0, lines -1 DO BEGIN

	ik = ik + 1

	   ;separate lines of data into variables, space delimited

	bits = str_sep(argos_data[i], ' ')

	   ;detect the lat, date and time value

	;hyphen_pos = strpos(bits[*], '-')
	;latbit = where(hyphen_pos EQ 0)
	;datebit = where(hyphen_pos EQ 4)

	;colon_pos = strpos(bits[*], ':')
	;timebit = where(colon_pos EQ 2)

      lons(ik) = bits[13]*1.0
      lats(ik) = bits[11]*1.0

	;date_string = bits(6)
	classes(ik) = bits(8)


	   ;having trouble with strsplit here, strtok returns the error statement
	   ;that it expects 'string' to be a scalar?  so using str_sep for now,
	   ;MDS 2Jul01
	date_string = bits(9)
	date = str_sep(date_string, '-')
	;date = bits(datebit)
	;date = str_sep(date, '-')
	day = date[2] * 1
    mth = date[1] * 1
    year = date[0] * 1

	time = str_sep(bits[10], ':')
	;time = bits(10)
	sec = time[0]*3600.0 + time[1]*60.0 + time[2]

	ut_time = ymds2js(year,mth,day,sec)
	ut_times(ik) = ut_time

	birds(ik) = bits(1)
	;dates(ik) = date_string
	;times(ik) = bits(7)
	ptts(ik) = bits(0)

ENDFOR

;bird = bits[0]
;return, {bird:bird, lons:lons, lats:lats, ut_times:ut_times, quality:quality}

   ;find the number of different seals in the data file

unique_ids = birds(uniq(birds))

   ;ix is array of subscripts for unique seals in 'seals' array

for k=0, n_elements(unique_ids)-1 do begin

    ix = where(birds eq unique_ids(k),ixc)

   	;npts is array with # of mentions of kth seal in 'seals' array,
	;this next line concatenates successive ix arrays of these numbers

    if k eq 0 then npts = [ixc] else npts = [npts, ixc]

endfor





   ;prepare the padding data for the ARGOS data format

ok           = replicate('Y',lines)
;classes      = replicate('3',lines)
min_classes  = replicate('3',lines)
include_refs = replicate('N',lines)
ref_name     =  replicate('',lines)
ref_lat      =  replicate(0.0,lines)
ref_lon      =  replicate(0.0,lines)
max_speeds   =  replicate(0.0,lines)

;print, 'npts ', npts
;print, 'birds', birds
;print, 'lons ', lons
;print, 'lats', lats
;print, 'times', ut_times
return, {npts:npts, $
         profile_nos:intarr(n_elements(npts)), $
	   include_refs:include_refs,	$
 	   min_classes:min_classes,	$
 	   ref_name:ref_name, 	$
 	   ref_lat:ref_lat, 	$
 	   ref_lon:ref_lon,	$
 	   max_speed:	max_speeds,	$
         ptts:birds, $
         ut_times:ut_times, $
         lats:lats, $
         lons:lons, $
         classes:classes, $
         ok:ok, $
         dates:dates, $
         times:times, $
         birds:birds}


END

