;This is a new version of filt_file, written to only output the filtered structure data
;MDSumner 12 Feb 03

PRO filt_file, filt_out, orig_file, filename = filename

IF NOT keyword_set(filename) THEN filename = 'filt_out.txt'
a = ''
openw, lun, filename, /get_lun

printf, lun, 'id' + ',' + 'date' + ',' + 'time' + ',' + 'lon' + ',' + 'lat' + ',' + $
 'ok' + ',' +   'direction' + ',' + 'range' + ',' + 'speed'+ ',' + 'rms'
for n = 0, n_elements(filt_out.ptts) - 1 do begin
	js2ymds, filt_out.ut_times[n], yy, mm, dd, ss
	if mm LT 10 THEN mm = strcompress('0' + string(mm), /remove_all)
	if dd LT 10 THEN dd = strcompress('0' + string(dd), /remove_all)

	sechms, ss, hh, mn, s
	if hh LT 10 THEN hh = strcompress('0' + string(hh), /remove_all)
	if mn LT 10 THEN mn = strcompress('0' + string(mn), /remove_all)
	if s LT 10 THEN s = strcompress('0' + string(s), /remove_all)
	date = string(dd) + '/' + string(mm) + '/' + string(yy)
	date = strcompress(date, /remove_all)
	time = string(hh) + ':' + string(mm) + ':' + string(s)
	time = strcompress(time, /remove_all)
	id = string(filt_out.ptts[n])
	lon = string(filt_out.lons[n])
	lat = string(filt_out.lats[n])
	ok = filt_out.ok[n]
	dir = string(filt_out.directions[n])
	range = string(filt_out.ranges[n])
	speed = string(filt_out.speeds[n])
	rms = string(filt_out.rms[n])
	line = id + ',' + date + ',' + time + ',' +  lon + ',' + lat + ',' + ok + ',' + dir + ',' + range + ',' + speed + ',' + rms
	line = strcompress(line, /remove_all)
	printf, lun, line

	;printf, lun, format = '(5(A256, :, ", "))', id,date,time,lon,lat,ok,dir,range,rms
endfor

free_lun, lun
;free_lun, lun2

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