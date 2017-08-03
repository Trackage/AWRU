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


FUNCTION CELL_MULTI, argos_data, $
	cell_size = cell_size, $
	rb = rb, $
	km = km, $
	crossing_data = crossing_data, $
	debug = debug, limits = limits

;limits = [-30.0, -80.0, 90.0, 240.0]

   ;IF cross = 1 in initialization then crossing_data is passed in as keyword
   ;km, rb keywords specify to work in range/bearing or kilometres

IF keyword_set(rb) THEN rb_flag = 1 ELSE rb_flag = 0
IF keyword_set(km) THEN km_flag = 1 ELSE km_flag = 0

   ;-- mod longitude if over dateline boundary, anything LT -90.0 is east of dateline

dateline = where(argos_data.lons LE -90.0, idate)

IF idate ne 0 THEN argos_data.lons(dateline) = argos_data.lons(dateline) + 360.0

   ;plot,argos_data.lons

argos_data.lons = argos_data.lons + 0.0001
argos_data.lats = argos_data.lats + 0.0001

  ;cell_size is optimal scale, e.g. 350 km

IF n_elements(cell_size) EQ 0 THEN BEGIN

	   ; lon degree
	   ; lat degree

	cell_x = 1.0
    	cell_y = 1.0

	IF keyword_set(rb) THEN BEGIN

		   ;degrees

		cell_x = 10.0

	   	   ;kilometres

    		cell_y = 100.0

    	ENDIF

END ELSE BEGIN

	;print, 'Mike wonders why y is lon and x is lat in cell_multi here!!!'

	cell_x = abs(cell_size(0))  ; lon
	cell_y = abs(cell_size(1))  ; lat

	   ; cell input size in km -> convert to degrees at center of data

	IF keyword_set(km) THEN BEGIN

	    lat_max = max(argos_data.lats, min=lat_min)
	    lat_mid = (lat_max + lat_min)/2.0


		IF keyword_set(limits) THEN BEGIN

		   	   ;DJW uses the mid lat of the seal area, we want the mid lat of the whole area

		  	lat_max = limits[0]
			lat_min = limits[1]
			lat_mid = (lat_max + lat_min)/2.0



		ENDIF


	    cell_y = cell_y / 60.0 / 1.852

		;!radeg - A read-only variable containing the floating-point value
		; used to convert radians to degrees (180/pi ~ 57.2958)
		;cell_x is cosine corrected, to find number of degrees to each
		;cell_size distance, which increases with latitude

	    cell_x = cell_x / cos(lat_mid / !radeg) / 60.0 / 1.852

	;	print, 'cell _y ', cell_y, ' cell_x ', cell_x

	ENDIF

	IF keyword_set(rb) THEN BEGIN

	    cell_x = abs(cell_size(1))  ; bearing
	    cell_y = abs(cell_size(0))  ; range

	ENDIF
ENDELSE




    ;-- subset multi-profile into a single profile

  ;make start point a long integer, 'point' refers to a lat/lon position for
  ;a seal

start_pt = 0L

FOR j = 0, n_elements(argos_data.npts)-1 DO BEGIN

    end_pt = start_pt + argos_data.npts(j) - 1

       ; extract lats/lons so we can remove 'bad' pts using WHERE

    temp_lats  = argos_data.lats(start_pt:end_pt)
    temp_lons  = argos_data.lons(start_pt:end_pt)
    temp_times = argos_data.ut_times(start_pt:end_pt)
    temp_ok    = argos_data.ok(start_pt:end_pt)

	   ;this will pick up points with OK temps

    good = where(temp_ok EQ 'Y', count)

    times = temp_times(good)

    IF keyword_set(rb) THEN BEGIN

	     ;convert lat /lon - ref_lat/lon to range, bearing
	     ;ref_lat/lon is probably [0.0,0.0]

        ll2rb, argos_data.ref_lon(j), argos_data.ref_lat(j), temp_lons(good), $
		temp_lats(good), range, bearing

        datax = bearing
        datay = range * !radeg * 60.0 * 1.852  ; km

    END ELSE BEGIN

        datax = temp_lons(good)
        datay = temp_lats(good)

    ENDELSE

       ;-- If not first pass then add previous min/max to current profile

    IF j ne 0 THEN BEGIN

        datax = [dataxmin, datax, dataxmax]
        datay = [dataymin, datay, dataymax]

    ENDIF

      ;-- find limits to data of all profiles ----


		;keyword absolute set in to map map_bins cells on a larger, fixed grid
		;MDS 11Jul01

	IF keyword_set(limits) THEN BEGIN

		dataxmin = limits[2]
		dataxmax = limits[3]
		dataymin = limits[1]
		dataymax = limits[0]

	ENDIF ELSE BEGIN

	    	dataxmin = min(datax, max=dataxmax)
	    	dataymin = min(datay, max=dataymax)

	ENDELSE


	start_pt = end_pt + 1


ENDFOR



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

IF keyword_set(debug) THEN BEGIN
    print,'Xgrid ',xgrid
    print,'Ygrid ',ygrid
ENDIF


   ; --- declare array for storing results ---

map_bins = dblarr(nx-1,ny-1)




   ;-- Now loop over all profiles

start_pt = 0l

FOR ip = 0, n_elements(argos_data.npts)-1 DO BEGIN

    end_pt = start_pt + argos_data.npts(ip) - 1

    ; extract lats/lons so we can remove 'bad' pts using WHERE

    ptt = argos_data.ptts(start_pt)
    temp_lats  = argos_data.lats(start_pt:end_pt)
    temp_lons  = argos_data.lons(start_pt:end_pt)
    temp_times = argos_data.ut_times(start_pt:end_pt)
    temp_ok    = argos_data.ok(start_pt:end_pt)
    good = where(temp_ok EQ 'Y', count)

    times = temp_times(good)

    IF keyword_set(rb) THEN BEGIN

        ll2rb, argos_data.ref_lon(ip), argos_data.ref_lat(ip), temp_lons(good), $
		 temp_lats(good), range, bearing

        datax = bearing
        datay = range * !radeg * 60.0 * 1.852  ; km

    END ELSE BEGIN

        datax = temp_lons(good)
        datay = temp_lats(good)

    ENDELSE

       ;-- remember the first location, x and y_last_cell are the cells within
	 ;the map_bin grid

    x_last_cell = ceil(datax(0)/cell_x) - xmin_index -1
    y_last_cell = ceil(datay(0)/cell_y) - ymin_index -1
    last_time = times(0)
    last_x = datax(0)
    last_y = datay(0)


       ;-- loop over from the 2nd pt till end ---

    FOR k=1,n_elements(times)-1 DO BEGIN

        x_cell = ceil(datax(k)/cell_x) - xmin_index - 1
        y_cell = ceil(datay(k)/cell_y) - ymin_index - 1
        delta_time = (times(k) - last_time) / 3600.0 ; hrs

      IF delta_time LT 0.0 THEN BEGIN
		print, 'PTT ', ptt,'  Delta time ',delta_time, 'Lon ',datax(k), 'Lat ',datay(k)
		stop
	ENDIF
	;IF k EQ 1 THEN stop
        ;-- distance from last point to this point

 	IF keyword_set(rb) THEN $
	    total_distance = ( (datax(k)-last_x)^2 + (datay(k)-last_y)^2 )^0.5 ELSE $
	    ll2rb, last_x, last_y, datax(k), datay(k), total_distance, best_azi

       IF keyword_set(debug) THEN $
            print,'X from', x_last_cell, ' to ',x_cell,'   Y from', y_last_cell, ' to ',y_cell

       IF x_cell EQ x_last_cell AND y_cell EQ y_last_cell THEN BEGIN

	    	   ; --- simple case - no movement to outside of current cell ---
; 	IF delta_time LT 0 THEN print, 'delta_time LT 0 ' & stop
       	map_bins(x_cell,y_cell) = map_bins(x_cell,y_cell) + delta_time

       END ELSE BEGIN

              ;-- Find number of crossings on the x grid

           add_to_hits = 0

           IF datax(k) EQ last_x THEN icount = 0

           IF datax(k) LT last_x THEN $
               x_crossings = where(xgrid GT datax(k) AND xgrid LT last_x, icount)

           IF datax(k) GT last_x THEN $
               x_crossings = where(xgrid LT datax(k) AND xgrid GT last_x, icount)

           IF icount GE 1 THEN BEGIN

               xpts = xgrid(x_crossings)
               ypts = (xpts - last_x) * (datay(k)-last_y) / (datax(k)-last_x) + last_y

               xgrid_hits  = xpts
               ygrid_hits  = ypts
               add_to_hits = 1

               IF keyword_set(debug) THEN print, 'X grid crossings', xpts, ypts

           ENDIF

           IF datay(k) EQ last_y THEN icount = 0
           IF datay(k) LT last_y THEN $
               y_crossings = where(ygrid GT datay(k) AND ygrid LT last_y, icount)
           IF datay(k) GT last_y THEN $
               y_crossings = where(ygrid LT datay(k) AND ygrid GT last_y, icount)
           IF icount GE 1 THEN BEGIN
               ypts = ygrid(y_crossings)
               xpts = (ypts - last_y) * (datax(k)-last_x) / (datay(k)-last_y) + last_x

               IF keyword_set(debug) THEN print,'Y grid crossings', xpts, ypts

               IF add_to_hits EQ 0 THEN BEGIN

                   xgrid_hits  = xpts
                   ygrid_hits  = ypts

               END ELSE BEGIN

                   xgrid_hits  = [xgrid_hits, xpts]
                   ygrid_hits  = [ygrid_hits, ypts]

               ENDELSE
           ENDIF

           IF keyword_set(debug) THEN BEGIN
               print, k, xgrid_hits
               print, k, ygrid_hits
           ENDIF


    ;-- Now take vector of grid crossings and sort in distance from initial pt

	    IF keyword_set(rb) THEN $
	        distance = ( (xgrid_hits-last_x)^2 + (ygrid_hits-last_y)^2 )^0.5 ELSE $
	        ll2rb, last_x, last_y, xgrid_hits, ygrid_hits, distance, best_azi

	    ;range = best_distance * !radeg * 60.0 * 1.852  ; km

	       ;-- sort from last point

	    sort_order = sort(distance)
	    xgrid_hits = xgrid_hits(sort_order)
	    ygrid_hits = ygrid_hits(sort_order)
	    distance = [0.0d0, distance(sort_order), total_distance]

	       ;-- compute mid-pt of each segment so we can find which cell it is in

	    xpts = [last_x, xgrid_hits, datax(k)]
	    ypts = [last_y, ygrid_hits, datay(k)]
	    last = n_elements(xpts)-1
	    xmid = (xpts(1:last) + xpts(0:last-1))/2.0
	    ymid = (ypts(1:last) + ypts(0:last-1))/2.0
          xmid_cell = ceil(xmid/cell_x) - xmin_index - 1
          ymid_cell = ceil(ymid/cell_y) - ymin_index - 1
          segment_distance = distance(1:last) - distance(0:last-1)

            ;-- Now compute contribution to each cell

         cell_hours = delta_time * (segment_distance / total_distance)

         bad_hrs = where(cell_hours LT 0.0, ibad)

         ;IF ibad GE 1 THEN BEGIN
              ;print, 'PTT ',ptt, '  Time ', dt_tm_fromjs(times(k))
              ;print, '    Delta time  (hrs)    ', delta_time
              ;print, '    Total Distance (km)  ', total_distance * !radeg * 60.0 * 1.852
              ;print, '    Segments       (km)  ', segment_distance  * !radeg * 60.0 * 1.852
              ;print, '    Cell hrs       (hrs) ', cell_hours
              ;print, ' start pos', last_x, last_y
              ;print, ' end   pos', datax(k), datay(k)
              ;print, xgrid_hits,'|', ygrid_hits
         ;ENDIF


         FOR j = 0, n_elements(cell_hours)-1 DO BEGIN

               map_bins(xmid_cell(j),ymid_cell(j)) = map_bins(xmid_cell(j),ymid_cell(j)) $
			+ cell_hours(j)

         ENDFOR

	    IF keyword_set(crossing_data) THEN BEGIN

	        crossing_times = last_time + (times(k)-last_time) * distance / total_distance

	        crossing_times = crossing_times(1:last-1)
	        cell_cross_x  = xpts(1:last-1)
	        cell_cross_y  = ypts(1:last-1)
	        start_cell_x    = xmid_cell(0:last-2)
	        start_cell_y    = ymid_cell(0:last-2)
	        end_cell_x      = xmid_cell(1:last-1)
	        end_cell_y      = ymid_cell(1:last-1)


	        IF n_elements(cross_data_times) EQ 0 THEN BEGIN

	             cross_data_ptts  = replicate(ptt,n_elements(crossing_times))
	             cross_data_times = crossing_times
	             cross_data_x     = cell_cross_x
	             cross_data_y     = cell_cross_y
	             cross_data_start_cell_x = start_cell_x
	             cross_data_start_cell_y = start_cell_y
	             cross_data_end_cell_x = end_cell_x
	             cross_data_end_cell_y = end_cell_y

	        END ELSE BEGIN

	             cross_data_ptts    = [cross_data_ptts, replicate(ptt,n_elements(crossing_times))]
	             cross_data_times   = [cross_data_times, crossing_times]
	             cross_data_x       = [cross_data_x, cell_cross_x]
	             cross_data_y       = [cross_data_y, cell_cross_y]
	             cross_data_start_cell_x = [cross_data_start_cell_x, start_cell_x]
	             cross_data_start_cell_y = [cross_data_start_cell_y, start_cell_y]
	             cross_data_end_cell_x = [cross_data_end_cell_x, end_cell_x]
	             cross_data_end_cell_y = [cross_data_end_cell_y, end_cell_y]

	        ENDELSE

	    ENDIF

         ENDELSE

            ;-- Remember where we were for the next pt

         x_last_cell = x_cell
         y_last_cell = y_cell
         last_time = times(k)
         last_x = datax(k)
         last_y = datay(k)
         add_to_hits = 0

    ENDFOR

    start_pt = end_pt + 1
;print, '2nd loop'

ENDFOR

;print, 'xgrid ', xgrid
;print, 'ygrid ', ygrid

;print, 'end cell_multi '



   ;-- data structure containing entry and exit times for each cell crossing

IF keyword_set(crossing_data) THEN BEGIN

	last = n_elements(cross_data_times)-1

     	return,{map_bins: map_bins, $
      		xgrid: xgrid,  $
            	ygrid: ygrid, $
           	 	rb:rb_flag, $
          	 	km:km_flag, $
          	 	cell_size: cell_size, $
            	cross_ptt:cross_data_ptts, $
            	cross_times:cross_data_times, $
            	cross_x:cross_data_x, $
            	cross_y:cross_data_y, $
			start_cell_x:cross_data_start_cell_x, $
	      	start_cell_y:cross_data_start_cell_y, $
	      	end_cell_x:cross_data_end_cell_x, $
	      	end_cell_y:cross_data_end_cell_y}

ENDIF


return,{map_bins: map_bins, $
		cell_size: cell_size, $
        	xgrid: xgrid,  $
        	ygrid: ygrid, $
        	rb:rb_flag, $
        	km:km_flag}

END
