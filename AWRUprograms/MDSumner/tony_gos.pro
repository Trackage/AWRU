;==============================================================================
; NAME:
;       PEN_GOS
;
; PURPOSE:
;       Read penguin argos data
;
; CATEGORY:
; CALLING SEQUENCE:
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;	  Modified from gl2ptt.pro, which was a program produced by KJM by
;	  modifying one by DJW MDS 02Jul01
;	  Record quality is saved in 'classes', not sure if this is what DJW
;	  intended, gl2ptt defaults this as '3' MDS16Jul01
;
;==============================================================================

FUNCTION tony_gos, filename

   ;if filename not entered then use default

if n_elements(filename) eq 0 then filename = 'mac2000filt1(2).csv'

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

lines = n_elements(a)
;i=0
;b = strarr(1)
;FOR y = 1, lines DO BEGIN
;	bite = strsplit(a(i), ',')
;
	;stop
	;IF n_elements(bite) GT 10 THEN BEGIN
		;IF i EQ 0 THEN b = a(i) ELSE b = [b, a(i)]
	;ENDIF

;	i = i+1
;ENDFOR


   ;determine which file lines contain location data

;loc_data = where(strlen(a(*)) EQ 76, lines)
;argos_data = a(loc_data)

;stop

  ;define arrays to accept data from file
argos_data = a
lines = n_elements(argos_data ) - 1

ut_times = dblarr(lines)
lats   = fltarr(lines)
lons   = fltarr(lines)
classes = strarr(lines)
birds = strarr(lines)
units = strarr(lines)

bits = str_sep(argos_data[0], ',')
latbit = where(bits EQ 'lat')
datebit = where(bits EQ 'date')
datebit = datebit(0)

;colon_pos = strpos(bits[*], ':')
timebit = where(bits EQ 'time')
timebit = timebit(0)
   ;define anchor value

;ik=-1


FOR ik=1, lines DO BEGIN

	;ik = ik + 1

	   ;separate lines of data into variables, space delimited

	bits = str_sep(argos_data[ik], ',')

      lons(ik-1) = bits[latbit + 1]*1.0
      lats(ik-1) = bits[latbit]*1.0

	date_string = bits(datebit)
	classes(ik-1) = bits(datebit -1)


	   ;having trouble with strsplit here, strtok returns the error statement
	   ;that it expects 'string' to be a scalar?  so using str_sep for now,
	   ;MDS 2Jul01

	date = str_sep(date_string, '/')
	day = date[1] * 1
    mth = date[0] * 1
    year = date[2] * 1
	if (year lt 50) then year = ('20'+date[2]) * 1

	if (year lt 100) then year = ('19'+date[2]) * 1
	time = str_sep(bits[timebit], ':')
	sec = time[0]*3600.0 + time[1]*60.0 + time[2]

	ut_time = ymds2js(year,mth,day,sec)
	ut_times(ik-1) = ut_time

	birds(ik-1) = bits(1)
	units(ik-1) = bits(0)



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

return, {npts:npts, $
         profile_nos:intarr(n_elements(npts)), $
	   include_refs:include_refs,	$
 	   min_classes:min_classes,	$
 	   ref_name:ref_name, 	$
 	   ref_lat:ref_lat, 	$
 	   ref_lon:ref_lon,	$
 	   max_speed:	max_speeds,	$
         ptts:birds, $
	   units:units, $
         ut_times:ut_times, $
         lats:lats, $
         lons:lons, $
         classes:classes, $
         ok:ok}


END

