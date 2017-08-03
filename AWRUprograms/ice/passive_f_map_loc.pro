;------------------------------------------------------------------------------
; set up values for calculating lat and lon
;------------------------------------------------------------------------------
pro map_init, source, hemisphere, channel,			$
		x_cell_size = x_cell,				$
		y_cell_size = y_cell,				$
		x_pole      = x_pole,				$
		y_pole      = y_pole,				$
		ref_long    = ref_long

common map,	mflag, slat, slon, x0, y0, re, e, e2, pi, cdr,	$
		x_cell_size, y_cell_size,			$
	    	srce, hemi, chnl

srce = source
hemi = hemisphere
chnl = channel

if passive_grid_info (source,				$
			hemisphere = hemisphere,	$
			channel    = channel,		$
			true_lat   = slat,		$
			ref_long   = slon,		$
			cell_size  = cell_size,		$
			x_origin   = x0,		$
			y_origin   = y0			) ne 0 then begin
	slat      = -60.0	; default values ("spsg")
	slon      = +10.0
	cell_size = 25.4
	x0        = 4394.2
	y0        = 3810.0
endif

if n_elements(x_cell) eq 0 	then x_cell_size = cell_size		$
				else x_cell_size = x_cell
if n_elements(y_cell) eq 0	then y_cell_size = cell_size		$
				else y_cell_size = y_cell
if n_elements(x_pole) gt 0 	then x0          = x_pole
if n_elements(y_pole) gt 0	then y0          = y_pole

if n_elements(ref_long)     gt 0 then slon = ref_long

re   = 6378.273
e2   = .006693883
e    = sqrt(e2)
pi   = 3.141592654
cdr  = pi/180.0
mflag = -1
end

;------------------------------------------------------------------------------
; map longitude and latitude points
;------------------------------------------------------------------------------
function mapll, alat, alon

common map, mflag, slat, slon, x0, y0, re, e, e2, pi, cdr, cell_size
common mapll, llflag, tc, mc, rho

if (n_elements(mflag) eq 0) then map_init
if (n_elements(llflag) eq 0) then begin
   if (abs(slat) eq 90) then begin
      rho = 2*re/((1+e)^(1+e)*(1-e)^(1-e))^(e/2)
   endif else begin
      sl = abs(slat)*cdr
      tc = tan(pi/4-sl/2)/((1-e*sin(sl))/(1+e*sin(sl)))^(e/2)
      mc = cos(sl)/sqrt(1-e2*(sin(sl)^2))
      rho = re*mc/tc
   endelse
   llflag = -1
endif

lat = abs(alat)*cdr
t = tan(pi/4-lat/2)/((1-e*sin(lat))/(1+e*sin(lat)))^(e/2)
lon = -(alon-slon)*cdr
x = x0 - (rho * t * sin(lon))
y = y0 + (rho * t * cos(lon))

return, [x,y]
end

;------------------------------------------------------------------------------
; map geo points
;------------------------------------------------------------------------------
function mapxy, x, y

common map, mflag, slat, slon, x0, y0, re, e, e2, pi, cdr, cell_size
common mapxy, xyflag, tc, mc, rho, a1, a2, a3, a4, a5

if (n_elements(mflag) eq 0) then map_init
if (n_elements(xyflag) eq 0) then begin
   if (abs(slat) eq 90) then begin
      rho = 2*re/sqrt((1+e)^(1+e)*(1-e)^(1-e))
   endif else begin
      sl = abs(slat)*cdr
      tc = tan(pi/4-sl/2)/((1-e*sin(sl))/(1+e*sin(sl)))^(e/2)
      mc = cos(sl)/sqrt(1-e2*(sin(sl)^2))
      rho = re*mc/tc
   endelse
   a1 =  5*e2^2 / 24
   a2 =    e2^3 / 12
   a3 =  7*e2^2 / 48
   a4 = 29*e2^3 /240
   a5 =  7*e2^3 /120
   xyflag = -1
endif

t = sqrt((x-x0)^2+(y-y0)^2)/rho
chi = (pi/2) - 2*atan(t)
alat = chi + ((e2/2)+a1+a2)*sin(2*chi) + (a3+a4)*sin(4*chi) + a5*sin(6*chi)
alat = -alat/cdr
alon = -atan(-(x-x0),(y-y0))/cdr + slon
return, [alat,alon]
end

;------------------------------------------------------------------------------
;+
; Name :- 
;
;		passive_f_map_loc
;
; Purpose :-
;
; 	Conversion of polar view coordinates, as applied to passive microwave
;	data (SMMR or SSM/I), viz:-
;		lat. long to x,y grid	(/TO_GRID)
;		x,y grid to lat. long	(/TO_GEO)
; 	NB: This routine differs from "passive_map_loc.pro" in that it accepts
;	(for /to_geog) and returns (for /to_grid) FRACTIONAL (floating point)
;	grid indices.
;
; Calling sequence :-
;
;		result = passive_f_map_loc (coord1, coord2)
;
; Returned values :-
;
;		Two element array:
;			[ lat,	long ]	(/TO_GEOG)
;			[  x,	 y   ]	(/TO_GRID) -- fractional
;
; Input parameters:-
;
;			coord1, coord2
;		==>	x	y	(/TO_GEOG) g-- fractional
;		==> 	lat     long	(/TO_GRID)
;
;		      source	  = any of the sources accepted by routine
;				    "passive_grid_info.pro".  Needs to be input
;				    at least on initial call, otherwise 'spsg'
;				    grid is assumed.  Parameters may be altered
;				    by inputting a new source.
;
;		      hemisphere  = 'north' or 'south' (default) hemisphere
;
;		      channel     = a DMSP channel descriptor, as accepted by
;				    routine "passive_grid_info.pro".  This
;				    argument only applies for brightness temp-
;				    erature sources.
;	NB: If coord1 and coord2 are input as 1D arrays (of same size), the
;	first half of the returned array contains x or latitudes, and the
;	remaining half the y or longitude values.
;
; Keywords:-
;
;	TO_GEO 	    ==>	set for  grid to geographic coordinate conversion
;
;	TO_GRID	    ==>	set for  geographic to grid coordinate conversion
;
;	(neither TO_GEO or TO_GRID set, no results returned)
;
;	x_cell_size ==> provide an x dimension for the cell to override the
;			look-up value.
;
;	y_cell_size ==> provide a y dimension for the cell to override the
;			look-up value.
;
;	x_pole      ==> provide an x offset (km) for the pole from the grid
;			origin (centre of cell[0,*]) to override the look-up
;			value.
;
;	y_pole      ==> provide a y offset (km) for the pole from the grid
;			origin (centre of cell[*,0]) to override the look-up
;			value.
;
;	ref_long    ==> provide a reference longitude in deg. (i.e. "long. up")
;			to override the look-up value.
;
;	initialize  ==> set to force (re-)initialization.
;
;	NB:  "x_cell_size", "y_cell_size" and "ref_long" only take effect if
;	routine is being (re-)initialized.
;
; History :-
;
;	Developed by Pelham Williams, based on map_loc.pro from NIC. 
;-
;------------------------------------------------------------------------------

function passive_f_map_loc,			$
		coord1,				$
		coord2,				$
		to_geog	     = to_geog,		$
		to_grid	     = to_grid,		$
		scale_factor = scale_factor,	$
		source	     = source,		$
		hemisphere   = hemisphere,	$
		channel	     = channel,		$
		x_cell_size  = x_cell,		$
		y_cell_size  = y_cell,		$
		x_pole	     = x_pole,		$
		y_pole       = y_pole,		$
		ref_long     = ref_long,	$
		initialize   = init

common map,	mflag, slat, slon, x0, y0, re, e, e2, pi, cdr,	$
		x_cell_size, y_cell_size,			$
	    	srce, hemi, chnl

; if common data hasn't been initialized, do it.
; otherwise, if no source supplied, use existing common data
; otherwise, if supplied source equals initialized value don't re-initialize
; otherwise re-initialize to new source.
if n_elements(source)     le 0 then source     = '?'
if n_elements(hemisphere) le 0 then hemisphere = '?'
if n_elements(channel)    le 0 then channel    = '?'
if n_elements(init)       le 0 then init       = 0
if n_elements(mflag)      le 0 then begin
	init = 1
	chnl = ''
	hemi = ''
	srce = ''
endif
if (source ne srce)		or				$
   (hemisphere ne hemi)		or				$
   (channel ne chnl)		or				$
   init then 	map_init, source, hemisphere, channel,		$
			  x_cell_size = x_cell,			$
			  y_cell_size = y_cell,			$
			  x_pole      = x_pole,			$
			  y_pole      = y_pole,			$
			  ref_long    = ref_long

; if zoom window requires higher resolution calculate grid from the scale
; factor of the zoom window
if (keyword_set(scale_factor)) then begin
   xcell = x_cell_size/scale_factor
   ycell = y_cell_size/scale_factor
endif else begin
   xcell = x_cell_size
   ycell = y_cell_size
end

if (keyword_set(to_geog)) then begin
   x = coord1*xcell
   y = coord2*ycell
   result = mapxy (x,y)
endif else if (keyword_set(to_grid)) then begin
   result = mapll (coord1,coord2)
   n = n_elements(result)/2
   result = [result[0:n-1]/xcell,result[n:*]/ycell]
endif

return, result
end

;------------------------------------------------------------------------------
