;==============================================================================
; NAME:  STORE_CELLSMOD
;
; PURPOSE:	To extract, filter and store location data as time spent arrays for
;			resampling with randomization methods.
;
; FUNCTIONS:   FILT2CELLS - a combination of READ_FILTPTT and CELL_MULTI
;					- for a specified group of animals produces time spent grid
;			   CELL_MULTI - produces grids of time spent from location data
;
; PROCEDURES:	FN_SEAL - produces arrays for each seal for every fortnight
;					i.e. (#fnights * #seals) arrays
;			    ALL_FNS - produces arrays for each seal over all fortnights
;					i.e. (#seals) arrays
;				ALL_CELLS - values over all fortnights for all seals
;					i.e. one array
;				UNDEFINE - undefines variables, www.dfanning.com
;				READ_FILTPTT - filters data for speed etc. DJWatts, AAD
;
; CATEGORY:
; CALLING SEQUENCE:		STORE_CELLSMOD
; INPUTS:			file, fortnights, scale, max_speed, file, limits - currently hardcoded for
;						PLEX data, but set as keyword options
;
; KEYWORD PARAMETERS: all_fns/fn_seal/all_cells - call appropriate procedure(s)
;					  scale - spatial scale (km)
;					  show - this will show pictures of arrays for mental reassurance
;					  limits - set the spatial limits, see CELL_MULTI
;					  max_speed - max speed to filter, km/hr
;
;
; OUTPUTS:			Structure(s) of arrays in the appropriate format are returned.
;
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;					Written MDSumner Sept01.
;					Tidied and commented, 8Oct01 MDS.
;======================================================================================
FUNCTION filt2cells, data, filt_out, seals, time0, time1, max_speed, scale, limits
;======================================================================================
FOR si = 0, n_elements(seals) -1 DO BEGIN

		;filter the data for each seals, appending each time to structure
	read_filtptt, data, filt_out, seals(si), $
		time0,  time1, 3, delta_time = 0, $
		max_speed = max_speed, include_ref = 'N'

ENDFOR

IF n_elements(filt_out) GT 0 THEN BEGIN
      ;determine time spent in grid
	cells = cell_multi(filt_out, cell_size = [scale, scale], /km, limits = limits)
return, cells
ENDIF


END
;======================================================================================

;======================================================================================
PRO fn_seal, data, seals,  fortnights, max_speed, scale, limits, show = show
;======================================================================================
   ;this flag enables the contents of cells to be saved for input into the
   ;super structure of this stuff, but not to crash when there is no data
   ;for the given time period
cell_flag = 0

   ;just for fun make a big window 3/4 size of screen
scr_size = get_screen_size()
window, xsize = scr_size(0)*0.75, ysize = scr_size(1)*0.75
!p.multi = [0, 10, 10]  ;set display to show lots of images!

  ;repeat for each fortnight
FOR a = 0, n_elements(fortnights) -2 DO BEGIN

	   ;read the time string and define a tag name for the structures
	reads, fortnights[a], iy, im, id, is, format='(i4,5i2)'
	fn_string = strcompress( month_cnv(im, /up, /short) +string(fix(id)), /remove_all)

		   ;repeat for each seal
		FOR j = 0, n_elements(seals) - 1 DO BEGIN

			   ;undefine the filtered structure (otherwise it will be added to)
			undefine, filt_out
			   ;filter and grid the data for this fn/seal
			cells = filt2cells(data, filt_out, seals[j], fortnights[a], fortnights[a+1], $
				max_speed, scale, limits)

			   ;check that some data came out
			type = size(cells, /type)
			IF type EQ 8 THEN BEGIN

				   ;show some stuff to reassure operator
				IF keyword_set(show) THEN imdisp, cells.map_bins, margin = 0.0, /noscale

				   ;
				IF cell_flag EQ 0 THEN BEGIN
						;find tag names of cells, to add multi map structure
   						;to cells structure - do this once only
					cells_sv = cells
					cell_flag = 1
					tags = tag_names(cells)
				ENDIF

				   ;then add to the structure each time
				IF j EQ 0 THEN BEGIN
   						;create structure for maps

					maps = create_struct(seals(j), cells.map_bins)

				ENDIF ELSE BEGIN
						;add successive maps
					maps = create_struct(maps,  seals(j), cells.map_bins)
				ENDELSE
			ENDIF
		ENDFOR

		   ;add these structures to the daddy structure
		IF a EQ 0 THEN BEGIN

			fn_cells = create_struct(fn_string, maps)

 		ENDIF ELSE BEGIN
 			fn_cells = create_struct(fn_cells, fn_string, maps)
 		ENDELSE
ENDFOR
			   ;now the granddaddy structure
 			super_cells = create_struct(tags[0], fn_cells, tags[1], cells_sv.cell_size, $
				tags[2], cells_sv.xgrid, tags[3], cells_sv.ygrid, tags[4], cells_sv.km, $
					tags[5], cells_sv.rb)

		   ;save to file and inform operator
		save, super_cells, filename = strcompress('allfnts.xdr')
		print, 'saved structure named "super_cells" to allfnts.xdr'


END
;======================================================================================

;======================================================================================
PRO all_fns, data, seals, fortnights, max_speed, scale, limits, show = show
;======================================================================================
   ;create time maps for whole period


   ;just for fun make a big window 3/4 size of screen
scr_size = get_screen_size()
window, xsize = scr_size(0)*0.75, ysize = scr_size(1)*0.75
!p.multi = [0, 10, 10]  ;set display to show lots of images!

	  ;repeat for each seal
	FOR i = 0, n_elements(seals) -1 DO BEGIN

			;filter and grid
		cells = filt2cells(data, filt_out, seals[i], fortnights(0), fortnights(n_elements(fortnights) - 1), $
			max_speed,   scale, limits)

		IF keyword_set(show) THEN imdisp, cells.map_bins, margin = 0.0, /noscale
		undefine, filt_out
		IF i EQ 0 THEN BEGIN
   				;create structure for maps
			maps = create_struct(seals(i), cells.map_bins)

		ENDIF ELSE BEGIN
				;add successive maps
			maps = create_struct(maps,  seals(i), cells.map_bins)
		ENDELSE
	ENDFOR


			;find tag names of cells, to add multi map structure to cells structure
		tags = tag_names(cells)
		allfns = create_struct(tags[0], maps, tags[1], cells.cell_size, $
			tags[2], cells.xgrid, tags[3], cells.ygrid, tags[4], cells.km, tags[5], cells.rb)

			;save this structure
		save, allfns, filename = strcompress('allfns.xdr')
		print, 'saved structure named "allfns" to allfns.xdr, containing map_bins for all seals for entire period'

;ENDIF

END
;======================================================================================

;======================================================================================
PRO all_cells, data, seals,  fortnights, max_speed, scale, limits, show = show
;======================================================================================
  ;now do this for all seals over all fortnights
  ;probably don't need to undefine here but HEY!
 undefine, filt_out
 undefine, cells
!p.multi = 0
allcells = filt2cells( data, filt_out, seals, fortnights[0], fortnights(n_elements(fortnights)-1), $
	 max_speed, scale, limits)
IF keyword_set(show) THEN imdisp, allcells.map_bins, margin = 0.0, /noscale
save, allcells, filename = 'allcells.xdr'
save, filt_out, filename = 'allfilt.xdr'
print, 'saved structure  named "allcells" to allcells.xdr, containing time sum for all seals all fortnights'
END
;======================================================================================

;======================================================================================
PRO store_cellsmod, all_fns = all_fns, fn_seal = fn_seal, all_cells = all_cells, $
		file = file, $
		scale = scale, $
		limits = limits, $
		fortnights = fortnights, $
		max_speed = max_speed, $
		show = show
;======================================================================================

   ;set display, seawifs looks good
set_display

   ;define default file if not input
IF n_elements(file) EQ 0 THEN BEGIN
	IF !version.os EQ 'Win32' THEN $
		file = filepath('sealplex2.csv', subdirectory = '/resource/datafile') ELSE 	file = 'sealplex2.csv'
ENDIF

   ;extract data from file, define the seals from within
data = gl2ptt(file)
seals = data.ptts(uniq(data.ptts))  ;pick out an array of all unique IDs

   ;guard against empty string case
IF seals(n_elements(seals) - 1) EQ '' THEN seals = seals(0 :n_elements(seals) -2)

   ;set default limits, times, speed and scale
IF n_elements(limits) EQ 0 THEN limits = [-41.0, -69.0, 127.0, 219.0]
IF n_elements(fortnights) EQ 0 THEN $
	fortnights = ['19501016000000', '19501101000000', '19501116000000', '19501201000000', $
	'19501216000000', '19510101000000', '19510116000000', '19510131000000']
IF n_elements(max_speed) EQ 0 THEN max_speed = 12.5
IF NOT keyword_set(scale) THEN scale = 350.0

   ;run appropriate modules
IF keyword_set(all_fns) THEN all_fns, data, seals, fortnights, max_speed, scale, limits, show = show
IF keyword_set(fn_seal) THEN fn_seal, data, seals, fortnights, max_speed, scale, limits, show = show
IF keyword_set(all_cells) THEN all_cells, data, seals, fortnights, max_speed, scale, limits, show = show
END

;---------------------------------------------------------------------------------------------------
