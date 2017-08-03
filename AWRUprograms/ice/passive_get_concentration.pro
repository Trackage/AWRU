; These routines are based on file "read_concentrations.pro" and
; "Get_Ice_Concentration.pro" as used by "edge_contour.pro" and "ice_movie.pro".
; These are designed for use with "passive_get_data.pro".

;_______________________________________________________________________________
;
;  Read HDF type data from DMSP cd's
;_______________________________________________________________________________

Function Read_DMSP_SSMI_on_cd, path, file, err

    filename = path + file

    err = 0
    ; Test that file is HDF format
    if not HDF_ISHDF(filename) then begin
	print, 'File ' + filename + ' is not in HDF format.'
	err = 1
	return, [0]
    endif

    HDF_DFR8_RESTART
    HDF_DFR8_GetImage, filename, map, colours

    r = colours[0,*]
    g = colours[1,*]
    b = colours[2,*]
    map = reverse(map,2)	; image retrieved in raster form

    return, map

end

;_______________________________________________________________________________
;
;  Read binary type data downloaded from NSDIC FTP site.
;_______________________________________________________________________________


Function Read_passive_image, source, filename, err

    map = intarr(source.xsize, source.ysize)

    openr, unit, filename, /get_lun, error = err
    if err ne 0 then return, [0b]
    readu, unit, map
    close, unit
    free_lun, unit

    map = reverse(map,2)	; image retrieved in raster form

    return, map

end


;-------------------------------------------------------------------------------
; Select and open a sea-ice data file (psg image) -- TYPE='data' -- or a land
; mask file -- TYPE='land'.  (The default is 'data'.)  The data is loaded as a
; byte array, "map", and rotated to the "10 deg. longitude up" orientation.
; The data filename must be supplied via the FILENAME keyword.
; The size of the resultant map (after rotation) may be supplied via XSIZE,
; YSIZE, if known, otherwise the standard south dimensions (355 x 345) are used.
;-------------------------------------------------------------------------------

pro get_data,	source, map,		$
		HEMISPHERE = hemisphere,$
		FILENAME=filename,	$
		ERROR = error

    if keyword_set(hemisphere) eq 0 then hemisphere = 'south'

    h = strlowcase(strmid(hemisphere,0,1))
    case h of
	's' : map = bytarr(source.ysize,source.xsize) ; to be rotated 90 deg.
	'n' : map = bytarr(source.xsize,source.ysize)
    endcase
    openr, lun, filename, /get_lun, ERROR = error
    if error eq 0 then begin
        readu, lun, map
        free_lun, lun
    endif else map = [0b]

    ; - rotate it

    if h eq 's' then map = byte(rotate(map, 1))

end


;-------------------------------------------------------------------------------
; Select and load up "psg" land image.
; Southern land mask (i.e. array of indices which represent land, in a 355 x 345
; pixel image (10 deg. long. up).  Length of the array (i.e. number of land
; pixels) may be returned via the keyword N_LAND.
; A full filepath/filename may be returned via keyword LANDFILE.
;-------------------------------------------------------------------------------

Function get_land,	source,				$
			N_LAND		= n_land,	$
			ROOT_PATH	= root_path,	$
			LANDFILE	= landfile,	$
			HEMISPHERE	= hemisphere

   ; Get a map

   sep = path_separator()
   h = strlowcase(strmid(hemisphere,0,1))
   landfile = root_path + 'NASATeam'	$
		  + sep + h + 'psg'	$
		  + sep + h + 'land.map'
   get_data, source, land, FILENAME = landfile, HEMISPHERE = hemisphere
   ; (Land = 157, coast = 195)
   return, where(land eq 157, n_land)

end


;-------------------------------------------------------------------------------
;
; Select and load up an image.  Do some preliminary cleaning up (i.e. give any
; flagged land or missing data values standard flag values; if requested via
; keyword "reduce", reduce isolated missing data by averaging with neighbours.)
; A mask (array of image indices) corresponding to "missing data" may be
; returned via keyword DUD_MASK.
; A full filepath/filename must be supplied via keyword DATAFILE.
; A "dat-group" type structure (see "passive_get_data.pro") with at least the
; tag ".form" must be supplied.  If "source.form" has one of the values:-
;		'SSMI CDrom'
;		'SSMI downloaded'
;		'SMMR downloaded'
;		'psg',
; an attempt is made to read data of the associated type, otherwise an empty
; i.e. [0b] map is returned, and keyword "error" set to -1.
; 
; For some image types, a land is encoded into the data, in which case a land
; mask may be obtained via the "land_mask" keyword.
; For "psg" type images the land mask is provided separately, and may be
; obtained via a call to function "get_land".
; A land mask is only retrieved when land_mask is input as an empty (single
; value) array, or scalar.
;
;-------------------------------------------------------------------------------

Function get_a_map,	source,			$
			DATAFILE  = datafile,	$
			LAND_MASK = land_mask,	$
			N_LAND    = n_land,	$
			LAND_VAL  = land_val,	$
			DUD_MASK  = dud_mask,	$
			N_DUD     = n_dud,	$
			DUD_VAL   = dud_val,	$
			REDUCE	  = reduce,	$
			ERROR	  = error
   
   ; Get a map

    dud_val = 224b
    land_val = -1b

    map = 0b
    case source.form of

	'SSMI CDrom'     : begin
			     map = Read_DMSP_SSMI_on_cd(datafile, error)
			     dud_val   = 157b
			     land_val  = 168b
			     ocean_val = 0b
			   end

	'SSMI downloaded': begin
			     map = Read_passive_image (source, datafile, error)
			     map = fix(map * 0.1)
			     dud_val   = -1
			     land_val  = -80
			     ocean_val = 0 ; or 2?????
			   end

	'SMMR downloaded': begin
			     map = Read_passive_image (source, datafile, error)
				map = fix(map * 0.1)
				dud_val   = -1
				land_val  = -80
				ocean_val = 0 ; or 2?????
			      end

	'psg'	         : begin
   				get_data, source, map, 			$
					FILENAME = datafile,		$
					HEMISPHERE = source.hemisphere, $
					ERROR = error
				dud_val  = 224b
				land_val  = 0b
				ocean_val = 177b
			   end

	else	         : error = 1

    endcase
    if n_elements(map) eq 0 then error = 1

    if error ne 0 then return, [0b]

   ; Clean the map up a bit

   ; set ocean to 0
   map = map * (map ne ocean_val)

   ; get land mask, if not already done & if present in image.
   if land_val ne 0 and n_elements(land_mask) eq 1 then begin
	land_mask = where(map eq land_val, n_land)
	if n_land gt 0 then map[land_mask] = 120b ; set to a "standard" value
   endif 

   dud_mask = where (map eq dud_val, n_dud)
   if n_dud gt 0 then map[dud_mask] = 224b ; a standard dud value
   if keyword_set(reduce) then map = reduce_missing_data (map, 224b)
   return, byte(map)

end


;-------------------------------------------------------------------------------
;
; Get ice-concentration data.
; (Based on "Get_Ice_Concentration.pro".)
; NB: "datafile" and "data_group" are required inputs.
;     All other keyword parameters except "get_info" are outputs (normally
;	 essential to caller).
; "data_group" must be a structure with at least the tags:-
;		.form		value on input - e.g. 'DMSP downloaded'
;		.hemisphere	value on input = 'north' or 'south'
;		.xsize		value returned = horiz. dimension of image
;		.ysize		value returned = vert. dimension of image
;		.xpole		value returned = horiz. location of pole
;		.ypole		value returned = vert. location of pole
;		.raster		value returned = 1 for top down
;						 0 for bottom up
;						 (as stored on medium -
;						  NB image should always be
;						  bottom up)
; Valid values for .form are:-
;				'SSMI CDrom'
;				'SSMI downloaded'
;				'SMMR downloaded'
;				'psg',
; Valid values for .hemisphere are:- 'north', 'south'
;
; The returned value is the 2D array of data obtained, unless an error is
; detected, in which case an empty array ([0b]) is returned, and keyword "error"
; receives a non-zero value.  The "data_group" structure tags .xsize, .ysize,
; .xpole, .ypole and .raster are updated.
;
; Land Mask
; A (new) land mask is obtained only when land_maks is input as a scalar or
; empty (single element) array. 
;
; Get Info
; Setting the keyword "get_info" causes just the periferal information to be
; obtained - no data is read, and the returned value is the "data_group"
; structure with the .xsize, .ysize, .xpole, .ypole and .raster tags updated.
; Input datafile is ignored, and dud_mask, n_dud and error are not evaluated.
; A land mask is obtained if the data source is "psg".  All other keywords are
; evaluated.
;
;-------------------------------------------------------------------------------

Function passive_get_concentration,			$
			        datafile = datafile,	$ name of data file
			      data_group = source,	$ data info. structure
				dud_mask = dud_mask,	$ return missing mask
			       land_mask = land_mask,	$ return land mask
			           n_dud = n_dud,	$ return number missing
			          n_land = n_land,	$ return size land mask
				  reduce = reduce,	$ set to reduce missing
			           error = error,	$ return error
			       xsize_img = xsize_img,	$ return x size of image
			       ysize_img = ysize_img,	$ return y size of image
				   xorig = xorig,	$ return x posn. of pole
				   yorig = yorig,	$ return y posn. of pole
				  raster = top_down,	$ return raster type
				get_info = get_info	; set for just info.

    top_down = 0
    source.raster = 0
    if source.hemisphere ne 'north' then source.hemisphere = 'south'
    hemi = strlowcase(strmid(source.hemisphere,0,1))
    if passive_grid_info (source.form,				$
			  hemisphere = source.hemisphere, 	$
			  xsize_img  = xsize_img,		$
			  ysize_img  = ysize_img,		$
			  xpole_cell = xorig,			$
			  ypole_cell = yorig	 ) ne 0		$
			  then begin 
				; image size
				xsize_img = 316
				ysize_img = 332
				; centre coordinates
				xorig = 157.5
				yorig = 157.5
    endif
    source.xsize = xsize_img
    source.ysize = ysize_img
    source.xpole = xorig
    source.ypole = yorig
    if n_elements(land_mask) eq 1 then begin ; new land mask triggered
	case source.form of
	    'spsg' : lnd = 's'
	    'npsg' : lnd = 'n'
	    'psg'  : lnd = hemi
	    else   : lnd = ''
	endcase
	if lnd ne '' then begin
	    l = strpos(datafile, 'NASATeam')
	    if l gt 0 then begin
		root_path = strmid(datafile, 0, l)
		land_mask = get_land (	source,			$
					n_land = n_land,	$
					root_path = root_path,	$
					hemisphere = lnd)
	    endif else n_land = -1
	endif
    endif
    if keyword_set (get_info) then return, source

    return, get_a_map (source, $
		      dud_mask = dud_mask,    $
		     land_mask = land_mask,   $
		         n_dud = n_dud,       $
		        n_land = n_land,      $
		      datafile = datafile,    $
		         error = error)

end


;-------------------------------------------------------------------------------
