;-------------------------------------------------------------
;+
; NAME:
;       MAP_PUT_SCALE
; PURPOSE:
;       Embed map coordinates info in image.
; CATEGORY:
; CALLING SEQUENCE:
;       map_put_scale
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         NOBORDER=nb  Indicate if /NOBORDER keyword was used
;            in map_set.  Tries to guess if not given.
;            Guess is pretty good, but must give for /MILLER
;            if /NOBORDER and /HORIZON used. Maybe other cases.
;         LIMIT=lim  Given limit (needed for Satellite proj).
;         SC_STR=sc_str  Scaling string, send or return.
;         /NOEMBED means just return the string (SC_STR).
;         /EMBED means embed given scaling string (SC_STR).
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Must use after a map_set command, before any other
;         commands that change cordinates (like plot).
;         Needs 307 pixels along the image bottom.
;         Allows an image of a map to be loaded later and have
;         data overplotted or positions read.
;         See also map_set_scale which sets up map coordinate
;         system using this embedded info.
;         If an image is remapped onto map it may confuse this
;         routine.  May grab scaling string first using SC_STR
;         and /NOEMBED, do the remapping, then add the string
;         using SC_STR and /EMBED.
; MODIFICATION HISTORY:
;       R. Sterner, 1996 Mar 20
;       R. Sterner, 1999 Aug 30 --- Revised.
;
; Copyright (C) 1996, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro map_put_scale, noborder=noboder, limit0=limit0, $
	  sc_str=sc_str, noembed=noembed, embed=embed, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Embed map coordinates info in image.'
	  print,' map_put_scale'
	  print,'   Any args are keywords.'
	  print,' Keywords:'
	  print,'   NOBORDER=nb  Indicate if /NOBORDER keyword was used'
	  print,'      in map_set.  Tries to guess if not given.'
	  print,'      Guess is pretty good, but must give for /MILLER'
	  print,'      if /NOBORDER and /HORIZON used. Maybe other cases.'
	  print,'   LIMIT=lim  Given limit (needed for Satellite proj).'
	  print,'   SC_STR=sc_str  Scaling string, send or return.'
	  print,'   /NOEMBED means just return the string (SC_STR).'
	  print,'   /EMBED means embed given scaling string (SC_STR).'
	  print,' Notes: Must use after a map_set command, before any other'
	  print,'   commands that change cordinates (like plot).'
	  print,'   Needs 307 pixels along the image bottom.'
	  print,'   Allows an image of a map to be loaded later and have'
	  print,'   data overplotted or positions read.'
	  print,'   See also map_set_scale which sets up map coordinate'
	  print,'   system using this embedded info.'
	  print,'   If an image is remapped onto map it may confuse this'
	  print,'   routine.  May grab scaling string first using SC_STR'
	  print,'   and /NOEMBED, do the remapping, then add the string'
	  print,'   using SC_STR and /EMBED.'
	  return
	endif
 
	;------  Check if giving the scaling string  -----------
	if keyword_set(embed) then begin
	  if n_elements(sc_str) eq 0 then begin
	    print,' Error in map_put_scale: scaling string to be embedded'
	    print,'   is undefined.  No scaling added to image.'
	    return
	  endif
	  goto, embed	; Jump down to the embed command.
	endif
 
	;------  Make sure last plot command was a map_set  ----------
	if !x.type ne 3 then begin
 	  print,' Error in map_put_scale: Map scaling not available.'
	  print,'   Must call this routine after map_set and before'
	  print,'   any other routine (like plot) resets scale.'
	  return
	endif
 
	;----  Guess /NOBORDER state if not given  --------
	if n_elements(noborder) eq 0 then begin
	  posbox, vis=vis,color=clr     ; Get /noborder flag and color used.
	  noborder = 1-vis
	endif
 
	;----  Determine if /ISO used  -------------
	shape = float(!d.y_size)/!d.x_size  ; Shape of window.
	sc_rat = !x.s[1]/!y.s[1]	    ; Ratio of norm x/y scale factors.
	if abs((sc_rat-shape))/sc_rat*10000d0 lt 1 then $
	  iso = 1 $			    ; Isotropic to within 0.01%.
	  else iso = 0			    ; No /ISO used.
 
	;----  Deal with POSITION  ---------------
	pos = [!x.window(0),!y.window(0),!x.window(1),!y.window(1)]  ; Map pos.
 
	;----  Deal with LIMIT  ------------------------
	;  This has a number of special cases.
	;  If LIMIT was used it appears in !map.ll_box.
	;  If LIMIT was not used then !map.ll_box
	;    may contain all 0s, or several other
	;    values depending on the projection.
	;-----------------------------------------------
	limit = !map.ll_box	; Possible Lat/Lon range.
	lon = !map.p0lon	; Central long.
	;----  Test for case: [-90,lon-180,90,lon+180] ---------
	test_lon1 = lon-180d0			; Test long guess.
	test_lon2 = lon+180d0
	if test_lon1 lt (-180) then begin	; Keep min GE -180.
	  test_lon1 = test_lon1+360
	  test_lon2 = test_lon2+360
	endif
	test = [-90d0,test_lon1,90d0,test_lon2]	; Special case.
	w = where(limit(0:3) ne test, cnt)	; Is this a special case?
	if cnt eq 0 then limit=limit*0.		; Zero out limit so not used.
	proj = !map.projection
	;----  Check for special cases for proj=1 or 2  ---------
	if (proj eq 1) or (proj eq 2) then begin
	  test = [-1.,-1.,1.,1.]		  ; Test for this (no LIMIT).
	  w = where(!map.uv_box  ne test, cnt)    ; Is this a special case?
	  if cnt eq 0 then limit=limit*0.	  ; Zero out limit so not used.
	endif
	;----  Check for special cases for proj=3,4,5  ---------
	if (proj eq 3) or (proj eq 4) or (proj eq 5) then begin 
	  test = [-2.,-2.,2.,2.]		  ; Test for this (no LIMIT).
	  w = where(!map.uv_box  ne test, cnt)    ; Is this a special case?
	  if cnt eq 0 then limit=limit*0.	  ; Zero out limit so not used.
	endif
	;----  Check for special cases for proj=3 or 14  ---------
	if (proj eq 3) or (proj eq 14) then begin ; /conic or /albers.
	  test = [-2.04,-2.04,2.04,2.04]	  ; Test for this (no LIMIT).
	  w = where(!map.uv_box  ne test, cnt)    ; Is this a special case?
	  if cnt eq 0 then limit=limit*0.	  ; Zero out limit so not used.
	endif
	;----  Use given LIMIT as over-ride  ---------
	if n_elements(limit0) ne 0 then limit=limit0
	;----  4 or 8 element case  ------------------
	if n_elements(limit) eq 4 then begin	; Force 8 elements.
	  lim = dblarr(8)
	  lim(0) = limit
	endif
 
	;----  Get values to be embedded and set up format  ----------
	m = 1234567891         & fmt='(I10'      ; Flag map scaling info.
 
	proj = !map.projection & fmt=fmt+',I3'    ; Map projection code.
 
	lat0 = !map.p0lat      & fmt=fmt+',F11.6'  ; Map central lat.
	lon0 = !map.p0lon      & fmt=fmt+',F12.6'  ; Map central lon.
	ang0 = !map.rotation   & fmt=fmt+',F7.2'  ; Map angle.
 
	bflag = noborder       & fmt=fmt+',I2'    ; /NOBORDER flag.
	bclr = clr             & fmt=fmt+',I4'    ; Border color.
	iflag = iso	       & fmt=fmt+',I2'    ; /ISO flag.
 
	p0 = pos(0)            & fmt=fmt+',F10.7' ; Extract position.
	p1 = pos(1)            & fmt=fmt+',F10.7'
	p2 = pos(2)            & fmt=fmt+',F10.7'
	p3 = pos(3)            & fmt=fmt+',F10.7'
 
	L0 = lim(0)            & fmt=fmt+',F12.6'  ; Extract limit (8 vals).
	L1 = lim(1)            & fmt=fmt+',F12.6'
	L2 = lim(2)            & fmt=fmt+',F12.6'
	L3 = lim(3)            & fmt=fmt+',F12.6'
	L4 = lim(4)            & fmt=fmt+',F12.6'
	L5 = lim(5)            & fmt=fmt+',F12.6'
	L6 = lim(6)            & fmt=fmt+',F12.6'
	L7 = lim(7)            & fmt=fmt+',F12.6'
 
	M0 = !map.p[0]         & fmt=fmt+',G20.14' ; Some extra values.
	M1 = !map.p[1]         & fmt=fmt+',G20.14'
	M2 = !map.p[2]         & fmt=fmt+',G20.14'
	M3 = !map.p[3]         & fmt=fmt+',G20.14'
	M4 = !map.p[4]         & fmt=fmt+',G20.14'
	M5 = !map.p[5]         & fmt=fmt+',G20.14'
	M6 = !map.p[6]         & fmt=fmt+',G20.14'
	M7 = !map.p[7]         & fmt=fmt+',G20.14'
 
	                         fmt=fmt+')'
 
	;-----  Create map coordinates info string  ------------
	sc_str = string(m, proj, lat0,lon0,ang0, bflag,bclr,iflag, $
	           p0,p1,p2,p3, $
	           L0,L1,L2,L3,L4,L5,L6,L7, M0,M1,M2,M3,M4,M5,M6,M7, $
		   form=fmt)
	if keyword_set(noembed) then return
 
	;------  Convert to bytes and write to image  --------
embed:	tv,byte(sc_str),0,0
 
	return
	end
