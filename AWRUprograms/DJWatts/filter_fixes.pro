pro filter_fixes, lats, lons, ut_times, ok, rms, max_speed

;+
; Input lats, lons, ut_times, max_speed
;
; Output ok, rms
;-

iarray = n_elements(lats)
pts_per_rms = 4

; delta_time, distance, velocity

good_count = 0l

; pts either side of the point being tested
; if require 5 pts to be tested then need to use 3 on either side

pts_per_side = round(pts_per_rms/2 + 0.1)

; check have enough pts to filter - otherwise no filtering

if ((pts_per_rms + 1) gt iarray) then return


; set logical Need_Filter to true
need_filter = 1
ipass = 0

while (need_filter) do begin
    ipass = ipass + 1

    for i = pts_per_side, iarray - pts_per_side - 1 do begin

	if (ok(i) eq 'Y') then begin
	    sqvel = 0.0

;	loop from this pt down to find pts_per_side pts
	    good_count = 0
	    for j = i-1 ,0 ,-1 do begin
		if (ok(j) eq 'Y') then begin
		    good_count = good_count + 1
		    if (good_count gt pts_per_side) then goto, top_side
		    ll2rb, lons(j), lats(j),lons(i), lats(i), distance, bearing
		    range = distance * !radeg * 60.0 * 1.852  ; km
		    delta_time = abs((ut_times(j) - ut_times(i) ) ) /3600.0

		    if (delta_time gt 0.0d0) then begin
		    	velocity = range / delta_time
		;added this line to zero if 14Feb03MDsumner
		    	sqvel = sqvel + velocity ^ 2
		    endif
	   	endif
	    endfor

;	loop from this pt up to find pts_per_side pts
top_side:   good_count = 0
	    for j = i+1 ,iarray-1 do begin
		if (ok(j) eq 'Y') then begin
		    good_count = good_count + 1
		    if (good_count gt pts_per_side) then goto, end_loop
		    ll2rb, lons(j), lats(j),lons(i), lats(i), distance, bearing
		    range = distance * !radeg * 60.0 * 1.852  ; km
		    delta_time = abs((ut_times(j) - ut_times(i) ) ) / 3600.0
		    if (delta_time gt 0.0d0) then velocity = range / delta_time
;	print, i,j,range, delta_time, velocity
			    sqvel = sqvel + velocity ^ 2
		endif
	    endfor

end_loop:   rms(i) = float(sqvel^0.5)
	if ipass eq 1 then rms_old = rms
	end else begin
	    rms(i) = -1.0
	endelse
    endfor

; now check if any points are still bad but we only mark the
; peak if there is a bunch of them

    need_filter = 0
    previous_peak = 0.0
    last_peak = -1
    for i = 0 , iarray-1 do begin
	if (rms(i) gt max_speed) then begin
	    need_filter = 1
; if no prevous peak remember the peak place and size
; if previous peak then check if larger
	    if ((last_peak eq -1) or $
		(last_peak ne -1 and rms(i) gt previous_peak)) then begin
		previous_peak = rms(i)
		last_peak = i
	    endif
	endif

; now we have good points again so kill the previous
; bad peak
	if ((rms(i) le max_speed) and (ok(i) eq 'Y') and (last_peak ne -1)) then begin
	    rms(last_peak) = -1.0
	    ok(last_peak) = 'N'
	    last_peak = -1
	    previous_peak = 0.0
	endif
    endfor

endwhile

end
