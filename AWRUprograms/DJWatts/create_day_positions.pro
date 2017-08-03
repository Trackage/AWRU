;+
; Argos_system:Create_Day_positions
;
; Given lats/lons and UT times , return replaced vectors of lats/lons at the
; required increment Delta_Time (in hours default = 24 hrs)
; Time is in solar time if the switch /Solar is used
; solar midnight ie start/end day marks. also returns the actual
; solar midnight so user can mark pts with date.
;
; used in argos_map.pro
;
; If time_limits are set then use them to define data returned
; if time limits is longer than data then lats,lons are set to 999 ie missing
;
;  /exclude_ends => dont add day marks outside data bounds
;
; Author DJW 24-apr-96
;-

pro create_day_positions, lats, lons, ut, $
	solar = solar, $
	delta_time = delta_time, $
	time_limits = time_limits, $
	exclude_ends = exclude_ends

time = ut
if keyword_set(solar) then time = ut + lons * 240 ; get local solar time (JHU seconds)
if n_elements(delta_time) eq 0 then delta_time = 24.0 
delta_sec = delta_time * 3600.0d0

;-- get start end time at multiples of delta_sec time
;   ie if delta_sec= 24 hrs then at 00:00 UT or solar
;      if delta_sec= 6 hrs then at 00:00 / 06:00 UT etc

If N_elements(time_limits) eq 0 then begin
    start_day = delta_sec * floor(min(time/delta_sec))
    end_day   = delta_sec * ceil(max(time/delta_sec))
end else begin
    start_day = delta_sec * floor(min(time_limits/delta_sec))
    end_day   = delta_sec * ceil(max(time_limits/delta_sec))
endelse

first = 0

;-- loop over solar midnight pts and find actual data pts either side of it

for k = 0, round((end_day - start_day) / delta_sec) do begin
    day = start_day + k * delta_sec

    below = where(ut lt day, count_below)
    above = where(ut ge day, count_above)
	
    if count_below ne 0 and count_above ne 0 then begin
        ;--- this time fits within actual fixes so 
		
	low_index = below(n_elements(below)-1)  ; last element of below
	high_index = above(0)   		; first element above
	
	;-- assume constant speed between any two fixes
	x = (day - ut(low_index)) / (ut(high_index) - ut(low_index))
	
	dlat  = (lats(high_index) - lats(low_index)) * x  + lats(low_index)

	;-- long may sufferfrom dateline ie from 180 to -180 etc
	lon1 = lons(high_index)
	lon2 = lons(low_index)
	if (lon1 ge 90.0  and lon2 le -90.0) then lon2 = lon2 + 360.0
	if (lon1 le -90.0 and lon2 ge 90.0) then lon1 = lon1 + 360.0
	dlong = (lon1 - lon2) * x  + lon2
	if dlong gt 180.0 then dlong = dlong - 360.0

	if first eq 0 then begin
		day_marks = [day]
		day_lats  = [dlat]
		day_lons  = [dlong]
		first=1
	end else begin
		day_marks = [day_marks, day]
		day_lats  = [day_lats,  dlat]
		day_lons  = [day_lons, dlong]
	endelse
    endif else begin
    	if keyword_set(exclude_ends) eq 0 then begin
    	    if first eq 0 then begin
		day_marks = [day]
		day_lats  = [999.0]
		day_lons  = [999.0]
		first=1
	    end else begin
		day_marks = [day_marks, day]
		day_lats  = [day_lats,  999.0]
		day_lons  = [day_lons, 999.0]
	    endelse
	endif
    endelse
endfor

lats = day_lats
lons = day_lons
ut = day_marks

end
