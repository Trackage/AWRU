;-------------------------------------------------------------------------------
; Compose a filename from date, according to data source.
; Keyword bt_band has effect only for brightness temperatures NOT from DMSP F-8
; (for DMSP F-11/F-13 may have values:-
;		       '85v' or '85h' if data_group.channel = '85Ghz', or
; '19v', '19h', '22v', '37v' or '37h' if data_group.channel = '19-37Ghz',
;  for Nimbus-7 (SMMR) may have values:-
;		'06v','06h', '10v', '10h', '18v', '18h', '37v', '37h')
;-------------------------------------------------------------------------------

Function passive_filename,	data_group,		$
				date,			$
				bt_band = bt_band,	$
				full = full

    mths1 = [	'jan', 'feb', 'mar', 'apr', 'may', 'jun',	$
		'jul', 'aug', 'sep', 'oct', 'nov', 'dec'	]

    sep = path_separator()

    if n_elements(date) lt 3 then return, ' '
    CASE data_group.type OF

      'ice concentration'	: BEGIN

	  hemi = strlowcase(data_group.hemisphere) + 'ern'
	  f =  data_group.method + sep

	  case data_group.form of

		'SSMI CDrom'      : begin
				d = reverse(date)
				y = string(d[0], format='(i4)')
				m = mths1[d[1]-1]
				d[0] = d[0] - fix(d[0]/100)*100
				ns = hemi + sep
				f = strlowcase(f) + ns + y + sep + m + sep + $
				string(d, format = '(3I2.2, ".tot")')
				   end

		'SSMI downloaded' : begin
				d = reverse(date)
				y = string(d[0], format='(i4)')
				m = mths1[d[1]-1]
				d[0] = d[0] - fix(d[0]/100)*100
				ns = strmid(hemi, 0, 1)
				f = f + 'SSMI' + sep + y + sep + ns +		     $
				string(d, format = '(3I2.2, ".ic")')
				   end

		'SMMR downloaded' : begin
				d = reverse(date)
				y = string(d[0], format='(i4)')
				m = mths1[d[1]-1]
				d[0] = d[0] - fix(d[0]/100)*100
				ns = strmid(hemi, 0, 1)
				f = f + 'SMMR' + sep + y + sep + ns +		     $
				string(d, format = '(3I2.2, ".ic")')
				   end

		'psg'             : begin
				d = reverse(date)
				y = string(d[0], format='(i4)')
				m = mths1[d[1]-1]
				d[0] = d[0] - fix(d[0]/100)*100
				ns = strmid(hemi, 0, 1)
				f = f + ns + 'psg' + sep + y + sep + ns +		     $
				string(d, format = '("psg.", 3I2.2)')
				   end

		else		  : f = ''

	  endcase
				  END

      'brightness temperature'	: BEGIN

	  d = reverse(date)
	  y = string(d[0], format='(i4)')
	  m = mths1[d[1]-1]
	  d[0] = d[0] - fix(d[0]/100)*100
	  f = y + sep + m + sep + string(d, format = '(3I2.2)')
	  hemi = strlowcase(strmid(data_group.hemisphere, 0, 1))

	  case data_group.experiment of

	    'SMMR'  : begin
		       bnds = passive_get_bands(inst='SMMR')
		       if keyword_set(bt_band) then begin
				ib = where(bt_band eq bnds, nb)
				if nb ne 1 then return, ''
				bnds = bnds[ib]
		       endif
		       f = 'tbs' + sep + f + hemi + '.' + bnds
		      end

	    'SSMI' : begin

			case data_group.channel of
				'19-37GHz' : ext = hemi + '3b'
				'85GHz'    : ext = hemi + '3a'
			endcase

			case data_group.satellite of

			    'DMSP-F8' : f = ext + sep + f + '.' + ext

			    else      : begin ; DMSP_F11 & F13
					  fqs = passive_get_bands(             $
					  	     instrument='SSMI',        $
					             channel=data_group.channel)
					  if keyword_set(bt_band) then begin
					     ib = where(bt_band eq fqs, nb)
					     if nb ne 1 then return, ''
					     fqs = fqs[ib]
					  endif
					  n = n_elements(fqs)
					  f = ext + sep + f + '.' + fqs
					end

			endcase 

		      end

	  endcase

				  END

      'scatterometer'		: BEGIN
				  END

      else                      : return, ' '

    ENDCASE


    if keyword_set(full) then pathname=file_path			$
			 else pathname=''
    s = size(f)
    if s[0] gt 0 and s[s[0]+2] eq 1 then f = f[0] ; make single elem. scalar
    return, pathname + f

end
