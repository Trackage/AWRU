;+
;  NAME:
;      OPLOTMAP
;
;  Purpose:
;
;      Read a national mapping AS2482-1984 map file and overplot it on
;      the current graphics. Look for position data in records between
;      feature header records, which are identified by F or f as the
;      first character.
;
;      Default format is AS2482
;
;      Can accept Arc-info Generate format (format_type = 'ARC'
;      See example below
; 
;             1
;             43.844597        -67.997124
;             43.844532        -67.996750
;      END
;             2
;             43.846519        -67.999077
;             43.845737        -67.998360
;             43.844673        -67.997574
;             43.844597        -67.997124
;      END
;      END  <---- Note double END to end data file
;
;   Usage:
;       oplotmap, mapname, colour=cull
;       
;       where mapname is the full pathname of a map. *.GEO maps
;       are assumed to be ArcInfo derived maps. The map is plotted
;       with the colour index cull.
;
;  Modified by DJW 14-Feb-1996 to include ARCinfo formats
;-

pro oplotmap, mapname, colour=cull, _extra = extra

;;on_error, 2
if n_params() lt 1 then message, 'OPLOTMAP: No map filename passed in'
;b = size(mapname)

if (not keyword_set(cull)) then cull=!p.color

format_type = 'AS2482'
if (strpos(strlowcase(mapname), '.geo') ne -1) then format_type = 'GEO'
if (strpos(strlowcase(mapname), '.arc') ne -1) then format_type = 'ARC'
if strlowcase(mapname) eq 'idl_world.dat' then format_type = 'IDL'

;;on_ioerror, error_found


lon = 0.0
lat = 0.0
sline = 'An initial string'

case format_type of
 'IDL': begin
	map_continents, /hires, /coasts, color=cull
	goto, idl_finish
    end

 'AS2482': begin
    openr,   unit, mapname, /GET_LUN
    while (not eof(unit)) and (strmid(sline, 0, 1))  ne 'F' do begin
       readf, unit, sline, format='(a)'
    endwhile

    as_loop:  readf,      unit, sline
	sline     = strcompress (strtrim(sline, 2))
	space     = strpos      (sline, ' ')
	lon       = strmid      (sline, 0, space-1)
	lat       = strmid      (sline, space+1, strlen(sline))
	lons      = [lon]
        lats      = [lat]
	if not eof(unit) then readf,      unit, sline
	while (not eof(unit)) and (strmid(sline, 0, 1))  ne 'F' do begin
	    sline = strcompress (strtrim(sline, 2))
	    space = strpos      (sline, ' ')
	    lon   = strmid      (sline, 0, space-1)
	    lat   = strmid      (sline, space+1, strlen(sline))
	    lons  = [lons, lon]
	    lats  = [lats, lat]
	    readf,   unit, sline
	endwhile
	size_of_lats = size(lats)
	if size_of_lats(1) ge 2 then oplot, lons, lats, color=cull, _extra=extra
	if not eof(unit) then goto, as_loop
	goto, finish
    end
    
    
  'GEO': begin
    openr,   unit, mapname, /GET_LUN
    ; read any initial blanks/rubbish
    ;    readf, unit, sline
    ;    readf, unit, sline
    segment_no = 0l
    
    geo_loop: 
	readf, unit, sline
        if sline eq ' ' then goto, geo_loop
        if strcompress(sline) eq 'END' then goto, finish
    	reads, sline, segment_no
	readf, unit, sline
	ipts = 0

; now loop over a segment until an 'END' is encountered
	while strcompress(sline) ne 'END' do begin
    	    reads, sline, lon, lat
	    ipts = ipts + 1
	    if ipts eq 1 then begin
		lons = [lon]
		lats = [lat]
	    endif else begin
		lons  = [lons, lon]
		lats  = [lats, lat]
	    endelse
	    readf, unit, sline
	endwhile

	size_of_lats = size(lats)
	if size_of_lats(2) ge 2 then oplot, lons, lats, color=cull, _extra=extra
	goto, geo_loop
    end
    
  'ARC': begin
    openr,   unit, mapname, /GET_LUN
    feature_code = 0l
    no_of_pts = 0l
       
    arc_loop: 
     
    while not eof(unit) do begin
     readf, unit, feature_code, no_of_pts
     if feature_code eq -99 then goto, finish
     
	for k=0, no_of_pts -1  do begin
    	    readf, unit, lat, lon
	    if k eq 0 then begin
		lons = [lon]
		lats = [lat]
	    endif else begin
		lons  = [lons, lon]
		lats  = [lats, lat]
	    endelse
	endfor

	if max(lons) gt 180.0 then lons = lons - 360.0

;	if feature_code le 10000 then begin
	    size_of_lats = size(lats)
	    if size_of_lats(2) ge 2 then oplot, lons, lats, color=cull, _extra=extra
;	endif
	endwhile
    end
    
 else: begin
	
    	print,'OPLOTMAP: Error - Unknown map filetype of ', format_type
    	goto, finish
    end
endcase

error_found: print,'OPLOTMAP: I/O error found with file ',mapname

finish:

free_lun, unit

idl_finish:

end
