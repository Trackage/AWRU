;+
; NAME:
; 	Read_argos_data
;
; Inputs   time_start, time_end - 14char date/time string
;         ptt - the PTT required
;         min_class - miniumm quality
;	  max_speed -
;	  ref_name -
;	  profile_no - the number of the profile in the Profiles table
;			(passed to map/listing)
;
;	  ref_position = [lat,long] of reference pt.
; 	  include_ref - a flag to indicate that ref pos be added to
;		N = none -
;		B = both - add start/end times of deployment to argos_data
;		S = add start times of deployment to array
;		E = add end times of deployment to array
; Outputs structure Data
;-

pro read_argos_data, argos_data, $
	ptt, time_start, time_end, min_class, $

	delta_time = delta_time, $
	max_speed = max_speed, $
	ref_name = ref_name, $
	ref_position = ref_position, $
	include_ref = include_ref, $
	profile_no = profile_no

; ---------- initialize record variables ------------

first = 1
ptt_string  = string(replicate(32b,  5))
time_string = string(replicate(32b, 14))
recid       = string(replicate(32b,  4))
filler      = ' '
time        = 0.0d0
sat1        = 0l
;chnq        = string(replicate(32b,  4))
chnq        = bytarr(4)
lind        = 0l
val         = fltarr(32)
indexl      = 0
class       = ' '
error_circle 	= 0.0
speed 		= 0.0
direction 	= 0.0
ut_time 	= 0.0d0
range 		= 0.0

if n_elements(profile_no) eq 0 then profile_no = 0

if n_elements(ref_position) eq 0 then ref_position = [0.0, 0.0]
if n_elements(ref_name) eq 0 then ref_name = ''
if n_elements(max_speed) eq 0 then max_speed = -1.0

;-- an arry for max/min lat lons that we have read from the file
map_limits = [90.0, 400.0, -90.0, -4000.0]
best_lat  = 0.0   &  best_lon  = 0.0
worst_lat = 0.0   &  worst_lon = 0.0
last_lat  = 0.0   &  last_lon  = 0.0
last_time = 0.0d0

hit_no      = 0l

required_ptt_string = string(ptt,format='(i5)')

key_start = required_ptt_string + time_start + recid
key_end   = required_ptt_string + time_end + recid


;-- convert start time string to julian seconds
    reads, time_start, iy, im, id, ihr, imin, isec, format='(i4,5i2)'
    start_time = ymds2js(iy,im,id,(ihr * 3600.0 + imin*60.0 + isec))

;-- convert end time string to julian seconds
    reads, time_end, iy, im, id, ihr, imin, isec, format='(i4,5i2)'
    end_time = ymds2js(iy,im,id,(ihr * 3600.0 + imin*60.0 + isec))

;--- load structure with start ref point if required --------
npt = 0l
if include_ref eq 'B' or include_ref eq 'S' then begin
    	ptts     = [ptt]
	ut_times = [start_time]
	lats     = [ref_position(0)]
	lons     = [ref_position(1)]
	classes  = [' ']
	speeds   = [0.0]
	directions = [0.0]
	ranges     = [0.0]
	npt = npt + 1
endif

on_IOerror, eod
;---- Now read data into structure --------
;openr, unit, 'argos_data:argos.dat', 172,  /get_lun, error = err
   ;modified to learn how this works, MDS 2Oct01
openr, unit, 'argos.dat', 172,  /get_lun, error = err

if (err ne 0) then print, !err_string

while 1 do begin
next_read:
    if (first) then begin
        readu, unit, ptt_string, time_string, recid, filler, 	$
               time, sat1, chnq, lind, val, 			$
               key_id = 0, key_match = 1, key_value = key_start
        first = 0
    endif else begin
        readu, unit, ptt_string, time_string, recid, filler, $
               time, sat1, chnq, lind, val
    endelse


    if ((ptt_string + time_string + recid) gt key_end) then goto, eod

    if (recid eq 'SS  ' or recid eq 'AS  ' or 			$
       (recid eq 'CZ  ' and lind lt indexl)) then goto, next_read

;-- CHNQ is stored as a binary integer
    if chnq(3) le 3 then class = string(chnq(3),format='(i1)')
;-- CHNQ is stored as a left-justified string
    if chnq(0) ne 0 then class = string(chnq(0))

;-- Check that this is better than the min class required
    min_class_index = strpos('ZBA0123',min_class)
    class_index     = strpos('ZBA0123',class)
    if class_index lt min_class_index then goto, next_read

    best_lat = val(0)
    best_lon = val(1)
    worst_lat = val(2)
    worst_lon = val(3)

;-- ensure all lats/long in record are valid
    if best_lat eq 0.0 and best_lon eq 0.0 then begin
        best_lat = worst_lat
        best_lon = worst_lon
    endif
   if worst_lat eq 0.0 and worst_lon eq 0.0 then begin
        worst_lat = best_lat
        worst_lon = best_lon
    endif

;-- convert time string to julian seconds
    reads, time_string, iy, im, id, ihr, imin, isec, format='(i4,5i2)'
    ut_time = ymds2js(iy,im,id,(ihr * 3600.0 + imin*60.0 + isec))

;-- compute closest distance from last position to this position
;   for worst and best fix position - if worst is closer use that.
    if hit_no ne 0 then begin
	delta_hours = float((ut_time - last_time) / 3600.0)

;-- ignore hits too close to last one.
	if delta_time gt 0.0 and delta_hours lt delta_time then goto, next_read
	if delta_hours gt 0.0 then begin
	    speed = range / delta_hours ; km/hr
	endif

	ll2rb, last_lon, last_lat, worst_lon, worst_lat, worst_dist, worst_azi
	ll2rb, last_lon, last_lat, best_lon, best_lat, best_dist, best_azi
	direction = best_azi
	range = best_dist * !radeg * 60.0 * 1.852  ; km
	if worst_dist lt best_dist then begin
	    best_lat = worst_lat
	    best_lon = worst_lon
	    direction = worst_azi
	    range = worst_dist * !radeg * 60.0 * 1.852  ; km
	endif

	speed = 0.0
	if ut_time gt last_time then begin
	    delta_hours = float((ut_time - last_time) / 3600.0)
	    speed = range / delta_hours ; km/hr
	endif
    endif

;-------------------------------
    npt = npt + 1

    if npt eq 1 then begin
    	ptts = [ptt]
	ut_times = [ut_time]
	lats  = [best_lat]
	lons = [best_lon]
	classes = [class]
	speeds = [speed]
	directions = [direction]
	ranges = [range]
    endif else begin
    	ptts = [ptts, ptt]
	ut_times = [ut_times, ut_time]
	lats = [lats, best_lat]
	lons = [lons, best_lon]
	classes = [classes, class]
	speeds = [speeds, speed]
	directions = [directions, direction]
	ranges = [ranges, range]
    endelse


    last_lat = best_lat
    last_lon = best_lon
    last_time = ut_time
    hit_no = hit_no + 1
endwhile

eod:

; return an array of lats and lons for mapping


free_lun, unit

;--- add end ref point if required --------

if include_ref eq 'B' or include_ref eq 'E' then begin

	ll2rb, last_lon, last_lat, best_lon, best_lat, dist, direction
	range = dist * !radeg * 60.0 * 1.852  ; km

	speed = 0.0
	if end_time gt last_time then begin
	    delta_hours = float((end_time - last_time) / 3600.0)
	    speed = range / delta_hours ; km/hr
	endif

    	ptts       = [ptts, ptt]
	ut_times   = [ut_times, end_time]
	lats       = [lats, ref_position(0)]
	lons       = [lons, ref_position(1)]
	classes    = [classes,' ']
	speeds     = [speeds, speed]
	directions = [directions, direction]
	ranges     = [ranges, range]
	npt        = npt + 1
endif


if npt ge 1 then begin
    ok = replicate('Y', npt)
    rms = replicate(0.0, npt)

    ; mark as bad any positions where lat/long lt 0.5
    zero_pts = where(abs(lats) le 0.5 or abs(lons) le 0.5, zero_count)
    if zero_count ne 0 then ok(zero_pts) = 'N'

    ; finally filter out any bad high speed fixes
    if (max_speed gt 0.0) then filter_fixes, lats, lons, ut_times, ok, rms, max_speed
endif

; ------- now return structure ---------
; ----- unload structure if it exists otherwise create one ----------

if n_elements(argos_data) eq 0 then begin
    if npt ge 1 then begin
    argos_data = $
	{ npts: 	[npt],		$
	profile_nos:	[profile_no],   $
	min_classes:	[min_class],	$
	include_refs:	[include_ref],	$
	ref_name:	[ref_name],	$
	ref_lat:	[ref_position(0)], $
	ref_lon:	[ref_position(1)], $
	max_speed:	[max_speed],	$

	ptts:		ptts,		$
	ut_times: 	ut_times, 	$
	lats: 		lats, 		$
	lons:		lons, 		$
	classes:	classes,	$
	speeds:		speeds,		$
	ok:		ok,		$
	rms:		rms,		$
	directions:	directions,	$
	ranges:		ranges}
    end else begin

    argos_data = $
	{ npts: 	[0],		$
	profile_nos:    [profile_no],   $
	min_classes:	[min_class],	$
	include_refs:	[' '],		$
	ptts:		[ptt],		$
	ut_times: 	[start_time, end_time] }
    endelse

endif else begin

	;-- Append new data to existing inputted structure

	npts         = [argos_data.npts, npt]
	profile_nos  = [argos_data.profile_nos, profile_no]
	min_classes  = [argos_data.min_classes, min_class]
	include_refs = [argos_data.include_refs, include_ref]
	ref_names    = [argos_data.ref_name, ref_name]
	ref_lats     = [argos_data.ref_lat, ref_position(0)]
	ref_lons     = [argos_data.ref_lon, ref_position(1)]
	max_speeds   = [argos_data.max_speed, max_speed]

    	ptts         = [argos_data.ptts, ptts]
	ut_times     = [argos_data.ut_times, ut_times]
	lats         = [argos_data.lats, lats]
	lons         = [argos_data.lons, lons]
	classes      = [argos_data.classes, classes]
	speeds       = [argos_data.speeds, speeds]
	ok	     = [argos_data.ok, ok]
	rms	     = [argos_data.rms, rms]
	directions   = [argos_data.directions, directions]
	ranges       = [argos_data.ranges, ranges]

    argos_data = $
	{npts: 		npts,		$
	profile_nos:    profile_nos,    $
	min_classes:	min_classes,	$
	include_refs:	include_refs,	$
	ref_name:	ref_names,	$
	ref_lat:	ref_lats, 	$
	ref_lon:	ref_lons,	$
	max_speed:	max_speeds,	$

	ptts:		ptts,		$
	ut_times: 	ut_times, 	$
	lats: 		lats, 		$
	lons:		lons, 		$
	classes:	classes,	$
	speeds:		speeds,		$
	ok:		ok,		$
	rms:		rms,		$
	directions:	directions,	$
	ranges:		ranges}
endelse

return
end
