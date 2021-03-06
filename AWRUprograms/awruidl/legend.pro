;==============================================================================
PRO LEGEND, DATA, TITLE = TITLE
;==============================================================================
; NAME:  LEGEND
;
; PURPOSE:	 To add a colorbar appropriate for the current colour settings and
;				map display.
; PROCEDURES:  D. Fanning's COLORBAR, www.dfanning.com
; CATEGORY:
; CALLING SEQUENCE:
; INPUTS:			Array of data for max and min values.
; KEYWORD PARAMETERS:  TITLE - give the bar a title
; OUTPUTS:		Draws a colorbar on the current display.
; COMMON BLOCKS:
; NOTES:
;				Works with SSTEXT, SWEXT, MAP_ARRAY.
;
; MODIFICATION HISTORY:  Written October 2001, MDSumner, AWRU.
;==============================================================================



IF size(data, /type) EQ 8 THEN data_arr = data.map_bins ELSE data_arr = data
IF min(data_arr) - max(data_arr) EQ 0 THEN BEGIN
	print, 'No range for color bar!'
	return
ENDIF
good = where(data_arr GT -9998)
datarange = data_arr[good]
mindata = min(datarange)
colorbar, title = title, charsize = 1.5, ncolors = !d.table_size,  color = !d.n_colors - 1, $
	/vertical,	position = [0.93, 0.15, 0.98, 0.95],minrange = mindata, $
		maxrange = max(data_arr)

end