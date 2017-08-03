;==============================================================================
; NAME:
;       CELL_MULTI
;
; PURPOSE:
;       Creates map cells with time spent in each returned in 'map_bins'.
;
; CATEGORY:
; CALLING SEQUENCE:
;	  cell_data = cell_multi(argos_data)

; INPUTS:
;	   /rb  - do gridding in (range, bearing)  not (lat, lon)
;        /km  - cell size was in km not degrees
;
;	   cell_size = [lon_size, lat_size]
;        [range (km), bearing] if /rb
;        default is [1,1] or [100,10] if /rb
;	   /crossing_data - if set then output contains data structure containing
;	   cell crossing times
;
; KEYWORD PARAMETERS:
; OUTPUTS:
;	  cell_data - a structure containing cell contents and its mid-pts
;
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;	  Written by DJW.  Modified by K.Michael (IASOS) and C.Bradshaw (AWRU), 2000.
;	  Annotated and made easier to read, MDSumner May2001
;
;	  Some confusion regarding the absolute grid problem, but DJW foresaw this
;	  and included ref_lat in the output structure of read_argos_data, absolute
;	  grid keyword added to output map_bins on the [80.0, -30.0} grid MDS 11Jul01
;
;	  I have converted from absolute keyword to limits keyword, with limits
;	  input by user, this way the cells can be calculated for a particular seal,
;	  a particular area or for the entire range of all data, with the least
;	  grid distortion at the mid_lat in each case, MDS 27Jul01
;
;	Changed lon_size and lat_size from y,x to x,y MDS20Aug01.
;	Converted map_bins to a double precision array for later bootstrapping sums, MDS 28Aug01.
;==============================================================================


FUNCTION ke_bathmap, depth_data, $
	cell_size = cell_size

   ;-- mod longitude if over dateline boundary, anything LT -90.0 is east of dateline

dateline = where(depth_data.lons LE -90.0, idate)

IF idate ne 0 THEN depth.lons(dateline) = argos_data.lons(dateline) + 360.0

   ;plot,argos_data.lons

;argos_data.lons = argos_data.lons + 0.0001
;argos_data.lats = argos_data.lats + 0.0001

  ;cell_size is optimal scale, e.g. 350 km

IF n_elements(cell_size) EQ 0 THEN BEGIN

	   ; lon degree
	   ; lat degree

	cell_x = 0.07
    	cell_y = 0.07


END ELSE BEGIN

	;print, 'Mike wonders why y is lon and x is lat in cell_multi here!!!'

	cell_x = abs(cell_size(0))  ; lon
	cell_y = abs(cell_size(1))  ; lat

	   ; cell input size in km -> convert to degrees at center of data

	IF keyword_set(km) THEN BEGIN

	    lat_max = max(depth_data.lats, min=lat_min)
	    lat_mid = (lat_max + lat_min)/2.0


	    cell_y = cell_y / 60.0 / 1.852

		;!radeg - A read-only variable containing the floating-point value
		; used to convert radians to degrees (180/pi ~ 57.2958)
		;cell_x is cosine corrected, to find number of degrees to each
		;cell_size distance, which increases with latitude

	    cell_x = cell_x / cos(lat_mid / !radeg) / 60.0 / 1.852

	;	print, 'cell _y ', cell_y, ' cell_x ', cell_x

	ENDIF

ENDELSE




    ;-- subset multi-profile into a single profile

  ;make start point a long integer, 'point' refers to a lat/lon position for
  ;a seal

    lats  = depth_data.lats
    lons  = depth_data.lons
    depths = depth_data.depth



	    	dataxmin = min(lons, max=dataxmax)
	    	dataymin = min(lats, max=dataymax)


   ;--- make integer index of each bounds --
;x
xmin_index = floor(dataxmin/cell_x)
xmax_index = ceil(dataxmax/cell_x) + 1
ymin_index = floor(dataymin/cell_y)
ymax_index = ceil(dataymax/cell_y) + 1
nx = xmax_index - xmin_index
ny = ymax_index - ymin_index
;


xgrid = (findgen(nx) + xmin_index) * cell_x
ygrid = (findgen(ny) + ymin_index) * cell_y


   ; --- declare array for storing results ---

map_bins = dblarr(nx-1,ny-1)

nn_bins = dblarr(nx-1,ny-1)


   ;-- Now loop over all profiles

;start_pt = 0l

;FOR ip = 0, n_elements(argos_data.npts)-1 DO BEGIN

 ;   end_pt = start_pt + argos_data.npts(ip) - 1

    ; extract lats/lons so we can remove 'bad' pts using WHERE

  ;  ptt = argos_data.ptts(start_pt)
   ; temp_lats  = argos_data.lats(start_pt:end_pt)
    ;temp_lons  = argos_data.lons(start_pt:end_pt)
    ;temp_times = argos_data.ut_times(start_pt:end_pt)
    ;temp_ok    = argos_data.ok(start_pt:end_pt)
    ;good = where(temp_ok EQ 'Y', count)

    ;times = temp_times(good)


       ;-- remember the first location, x and y_last_cell are the cells within
	 ;the map_bin grid

    x_last_cell = ceil(lons(0)/cell_x) - xmin_index -1
    y_last_cell = ceil(lats(0)/cell_y) - ymin_index -1

    last_x = lons(0)
    last_y = lats(0)


       ;-- loop over from the 2nd pt till end ---

    FOR k=1L,n_elements(depths)-1 DO BEGIN

        x_cell = ceil(lons(k)/cell_x) - xmin_index - 1
        y_cell = ceil(lats(k)/cell_y) - ymin_index - 1
        depth = depths(k)

       IF x_cell EQ x_last_cell AND y_cell EQ y_last_cell THEN BEGIN

	    	   ; --- simple case - no movement to outside of current cell ---
; 	IF delta_time LT 0 THEN print, 'delta_time LT 0 ' & stop
       	map_bins(x_cell,y_cell) = map_bins(x_cell,y_cell) + depth
       	nn_bins(x_cell,y_cell) = nn_bins(x_cell,y_cell) + 1

       END ELSE BEGIN

              ;-- Find number of crossings on the x grid

           add_to_hits = 0

           IF lons(k) EQ last_x THEN icount = 0

           IF lons(k) LT last_x THEN $
               x_crossings = where(xgrid GT lons(k) AND xgrid LT last_x, icount)

           IF lons(k) GT last_x THEN $
               x_crossings = where(xgrid LT lons(k) AND xgrid GT last_x, icount)

           IF icount GE 1 THEN BEGIN

               xpts = xgrid(x_crossings)
               ypts = (xpts - last_x) * (lats(k)-last_y) / (lons(k)-last_x) + last_y

               xgrid_hits  = xpts
               ygrid_hits  = ypts
               add_to_hits = 1

               IF keyword_set(debug) THEN print, 'X grid crossings', xpts, ypts

           ENDIF

           IF lats(k) EQ last_y THEN icount = 0

	      ;xmid_cell = ceil(xmid/cell_x) - xmin_index - 1
          ;ymid_cell = ceil(ymid/cell_y) - ymin_index - 1
          ;segment_distance = distance(1:last) - distance(0:last-1)

            ;-- Remember where we were for the next pt

         x_last_cell = x_cell
         y_last_cell = y_cell

         last_x = lons(k)
         last_y = lats(k)
         add_to_hits = 0
		ENDELSE


ENDFOR

;print, 'xgrid ', xgrid
;print, 'ygrid ', ygrid

;print, 'end cell_multi '

;calculate mean depth

map_bins = map_bins/nn_bins


return, map_bins


END
