;+
;   NAME
;       Read_GLTDR
; 
;       Read Geo-Location TDR data (GLTDR) as ouputted
;       from a PC that analyses the light levels and computes
;       day (and sometimes night) positions.
; 
;       Output data structure is compatiable with ARGOS analysis routines
;
;       DJW Mar 2000
;-


function read_gltdr, filename

if n_elements(filename) eq 0 then filename = '1999_gltdr.csv'


openr, unit, filename, /get_lun, ERROR=i		;open the file and then
if i lt 0 then begin		;OK?
	    return, [ !err_string, ' Can not display ' + filename]  ;No
endif else begin
	  maxlines = 600000l		;Maximum # of lines in file
	  a = strarr(maxlines)
	  on_ioerror, done_reading
	  readf, unit, a
done_reading: s = fstat(unit)		;Get # of lines actually read
	  a = a[0: (s.transfer_count-1) > 0]
	  on_ioerror, null
	  FREE_LUN, unit				;free the file unit.
endelse

good_lines = where(a ne '',iok)
a = a(good_lines)

ut_times = dblarr(n_elements(a))
lats   = fltarr(n_elements(a))
lons   = fltarr(n_elements(a)) 
brands = strarr(n_elements(a))

col=define_colours()
ik=-1
;print,'array ', n_elements(a)
for i=0l,n_elements(a)-1 do begin
;for i=0,10 do begin
    g = strparse(a(i), ',/:',chunks)
;print,chunks
    if g ge 8 then begin
        day = chunks(1) * 1
        mth = chunks(2) * 1
        year = chunks(3) * 1 
        sec = chunks(4)*3600.0 + chunks(5) * 60.0 + chunks(6)
        ut_time = ymds2js(year,mth,day,sec) 
    
        ik = ik + 1
        brands(ik) = chunks(0)
        ut_times(ik) = ut_time
        lons(ik)    = chunks(7)*1.0
        lats(ik)    = chunks(8)*1.0
    endif

endfor

good_data = where(brands ne '')
brands = brands(good_data)

unique_ids = brands(uniq(brands))
for k=0,n_elements(unique_ids)-1 do begin
    ix = where(brands eq unique_ids(k),ixc)
    if k eq 0 then npts = [ixc] else npts = [npts, ixc]
endfor

;-- check for any recalitrant times, ie sequences that reverse in time per PTT/Brand
start_pt = 0l
for j = 0, n_elements(npts)-1 do begin
    end_pt = start_pt + npts(j) - 1
    times = ut_times(start_pt:end_pt)
    ;print, npts(j), start_pt, end_pt
    ;window,j
    ;plot, times
    last = n_elements(times)-1
    delta_times = times(1:last) - times(0:last-1)
    bad_times = where(delta_times lt 0.0,ibad)
    if ibad ne 0 then begin
        times(bad_times) =  times(bad_times) - 86400.0d0  ;-- remove one day
        ut_times(start_pt:end_pt) = times
    endif
    
    ;oplot, times, color=col.yellow

    start_pt = end_pt + 1
endfor

;times = times(good_data) - lons(good_data) * 144.0   ; in UT

ok           = replicate('Y',n_elements(brands))
classes      = replicate('3',n_elements(brands))
min_classes  = replicate('3',n_elements(brands))
include_refs = replicate('N',n_elements(brands))
ref_name     =  replicate('',n_elements(brands))
ref_lat      =  replicate(0.0,n_elements(brands))
ref_lon      =  replicate(0.0,n_elements(brands))
max_speeds   =  replicate(0.0,n_elements(brands))

return, {npts:npts, $
         profile_nos:intarr(n_elements(npts)), $
	   include_refs:include_refs,	$
 	   min_classes:min_classes,	$
 	   ref_name:ref_name, 	$
 	   ref_lat:ref_lat, 	$
 	   ref_lon:ref_lon,	$
 	   max_speed:	max_speeds,	$
 
         ptts:brands(good_data), $
         ut_times:ut_times(good_data), $
         lats:lats(good_data), $
         lons:lons(good_data), $
         classes:classes, $
         ok:ok}
         
         
end


;	speeds:		speeds,		$
;	rms:		rms,		$
;	directions:	directions,	$
;	ranges:		ranges}
