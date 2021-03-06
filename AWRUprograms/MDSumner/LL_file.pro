;---------------------------------------------------------------------------------------
PRO LL_FILE, LONS, LATS, FILENAME, NOZERO = NOZERO
;==============================================================================
; NAME:  SAT_FILE
;
; PURPOSE: Output an array of SeaWIFS or MCSST data with lons and lats to
;			file for ARC GIS input.
; CATEGORY:
; CALLING SEQUENCE:  sat_file, data_array, lons, lats, filename
;
; INPUTS:			ARRAY - 2-D array of data values, -9999 is expected missing
;					LONS - 1-D array of longitude values [expect cell centres]
;					LATS - 1-D array of latitude values  [ditto]
;					FILENAME - name of output file
;
;
; KEYWORD PARAMETERS:	VAL - optional string to assign to data value in file column
;						NOZERO - to not print out zero values to file
; OUTPUTS:  	File with data array, arranged as:
;							lons, lats, value
;
; COMMON BLOCKS:
; NOTES:	This works fine in conjunction with SWEXT, SSTEXT, SUM_SST and SUM_CHL
;			but beware some arrays don't come upside down.  This flips the array
;			to get it right and so MAP_ARRAY works will with these procedures.
;			 I would always include some land areas at least for a test run to
;			ensure the data are correctly orientated.
; MODIFICATION HISTORY:  Written MDSumner October 2001, ripped off DJW's
;						map_cell.
;
;==============================================================================
	;open the output file for writing
openw,wlun, filename, /get_lun


   ;print the header line
printf, wlun, 'Long' , ',',    'Lat'


   ;print out the lons, lats and values
for ix = 0, n_elements(lons)-1 do begin
    xpt = lons(ix)

        ypt = lats(ix)

	    	printf, wlun, xpt, ', ', ypt


endfor

free_lun, wlun
END
;------------------------------------------------------------------------------------------------
