;-------------------------------------------------------------
;+
; NAME:
;       MAP_SET_SCALE
; PURPOSE:
;       Set map scaling from info embedded in a map image.
; CATEGORY:
; CALLING SEQUENCE:
;       No args.
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /LIST  List values.
;         LAT=lat, LON=lon, ANG=ang  returned lat,long,ang.
;         POSITION=pos  returned position.
;         LIMIT=lim     returned LIMIT.
;         Screen window position values returned:
;           IX1=ix1,IX2=ix2,IY1=iy1,IY2=iy2,IDX=idx,IDY=idy
;         PIX=pix map scale in pixels/degree (only if /ISO used).
;         IMAGE=img  Give image array instead of reading it from
;           the display.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Uses info embedded on bottom image line by
;       map_put_scale, if available.
; MODIFICATION HISTORY:
;       R. Sterner, 1999 Aug 31
;       R. Sterner, 2000 Jun 29 --- Added IMAGE=img keyword.
;
; Copyright (C) 1999, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
;===================================================================
;	map_proj_name = Convert map_set projection number to name
;	R. Sterner, 1999 Sep 21
;===================================================================
 
	function map_proj_name, proj, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert map_set projection number to projection name.'
	  print,' name = map_proj_name( proj)'
	  print,'   proj = projection number.  in'
	  print,'   name = projection name.    out'
	  print,' Note: projection number is the number set by the'
	  print,' map_set command and may be found in !map.projection'
	  print,' after map_set is executed.'
	  return,''
	endif
 
	names = ['', $
		'Stereographic', $
		'Orthographic', $
		'Lambert Conic', $
		'Lambert Azimuthal', $
		'Gnomic', $
		'Azimuthal Equidistant', $
		'Satellite', $
		'Cylindrical', $
		'Mercator', $
		'Mollweide', $
		'Sinusoidal', $
		'Aitoff', $
		'Hammer Aitoff', $
		'Albers Equal Area Conic', $
		'Transverse Mercator', $
		'Miller Cylindrical', $
		'Robinson', $
		'Lambert Conic Ellipsoid', $
		'Goodes Homolosine', $
		'']
 
	return, (names([proj]))(0)
 
	end
 
 
;===================================================================
;	map_set_scale = Set map scaling from info embedded in a map image.
;	R. Sterner, 1999 Aug 31
;===================================================================
 
	pro map_set_scale, position=pos, limit=lim, lat=lat, lon=lon, $
	  ang=ang, ix1=ix1,ix2=ix2,iy1=iy1,iy2=iy2,idx=idx,idy=idy, $
	  pix=pix, list=list, image=t0, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Set map scaling from info embedded in a map image.'
 	  print,'   No args.'
	  print,' Keywords:'
	  print,'   /LIST  List values.'
	  print,'   LAT=lat, LON=lon, ANG=ang  returned lat,long,ang.'
	  print,'   POSITION=pos  returned position.'
	  print,'   LIMIT=lim     returned LIMIT.'
	  print,'   Screen window position values returned:'
	  print,'     IX1=ix1,IX2=ix2,IY1=iy1,IY2=iy2,IDX=idx,IDY=idy'
	  print,'   PIX=pix map scale in pixels/degree (only if /ISO used).'
	  print,'   IMAGE=img  Give image array instead of reading it from'
	  print,'     the display.'
 	  print,' Notes: Uses info embedded on bottom image line by'
	  print,' map_put_scale, if available.'
	  return
	endif
 
	;****************************************************************
	;	Extract embedded info from image and interpret
	;****************************************************************
 
	;=============================================================
	;	Make sure map cordinate info is embedded in image
	;=============================================================
	if !d.x_size lt 347 then return		; Image too small.
	if n_elements(t0) eq 0 then t0=tvrd()
;	if n_elements(t) eq 0 then t=tvrd(0,0,347,1)	; Read data.
	t = t0(0:346,0)
	m = string(t(0:9))			; Data available flag.
	if m ne '1234567891' then return	; No map scaling info in image.
 
	;=============================================================
	;	Predefine variables to read
	;=============================================================
	proj = 0			; Map projection code.
	bflag = 0			; /NOBORDER flag (1 if used).
	bclr = 0			; Border color.
	iflag = 0			; /ISO flag (1 if used).
	lat=0. & lon=0. & ang=0.	; central lat,long, and map angle.
	p0=0. & p1=0. & p2=0. & p3=0.	; Screen position.
	L0=0. & L1=0. & L2=0. & L3=0.	; Map limits.
	L4=0. & L5=0. & L6=0. & L7=0.
	M0=0d0 & M1=0d0 & M2=0d0 & M3=0d0 & M4=0d0 & M5=0d0 & M6=0d0 & M7=0d0
 
	;=============================================================
	;	Set up read format
	;=============================================================
	fmt = '(I3, F11.6,F12.6,F7.2, I2,I4,I2, '+$
	      'F10.7,F10.7,F10.7,F10.7,'+$
	      'F12.6,F12.6,F12.6,F12.6,F12.6,F12.6,F12.6,F12.6,'+$
	      'G20.14,G20.14,G20.14,G20.14,G20.14,G20.14,G20.14,G20.14)'
 
	;=============================================================
	;	Extract values from string
	;=============================================================
	s = string(t(10:*))			; Turn data into a string.
	reads,s,form=fmt, $
	  proj, lat,lon,ang, bflag,bclr,iflag, $
	  p0,p1,p2,p3, $
	  L0,L1,L2,L3,L4,L5,L6,L7, $
	  M0,M1,M2,M3,M4,M5,M6,M7
	proj0 = proj				; proj may change, save copy.
 
	;=============================================================
	;	Deal with POSITION and LIMIT parameters
	;=============================================================
	pos = [p0,p1,p2,p3]		; Set up POSITION.
	lim = [L0,L1,L2,L3]		; Set up LIMIT.
	if max(abs(lim)) eq 0 then $	; Limit used? 0=no, 1=yes.
	  flag_lim=0 else flag_lim=1
	if proj eq 7 then begin		; Special case: Satellite proj.
	  lim2 = [L4,L5,L6,L7]		; Deal with 8 element limit case.
	  if max(abs(lim2)) gt 0 then $	; If had 8 limit values update lim.
	    lim = [lim,lim2]
	endif
 
	;****************************************************************
	;	Use extracted info to set up map_set command
	;****************************************************************
 
	;=========================================
	;	Set up basic map_set command
	;=========================================
	cmd = 'map_set,/noerase,lat,lon,ang,proj=proj,pos=pos'	; Basic command.
 
	;=========================================
	;	Deal with /NOBORDER
	;=========================================
	if bflag eq 1 then $
	  cmd = cmd + ',/noborder,color=bclr'		; Add /NOBORDER.
 
	;=========================================
	;	Deal with LIMIT=[...]
	;=========================================
	if flag_lim then cmd=cmd+',limit=lim'		; Add limit.
 
	;=====================================
	;	Deal with special cases
	;=====================================
 
	;------  Conic or Albers  ----------
; >>>===> Maybe also include (proj eq 18) ???
	if (proj eq 3) or (proj eq 14) then begin	; What about 18?
	  stdpar = [M3,M4]/!dtor			; Stand. Parallels.
	  cmd = cmd+',standard_par=stdpar'		; Add std. Par.
	endif
 
	;------  Satellite  --------------
	if proj eq 7 then begin				; Sat proj.
	  sat_p = [M0,M1/!dtor,0.]
	  cmd = cmd+',sat_p=sat_p'			; Add sat par.
	endif
 
	;------  Transverse Mercator (proj=15) --------
	if proj eq 15 then begin
	  ellips = [ M3, M1, M0]
	  cmd = cmd+',ellips=ellips'			; Add Ellipsoid.
	endif
 
	;------  Lambert Conic Ellipsoid (proj=18)  -----
	if proj eq 18 then begin
	  proj = 3					; Set to Lambert.
	  ellips = [ M5, M6, M7]
	  cmd = cmd+',ellips=ellips'			; Use Ellipsoid.
	endif
 
	;=========================================
	;	Execute the map_set command
	;=========================================
	err = execute(cmd)
	if err ne 1 then begin
	  print,' Error in map_set_scale: command not executed correctly.'
	  print,' Command was:'
	  print, cmd
	endif
 
	;=======================================
        ;       Extract some values
        ;=======================================
	ix1 = round(p0*!d.x_size)
	ix2 = round(p2*!d.x_size) & idx=ix2+0-ix1
	iy1 = round(p1*!d.y_size)
	iy2 = round(p3*!d.y_size) & idy=iy2+0-iy1
 
	;=======================================
	;	List
	;=======================================
	if keyword_set(list) then begin
	  print,' '
          print,' Values set from embedded scaling:'
          print,' '
	  print,' Map projection = ',map_proj_name(proj0),' ('+$
	    strtrim(proj0,2)+')'
	  print,' Central lat, long = ',strtrim(lat,2),', ',strtrim(lon,2), $
	  '    Map angle = ',strtrim(ang,2)
	  txt = ''
	  if bflag eq 0 then txt=' Map Border' else txt=' No Map Border'
	  if bflag eq 0 then txt=txt+' of color = '+strtrim(bclr,2)
	  if iflag eq 1 then txt=txt+',   /ISO used' else $
	    txt=txt+',   No /ISO used'
	  print,txt
	  if max(abs(lim)) eq 0 then begin
	    print,' No LIMIT used'
	  endif else begin
	    print,' LIMIT = ',strtrim(lim,2)
	  endelse
	  if (proj eq 3) or (proj eq 14) then begin
	    print,' Standard parallels = ',strtrim(stdpar,2)
	  endif
	  if proj eq 7 then begin
	    print,' Satellite parameters = ',strtrim(sat_p,2)
	  endif
	  ;------  Screen position  -----------
	  six1 = strtrim(ix1,2)
	  six2 = strtrim(ix2,2) & sidx=strtrim(idx,2)
	  siy1 = strtrim(iy1,2)
	  siy2 = strtrim(iy2,2) & sidy=strtrim(idy,2)
	  print,' Screen window: '+$
	    'ix1, ix2, iy1, iy2: '+six1+','+ six2+','+ siy1+','+siy2
	  print,'   position format: '+$
            'pos=['+six1+','+siy1+','+ six2+','+siy2+'],/dev'
          print,'   tvrd format:     a=tvrd('+$
            six1+','+siy1+','+ sidx+','+sidy+')'
          print,'   plots format:    plots,['+$
            six1+','+six2+','+six2+','+ six1+','+six1+'],['+$
            siy1+','+siy1+','+siy2+','+ siy2+','+siy1+'],/dev' 
          print,'   crop image:      a=tvrd('+$
            six1+','+siy1+','+ sidx+','+sidy+')'
          print,'                    swindow,xs='+sidx+',ys='+sidy+' & tv,a'
	  ;------  Central map scale (pixels/degree)  -------
	  if iflag eq 1 then begin	; Only for /ISO.
	    ixmd=(ix1+ix2)/2. & iymd=(iy1+iy2)/2. & iyy1=iymd-10 & iyy2=iymd+10
	    tmp=convert_coord([ixmd,ixmd],[iyy1,iyy2],/dev,/to_data)
	    x=tmp(0,*) & y=tmp(1,*)
	    d = sphdist(x(0),y(0),x(1),y(1),/deg)
	    pix = 20/d
	    print,' Map scale at center = '+strtrim(pix,2)+' pixels/degree'
	  endif
	endif
 
	return
	end
