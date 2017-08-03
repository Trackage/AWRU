;==============================================================================
; NAME:
;       ARGOS2CSV
;
; PURPOSE:
;       Read argos location data from .dat files and make a standard format
;			.csv file for filtering.  I.e. beast from 2nd column of .dat file
;			then 6 empty columns, then class, time, date, lon, lat
;
;	'beast',',',',',',',',',',',',','CLASS',',','TIME',',','DATE',',','LON',',','LAT'
;
; CATEGORY:
; CALLING SEQUENCE:	ARGOS2CSV, files, csvname [, beasts]
;
; INPUTS:			files - array of .dat files (these would each contain one tracking
;						'event')
;					csvname - name for output file
;
; KEYWORD PARAMETERS:       beasts - array of IDs for animals, corresponding to
;								files
;
;
; OUTPUTS:			CSV file incorporating all input files
;
; COMMON BLOCKS:
; NOTES:	E.G. names for the beasts keyword
;
;			;take the file names array and extract the relevant ID
;		files = findfile(filepath('*.dat', subdirectory = '/resource/datafile/aleks'))
;;			;files(0) = 'C:\Program Files\RSI\IDL52\/resource/datafile/aleks\20874_00.dat'
;		beasts = files
;		for n = 0, n_elements(files) - 1 do beasts(n) = strmid(files(n), rstrpos(files(n), '\') + 1, 8)
;
; MODIFICATION HISTORY:
;				Taken from GL2PTT.PRO Michael Sumner, 23Oct01
;==============================================================================

PRO argos2csv, files, csvname, beasts = beasts

ON_ERROR, 2
   ;if filename not entered then use default

;if n_elements(filename) eq 0 then filename = 'mac01201.log'

openw, lun, csvname, /get_lun
printf, lun, 'ptt',',',',',',',',',',',',','CLASS',',','TIME',',','DATE',',','LON',',','LAT'


for n = 0 , n_elements(files) - 1 do begin

	   ;open the file, returning nonzero error value to i if it occurs
	filename = files(n)
	openr, unit, filename, /get_lun, ERROR=i

	   ;if error occurs

	if i lt 0 then begin
		print, 'Error '
		return;,  !err_string, ' Can not display ' + filename

	endif else begin

		   ;Maximum # of lines in file

		maxlines = 50000

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

		;must undefine b here, or it will continue to concatenate!
	undefine, b

	FOR y = 1l, lines DO BEGIN
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

	   ;define anchor value

	ik=-1

	FOR i=0, lines -1 DO BEGIN

		ik = ik + 1

		   ;separate lines of data into variables, space delimited

		bits = str_sep(argos_data[i], ' ')
		ptt = bits(0)
		beast = bits(1)
	      lon = bits[13]
	      lat = bits[11]

		;date_string = bits(6)
		class = bits(8)


		date_string = bits(9)
		date = str_sep(date_string, '-')

		date_string = date(2) + '/' + date(1) + '/' + date(0)

		time = bits[10]


		IF keyword_set(beasts) THEN BEGIN
			;IF beasts(n) EQ '20875_00' AND i Gt 225 THEN stop
			printf, lun, beasts(n),',',',',',',',',',',',',class,',',time,',',date_string,',',lon,',',lat
		ENDIF ELSE BEGIN
		printf, lun, beast,',',',',',',',',',',',',class,',',time,',',date_string,',',lon,',',lat
		ENDELSE

	ENDFOR
		;print, beasts, beast
		;stop
endfor

free_lun, lun
END

