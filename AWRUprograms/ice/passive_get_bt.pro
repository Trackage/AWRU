;-------------------------------------------------------------------------------
;
; Read a brightness temp. (or radiance) binary land mask file, if exists.
;
;-------------------------------------------------------------------------------

Function read_bt_land_binary, landfile, land = land, error = error

	s = size(land)
TryAgain:
	openr, unit, landfile, /get_lun, error = error
	if error eq 0 then begin
	    readu, unit, land
	    close, unit
	    free_lun, unit
	endif
	if land[0,1] eq 3338 then begin ; some files have <LF> at end of line
					; (byte swapped)
		land = [land, land[0,*]]
		goto, tryagain
	endif
	land = land[0:s[1]-1,*]

return, error

end


;-------------------------------------------------------------------------------
;
; get the brightness temperature (or radiance) image size depending on the
; satellite, channel and hemisphere.
;
;-------------------------------------------------------------------------------

Function get_bt_size,	source

    
    case source.satellite of
	'Nimbus-7'  : size = 'Nimbus-7'
	'DMSP-F8'   : size = 'DMSP'
	'DMSP-F11'  : size = 'DMSP'
	'DMSP-F13'  : size = 'DMSP'
    endcase


    case size of
	'Nimbus-7' : begin
			case source.hemisphere of
			    'north' : return, [304, 448]
			    'south' : return, [316, 332]
			    else    : return, [0,0]
			 endcase
		     end

	'DMSP'     : begin
			case source.channel of
			  '85GHz'    : begin
					 case source.hemisphere of
					   'north' : return, [608, 896]
					   'south' : return, [632, 664]
					   else    : return, [0,0]
					 endcase
				       end
			  '19-37GHz' : begin
					 case source.hemisphere of
					   'north' : return, [304, 448]
					   'south' : return, [316, 332]
					   else    : return, [0,0]
					 endcase
				       end
			  else       : return, [0,0]
			endcase
		     end
	  else     : return, [0,0]
    endcase	

end


;-------------------------------------------------------------------------------
;
; Read a brightness temperature land mask.
;
; Keywords : -
;
;	root	 	Root directory - must be provided.  The complete path
;			down to the level preceeding "documents/".
;
;	data_group	Information structure heving (at least) tags
;						.satellite,
;						.hemisphere,
;						.channel.
;			(See routine passive_get_data.)
;
;	n_land		Returns number of elements (pixels) in land mask.
;
;	error		Returns 0 if no error encountered, otherwise a non zero
;			value depending on the error.
;
;-------------------------------------------------------------------------------

Function get_BT_land,		root = root,			$
				data_group = source,		$
				error = error

    ns = strmid(source.hemisphere, 0, 1)
    sep = path_separator()

    land_mask = [-1]
    size = get_bt_size (source)
    xsize = size[0]
    ysize = size[1]

    case source.satellite of
	'Nimbus-7' : begin
			land = intarr(xsize, ysize)
			landfile = root + 				$
				   'tools' + sep + 'landmask.' + ns + 'tb'
			; no land mask provided for northen hemisphere ON SAME
			; DISK AS DATA.  - Norhtern land mask for SMMR data is
			; however available on DMSP - F11/13 disks.
			; It is possible therefore that such a mask could be
			; stored in a ./tools/ directory on storeage areas
			; (root directories) other than the distribution CD's;
			; an attempt is thus made to read one.
			if read_bt_land_binary (landfile,		$
						land = land,		$
						error = error)		$
			    ne 0 then begin
				; some disks have a 'tools/tools/' area.
				landfile = root + 			$
				        'tools' + sep + 'tools'		$
					+ sep + 'landmask.' + ns + 'tb'
				error = read_bt_land_binary (landfile,	$
						land = land)
			endif
			land = swap_endian(land)
		     end

	'DMSP-F8'  : begin
			case source.channel of
			  '85GHz'    : c = 'a'
			  '19-37GHz' : c = 'b'
			  else       : return, 2
			endcase
			land = bytarr(xsize, ysize)
			landfile = root + 				$
				   'tools' + sep +  ns + '3' + c + 'mask.dat'
			if read_bt_land_binary (landfile,		$
						land = land,		$
						error = error)		$
			  ne 0 then begin
			    ; some disks have a 'tools/tools/' area.
			    landfile =  root + 				$
				        'tools' + sep + 'tools' $
					+ sep +  ns + '3' + c + 'mask.dat'
 			    if read_bt_land_binary (landfile,		$
						land = land,		$
						error = error)		$
			      ne 0 then begin
			    	landfile = root + 				$
				           'tools' + sep + ns + $
						'3' + c + 'mask.HDF'
				if HDF_ISHDF(landfile) then begin
				  HDF_DFSD_SETINFO, /restart
				  HDF_DFSD_GETINFO,landfile,TYPE=type,DIMS=dims
				  HDF_DFSD_GETDATA,landfile,land
				  HDF_DFSD_SETINFO, /restart
				endif
			    endif
			endif
			land = swap_endian(land)
		     end
	'DMSP-F11' : begin
			case source.channel of
			  '85GHz'    : c = 'a'
			  '19-37GHz' : c = 'b'
			  else       : return, 2
			endcase
			landfile= root + 				$
				  'tools' + sep + ns + '3' + c + 'mask.HDF'
			if HDF_ISHDF(landfile) then begin
			  HDF_DFSD_SETINFO, /restart
			  HDF_DFSD_GETINFO,landfile,TYPE=type,DIMS=dims
			  HDF_DFSD_GETDATA,landfile,land
			  HDF_DFSD_SETINFO, /restart
			 endif
			land = swap_endian(land)
		     end
	'DMSP-F13' : begin
			case source.channel of
			  '85GHz'    : c = 'a'
			  '19-37GHz' : c = 'b'
			  else       : return, 2
			endcase
			landfile = root + 'tools' + sep + 'masks' + sep $
					 + ns + '3' + c + 'mask.HDF'
			if HDF_ISHDF(landfile) then begin
			  HDF_DFSD_SETINFO, /restart
			  HDF_DFSD_GETINFO,landfile,TYPE=type,DIMS=dims
			  HDF_DFSD_GETDATA,landfile,land
			  HDF_DFSD_SETINFO, /restart
			endif
			land = swap_endian(land)
		     end
	else	   : return, 2
    endcase	

    ; image retrieved in raster form
    if n_elements(land) gt 1 then land = reverse(land,2)
    return, where(land ge 1, n_land)

end


;-------------------------------------------------------------------------------
; Read a single Nimbus 7 Radiance image.  (Channel determined by filename
; provided.)
; If keyword "get_size" is set, no data is read, but a 3 element array is
; returned containing :-
;			x dimension (pixels)
;			y dimension (pixels)
;			number of images
;-------------------------------------------------------------------------------

Function Nimbus_7_BT,		datafile, source,	$
				error = error,		$
				get_size = get_size	; [xsize,ysize,#images]

	size = get_bt_size (source)

	if keyword_set (get_size) then return, [size[0], size[1], 1]

	map = intarr(size[0], size[1])
	openr, unit, datafile, /get_lun, error = ok
	if ok eq 0 then begin
		readu, unit, map
		close, unit
		free_lun, unit
	endif
	; F8 data was written in FORTRAN Integer*2.  To read in IDL, need to
	; swap low and high order bytes.
	map = swap_endian(map)
	error = ok

return, reverse(map,2)

end


;-------------------------------------------------------------------------------
; Read DMSP-F8 images for either 85GHz or 19-37GHz.  The images are "layered" to
; form a 3D array, first index of which corresponds to the channel (2 channels
; for 85GHz, 5 for 19-37GHz).  The channels are deduced from the filename.
; If keyword band is set to any of:-
;		'85v' or '85h' (if type "3a" file), or
;		'91v', '19h', '22v', '37v' or '37h' (if type "3b" file),
; then only data for the nominated channel are returned (as 2D array)
; If keyword "get_size" is set, no data is read, but a 3 element array is
; returned containing :-
;			x dimension (pixels)
;			y dimension (pixels)
;			number of images
;-------------------------------------------------------------------------------

Function DMSP_F8_BT,		datafile, source,	$
				band     = band,	$
				error    = error,	$
				get_size = get_size	; [xsize,ysize,#images]

    length	= strlen(datafile)
    channel	= strmid(datafile, length-2, 2) ; 3a or 3b
    hemi	= strmid(datafile, length-3, 1) ; n or s

    error = 0

    size = get_bt_size (source)

    bands = passive_get_bands (satellite='DMSP-F8', channel=channel)
    nb = n_elements(bands)

	; identify which of the multiple images to retrieve
	if (n_elements(band) gt 0) then begin
	    ib = where (band eq bands, n)
	    if (n eq 0) then begin
		error = 2
		if keyword_set (get_size) then return, [-1, -1, -1]	$
					  else return, [0b]
	    endif
	endif else ib = indgen(nb)

	if (keyword_set(get_size)) then return, [size[0], size[1], nb]

	; F8 data was written in FORTRAN Integer*2.  To read in IDL, need to
	; swap low and high order bytes.

	map = intarr(nb,size[0],size[1])
	openr, unit, datafile, /get_lun, error = ok
	if ok eq 0 then begin
		readu, unit, map
		close, unit
		free_lun, unit
	endif else return, [0b]
	map = swap_endian(map)
	error = ok

return, reform(reverse(map[ib,*,*],3))

end


;-------------------------------------------------------------------------------
; Read a DMSP-F11/13 image for a single channel, as determined by filename.
; If keyword "get_size" is set, no data is read, but a 3 element array is
; returned containing :-
;			x dimension (pixels)
;			y dimension (pixels)
;			number of images
;-------------------------------------------------------------------------------

Function DMSP_F11_F13_BT,	datafile, source,	$
				error = error,		$
				get_size = get_size	; [xsize,ysize,#images]

    error = 0

    if keyword_set (get_size) then begin
	a = passive_get_bands (satellite = 'DMSP', channel = '85GHz')
	b = passive_get_bands (satellite = 'DMSP', channel = '19-37GHz')
	p = rstrpos(datafile, '.')
	ext = strmid(datafile, p+1, 3)
	ia = where(ext eq a, na)
	ib = where(ext eq b, nb)
	if            na eq 1 then begin
				xsize_img = 632
				ysize_img = 664
	endif else if nb eq 1 then begin
				xsize_img = 316
				ysize_img = 332
	endif else begin
				error = 2
				return, [-1, -1, -1]
	endelse
	return, [xsize_img, ysize_img, 1]
    endif

    HDF_DFSD_SETINFO, /restart	; this ensures file set to top
				; (necessary for file used to test data type
				; in routine :passive_get_data.pro",
				;  and in case the program is restarted or for
				;  some other reason attempts to re-read
				; the previous HDF file.)
    HDF_DFSD_GETINFO,datafile,TYPE=type,DIMS=dims
    HDF_DFSD_GETDATA,datafile,map
    HDF_DFSD_SETINFO, /restart	; another re-start to prevent the HDF facility
				; "locking" - e.g. if a subsequent program
				; attempts to access the same file.

    map = reverse(map,2)	; image retrieved in raster form

    error = 0

return, map

    catch, error
    return, [0b]

end


;-------------------------------------------------------------------------------
; Get brightness temperature data.
; This is a modified version of "Get_Brightness_Temperatures.pro" (which is
; used with "ice_movie.pro").  this version is adapted for use with routine
; "passive_get_data.pro" (used with "movie_player.pro").
; NB: "datafile", "source" and "year" are required inputs.
; For DMSP-F8 data "data_group" must be a structure (see "passive_get_data")
; with (as minimum) the tags ".satellite". 
;     All other keyword parameters are outputs (normally essential to caller).
; "data_group" must be a structure with at least the tags:-
;	.satellite	'Nimbus-7', 'DMSP-F8' etc.
;	.hemisphere	'north', 'south', used only in getting land mask
;	.channel	'85GHz', etc., used only in getting land mask
;	.xsize		for returning horizontal image size (pxls)
;	.ysize		for returning vertical image size (pxls)
;	.xpole		for returning horizontal pole pixel (not as yet used)
;	.ypole		for returning vertical pole pixel (not as yet used)
;	.raster		for returning 1 for 'topdown', 0 for 'bottom up'
;	.images		for returning number of images returned
; Although the raster type is returned, the image is already converted to bottom
; up.  The raster tag simply reflects to form in which the image is stored on
; disk.
; The number of images (.images) will be 1 for all but the DMSP-F8 images,
; which may return either 2 or 5 images, depending on whether the file name
; refers to 85GHz or 91 to 37 GHz data (respectively).  If a single band is
; selected, only one image is returned.
;
; keywords :-
;
;	datafile	Full file path/name for requested data.
;
;	data_group	Structure as described above.
;
;	band		Optionally request a single band from the DMSP-F8 (only)
;			data.  May take values '85v', '85h', '19v', '19h',
;			'22v', '37v' or '37h'.  NB: the file name must also
;			correspond to the bands, i.e. '3a' in the extension
;			for the 85GHz bands, '3b' for the 19 to 37GHz bands.
;
;	dud_mask	reserved
;
;	land_mask	Returns a land mask (array of indices) for the image
;			specifications relevant to datafile / datagroup.
;			A new mask is only returned if an "empty" array (i.e.
;			a single element array) is supplied on input.  This way
;			no unneccessary retrieval of land masks is made if:
;				* the keyword was not used, or
;				* the supplied variable already contains a mask.
;			The land masks are generally identical for similar image
;			specifications, and so when retrieving multiple images,
;			the "land_mask" need only be initialized (i.e. made
;			single valued) prior to the first call for a particular
;			image type, and thereafter retain the same mask.
;
;	n_dud		reserved
;
;	n_land		Returns the number of elements in the land mask.
;
;	error		Error status.  Returns 0 if no errors encountered,
;			otherwise a non-zero value dependent on the error.
;
;	xsize_img	Returns the horizontal size (pxls) of the image.
;
;	ysize_img	Returns the vertical size (pxls) of the image.
;
;	n_images	Returns the number of images returned.  Normally 1,
;			except for the DMSP-F8 images.  Where multiple images
;			are returned, they form a 3D array, with the image
;			number represented by the first dimension.
;
;	xorig		reserved
;
;	yorig		reserved
;
;	raster		Returns the raster type for the images as stored on
;			disk.  The returned images are always converted to
;			"bottom up", so this keyword is of little consequence.
;			(1 = top down, 0 = bottom up)
;
;	get_info	Set this keyword to cause the function to return an
;			informational structure instead of images.  The
;			structure is of the same type as "data_group" (with
;			.xsize, .ysize and .images updated).  No attempt is
;			made to access or read the data.
;
;-------------------------------------------------------------------------------

Function passive_get_bt,			$
		        datafile = datafile,	$ name of data file
		      data_group = source,	$ data info. structure
			    band = band,	$ optional band spec.
			dud_mask = dud_mask,	$ return missing mask
		       land_mask = land_mask,	$ return land mask
		           n_dud = n_dud,	$ return number missing
		          n_land = n_land,	$ return size land mask
		;;;	  reduce = reduce,	$ set to reduce missing
		           error = error,	$ return error
		       xsize_img = xsize_img,	$ return x size of image
		       ysize_img = ysize_img,	$ return y size of image
			n_images = n_images,	$ return no. of images
			   xorig = xorig,	$ return x posn. of pole
			   yorig = yorig,	$ return y posn. of pole
			  raster = top_down,	$ return raster type
			get_info = get_info	; set for just info.

    top_down = 1
    source.raster = 1

    ; This part needs to be at the beginning so that the land mask can be
    ; obtained even if the call to "passive_get_bt" is only a /get_info call.
    ; mask only obtained if "land_mask" is empty (i.e. single element)
    ; array.
    if n_elements(land_mask) eq 1 then begin
	sep = path_separator()
	SMMR_word = 'tbs'
	SSMI_word = strmid(source.hemisphere, 0, 1) + '3'
	case source.satellite of
	    'Nimbus-7' : word = SMMR_word
	    'DMSP-F8'  : word = SSMI_word
	    'DMSP-F11' : word = SSMI_word
	    'DMSP-F13' : word = SSMI_word
	endcase
	word = sep + word
	l = strlen(word)
	m = strpos(datafile, word)
	root = strmid(datafile, 0, m + 1)
	land_mask = get_BT_land(      root = root,	$
				data_group = source,	$
				     error = error)
	n_land = n_elements(land_mask)
    endif

    if keyword_set(get_info) then begin
      ; set nominal (hopefully correct) images specs.
      case source.satellite of
	'Nimbus-7' : inf = Nimbus_7_BT (datafile,source,er=error,/get_size)
	'DMSP-F8'  : inf = DMSP_F8_BT (datafile,source,er=error,/get_size,ba=band)
	'DMSP-F11' : inf = DMSP_F11_F13_BT (datafile,source,er=error,/get_size)
	'DMSP-F13' : inf = DMSP_F11_F13_BT (datafile,source,er=error,/get_size)
      endcase
      source.xsize  = inf[0]
      source.ysize  = inf[1]
      source.xpole  = -1;?????????????????????????
      source.ypole  = -1;?????????????????????????
      source.images = inf[2]
      return, source
    endif

    case source.satellite of

	'Nimbus-7' : map = Nimbus_7_BT (datafile,source,error=error)
	'DMSP-F8'  : map = DMSP_F8_BT (datafile,source,error=error, band=band)
	'DMSP-F11' : map = DMSP_F11_F13_BT (datafile,source,error=error)
	'DMSP-F13' : map = DMSP_F11_F13_BT (datafile,source,error=error)

    endcase

    size = size(map)
    case size[0] of
	2    :	begin
		  n_images = 1
		  xsize_img = size[1]
		  ysize_img = size[2]
		end
	3    :	begin
		  n_images = 2
		  xsize_img = size[2]
		  ysize_img = size[3]
		end
	else :	begin
		  n_images = 0
		  xsize_img = -1
		  ysize_img = -1
		end
    endcase

    source.xsize  = xsize_img
    source.ysize  = ysize_img
    source.xpole  = -1;?????????????????????????
    source.ypole  = -1;?????????????????????????
    source.images = n_images

return, map

end


;-------------------------------------------------------------------------------
