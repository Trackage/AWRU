;-------------------------------------------------------------------------------------------
PRO LIM_AREA, ARRAY, LONS, LATS, AREA, ALONS, ALATS, LIMITS = LIMITS
;==============================================================================
; NAME:   LIM_AREA
;
; PURPOSE:	To subset a 2-d array of data given lons and lats for each cell.
;
; CATEGORY:
; CALLING SEQUENCE:
; INPUTS:			ARRAY - 2-D array of values
;					LONS - 1-D array of lon values, centres of cells
;					LATS - 1-D array of lat values, ditto
;
; KEYWORD PARAMETERS: LIMITS - array of lon/lats limits [Nlat, Slat, Wlon, Elon]
;
; OUTPUTS:   		AREA - subset area
;					ALONS - subset lons
;					ALATS -subset lats
;
; COMMON BLOCKS:
; NOTES:		This rotates the array (7) and then back to get it right, interacts
;				properly with SSTEXT, SWEXT, MAP_ARRAY.
;
; MODIFICATION HISTORY:
;				Written Sept2001 MDSumner.
;==============================================================================

;IF keyword_set(limits) AND size(limits, /type) EQ 0 THEN extent = [-30.0, -80.0, 90.0, 240.0]
;IF keyword_set(limits) AND n_elements(limits) EQ 4 THEN extent = limits

  ;use these to limit the arrays of lat/lons, note this is much neater than the
  ;ixy method - create all lat/lons off global grid at required res, then delimit
  ;these arrays by the limits

latlims = where(lats LE limits[0] and lats GE limits[1])
lonlims = where(lons GE limits[2] and lons LE limits[3])

  ;extract desired area

area = rotate(array, 7)
area = area(min(lonlims):max(lonlims), min(latlims):max(latlims))

;array = rotate(array, 7)
area = rotate(area, 7)
alons = lons(min(lonlims):max(lonlims))
alats = lats(min(latlims):max(latlims))


END
;-----------------------------------------------------------------------------------------------
