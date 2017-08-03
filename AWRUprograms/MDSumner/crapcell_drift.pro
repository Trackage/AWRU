;+
; NAME:
;    Cell_drift
;
;    fills the map cells (created in cell_multi) with drift data
;
; Calling Sequence: cell_data = cell_multi(argos_data) - need crossing data ON
;					cell_dive(argos_data,cell_data)
;
;
; Output: cell_data - modified structure with stuff added
;  Bastardized from cell_dive, MDS 4Sep01


function cell_drift, divedata, cell_data, seal, maps, divefile = divefile

cell_x = fix(cell_data.end_cell_x)
cell_y = fix(cell_data.end_cell_y)
ncell = n_elements(cell_x) - 1


last_cell_x = cell_data.end_cell_x[ncell]
last_cell_y = cell_data.end_cell_y[ncell]
first_cell_x = cell_data.end_cell_x[0]
first_cell_y = cell_data.end_cell_y[0]


cell_x = [fix(cell_data.start_cell_x[0]), cell_x, cell_x[ncell]]
cell_y = [fix(cell_data.start_cell_y[0]), cell_y, cell_y[ncell]]

;map_dslope = fltarr(n_elements(cell_data.xgrid)-1,n_elements(cell_data.ygrid)-1)
;map_drift= fltarr(n_elements(cell_data.xgrid)-1,n_elements(cell_data.ygrid)-1)
;map_poslope = intarr(n_elements(cell_data.xgrid)-1,n_elements(cell_data.ygrid)-1)
;map_negslope = intarr(n_elements(cell_data.xgrid)-1,n_elements(cell_data.ygrid)-1)
;help, map_drift

map_dslope = maps.map_dslope
map_drift = maps.map_drift
map_poslope = maps.map_poslope
map_negslope = maps.map_negslope


ptts =divedata.seals

; extract data for the right seal

;IF n_elements(seals) EQ 0 THEN seals = divedata.seals(uniq(divedata.seals))
;help, seals
;help, st

;help, divedata, /stru
;FOR n = 0, n_elements(seals) -1  DO BEGIN
		;imdisp, map_poslope, title = n, /noscale, /axis

		;right_seal = where(seal eq argos_data.ptts, count)

		right_seal = where(ptts EQ seal, count)
		;help, right_seal


	;if count gt 0 then begin


		right_seal = where(ptts EQ seal, count)
		;ut_times = divedata.ut_times
		mapcount = 0

		st = cell_data.cross_times(right_seal)
		;st = cell_data.cross_times
		start_time = st[0] - 3600.0*cell_data.map_bins[first_cell_x,first_cell_y]
		end_time = st[ncell] + 3600.0*cell_data.map_bins[last_cell_x,last_cell_y]
stop
		st = [start_time, st, end_time]
		last_mapcount = n_elements(st)-1
		plot, st
		oplot, ut_times, color = 260
		plot, ut_times
		oplot, st
		stop

		done = 0
		;st = [st,st[last_mapcount],st[last_mapcount]]

 		drift = divedata.drift(right_seal)
 		dslope = divedata.dslope(right_seal)

 		;stop

    	sum_drift    = 0.0
 		sum_dslope    = 0.0
 		pos_count = 0
 		neg_count = 0

		;mapcount = 0

		;print, 'st (modified) = ', st
	;print, 'LOCATION ARRAYS (combined start and end cell)'
	;print, cell_x
	;print, cell_y

		for each_pt = 0, count-1 do begin

			if (done eq 0) then begin

				;print, 'mapcount = ', mapcount
				ut_time = ut_times(each_pt)
;				print, 'time = ', ut_time
				;IF seal EQ 'B568' THEN stop
				if ut_time gt st[mapcount+1] then begin

					print, 'entering map_params if statement'

					loc_x = cell_x[mapcount]
					loc_y = cell_y[mapcount]

					map_drift[loc_x, loc_y] = map_drift[loc_x, loc_y] + sum_drift
					map_dslope[loc_x, loc_y] = 	map_dslope[loc_x, loc_y] + sum_dslope
					map_poslope[loc_x, loc_y] = map_poslope[loc_x, loc_y] + pos_count
					map_negslope[loc_x, loc_y] = map_negslope[loc_x, loc_y] + neg_count



					mapcount = mapcount + 1
					done = mapcount ge last_mapcount

					;print, 'count = ', count
					;print, 'mapcount = ', mapcount
					;print, 'last_mapcount = ', last_mapcount
					;print, 'done ', done
					if (done eq 1) then print, 'Done!!'

				    sum_drift    = 0.0
    				sum_dslope    = 0.0
 		   			pos_count = 0
 		   			neg_count = 0

    			endif
			;stop
				if (ut_time ge st[mapcount] and ut_time le st[mapcount+1]) then begin

					print, 'entering sum_param if statement'

				    sum_drift    = sum_drift + drift[each_pt]
	    			sum_dslope    = sum_dslope + dslope[each_pt]


						;this needs to count the positive drift values for each cell

					IF dslope[each_pt] GT 0.0 THEN pos_count = pos_count + 1 ELSE neg_count = neg_count + 1
					;IF n EQ 0 THEN cum = pos_count ELSE cum = [cum, pos_count]
					;print, pos_count, neg_count
					;print, sum_drift, sum_dslope
					;IF seal EQ 'B568' THEN BEGIN
					;	print, 'map_poslope ', map_poslope[loc_x, loc_y]
					;	print, 'map_negslope ', map_negslope[loc_x, loc_y]
					;	print, 'dslope(each_pt) ', dslope(each_pt)
					;	print, 'pos_count ', pos_count
					;	print, 'neg_count ', neg_count
					;	stop
					;ENDIF
				endif

			endif

		endfor

	;endif else begin

		;print, 'No match to the seal id in sealdive.csv'

	;endelse

;ENDFOR

;imdisp, map_poslope, /noscale, /axis, title = seal

return, {drift:map_drift, $
		 dslope:map_dslope, $
		 map_poslope:map_poslope, $
		 map_negslope:map_negslope $
		}
end
