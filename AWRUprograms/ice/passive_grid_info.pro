;-------------------------------------------------------------------------------
; Error reporter
;-------------------------------------------------------------------------------

Function grid_error, name, tag

 if name eq 'OK' then return, 0
 s = size(tag)
 if s[0] ne 0 or s[1] ne 7 then tag = '' else tag = ' [' + tag + ']'

 ercode = {EC, name:'', number:0L, report:''}
 errors =								       $
 [{EC, 'BadSource'	   ,-4,'The supplied source is not listed.'},	       $
  {EC, 'BadDataType'	   ,-5,'The supplied data type is not valid.'},	       $
  {EC, 'NoSource'	   ,-3,'No source argument supplied.'},		       $
  {EC, 'HemisphereConflict',-2,'Input hemisphere and "psg" prefix disagree.'}, $
  {EC, 'MissingChannel'    ,-1,'Channel needs to be supplied for DMSP B.T.'},  $
  {EC, 'OK'		   , 0,''}					       ]

 a = where(errors.name eq name, n)
 pre = 'ERROR IN PASSIVE_GRID_INFO: '
 if n eq 1 then begin
	Print, pre + errors[a[0]].report + tag
	return, errors[a[0]].number
 endif else begin
	Print, pre + 'Error of unknown type.'
	return, -999
 endelse

end


;------------------------------------------------------------------------------
;
; A repository for grid and projection information for passive microwave image
; data.
;
; Requires input :-
;			"source" as one of the following:
;					'NSIDC SMMR ICE CONCENTRATION'
;					'SMMR CDROM'
;					'SMMR DOWNLOADED'
;					'SMMR ON <BERG>'
;					'DMSP ON CDROM'
;					'NSIDC SSM/I ICE CONCENTRATION'
;					'SSMI DOWNLOADED'
;					'SSMI ON <BERG>'
;					'SSM/I DOWNLOADED'
;					'SSM/I ON <BERG>'
;					'NSIDC SMMR RADIANCE'
;					'NSIDC SMMR BRIGHTNESS TEMPERATURE'
;					'NSIDC SSM/I BRIGHTNESS TEMPERATURE'
;					'NSIDC SSMI BRIGHTNESS TEMPERATURE'
;					'NIC ICE CONCENTRATION'
;					'SPSG'
;					'SPSG DOWNLOADED'
;					'SPSG ON <BERG>'
;					'NPSG'
;					'NPSG DOWNLOADED'
;					'NPSG ON <BERG>'
;					'PSG'
;					'PSG DOWNLOADED'
;					'PSG ON <BERG>'
;					'Pole Centred 12.5'
;					'Pole Centred 25'
;					'Pole Centred 50'
;					'Pole Centred 100'
;					'Pole Centred' -- supply cell size
;	(add more to the routine as required -- either to refer to existing
;	 specifications, or for new specs.)
;
; Keywords :-
;	hemisphere	Input 'N[orth]' or 'S[outh]'.  South is default.
;
;	channel		Input the SSMI Brightness Temperature channel (only
;			required for SSM/I brightness temperature sources), as
;			one of the following:
;					'a'		= 85 GHz
;					'3a'		= 85 GHz
;					'85GHZ'
;					'b'		= 19 to 37 GHz
;					'3b'		= 19 to 37 GHz
;					'19-37GHZ'
;
;	cell_size	Returns the cell dimension in km.
;
;	true_lat	Returns the "true latitude" for the polar stereographic
;			projection.  (Ie. the "distortion free" latitude.)
;
;	ref_long	Returns the longitude represented by a vertical vector
;			from the pole (+y) in the dsiplayed image.
;
;	x_origin	Returns the "horizontal" (x) distance in (grid) km from
;			the centre of the left boundary column (x = 0) to the
;			pole.
;
;	y_origin	Returns the "vertical" (y) distance in (grid) km from
;			the centre of the llower boundary row (y = 0) to the
;			pole.
;
;	xsize_img	Returns the number of columns in the image.
;
;	ysize_img	Returns the number of rows in the image.
;
;	xpole_cell	Returns the "horizontal" grid cell location (column) of
;			the pole.
;
;	ypole_cell	Returns the "vertical" grid cell location (row) of
;			the pole.
;
; (Note 1: xpole_cell, ypole_cell --- pole locations are returned to the
;	   nearest 1/2 cell; it is assumed that the pole is either at a cell
;	   centre or a cell boundary in either direction.
;  Note 2: Grid cell specifications are referenced from the centre of the cell.)
;
;------------------------------------------------------------------------------

Function passive_grid_info,	source,			 $
				data_type  = data_type,	 $
				hemisphere = hemisphere, $ N[orth] or S[outh]
				channel    = channel,	 $ SSMI BT only
				cell_size  = cell_size,	 $ cell dimension in km
				true_lat   = true_lat,	 $ true lat. for p.s.p.
				ref_long   = ref_long,	 $ longitude upwards
				x_origin   = x_origin,	 $ from lower left km
				y_origin   = y_origin,	 $  "     "    "   "
				xsize_img  = xsize_img,	 $ # cols. in image
				ysize_img  = ysize_img,	 $ # rows in image
				xpole_cell = xpole_cell, $ x posn. pole (cells)
				ypole_cell = ypole_cell, $ y posn. pole (cells)
				info = info

    ; buffer inputs
    if (n_elements(data_type)  eq 0) then data_type = -1
    if (n_elements(hemisphere) eq 0) then hemisphere = '?'
    if (n_elements(channel)    eq 0) then channel    = '?'

    hemi = strupcase(strmid(hemisphere,0,1))

    if (data_type ge 0) then begin

    case data_type of
	0				: src = 5
	1				: src = 5
	2				: src = 4
	3				: src = 0
	4				: src = 2
	5				: src = 2
	else				: return, $
					  grid_error('BadDataType',data_type)
    endcase
    hemii = 'S' ; default

    endif else begin

    if (n_elements(source)     eq 0) then return, grid_error('NoSource')
    case strupcase(source) of
	'NSIDC SMMR ICE CONCENTRATION'		: src = 3
	'SMMR CDROM'				: src = 3
	'SMMR DOWNLOADED'			: src = 3
	'SMMR ON <BERG>'			: src = 3
	'DMSP ON CDROM'				: src = 1
	'NSIDC SSM/I ICE CONCENTRATION'		: src = 2
	'SSMI DOWNLOADED'			: src = 2
	'SSMI ON <BERG>'			: src = 2
	'SSM/I DOWNLOADED'			: src = 2
	'SSM/I ON <BERG>'			: src = 2
	'DMSP ON <BERG>'			: src = 2
	'DMSP DOWNLOADED'			: src = 2
	'NSIDC SMMR RADIANCE'			: src = 4
	'NSIDC SMMR BRIGHTNESS TEMPERATURE'	: src = 4
	'NSIDC SSM/I BRIGHTNESS TEMPERATURE'	: src = 5
	'NSIDC SSMI BRIGHTNESS TEMPERATURE'	: src = 5
	'NIC ICE CONCENTRATION'			: src = 0
	'SPSG'					: src = 0
	'SPSG DOWNLOADED'			: src = 0
	'SPSG ON <BERG>'			: src = 0
	'NPSG'					: src = 0
	'NPSG DOWNLOADED'			: src = 0
	'NPSG ON <BERG>'			: src = 0
	'PSG'					: src = 0
	'PSG DOWNLOADED'			: src = 0
	'PSG ON <BERG>'				: src = 0
	'POLE CENTRED 12.5'			: src = 6
	'POLE CENTRED 25'			: src = 6
	'POLE CENTRED 50'			: src = 6
	'POLE CENTRED 100'			: src = 6
	'POLE CENTRED'				: src = 6
	else					: return, $
						  grid_error('BadSource',source)
    endcase

    if (src eq 0) then begin
	case strupcase(strmid(source,0,1)) of
	    'N'		: hemii = 'N'
	    'S'		: hemii = 'S'
	    'P'		: hemii = hemi
	endcase
	if (hemii ne hemi and hemi ne '?') then				$
				return, grid_error('HemisphereConflict',source)
    endif else hemii = 'S' ; default

    endelse

    case strupcase(channel) of
	'A'		: chan = 0
	'3A'		: chan = 0
	'85GHZ'		: chan = 0
	'85H'		: chan = 0
	'85V'		: chan = 0
	'B'		: chan = 1
	'3B'		: chan = 1
	'19-37GHZ'	: chan = 1
	'19H'		: chan = 1
	'19V'		: chan = 1
	'22H'		: chan = 1
	'22V'		: chan = 1
	'37H'		: chan = 1
	'37V'		: chan = 1
	'?'		: chan = -1
	else		: chan = -1
    endcase

    if (hemi eq '?') then hemi = hemii

    case hemi of
	'N' : begin
		case src of
		  0 : begin		; npsg (NIC)
			true_lat   = +60.
			ref_long   = -80.	; NB: unlike the spsg images,
			x_origin   = 4826.	; these specs. assume no rotat-
			y_origin   = 5842.	; ion of the image after recov-
			cell_size  = 25.4	; ery from disk, but does assume
			xsize_img  = 385	; "bottom up" display.
			ysize_img  = 465
		      end
		  1 : begin		; SSM/I (NSIDC) ice conc. (CD rom)
			true_lat   = +70.
			ref_long   = -45.
			x_origin   = 3837.5
			y_origin   = 5337.5
			cell_size  = 25.0
			xsize_img  = 304
			ysize_img  = 448
		      end
		  2 : begin		; SSM/I (NSIDC) ice conc. (ftp)
			true_lat   = +70.
			ref_long   = -45.
			x_origin   = 3837.5
			y_origin   = 5337.5
			cell_size  = 25.0
			xsize_img  = 304
			ysize_img  = 448
		      end
		  3 : begin		; SMMR (NSIDC) ice conc. (ftp)
			true_lat   = +70.
			ref_long   = -45.
			x_origin   = 3837.5
			y_origin   = 5337.5
			cell_size  = 25.0
			xsize_img  = 304
			ysize_img  = 448
		      end
		  4 : begin		; SMMR (NSIDC) radiance (CDrom)
			true_lat   = +70.
			ref_long   = -45.
			x_origin   = 3837.5
			y_origin   = 5337.5
			cell_size  = 25.0
			xsize_img  = 304
			ysize_img  = 448
		      end
		  5 : begin		; SSM/I (NSIDC) brightness temp. (CDrom)
			true_lat   = +70.
			ref_long   = -45.
			case chan of
			  0    : begin	; 85 GHz channel
				   x_origin   = 3843.75
				   y_origin   = 5343.75
				   cell_size  = 12.5 
				   xsize_img  = 608
				   ysize_img  = 896
			         end
			  1    : begin	; 19 to 37 GHz channels
				   x_origin   = 3837.5
				   y_origin   = 5337.5
				   cell_size  = 25.0
				   xsize_img  = 304
				   ysize_img  = 448
			         end
			  -1   : return, grid_error('MissingChannel',channel)
			endcase
		      end
		  6 : begin		; pole centred (not a supplied type)
			true_lat   = +70.
			ref_long   = -45.
			x_origin   = 0.
			y_origin   = 0.
			if strlen(source) gt 13 then 			$
				reads, source, cell_size, format='(13x,f)'$
					else cell_size = 1.

			xsize_img  = 0
			ysize_img  = 0
		      end
		endcase
	      end
	'S' : begin
		case src of
		  0 : begin		; spsg (NIC)
			true_lat   = -60.
			ref_long   = +10.	; NB: the following specs. all
			x_origin   = 4394.2	; the spsg image has been rot-
			y_origin   = 3810.0	; ated by +90 deg. after recov-
			cell_size  = 25.4	; ery from disk.
			xsize_img  = 355
			ysize_img  = 345
		      end
		  1 : begin		; SSM/I (NSIDC) ice conc. (CD rom)
			true_lat   = -70.
			ref_long   = 0.0
			x_origin   = 3937.5
			y_origin   = 3937.5
			cell_size  = 25.0
			xsize_img  = 316
			ysize_img  = 332
		      end
		  2 : begin		; SSM/I (NSIDC) ice conc. (ftp)
			true_lat   = -70.
			ref_long   = 0.0
			x_origin   = 3937.5
			y_origin   = 3937.5
			cell_size  = 25.0
			xsize_img  = 316
			ysize_img  = 332
		      end
		  3 : begin		; SMMR (NSIDC) ice conc. (ftp)
			true_lat   = -70.
			ref_long   = 0.0
			x_origin   = 3937.5
			y_origin   = 3937.5
			cell_size  = 25.0
			xsize_img  = 316
			ysize_img  = 332
		      end
		  4 : begin		; SMMR (NSIDC) radiance (CDrom)
			true_lat   = -70.
			ref_long   = 0.0
			x_origin   = 3937.5
			y_origin   = 3937.5
			cell_size  = 25.0
			xsize_img  = 316
			ysize_img  = 332
		      end
		  5 : begin		; SSM/I (NSIDC) brightness temp. (CDrom)
			true_lat   = -70.
			ref_long   = 0.0
			case chan of
			  0    : begin	; 85 GHz channel
				   x_origin   = 3943.75
				   y_origin   = 3943.75
				   cell_size  = 12.5
				   xsize_img  = 632
				   ysize_img  = 664
			         end
			  1    : begin	; 19 to 37 GHz channels
				   x_origin   = 3937.5
				   y_origin   = 3937.5
				   cell_size  = 25.0
				   xsize_img  = 316
				   ysize_img  = 332
			         end
			  -1   : return, grid_error('MissingChannel',channel)
			endcase
		      end
		  6 : begin		; pole centred (not a supplied type)
			true_lat   = -70.
			ref_long   = 0.
			x_origin   = 0.
			y_origin   = 0.
			if strlen(source) gt 13 then 			$
				reads, source, cell_size, format='(13x,f)'$
					else cell_size = 1.
			xsize_img  = 0
			ysize_img  = 0
		      end
		endcase
	      end
    endcase

    xpole_cell = fix(x_origin / cell_size * 2. + .5) / 2.
    ypole_cell = fix(y_origin / cell_size * 2. + .5) / 2.

    info = { cell_size:cell_size, x_origin:x_origin, y_origin:y_origin, $
	     xsize_img:xsize_img, ysize_img:ysize_img, true_lat:true_lat, $
	     ref_long:ref_long, xpole_cell:xpole_cell, ypole_cell:ypole_cell }

    return, 0

end
