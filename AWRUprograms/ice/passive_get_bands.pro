;-------------------------------------------------------------------------------
; Returns an array of strings representing the individual brightness temperature
; bands corresponding to the keyword values provided.  If keywords are illegal,
; insufficient or conflicting, an empty array (['']) is returned.
; The keyword string values (satellite and channel) are case insensitive.
;
; Keywords :-
;	satellite	Nimbus-7
;			Nimbus	(assumes Nimbus-7)
;			DMSP-F8
;			DMSP-F11
;			DMSP-F13
;			DMSP	(assumes any of DMSP-F8, F11, F13)
;	instrument	SSMI	(translates to satellite = 'DMSP')
;			SMMR	(translates to satellite = 'Nimbus-7')
;			Ice C[concentration] (returns 'ic')
;			IC	(returns 'ic')
;	channel		'85GHz'
;			'19-37GHz'
;			'6-37GHz'
;			'3a'
;			'3b'
;	type		0	(SSM/I 85GHz)
;			1	(SSM/I 19 to 37GHz)
;			2	(SMMR)
;			3-5	(Ice Concentration)
;	specs		Returns the acutal specifications used, as structure
;			with tags:-
;					.sat
;					.inst
;					.chan
;					.typ
;
; Satellite defaults to "any satellite" compatible with the other keywords.
; Channel defaults to "all channels" compatible with the other keywords.
; Type defaults to "unspecified", in which case satellite and channel must be
; sufficiently specified.
;
; Each returned string is of the form nnp, where nn = frequency in GHz (with
; leading zero if required), and p = polarization (v or h).
;-------------------------------------------------------------------------------

Function passive_get_bands,			$
			satellite = satellite,	$ Nimbus-7, DMSP-F8 -F11, -F13
			instrument= instrument,	$ SMMR, SSMI
			channel   = channel,	$ 85GHz, 19-37GHz, 6-37GHz, 3a, 3b
			type      = type,	$ 0 - 5
			specs	  = specs	; specs. used


    specs = { sat:'', inst:'', chan:'', typ:'' }

; set defaults and upper case

    if keyword_set(channel) then specs.chan = strupcase(channel)	$
			    else specs.chan = 'all'
    if keyword_set(satellite) then specs.sat = strupcase(satellite)	$
			      else specs.sat = 'any'
    if n_elements(type) gt 0 then specs.typ = type else specs.typ = -1
    if keyword_set(instrument) then begin
				    l = min([strlen(instrument),5])
				    specs.inst =			$
				     strupcase(strmid(instrument, 0 ,5))
			 endif else specs.inst = '?'
    if specs.inst eq 'IC' then specs.inst = 'ICE C'

; check legality of individual specs.

    case specs.chan of	; all legal channel specs.
	'all'		:
	'85GHZ'		:
	'19-37GHZ'	:
	'6-37GHZ'	:
	'3A'		: specs.chan = '85GHZ'
	'3B'		: specs.chan = '19-37GHZ'
	else		: goto, ret_error
    endcase
    case specs.sat of	; all legal satellite names
	'any'		:
	'DMSP-F8' 	: specs.sat = 'DMSP'
	'DMSP-F11'	: specs.sat = 'DMSP'
	'DMSP-F13'	: specs.sat = 'DMSP'
	'DMSP'		:
	'NIMBUS-7'	:
	'NIMBUS'	: specs.sat = 'NIMBUS-7'
	else	  	: goto, ret_error
    endcase

    sat = specs.sat
setinst:
    case specs.inst of
		  '?'	  :
		  'SMMR'  : sat = 'NIMBUS-7'
		  'SSMI'  : sat = 'DMSP'
		  'SSM/I' : sat = 'DMSP'
		  'ICE C' : begin
			      if specs.sat  eq 'any' and		$
				 specs.chan eq 'all' and		$
				 specs.typ  eq -1 then return, ['ic']
			      case specs.typ of ; exclude conflicting types
				-1	:
				 0	: goto, ret_error
				 1	: goto, ret_error
				 2	: goto, ret_error
				 3	: specs.typ = -1
				 4	: specs.typ = -1
				 5	: specs.typ = -1
				else	: goto, ret_error
			      endcase
			      sat = 'any'
			    end
		  else    : goto, ret_error
    endcase

    case specs.typ of	; all valid type values
	-1		:
	 0		: 
	 1		:
	 2		:
	 3		: specs.inst = 'conc'
	 4		: specs.inst = 'conc'
	 5		: specs.inst = 'conc'
	else		: goto, ret_error
    endcase
    if specs.inst eq 'conc' then begin
       specs.inst = 'ICE C'
       goto, setinst
    endif


; check for conflicts and insufficient specifications

    sufficient = 0
    case specs.sat of

	 'NIMBUS-7' : begin
			    case specs.chan of
				'all'	   : sufficient = 1
				'6-37GHZ'  : sufficient = 1
				else	   : goto, ret_error
			    endcase
			    case specs.typ of
				-1	   : sufficient = 1
				 2	   : sufficient = 1
				else	   : goto, ret_error
			    endcase
		      end
			    
	 'DMSP'	    : begin
			    case specs.chan of
				'all'	   : sufficient = 1
				'19-37GHZ' : sufficient = specs.typ ne 0
				'85GHZ'    : sufficient = specs.typ ne 1
				else	   : goto, ret_error
			    endcase
			    case specs.typ of
				-1	   :
				 0	   :
				 1	   :
				else	   : goto, ret_error
			    endcase
		      end

	'any'       : begin 
			case specs.chan of
			  'all'	     : sufficient = specs.typ ne -1
			  '6-37GHZ'  : sufficient = specs.typ ne 0 and $
						    specs.typ ne 1 
			  '19-37GHZ' : sufficient = specs.typ ne 2 and $
						    specs.typ ne 0
			  '85GHZ'    : sufficient = specs.typ ne 2 and $
						    specs.typ ne 1
			  else	     : goto, ret_error
			endcase
			case specs.typ of
			  -1	     :
			   0	     :
			   1	     :
			   2	     :
			  else	     : goto, ret_error
			endcase
		      end

	else	    :

    endcase

    if sufficient ne 1 then begin ; insufficient specs.
	case specs.inst of
	  '?'	    : goto, ret_error
	  'ICE C'   : return, ['ic'] ; ice conc.
	  else	    :
	endcase
    end


; resolve assumed satellites

    case specs.sat of

	'any'       : begin
			case specs.chan of
			  'all'	     :
			  '6-37GHZ'  : specs.sat = 'NIMBUS-7' 
			  '19-37GHZ' : specs.sat = 'DMSP'
			  '85GHZ'    : specs.sat = 'DMSP'
			  else	     : goto, ret_error
			endcase
			case specs.typ of
			  -1	     :
			   0	     : specs.sat = 'DMSP'
			   1	     : specs.sat = 'DMSP'
			   2	     : specs.sat = 'NIMBUS-7'
			  else	     : goto, ret_error
			endcase
		      end

	else	    :

    endcase


; resolve instrument

    if specs.sat ne sat then begin ; does instr. agree with sat. request?
        case specs.sat of
	   'any'    : specs.sat = sat
	   else	    : begin
		        case sat of
			   'any'    : sat = specs.sat
			   else	    : goto, ret_error
			endcase
		      end
	endcase
    end
    case specs.inst of
	'?'	: begin
		    case specs.sat of
		      'NIMBUS-7' : specs.inst = 'SMMR'
		      'DMSP'     : specs.inst = 'SMMI'
		      else	 : goto, ret_error
		    endcase
		  end
	'ICE C' : return, ['ic'] ; ice conc.
	else	: 
    endcase


; resolve assumed channels

    case specs.chan of

	'all'	    : begin
			case specs.typ of
			  -1	:
			   0	: specs.chan = '85GHZ'
			   1	: specs.chan = '19-37GHZ'
			   2	: specs.chan = '6-37GHZ'
			  else	: goto, ret_error
			endcase
		      end

	else	    : 

    endcase

; get bands
    case specs.sat of

	'NIMBUS-7' : return, ['06v','06h','10v','10h','18v','18h','37v','37h']

	'DMSP'	   : begin
			a = ['85v', '85h']
			b = ['19v','19h','22v','37v','37h']
			case specs.chan of
			    'all'      : return, [b,a]
			    '19-37GHZ' : return, b
			    '85GHZ'    : return, a
			    else       : goto, ret_error
			endcase
		     end

	else	   : goto, ret_error

    endcase

ret_error:
	return, ['']	; bad call
end
