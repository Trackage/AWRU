;+
; NAME:
;    Cell_dive
;
;    fills the map cells (created in cell_multi) with dive data
;
; Calling Sequence: cell_data = cell_multi(argos_data) - need crossing data ON
;					cell_dive(argos_data,cell_data)
;
;
; Output: cell_data - modified structure with stuff added


function cell_dive, argos_data, cell_data, divefile = divefile, drift = drift

cell_x = fix(cell_data.end_cell_x)
cell_y = fix(cell_data.end_cell_y)
ncell = n_elements(cell_x) - 1
;print, 'ncell: ', ncell

;print, 'END CELL ARRAYS'
;print, cell_x
;print, cell_y

;print, 'START CELL ARRAYS'
;print, cell_data.start_cell_x
;print, cell_data.start_cell_y

last_cell_x = cell_data.end_cell_x[ncell]
last_cell_y = cell_data.end_cell_y[ncell]
first_cell_x = cell_data.end_cell_x[0]
first_cell_y = cell_data.end_cell_y[0]

st = cell_data.cross_times
start_time = st[0] - 3600.0*cell_data.map_bins[first_cell_x,first_cell_y]
end_time = st[ncell] + 3600.0*cell_data.map_bins[last_cell_x,last_cell_y]

st = [start_time, st, end_time]

cell_x = [fix(cell_data.start_cell_x[0]), cell_x, cell_x[ncell]]
cell_y = [fix(cell_data.start_cell_y[0]), cell_y, cell_y[ncell]]

map_depth = fltarr(n_elements(cell_data.xgrid)-1,n_elements(cell_data.ygrid)-1)
map_durat = fltarr(n_elements(cell_data.xgrid)-1,n_elements(cell_data.ygrid)-1)
map_sfint = fltarr(n_elements(cell_data.xgrid)-1,n_elements(cell_data.ygrid)-1)
map_btime = fltarr(n_elements(cell_data.xgrid)-1,n_elements(cell_data.ygrid)-1)
map_devel = fltarr(n_elements(cell_data.xgrid)-1,n_elements(cell_data.ygrid)-1)
map_asvel = fltarr(n_elements(cell_data.xgrid)-1,n_elements(cell_data.ygrid)-1)
map_wiggs = fltarr(n_elements(cell_data.xgrid)-1,n_elements(cell_data.ygrid)-1)
map_dvert = fltarr(n_elements(cell_data.xgrid)-1,n_elements(cell_data.ygrid)-1)
map_dvtdv = fltarr(n_elements(cell_data.xgrid)-1,n_elements(cell_data.ygrid)-1)
map_dives = fltarr(n_elements(cell_data.xgrid)-1,n_elements(cell_data.ygrid)-1)

help, map_depth

divedata = get_dive_data(divefile)


; extract data for the right seal


right_seal = where(seals eq argos_data.ptts, count)

if count gt 0 then begin


	ut_times = divedata.ut_times(right_seal)


    depth    = divedata.depth(right_seal)
    durat    = divedata.durat(right_seal)
    sfint    = divedata.sfint(right_seal)
    btime    = divedata.btime(right_seal)
    devel    = divedata.devel(right_seal)
    asvel    = divedata.asvel(right_seal)
    wiggs    = divedata.wiggs(right_seal)
    dvert    = divedata.dvert(right_seal)
	dvtdv    = divedata.dvtdv(right_seal)

    sum_depth    = 0
    sum_durat    = 0
    sum_sfint    = 0
    sum_btime    = 0
    sum_devel    = 0
    sum_asvel    = 0
    sum_wiggs    = 0
    sum_dvert    = 0
    sum_dvtdv	 = 0
    num_dives	 = 0

	mapcount = 0
	last_mapcount = n_elements(st)-1
	done = 0

	print, 'count = ', count
	print, 'last_mapcount = ', last_mapcount

	st = [st,st[last_mapcount],st[last_mapcount]]

	print, 'st (modified) = ', st
;print, 'LOCATION ARRAYS (combined start and end cell)'
;print, cell_x
;print, cell_y

	for divecount = 0, count-1 do begin

		if (done eq 0) then begin

;			print, 'mapcount = ', mapcount
			ut_time = ut_times(divecount)
;			print, 'time = ', ut_time

			if ut_time gt st[mapcount+1] then begin

;				print, 'entering map_params if statement'

				loc_x = cell_x[mapcount]
				loc_y = cell_y[mapcount]

;			print, loc_x, loc_y

				map_depth[loc_x, loc_y] = sum_depth
				map_durat[loc_x, loc_y] = sum_durat
				map_sfint[loc_x, loc_y] = sum_sfint
				map_btime[loc_x, loc_y] = sum_btime
				map_devel[loc_x, loc_y] = sum_devel
				map_asvel[loc_x, loc_y] = sum_asvel
				map_wiggs[loc_x, loc_y] = sum_wiggs
				map_dvert[loc_x, loc_y] = sum_dvert
				map_dvtdv[loc_x, loc_y] = sum_dvtdv
				map_dives[loc_x, loc_y] = num_dives

				mapcount = mapcount + 1
				done = mapcount ge last_mapcount
				if (done eq 1) then print, 'Done!!'

			    sum_depth    = 0
    			sum_durat    = 0
    			sum_sfint    = 0
    			sum_btime    = 0
    			sum_devel    = 0
    			sum_asvel    = 0
    			sum_wiggs    = 0
    			sum_dvert    = 0
    			sum_dvtdv	 = 0
    			num_dives 	 = 0

			endif

			if (ut_time ge st[mapcount] and ut_time le st[mapcount+1]) then begin

;				print, 'entering sum_param if statement'

			    sum_depth    = sum_depth + depth[divecount]
    			sum_durat    = sum_durat + durat[divecount]
    			sum_sfint    = sum_sfint + sfint[divecount]
    			sum_btime    = sum_btime + btime[divecount]
    			sum_devel    = sum_devel + devel[divecount]
    			sum_asvel    = sum_asvel + asvel[divecount]
    			sum_wiggs    = sum_wiggs + wiggs[divecount]
    			sum_dvert    = sum_dvert + dvert[divecount]
    			sum_dvtdv    = sum_dvtdv + dvtdv[divecount]

				num_dives = num_dives + 1

			endif

		endif

	endfor

endif else begin

	print, 'No match to the seal id in sealdive.csv'

endelse

return, {depth:map_depth, $
		 durat:map_durat, $
		 sfint:map_sfint, $
		 btime:map_btime, $
		 devel:map_devel, $
		 asvel:map_asvel, $
		 wiggs:map_wiggs, $
		 dvert:map_dvert, $
		 dvtdv:map_dvtdv, $
		 dives:map_dives}

end
