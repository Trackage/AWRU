;-------------------------------------------------------------
;+
; NAME:
;       WGS_84
; PURPOSE:
;       Return a structure with some WGS 84 Ellipsoid values.
; CATEGORY:
; CALLING SEQUENCE:
;       s = wgs_84()
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         LAT=lat  Specified latitude in degrees (def=0).
; OUTPUTS:
;       s = returned structure:              out
;         s.a = semi-major axis (m).
;         s.b = semi-minor axis (thru N-S pole) (m).
;         s.f1 = Reciprocal of flattening.
;         s.lat = Latitude for returned radius (deg).
;         s.r = Radius at given latitude (m).
;         s.d2m_lat = Meters/deg of lat at given lat (m).
;         s.d2m_lon = Meters/deg of lon at given lat (m).
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 1998 Nov 2
;
; Copyright (C) 1998, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
	function wgs_84, help=hlp, lat=lat
 
	if keyword_set(hlp) then begin
	  print,' Return a structure with some WGS 84 Ellipsoid values.'
	  print,' s = wgs_84()'
	  print,'   s = returned structure:              out'
	  print,'     s.a = semi-major axis (m).'
	  print,'     s.b = semi-minor axis (thru N-S pole) (m).'
	  print,'     s.f1 = Reciprocal of flattening.'
	  print,'     s.lat = Latitude for returned radius (deg).'
	  print,'     s.r = Radius at given latitude (m).'
	  print,'     s.d2m_lat = Meters/deg of lat at given lat (m).'
	  print,'     s.d2m_lon = Meters/deg of lon at given lat (m).'
	  print,' Keywords:'
	  print,'   LAT=lat  Specified latitude in degrees (def=0).'
	endif
 
	a = 6378137.0000D0	; semi-major axis (m).
	f1 = 298.257223563D0	; Reciprocal flattening.
	f = 1D0/f1		; Actual flattening value.
	b = a*(1D0-f)		; semi-minor axis (thru N-S pole) (m).
 
	if n_elements(lat) eq 0 then lat=0D0	; Latitude of interest (deg).
	degrad = !dpi/180D0			; Radians/degree.
 
	a2 = a^2
	b2 = b^2
	s = sin(lat*degrad)
	c = cos(lat*degrad)
 
	r = sqrt((a2*b2)/(a2*s^2+b2*c^2))	; Earth radius at lat (m).
 
	d2m_lat = r*degrad			; meters per deg of lat at lat.
	d2m_lon = r*c*degrad			; meters per deg of lon at lat.
 
	st = {a:a, b:b, f1:f1, lat:lat, r:r, d2m_lat:d2m_lat, d2m_lon:d2m_lon}
 
	return, st
 
	end
