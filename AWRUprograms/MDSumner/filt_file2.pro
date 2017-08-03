PRO filt_file2, filt_out, orig_file, filename = filename

IF NOT keyword_set(filename) THEN filename = 'filt_out.txt'
a = ''
openw, lun, filename, /get_lun
openr, lun2, orig_file, /get_lun
readf, lun2, a
commas = strpos(a, ',,,,,')
strstart = strmid(a, 0, commas)
strend = strmid(a, commas + 5, strlen(a))
a = strstart + strend
printf, lun, format = '(5(A, :, ", "))', a, 'ok',  'direction', 'range',  'speed'
for n = 0, n_elements(filt_out.ptts) - 1 do begin
	a = ''
	readf, lun2, a
	commas = strpos(a, ',,,,,')
	strstart = strmid(a, 0, commas)
	strend = strmid(a, commas + 5, strlen(a))
	b = strstart + strend

	;a = str_sep(a, ',')
	;printf, lun, a, ',', filt_out.ok(n), ',', filt_out.directions(n), ',', filt_out.ranges(n), ',', filt_out.rms(n)
	;b = b, ',',  string(filt_out.ok(n)), ',', string(filt_out.directions(n)), ',', string(filt_out.ranges(n)), ',', string(filt_out.rms(n))]
	;b = strcompress( b + ',' +  string(filt_out.ok(n)) +  ',' +  string(filt_out.directions(n)) +  ',' +  $
	;	string(filt_out.ranges(n)) +  ',' +  string(filt_out.rms(n)))
	printf, lun, format = '(5(A, :, ", "))', b,  filt_out.ok(n),  filt_out.directions(n),  filt_out.ranges(n),  filt_out.rms(n)
	;printf, lun, b

endfor

free_lun, lun
free_lun, lun2

end



;NPTS            LONG      Array[24]
 ;  PROFILE_NOS     INT       Array[24]
  ; MIN_CLASSES     INT       Array[24]
   ;INCLUDE_REFS    STRING    Array[24]
;   REF_NAME        STRING    Array[24]
 ;  REF_LAT         FLOAT     Array[24]
  ; REF_LON         FLOAT     Array[24]
 ;  MAX_SPEED       FLOAT     Array[24]
 ;  PTTS            STRING    Array[1143]
 ;  UT_TIMES        DOUBLE    Array[1143]
 ;  LATS            FLOAT     Array[1143]
 ;  LONS            FLOAT     Array[1143]
  ; CLASSES         STRING    Array[1143]
 ;  SPEEDS          FLOAT     Array[1143]
 ;  OK              STRING    Array[1143]
 ;  RMS             FLOAT     Array[1143]
 ;  DIRECTIONS      FLOAT     Array[1143]
  ; RANGES          FLOAT     Array[1143]