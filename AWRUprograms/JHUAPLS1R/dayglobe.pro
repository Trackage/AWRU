;-------------------------------------------------------------
;+
; NAME:
;       DAYGLOBE
; PURPOSE:
;       Show the area of daylight/night on a globe.
; CATEGORY:
; CALLING SEQUENCE:
;       dayglobe, lat0, lng0, ang0
; INPUTS:
;       lat0 = Latitude at center of globe.        in
;       lng0 = Longitude at center of globe.       in
;       ang0 = Rotation angle of image (deg CCW).  in
; KEYWORD PARAMETERS:
;       Keywords:
;         TIME=time  Time string (def=current).
;         ZONE=hrs  Hours ahead of GMT (def=0).  Ex: zone=-4 for EDT.
;         /DEEPER  means use deeper colors.
;         /QUANTIZED  means 10 degree banded day colors.
;         /BLACK   means use black background (else white).
;         /COUNTRIES means plot countries.
;         POINT='lng lat'  Point to mark.
;         COLOR=clr Color of point as R G B like '0 255 0').
;         /GRID  display a grid.
;         CGRID=gclr  Color for Grid as R G B like '0 255 0').
;         CHARSIZE=csz  Relative character size (def=1).
;         /STEREO  means use Stereographic projection instead of
;            Orthographic.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Oct 14
;       R. Sterner, 2000 Sep 19 --- Added quantized day colors.
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	pro dayglobe, lat0, lng0, ang0, time=time0, zone=zone, deeper=deep, $
	  quantized=quant, countries=count, black=black, point=pt, color=pclr, $
	  grid=grid, cgrid=grdc, charsize=csz, stereo=stereo, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Show the area of daylight/night on a globe.'
	  print,' dayglobe, lat0, lng0, ang0'
	  print,'   lat0 = Latitude at center of globe.        in'
	  print,'   lng0 = Longitude at center of globe.       in'
	  print,'   ang0 = Rotation angle of image (deg CCW).  in'
	  print,' Keywords:'
	  print,'   TIME=time  Time string (def=current).'
	  print,'   ZONE=hrs  Hours ahead of GMT (def=0).  Ex: zone=-4 for EDT.'
	  print,'   /DEEPER  means use deeper colors.'
	  print,'   /QUANTIZED  means 10 degree banded day colors.'
	  print,'   /BLACK   means use black background (else white).'
	  print,'   /COUNTRIES means plot countries.'
	  print,"   POINT='lng lat'  Point to mark."
	  print,"   COLOR=clr Color of point as R G B like '0 255 0')."
	  print,'   /GRID  display a grid.'
	  print,"   CGRID=gclr  Color for Grid as R G B like '0 255 0')."
	  print,'   CHARSIZE=csz  Relative character size (def=1).'
	  print,'   /STEREO  means use Stereographic projection instead of'
	  print,'      Orthographic.'
	  return
	endif
 
	;------  Define coordinates  ---------------
	if n_elements(lat0) eq 0 then lat0=0
	if n_elements(lng0) eq 0 then lng0=0
	if n_elements(ang0) eq 0 then ang0=0
 
	;------  Projection  -------------------------
	orth = 1
	ster = 0
	if keyword_set(stereo) then begin
	  orth = 0
	  ster = 1
	endif
 
	;------  Get current window size and find position  ---------
	nx = !d.x_size  &  ny = !d.y_size
	pos=[0,(ny-nx-1.)/ny,(nx-1.)/nx,(ny-1.)/ny]
 
	;------  Deal with time and get sun zenith distances  --------
	if n_elements(time0) eq 0 then time0=''
	time = time0
	t = strupcase(strtrim(time,2))
	if (t eq '') or (t eq 'NOW') then begin
	  time = systime()			; If null use current.
	  zone = -gmt_offsec()/3600.		; Use local time zone.
	endif
	if n_elements(zone) eq 0 then zone=0	; GMT def.
	;------  Want to use JS  ----------------
        if datatype(time) eq 'DOU' then begin
          js = time
          err = 0
        endif else begin
          js = dt_tm_tojs(time, err=err)
          if err ne 0 then return
        endelse
	;------  Compute world altitudes  -------------
	a = world_sunzd(js, 0.5, zone=zone, sunlat=slat, sunlng=slng)
 
	;------  Color table  --------------
	sun_colors, deep=deep, quant=quant
	tp = topc()
	tvlct,0,0,0,tp
;	blk = tarclr(0,0,0)
	blk = tp
 
	;-------  Do map  ------------------
	map_set, pos=pos, /iso, /hor, ortho=orth, stereo=ster, $
	  lat0, lng0, ang0, /noerase
	if keyword_set(black) then miss=blk else miss=0
	img = map_image(a,ix,iy,comp=1,miss=miss)
	erase, 0
	tv,img,ix,iy
 
	;-------  Grid  -----------------------
	if n_elements(grdc) eq 0 then grdc='200 200 200'
	grd = tarclr(grdc,set=183)
        if keyword_set(grid) then begin
          xx = maken(0,360,181)
          for y=-90,90,30 do begin
            yy = maken(y,y,181)
            plots,xx,yy,col=grd   
          endfor
          yy = maken(-90,90,91)
          for x=0,330,30 do begin
            xx = maken(x,x,91)
            plots,xx,yy,col=grd
          endfor
        endif
 
	;-------  Add countries  -----------------
	map_set,pos=pos,/iso,/hor,ortho=orth, stereo=ster, $
	  lat0,lng0,ang0,/noerase,col=blk,/cont
	if keyword_set(count) then $
	  map_continents, /countries, /usa, col=blk
 
	;-------  Plot reference point  ------------
	rtxt1 = ''
	rtxt2 = ''
	if n_elements(pt) ne 0 then begin
	  if strtrim(pt(0),2) ne '' then begin
	    wordarray,string(pt),txt,del=',',/white
	    plng = txt(0)+0.
	    plat = txt(1)+0.
	    if n_elements(pclr) eq 0 then pclr='0 255 0'
	    t = tarclr(pclr,set=182)
	    point,plng,plat,col=182
	    sunpos, js, plng, plat, azi, alt, zone=zone
	    rtxt1 = 'Reference point: Latitude '+string(plat,form='(F6.2)')+$
	      '  Longitude '+string(plng,form='(F7.2)')
	    rtxt2 = 'Sun at reference point: Altitude '+ $
	      string(alt,form='(F5.1)')+$
	      '  Azimuth '+string(azi,form='(F5.1)')
	  endif
	endif
 
	;------  Label plot  ---------------
	if n_elements(csz) eq 0 then csz=1.0
	txt = dt_tm_fromjs(js,form='Y$ n$ d$ h$:m$') + $
	  '  ('+string(zone,form='(F6.2)')+' hours from GMT)'
	stxt = 'Subsolar point: Latitude '+string(slat,form='(F6.2)')+$
	  '  Longitude '+string(slng,form='(F7.2)')
	y0 = pos(1)
	csz = csz*nx/550.*1.8
	if csz lt 1.5 then cth=1 else cth=2
	xprint,/init,.5,y0,/norm,chars=csz,charth=cth,dy=1.5
	xprint,' '
	clr = blk
	xprint,txt,col=clr,align=.5
	xprint,stxt,col=clr,align=.5
	xprint,rtxt1,col=clr,align=.5
	xprint,rtxt2,col=clr,align=.5
 
	return
	end
