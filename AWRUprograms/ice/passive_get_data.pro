@passive_get_concentration
@passive_get_bt
@passive_filename
@passive_check_file
@path_separator

;-------------------------------------------------------------------------------
; Get the form (e.g. 'psg', 'SMMR on CDrom', etc) in which the passive
; data has been stored.  (NB this is not explicitly the actual format.)
; It is dependent on  the integer data designation ('itype'), and uses
; information already inserted into 'data_group.experiment' and
; 'data_group.source'.
; The value of 'data_group.form' is updated.
;-------------------------------------------------------------------------------

Pro passive_get_form, data_group, itype

    case itype of

	0    : data_group.form = data_group.experiment + ' ' + data_group.source
	1    : data_group.form = data_group.experiment + ' ' + data_group.source
	2    : data_group.form = data_group.experiment + ' ' + data_group.source
	3    : data_group.form = 'psg'
	4    : data_group.form = data_group.experiment + ' ' + data_group.source
	5    : data_group.form = data_group.experiment + ' ' + data_group.source
	else : data_group.form = '?'

    endcase

end


;-------------------------------------------------------------------------------
; Get method used (i.e. COMISO or NASATeam) for the ice concentration
; data corresponding to integer data type designation 'itype'.
;-------------------------------------------------------------------------------

Function passive_get_method, itype

    case itype of

	3	: method = 'NASATeam'
	4	: method = 'NASATeam'
	5	: method = 'COMISO'
	else	: method = '?'

    endcase

return, method

end


;-------------------------------------------------------------------------------
; Get default source (i.e. CDrom or downloaded) for the ice concentration
; data corresponding to integer data type designation 'itype'.
; This impacts on the directory structure used.
;-------------------------------------------------------------------------------

Function passive_get_source, itype

    case itype of

	0	: source	= 'CDrom'
	1	: source	= 'CDrom'
	2	: source	= 'CDrom'
	3	: source	= 'downloaded'
	4	: source	= 'downloaded'
	5	: source	= 'downloaded'
	else	: source	= '?'

    endcase

return, source

end


;-------------------------------------------------------------------------------
; Get channel (i.e. 6-37GHz, 19-37GHz or 85GHz) for the brightness temperature
; data corresponding to integer data type designation 'itype'.
;-------------------------------------------------------------------------------

Function passive_get_channel, itype

    case itype of

	0	: channel	= '85GHz'
	1	: channel	= '19-37GHz'
	2	: channel	= '6-37GHz'
	else	: channel	= '?'

    endcase

return, channel

end


;-------------------------------------------------------------------------------
; Get (default) satellite (i.e. Nimbus-7, DMSP-F8, -F11 or -F13) represented by
; the experiment (SMMR or SSM/I), 'exp' and the julian day, 'jday'.
; NB: Where satellite coverage overlaps, this routine assumes the older unit.
;-------------------------------------------------------------------------------

Function passive_get_satellite, exp, jday

    case exp of

	'SMMR'	: satellite = 'Nimbus-7'

	'SSMI'	:      if jday lt 2446986 then satellite = '?'		$
		  else if jday lt 2448622 then satellite = 'DMSP-F8'	$
		  else if jday lt 2449991 then satellite = 'DMSP-F11'	$
		  else                         satellite = 'DMSP-F13'

	else	: satellite = '?'

    endcase

return, satellite

end


;-------------------------------------------------------------------------------
; Get (default) passive experiment (i.e. SMMR or SSM/I) represented by
; the integer type designation 'itype' and the julian day, 'jday'.
;-------------------------------------------------------------------------------

Function passive_get_experiment, itype, jday

    case itype of

	0	: experiment	= 'SSMI'

	1	: experiment	= 'SSMI'

	2	: experiment	= 'SMMR'

	3	: experiment	= 'SSMI'

	4	:	if jday lt 2447028 then experiment	= 'SMMR'  $
					   else experiment	= 'SSMI'

	5	:	if jday lt 2447028 then experiment	= 'SMMR'  $
					   else experiment	= 'SSMI'

	else	: experiment	 = '?'

    endcase

return, experiment

end


;-------------------------------------------------------------------------------
; Get passive data type (ice concentrations or brightness temp.) represented by
; the integer type designation 'itype'.
;-------------------------------------------------------------------------------

Function passive_get_type, itype

    case itype of

	0	: type = 'brightness temperature'
	1	: type = 'brightness temperature'
	2	: type = 'brightness temperature'
	3	: type = 'ice concentration'
	4	: type = 'ice concentration'
	5	: type = 'ice concentration'
	else	: type = '?'

    endcase

return, type

end


;-------------------------------------------------------------------------------
; Error reporter
;-------------------------------------------------------------------------------

Function get_error, name, tag, disable=disable

 if name eq 'OK' then return, 0
 s = size(tag)
 if s[0] ne 0 or s[1] ne 7 then tag = '' else tag = ' [' + tag + ']'

 ercode = {EC, name:'', number:0L, report:''}
 errors =								       $
 [{EC, 'NoRoot'      ,-3, 'Root directory not found.'},			       $
  {EC, 'NoDirectory' ,-2, 'Directory not found.'},			       $
  {EC, 'NoFile'      ,-1, 'File not found.'},				       $
  {EC, 'OK'	      ,0,  ''},					       $
  {EC, 'BadData'     ,1,  'Error encountered trying to open or read data.'},   $
  {EC, 'BadRequest'  ,2,  'Bad request - e.g. inappropriate keywords.'}        ]

 a = where(errors.name eq name, n)
 pre = 'ERROR IN PASSIVE_GET_DATA: '
 if n eq 1 then begin
	if not keyword_set(disable) then Print, pre + errors[a[0]].report + tag
	return, errors[a[0]].number
 endif else begin
	if not keyword_set(disable) then Print, pre + 'Error of unknown type.'
	return, -999
 endelse

end


;-------------------------------------------------------------------------------
; Print help info.
;-------------------------------------------------------------------------------

Pro print_passive_info

	print,	format='(a)',						       $
['---------------------------------------------------------------------------',$
'',$
' Name :-',$
'	passive_get_data',$
'',$
' Purpose :-',$
'	A general reader of passive microwave data (ice concentrations or',$
'	brightness temperature) from various data sources (directories,',$
'	cd rom).',$
'',$
'	Platform independent.  Handles binary and HDF formats.',$
'',$
' Calling sequence :-',$
'	status = passive_get_data (type, root_dir, day, month, year)',$
'',$
' Returned value :-',$
'	a status indicator, viz:',$
'			-3 = root directory not found or empty',$
'			-2 = full directory path not found or empty',$
'			-1 = file not found',$
'			 0 = ok',$
'			 1 = file found, but error in opening/reading',$
'			 2 = bad/illegal call (e.g. inappropriate',$
'				keyword values supplied)',$
'			unless /get_info is set (see "keywords").',$
'',$
' Required inputs:-',$
'',$
'	type	    An integer representing the data type/source,',$
'		    vz:',$
'			0 =  SSM/I brightness temperatures, 85GHz',$
'			1 =  SSM/I brightness temperatures, 19-37GHz',$
'			2 =  SMMR brightness temperatures, 6-37GHz',$
'			3 =  spsg or npsg ice concentrations',$
'			4 =  NASATeam ice concentrations',$
'			5 =  COMISO ice concentrations',$
'',$
'	root_dir    Path to the data, not including data type or date',$
'		    directory levels.',$
'',$
'	day	    Integer day of month, or Julian day (if /julian set).',$
'',$
'	month	    Integer month (required if day is not Julian).',$
'',$
'	year	    4 digit integer year (required if day is not Julian).',$
'',$
' Keywords:-',$
'',$
'	data	    Variable to return image (may be 2D array, or 3D if',$
'		    multi-band image returned).',$
'',$
'	bt_band	    Optional string input (for brightness temperature data',$
'		    only) to select a single band.',$
'		    For Nimbus-7 (SMMR) data, may have values:-',$
'				"06v"	"10v"	"18v"	"37v"',$
'				"06h"	"10h"	"18h"	"37h"',$
'		    For DMSP (SSM/I) data, may have values:-',$
'				"19v"	"22v"	"37v"	"85v"',$
'				"19h"		"37h"	"85h"',$
'',$
'	land_mask   Returns 1D array of indices representing land pixels.',$
'		    Only takes effect if the variable is "empty" on input',$
'		    (i.e. scalar or single element array of value 0).',$
'		    Thus, repeated calls with the same variable (unaltered)',$
'		    will only read a landmask the first time through.',$
'		    If variable is undefined, or not supplied, no attempt',$
'		    is made to read a landmask.',$
'',$
'	julian	    Set to indicate that "day" is in Julian days.',$
'',$
'	help	    Set this keyword to display this information.',$
'		    Any other settings or inputs are disregarded.',$
'']
	print,	format='(a)',						       $
['	get_info    Set this keyword to return an information structure',$
'		    containing the following tags:-',$
'			.type ....... type of data (e.g. "ice concentration")',$
'			.experiment . "SMMR" or "SSM/I"	',$
'			.satellite .. "Nimbus-7", "DMSP-F8", etc.',$
'			.hemisphere . "north" or "south"',$
'			.source ..... "downloaded" or "CDrom"',$
'			.form ....... e.g. "SMMR downloaded", "SSMI CDrom"',$
'			.channel .... (B. Temp. only) e.g. "19-37GHz"',$
'			.method ..... (Ice. Conc. only) e.g. "COMISO"',$
'			.format ..... "HDF", "byte", "none", "unknown"',$
'			.xsize ...... horizontal dimension (pixels)',$
'			.ysize ...... vertical dimension (pixels)',$
'			.xpole ...... horiz. location of pole (pxls - float.)',$
'			.ypole ...... vert. location of pole (pxls - float.)',$
'			.raster ..... 0 = "bottom-up", 1 = "top-down"',$
'		    (No attempt is made to read data.)',$
'',$
'	south	    Set to specify southern hemisphere (default).',$
'',$
'	north	    Set to specify northern hemisphere.',$
'',$
'	xsize_img   Returns the size of the x (horizontal) dimension of the',$
'		    image(s)',$
'',$
'	ysize_img   Returns the size of the y (vertical) dimension of the',$
'		    image(s)',$
'',$
'	n_images    Returns the number of images recovered.  For many',$
'		    cases, a single image (2D array) is returned.  For',$
'		    brightness temperatures, where "bt_band" is not',$
'		    specified, a 3D array is returned, the size of the first',$
'		    dimension of which should equal "n_images".  For an',$
'		    unsuccessful call (i.e. no data returned), n_images = 0.',$
'',$
'	full_path   Returns the full file path less the filenames.',$
'',$
'	cdrom	    Set to restrict data search to CDrom only.  Only has',$
'		    effect for ice-concentrations (data types 3, 4 & 5).',$
'		    NB: If both /cdrom and /download are set, an error is',$
'		    generated, and no data is returned.',$
'',$
'	download    Set to restrict data search to "downloaded" data sources',$
'		    only.  Only has effect for ice-concentrations (data types',$
'		    3, 4 & 5).  NB: If both /cdrom and /download are set, an',$
'		    error is generated, and no data is returned.',$
'',$
'	files       Returns the bare file names (i.e. deviod of path info.)',$
'		    as a single string or string array (depending on',$
'		    requested data).',$
'',$
' Author :-',$
'	Pelham Williams, 1999',$
'',$
'',$
'-----------------------------------------------------------------------------']

end


;+______________________________________________________________________________
;
; Name :-
;	passive_get_data
;
; Purpose :-
;	A general reader of passive microwave data (ice concentrations or
;	brightness temperature) from various data sources (directories, cd rom).
;
;	Platform independent.  Handles binary and HDF formats.
;
; Calling sequence :-
;	status = passive_get_data (type, root_dir, day, month, year)
;
; Returned value :-
;	a status indicator, viz:
;			-3 = root directory not found or empty
;			-2 = full directory path not found or empty
;			-1 = file not found
;			 0 = ok
;			 1 = file found, but error in opening/reading
;			 2 = bad/illegal call (e.g. inappropriate
;				keyword values supplied)
;			unless /get_info is set (see "keywords")
; Required inputs:-
;
;	type	    An integer representing the data type/source,
;		    vz:
;			0 =  SSM/I brightness temperatures, 85GHz
;			1 =  SSM/I brightness temperatures, 19-37GHz
;			2 =  SMMR brightness temperatures, 6-37GHz
;			3 =  spsg or npsg ice concentrations
;			4 =  NASATeam ice concentrations
;			5 =  COMISO ice concentrations
;
;	root_dir    Path to the data, not including data type or date
;		    directory levels.
;
;	day	    Integer day of month, or Julian day (if /julian set).
;
;	month	    Integer month (required if day is not Julian).
;
;	year	    4 digit integer year (required if day is not Julian).
;
; Keywords:-
;
;	data	    Variable to return image (may be 2D array, or 3D if
;		    multi-band image returned).
;
;	bt_band	    Optional string input (for brightness temperature data
;		    only) to select a single band.
;		    For Nimbus-7 (SMMR) data, may have values:-
;				"06v"	"10v"	"18v"	"37v"
;				"06h"	"10h"	"18h"	"37h"
;		    For DMSP (SSM/I) data, may have values:-
;				"19v"	"22v"	"37v"	"85v"
;				"19h"		"37h"	"85h"
;
;	land_mask   Returns 1D array of indices representing land pixels.
;		    Only takes effect if the variable is "empty" on input
;		    (i.e. scalar or single element array of value 0).
;		    Thus, repeated calls with the same variable (unaltered)
;		    will only read a landmask the first time through.
;		    If variable is undefined, or not supplied, no attempt
;		    is made to read a landmask.
;
;	julian	    Set to indicate that "day" is in Julian days.
;
;	help	    Set this keyword to display this information.
;		    Any other settings or inputs are disregarded.
;
;	get_info    Set this keyword to return an information structure
;		    containing the following tags:-
;			.type ....... type of data (e.g. "ice concentration")
;			.experiment . "SMMR" or "SSM/I"
;			.satellite .. "Nimbus-7", "DMSP-F8", etc.
;			.hemisphere . "north" or "south"
;			.source ..... "downloaded" or "CDrom"
;			.form ....... e.g. "SMMR downloaded", "SSMI CDrom"
;			.channel .... (B. Temp. only) e.g. "19-37GHz"
;			.method ..... (Ice. Conc. only) e.g. "COMISO"
;			.format ..... "HDF", "byte", "none", "unknown"
;			.xsize ...... horizontal dimension (pixels)
;			.ysize ...... vertical dimension (pixels)
;			.xpole ...... horiz. location of pole (pxls - float.)
;			.ypole ...... vert. location of pole (pxls - float.)
;			.raster ..... 0 = "bottom-up", 1 = "top-down"
;		    (No attempt is made to read data.)
;
;	south	    Set to specify southern hemisphere (default).
;
;	north	    Set to specify northern hemisphere.
;
;	xsize_img   Returns the size of the x (horizontal) dimension of the
;		    image(s)
;
;	ysize_img   Returns the size of the y (vertical) dimension of the
;		    image(s)
;
;	n_images    Returns the number of images recovered.  For many
;		    cases, a single image (2D array) is returned.  For
;		    brightness temperatures, where "bt_band" is not
;		    specified, a 3D array is returned, the size of the first
;		    dimension of which should equal "n_images".  For an
;		    unsuccessful call (i.e. no data returned), n_images = 0.
;
;	full_path   Returns the full file path less the filenames.
;
;	cdrom	    Set to restrict data search to CDrom only.  Only has
;		    effect for ice-concentrations (data types 3, 4 & 5).
;		    NB: If both /cdrom and /download are set, an error is
;		    generated, and no data is returned.
;
;	download    Set to restrict data search to "downloaded" data sources
;		    only.  Only has effect for ice-concentrations (data types
;		    3, 4 & 5).  NB: If both /cdrom and /download are set, an
;		    error is generated, and no data is returned.
;
;	files       Returns the bare file names (i.e. deviod of path info.)
;		    as a single string or string array (depending on
;		    requested data).
;
; Author :-
;	Pelham Williams, 1999
;
;-______________________________________________________________________________

Function passive_get_data,			$
			type,			$; integer data type designation
			root_dir,		$; root directory
			day,			$; integer day (DOM or Julian)
			month,			$; integer month
			year,			$; 4 digit year
			data 	  = data,	$; returned image
			bt_band	  = bt_band,	$; optional band selector
			land_mask = land_mask,	$; land indices
			julian	  = julian,	$; set for day as Julian
			help	  = help,	$; set to display info.
			get_info  = get_info,	$; set for just info.
			south	  = south,	$; set for southern hemis. [def]
			north	  = north,	$; set for northern hemisphere
			xsize_img = xsize_img,	$; horiz. dimension of image(s)
			ysize_img = ysize_img,	$; vert. dimension of image(s)
			n_images  = n_images,	$; number of images returned in
						 ;   "data", = 0 if unsuccessful
						 ;           = 1 in most cases
						 ;	     = 2 for F8 85GHz
						 ;           = 5 for F8 19-37GHz
			full_path = full_path,	$; return full path (less file)
			cdrom	  = cdrom,	$; restrict source to CD
			download  = download,	$; restrict source to downloads
			files	  = files,	$; return filenames (less path)
			no_error_messages = nem	 ; set to disable error messages

    if keyword_set(help) then begin
	print_passive_info
	return, 0
    endif

; some data type structures

	bt = {	type:		'?',	$ ; brightness temperature
		experiment:	'?',	$
		satellite:	'?',	$
		hemisphere:	'?',	$
		source:		'?',	$
		form:		'?',	$
		channel:	'?',	$
;		polarization:	'?',	$;?????????????? don't need ????????????
		format:		'?',	$
		xsize:		0L,	$
		ysize:		0L,	$
		xpole:		0.0,	$
		ypole:		0.0,	$
		images:		0L,	$
		raster:		0L}

	ic = {	type:		'?',	$ ; ice concentration
		experiment:	'?',	$
		satellite:	'?',	$
		hemisphere:	'?',	$
		source:		'?',	$
		form:		'?',	$
		method:		'?',	$
		format:		'?',	$
		xsize:		0L,	$
		ysize:		0L,	$
		xpole:		0.0,	$
		ypole:		0.0,	$
		raster:		0L}

	uk = {	type:		'?',	$ ; unknown
		experiment:	'?',	$
		satellite:	'?',	$
		hemisphere:	'?',	$
		source:		'?',	$
		form:		'?',	$
		format:		'?',	$
		xsize:		0L,	$
		ysize:		0L,	$
		xpole:		0.0,	$
		ypole:		0.0,	$
		raster:		0L}

; buffer inputs
	itype = type
	iday = day
	if n_elements(month) gt 0 then imonth = month
	if n_elements(year)  gt 0 then iyear = year

    icd = keyword_set(cdrom)
    idn = keyword_set(download)
    if icd and idn then			$
    	return, get_error('BadRequest','CD / download conflict',disable=nem)
    if keyword_set(bt_band) then begin
;	if itype gt 2 then		$
;		return, get_error('BadRequest','type/band conflict',disable=nem)
	bt_band = strlowcase(bt_band)
	n = where(passive_get_bands(type = itype) eq bt_band, nb)
	if nb ne 1 then begin ; requested band not identified in list of bands
	    if itype ge 2 then		$; SMMR data - only 1 set
		return,get_error('BadRequest', 'type/band conflict',disable=nem)
	    if itype eq 0 then itype = 1 else itype = 0 ; 85GHz or 19-37GHz
	    n = where(passive_get_bands(type = itype) eq bt_band, nb)
	    if nb ne 1 then	 	$; not in either list
		return,get_error('BadRequest', 'type/band conflict',disable=nem)
	endif
    endif

    sep = path_separator()
    if strmid(root_dir, strlen(root_dir)-1,1) ne sep then root_dir=root_dir+sep
    fff = findfile(root_dir+'*', count = count)
    if count le 0 then return, get_error('NoRoot',root_dir,disable=nem)

; select appropriate data type

         if itype le 2	then data_group = bt $
    else if itype le 5	then data_group = ic $; add any new data types to chain
    else                     data_group = uk

    data_group.type = passive_get_type (itype)
    if icd then data_group.source = 'CDrom'		else		$
    if idn then	data_group.source = 'downloaded'	else		$
    		data_group.source = passive_get_source (itype)
    if keyword_set(north) then data_group.hemisphere = 'north'		$
			  else data_group.hemisphere = 'south'

    case data_group.type of
      'brightness temperature' : data_group.channel = passive_get_channel(itype)
      'ice concentration'      : data_group.method  = passive_get_method (itype)
      else                     :
    endcase

; make date string

    if keyword_set(julian) then begin
	jday = iday
	caldat, jday, imonth, iday, iyear
    endif
    dates = string(iyear, imonth, iday, format='(3i2.2)')
    jday = julday(imonth, iday, iyear) ; Julian day
    date = [iday, imonth, iyear] ; date array

; get date dependant info.

    data_group.experiment = passive_get_experiment (itype, jday)
    data_group.satellite  = passive_get_satellite (data_group.experiment, jday)

; compile filename
TryAgain:
    passive_get_form, data_group, itype 
    file = passive_filename (data_group, date, bt_band=bt_band) ; may be scalar
							    ; or array returned
; check file

    ff = file
    fn = n_elements(file)
    if fn gt 1 then ff = file[0]
    l = rstrpos(ff, sep)
    full_path = root_dir + strmid(ff, 0, l+1)
    files = strmid(file, l+1)
    fff = findfile(full_path, count = count)
    data_group.format = 'none'
    if count le 0 then er = 'NoDirectory' else begin
	er = 'NoFile'
	data_group.format = passive_check_file (root_dir + ff)
    end
    if data_group.format eq 'unknown' then		$
			return, get_error('NoFile',root_dir+ff,disable=nem)
    if data_group.format eq 'none'    then begin ; not found, try different dir.
      case data_group.type of
	'ice concentration'      : begin
	    case data_group.form of
	      'SSMI CDrom'      : return, get_error(er,root_dir+ff,disable=nem)
	      'SMMR downloaded' : begin
				    data_group.experiment = 'SSMI'
				    data_group.satellite  = 'DMSP-F8'
				    goto, TryAgain
				  end
	      'SSMI downloaded' : begin
				    case data_group.satellite of
				     'DMSP-F8' : data_group.satellite='DMSP-F11'
				     'DMSP-F11': data_group.satellite='DMSP-F13'
				     'DMSP-F13': if idn then		       $
						   return, get_error(er,       $
						     root_dir+ff,disable=nem)  $
						 else data_group.source='CDrom'
				      else     : return,get_error('BadRequest',$
								'1',disable=nem)
				    endcase
				    goto, TryAgain
				  end
	      'psg'             : return,get_error(er,root_dir+ff,disable=nem)
	      else		: return,get_error('BadRequest','2',disable=nem)
	    endcase
                                   end
	'brightness temperature' : begin
				    case data_group.satellite of
				     'Nimbus-7':return,get_error(er,	    $
								root_dir+ff,$
								disable=nem)
				     'DMSP-F8' :data_group.satellite='DMSP-F11'
				     'DMSP-F11':data_group.satellite='DMSP-F13'
				     'DMSP-F13':return,get_error(er,	    $
								root_dir+ff,$
								disable=nem)
				     else      :return,get_error('BadRequest',$
								 root_dir+ff, $
								  disable=nem)
				    endcase
				    goto, TryAgain
				   end

	else		         : return, get_error('BadRequest','4',disab=nem)
      endcase
    endif

    if keyword_set(get_info) then begin
      case data_group.type of
	'ice concentration'      : return, passive_get_concentration(	  $
						datafile = root_dir + ff, $
				      		data_group = data_group,  $
						/get_info)

	'brightness temperature' : return, passive_get_bt(		  $
						datafile = root_dir + ff, $
				      		data_group = data_group,  $
						/get_info)
	else		         : return,  get_error('BadRequest','5',	  $
								disable=nem)
      endcase
    endif
	

; open - read data

    n_images = 0
    for i = 0, fn-1 do begin
      case data_group.type of
	'ice concentration'      : begin
				    newdata = passive_get_concentration($
				        datafile = root_dir + file[i],	$
				      data_group = data_group,		$
					dud_mask = dud_mask,		$
				       land_mask = land_mask,		$
				           n_dud = n_dud,		$
				          n_land = n_land,		$
				           error = error,		$
				       xsize_img = xsize_img,		$
				       ysize_img = ysize_img,		$
					   xorig = xorig,		$
					   yorig = yorig,		$
					  raster = top_down)
				    s = size(newdata)
				    if s[0] eq 2 and s[s[0]+2] gt 100	$
						then images = 1		$
						else images = 0
                                   end
	'brightness temperature' : begin
				    newdata = passive_get_bt(		$
				        datafile = root_dir + file[i],	$
				      data_group = data_group,		$
					    band = bt_band,		$
					dud_mask = dud_mask,		$
				       land_mask = land_mask,		$
				           n_dud = n_dud,		$
				          n_land = n_land,		$
				           error = error,		$
				       xsize_img = xsize_img,		$
				       ysize_img = ysize_img,		$
					   xorig = xorig,		$
					   yorig = yorig,		$
					  raster = top_down,		$
					n_images = images)
                                   end
	else		         : return, get_error('BadRequest','6',disab=nem)
      endcase
      if error ne 0 then return, get_error('BadData',disable=nem)
      case i of
	   0	: data = newdata
	   1	: begin
		    temp = data
		    dsize = size(data)
		    data_type = dsize[dsize[0]+1]
		    data = make_array(fn, xsize_img, ysize_img, type=data_type)
		    data[0,*,*] = temp
		    data[1,*,*] = newdata
		  end
	   else	: data[i,*,*] = newdata
      endcase
      n_images = n_images + images
	
    endfor

return, get_error('OK',disable=nem)

end
