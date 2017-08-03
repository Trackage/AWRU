;==============================================================================
; NAME:	SAT_RESCALE
;
; PURPOSE:	To rescale an array of satellite remote sensing data (lat/lon
;			projection of entire globe) returning mean and variance values
;			of SST/height/colour/ice for a corresponding grid of time spent
;			values
;
; FUNCTIONS:	REVERSE - reverses array of latitude values
;				MOMENT - calculates mean and variance of satellite values in
;						 cells
;
; PROCEDURES:	LIM_AREA - subsets global array for each grid cell
;
; CATEGORY:		AWRU sealstuff
;
; CALLING SEQUENCE:	SAT_RESCALE, ARRAY, LONS, LATS, CELLS, MEAN, VARIANCE, NN
;						ARRAY - global array of satellite data
;						LONS  - longitudes for global array
;						LATS  - latitudes for global array
;						CELLS - structure of time spent data, output by FILTCELLARC
;						MEAN  - array of means ofsatellite data
;						VARIANCE - array of variances of satellite data
;						NN - array of mean sample sizes
;
; INPUTS:   ARRAY, LONS, LATS, CELLS
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:	MEAN, VARIANCE, NN
;
; COMMON BLOCKS:
;
; NOTES:    This will be integrated with FILTCELLARC to return desired average
;			satellite data to users - easily adapted to temporal summaries also
;			by adding a series of arrays together and averaging.
;			This routine assumes that the missing data value is -9999 as output
;			by SSTEXT, PFEXT, SSA_EXT and SWEXT.
;
; MODIFICATION HISTORY:  Written by MDSumner 15Aug02.
;==============================================================================
PRO SAT_RESCALE, array, lons, lats, cells, mean, variance, nn, alons, alats
;==============================================================================
  ;create empty arrays matching time spent grid
mean = cells.map_bins * 0.0
variance = cells.map_bins * 0.0
nn = cells.map_bins * 0.0
  ;retrieve the grid coordinates, lats run in reverse

xgrid = cells.xgrid
ygrid = reverse(cells.ygrid)

  ;loop over the grid, extract that area from the satdata array
  ;get its mean, variance
for x = 0, n_elements(xgrid) - 2 do begin

	for y = 0, n_elements(ygrid) - 2 do begin


		cellcoords = [ygrid[y],ygrid[y+1],xgrid[x],xgrid[x+1]]

		lim_area, array, lons, lats, area, alons, alats, limits = cellcoords
		good = where(area GT -9998, sample_size)

			;check that there are some valid values
		IF NOT good[0] LT 0 AND n_elements(good) GT 1 THEN BEGIN

			values = area(good)
			meanvar = moment(values)

			mean[x,y] = meanvar[0]
			variance[x,y] = meanvar[1]
			nn[x,y] = sample_size
		ENDIF ELSE BEGIN
			IF n_elements(good) EQ 1 THEN BEGIN
				mean[x,y] = values[0]
				variance[x,y] = 0
				nn[x,y] = 1
			ENDIF ELSE BEGIN

				mean[x,y] = -9999
				variance[x,y] = -9999
			ENDELSE
        ENDELSE


	endfor



endfor










END