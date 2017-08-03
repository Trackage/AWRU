;==============================================================================
; NAME:
;       MDSREAD_FILTPT
; PURPOSE:
;
; CATEGORY:
; CALLING SEQUENCE:
; INPUTS:
;	  time_start, time_end - 14char date/time string
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
;		B = both - add start/end times of deployment to
;		S = add start times of deployment to array
;		E = add end times of deployment to array
;
; KEYWORD PARAMETERS:
; OUTPUTS:
;	  structure Data
;
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;	  Modified version of Read_argos_data - KM May 2000
;	  Comments added, MDS May 2001.  ;ed out print, MDS May01
;	  Attempt to redesign this for seal purposes from the ground up - KJM and
;	  CJAB simply adopted this from DJW to quickly provide structures of GL data.
;	  Ultimately we want to streamline this specifically for our purposes, MDS Jun01.
;		Modified start and end time variables to accept js values if necessary, MDS 29Aug01.
;		Modified this above js option to redefine input strings as js, so that sat routines
;		 proceeding in FILTCELLARC have this js input, MDS 25Oct01.
;		This is mdsread_filtptt, as used by FILTCELLARC, MDS7Nov01.
;
;==============================================================================

PRO MDSREAD_FILTPTT, input_data, argos_data, $
	ptt, time_start, time_end, min_class, $
	delta_time = delta_time, $
	max_speed = max_speed, $
	include_ref = include_ref, $
	ref_name = ref_name, $
	ref_position = ref_position, $
	profile_no = profile_no

; ---------- initialize record variables ------------

npt			= 0l
speed 		= 0.0
direction 	= 0.0
range 		= 0.0

file_lines = n_elements(input_data.ptts) - 1

if n_elements(profile_no) eq 0 then profile_no = 0

if n_elements(ref_position) eq 0 then ref_position = [0.0, 0.0]

if n_elements(ref_name) eq 0 then ref_name = ''

if n_elements(max_speed) eq 0 then max_speed = -1.0


   ;-- an array for max/min lat lons that we have read from the file

;map_limits = [90.0, 400.0, -90.0, -4000.0]
last_lat  = 0.0   &  last_lon  = 0.0
last_time = 0.0d0

hit_no      = 0l

required_ptt_string = ptt

IF size(time_start, /type) EQ 7 THEN BEGIN
  	 ;-- convert start time string to julian seconds

	reads, time_start, iy, im, id, ihr, imin, isec, format='(i4,5i2)'
	start_time = ymds2js(iy,im,id,(ihr * 3600.0 + imin*60.0 + isec))
	time_start = start_time
  	 ;-- convert end time string to julian seconds

	reads, time_end, iy, im, id, ihr, imin, isec, format='(i4,5i2)'
	end_time = ymds2js(iy,im,id,(ihr * 3600.0 + imin*60.0 + isec))
	time_end = end_time
ENDIF ELSE BEGIN
	start_time = time_start
	end_time = time_end
ENDELSE

   ;--- load structure with start ref point if required --------
   ; Read data from the input array and perform some calculations

found = 0

On_IOerror, eod

found_seal = 0

while 1 do begin

next_read:

	if (npt gt file_lines) then begin
		;print, 'going to eod '
		 goto, eod
	endif

	ptt_string = input_data.ptts[npt]

	ut_time = input_data.ut_times[npt]
	class = input_data.classes[npt]	; always 3!!
	lat = input_data.lats[npt]
	lon = input_data.lons[npt]

	   ;fix the dateline problem (just locally - cell_multi does this permanently)

	lon2 = lon
	if (lon le 0.0) then lon2 = lon + 360.0

	   ; make a local solar time parameter - add 1 hour (3600 s) for each 15 degrees east of Greenwich

	ls_time = ut_time + 3600.0d0*lon2/15.0d0

	   ;increment the counter
	npt = npt + 1

	   ;do we have a match for the seal id?

	if (ptt_string ne ptt) then begin
			;commented out 20Aug01, not sure needed MDS 20 Aug01
		if (found_seal eq 1) then begin
			goto, eod
		endif else begin
			goto, next_read
		endelse
	endif

	   ;check for the end of the desired period with this seal

      ;if (ut_time gt end_time) then goto, eod
      if (ut_time gt end_time) then BEGIN

		goto, next_read
	endif
	   ;only process data which occurs after start time with the desired seal

	if (ut_time ge start_time) then begin

		found_seal =  1

	   	   ;-- Check that this is better than the min class required

    		min_class_index = strpos('ZBA0123',min_class)
    		class_index     = strpos('ZBA0123',class)
    		if class_index lt min_class_index then goto, next_read

	   	   ;-- compute closest distance from last position to this position

    		if hit_no ne 0 then begin

			   ;print, 'hit_no = ', hit_no

			delta_hours = float((ut_time - last_time) / 3600.0)

		   	   ;-- ignore hits too close to last one

			if delta_time gt 0.0 and delta_hours lt delta_time then goto, next_read

			ll2rb, last_lon, last_lat, lon, lat, dist, azi
			;print, last_lon, last_lat, lon, lat, dist, azi

			direction = azi
			range = dist * !radeg * 60.0 * 1.852  ; km

			speed = 0.0

			if ut_time gt last_time then begin

		    		delta_hours = float((ut_time - last_time) / 3600.0)
		    		speed = range / delta_hours ; km/hr

			endif

			;print, 'range = ', range, '  delta_hours = ', delta_hours, '  speed = ', speed

    		endif

    		if hit_no eq 0 then begin

			ptts = [ptt]
			ut_times = [ut_time]
			ls_times = [ls_time]
			lats  = [lat]
			lons = [lon]
			classes = [class]
			speeds = [speed]
			directions = [direction]
			ranges = [range]

		endif else begin

    			ptts = [ptts, ptt]
			ut_times = [ut_times, ut_time]
			ls_times = [ls_times, ls_time]
			lats = [lats, lat]
			lons = [lons, lon]
			classes = [classes, class]
			speeds = [speeds, speed]
			directions = [directions, direction]
			ranges = [ranges, range]

		endelse


    		last_lat = lat
    		last_lon = lon
    		last_time = ut_time
    		hit_no = hit_no + 1


	endif

endwhile

eod:




;print, 'end of valid data reached'

;npt = 0l

   ; comment - I don't think the if loop below would do the right thing, but
   ; we are not using it at the moment anyway - it is utter, utter crap KJM 2001

if include_ref eq 'B' or include_ref eq 'S' then begin
    ptts     = [ptt]
	ut_times = [start_time]
	lats     = [ref_position(0)]
	lons     = [ref_position(1)]
	classes  = [' ']
	speeds   = [0.0]
	directions = [0.0]
	ranges     = [0.0]
	hit_no = hit_no + 1
endif


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
	hit_no        = hit_no + 1
endif

if include_ref eq 'N' then begin
	;changed MDS 20Aug01
	;ptts = [ptt]
	ptts = ptts

endif

if hit_no ge 1 then begin
    ok = replicate('Y', hit_no)
    rms = replicate(0.0, hit_no)

    ; mark as bad any positions where lat/long lt 0.5
    zero_pts = where(abs(lats) le 0.5 or abs(lons) le 0.5, zero_count)
    if zero_count ne 0 then ok(zero_pts) = 'N'

    ; finally filter out any bad high speed fixes
    if (max_speed gt 0.0) then filter_fixes, lats, lons, ut_times, ok, rms, max_speed
endif

; ------- now return structure ---------

;output_data = { $
;		npts: [hit_no], $
;	 	profile_nos:[profile_no], $
;	 	min_classes:[min_class], $
;	 	include_refs:[include_ref], $
;	 	ref_lats:[ref_position(0)], $
;	 	ref_lons:[ref_position(1)], $
;	 	max_speeds:[max_speed], $
 ;    	ptts:ptts, $
;	 	ut_times:ut_times, $
;	 	ls_times:ls_times, $
;	 	lats:lats, $
;	 	lons:lons, $
;	 	classes:classes, $
;	 	speeds:speeds, $
;	 	ok:ok, $
;	 	rms:rms, $
;;	 	directions:directions, $
;	 	ranges:ranges}
;
endprog:

;start of stuff from DJW
; ------- now return structure ---------
; ----- unload structure if it exists otherwise create one ----------
;replacing definition of npt here with hit_no, MDS 20Aug01
;print, ptt


if n_elements(argos_data) eq 0 then begin

    ;if npt ge 1 then begin
    if hit_no ge 1 then begin
    	argos_data = $
		;{ npts: 	[npt],		$
		{npts: [hit_no], $
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
	endif		;removing the empty case MDS 21Aug01
    ;end else begin

    ;	argos_data = $
	;	{ npts: 	[0],		$
	;	profile_nos:    [profile_no],   $
	;	min_classes:	[min_class],	$
	;	include_refs:	[' '],		$
	;	ptts:		[ptt],		$
	;	ut_times: 	[start_time, end_time] }
    ;endelse

endif else begin

   ;trying to exit in event of no locations within this period MDS 20Aug01

	IF hit_no GT 0 THEN BEGIN

	;-- Append new data to existing inputted structure

    ;this has been bodged together to make it work, have to fix for cases other than
    ;include_ref = 'N' MDS 20Aug01
	;npts         = [argos_data.npts, npt]
	npts         = [argos_data.npts, hit_no]
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
	ENDIF
endelse



return
end
