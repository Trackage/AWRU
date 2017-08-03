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

map_dslope = maps.map_dslope
map_drift = maps.map_drift
map_poslope = maps.map_poslope
map_negslope = maps.map_negslope
propos = maps.propos
proneg = maps.proneg
sumpos = maps.sumpos
sumneg = maps.sumneg

ptts = divedata.seals
right_seal = where(ptts EQ seal, count)
ut_times = divedata.ut_times(right_seal)
mapcount = 0

st = cell_data.cross_times
start_time = st[0] - 3600.0*cell_data.map_bins[first_cell_x,first_cell_y]
end_time = st[ncell] + 3600.0*cell_data.map_bins[last_cell_x,last_cell_y]

st = [start_time, st, end_time]

 drift = divedata.drift(right_seal)
 dslope = divedata.dslope(right_seal)

dtime = 0.0


FOR each_pt = 0, n_elements(st)-2 do begin

	sum_drift    = 0.0
    sum_dslope    = 0.0
 	pos_count = 0
 	neg_count = 0

	uts = where(ut_times LE st(each_pt + 1) )

	this_dtime = (st(each_pt + 1 ) - st(each_pt))/(3600*24)

	FOR each_loc = 0, n_elements(uts) - 1 do begin

		ut_time = uts(each_loc)

		sum_drift    = sum_drift + drift[each_loc]
	    sum_dslope    = sum_dslope + dslope[each_loc]

		IF dslope[each_loc] GT 0.0 THEN pos_count = pos_count + 1 ELSE neg_count = neg_count + 1

	ENDFOR

	loc_x = cell_x[each_pt +1]
	loc_y = cell_y[each_pt + 1]

	map_drift[loc_x, loc_y] = map_drift[loc_x, loc_y] + sum_drift
	map_dslope[loc_x, loc_y] = 	map_dslope[loc_x, loc_y] + sum_dslope
	;map_poslope[loc_x, loc_y] = map_poslope[loc_x, loc_y] + pos_count
	;map_negslope[loc_x, loc_y] = map_negslope[loc_x, loc_y] + neg_count

	sumpos[loc_x, loc_y] =  pos_count
	sumneg[loc_x, loc_y] = neg_count
	dtime = dtime + this_dtime


ENDFOR

seal_nn = sumpos*0
mask = where((sumpos + sumneg) GT 0)
seal_nn(mask) = 1
;this_propos = map_poslope/dtime
;this_proneg = map_negslope/dtime
;propos = this_propos + propos
;proneg = this_proneg + proneg

;mask = where((nn) GT 0)

propos_m = sumpos*1.0
propos_m(mask) = propos_m(mask)/(sumpos(mask) + sumneg(mask))

proneg_m = sumneg*1.0
proneg_m(mask) = proneg_m(mask)/(sumpos(mask) + sumneg(mask))





return, {drift:map_drift, $
		 dslope:map_dslope, $
		 ;map_poslope:map_poslope, $
		 ;map_negslope:map_negslope, $
		 propos_m:propos_m, $
		 proneg_m:proneg_m, $
		 propos_t:sumpos, $
		 proneg_t:sumneg, $
		 ;seal_mask:seal_nn, $
		 seal_nn:seal_nn $
		}
END
