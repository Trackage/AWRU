; IDL Version 5.2.1 (Win32 x86)
; Journal File for Administrator@ANTARCTIQUE
; Working directory: c:\program files\RSI\IDL52
; Date: Thu Sep 06 15:22:35 2001

;-----------------------------------------------------------------------------
FUNCTION COS_CORR, ARRAY, LATS

;correct presence values for latitude for spatial power analysis, called by
;SPATBOOT
info = size(array)
IF (n_params(0) LT 2) OR info(2) NE n_elements(lats) -1 THEN BEGIN

	print, 'From 2D presence and lats array (flt. pt.) weight presences by '
	print, 'cosine of latitude.
	print, 'coswts = COS_CORR(ARRAY, LATS) '
	print, 'Multiply these weights by grain size to calculate area '
	print, 'Lats expected are cell corners from cell_multi.pro'
	RETURN, -1

ENDIF
print, total(array)
   ;convert to floating point, save zero elements, convert to centre lats

array = array*1.0
zero = where(array EQ 0)
ny = n_elements(lats) -1
y_centers = (lats(0:ny-1) + lats(1:ny))/2.0

	;weight values to the cosine of the latitude

midlat = (min(lats) + max(lats))/2
	FOR y = 0, ny - 1 DO BEGIN

				;array(*,y)=  cos(((-1)*midlat +  cell)/!radeg)
				array(*,y)=  cos((-1)*(y_centers(y) - midlat)/!radeg)

	ENDFOR

IF zero(0) NE  -1 THEN array(zero) = 0

return, array
END
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
pro oplopt, array, plots

for m = 1, plots  do begin
oplot, array[m, *]
endfor
end
;------------------------------------------------------------------------------

;-----------------------------------------------------------------------------
function ranplex, array, seed, number = number

   ;create array of subscripts 0 to n of input array

n = n_elements(array)
;subscripts = indgen(n)

   ;create array of n random numbers, determine their order and rearrange input
   ;array accordingly

;random_numbers = randomu(seed, n_elements(array))
random_numbers = randomu(seed, n)

;subscripts = subscripts(sort(random_numbers))
subscripts = array(sort(random_numbers))


IF keyword_set(number) THEN subscripts = subscripts(0:number -1)

return, subscripts
END
;------------------------------------------------------------------------------
;==============================================================================
; NAME:
;       MEANCUM.PRO
;
; PURPOSE:
;		To calculate summary statistics from monte carlo spatial power data.
;
; CATEGORY:
; CALLING SEQUENCE:
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;		Modified from version kept on Harp, when moved over to Antarctique,
;		changed to correct bootstrap SE calculation, MDS 5Sep01.
;		This would only apply to replacement calc
;
;==============================================================================

PRO meancum, array, output


info = size(array)
n = info(1) * 1.0
array = array*1.0
for g = 0, info[2] - 1  do begin

	IF g EQ 0 THEN BEGIN


		a = moment(array[*,g])
		oldmean = a[0]
		oldsd = sqrt (a[1])
		help, oldmean
		help, oldsd


		sum = total(array[*, g])
		ssq = total(array[*, g] * array[*, g])
		var1 = ssq - (sum*sum)/n
		var = var1/(n*(n-1))
		sd = sqrt(var)
		se = sd*(sqrt((n-1)/n))

		;this calculation of SE is from Chernick (1999), p. 8
		;the commented out stuff is from master_mc, done on all fortnights
	;boot_mean_pc.(e) = fn_sums_pc.(e)/iters
	;boot_var1_pc.(e) = (fn_ssq_pc.(e) - (fn_sums_pc.(e)*fn_sums_pc.(e))/iters)
	;boot_var_pc.(e) = boot_var1_pc.(e)/(iters*(iters-1))
	;boot_sd_pc.(e) = sqrt(boot_var_pc.(e))
	;boot_se_pc.(e) = boot_sd_pc.(e)*(sqrt((iters-1)/iters))

 		mean = total(array[*, g])/n


		;N = sqrt((n-1)/n)
		;print, N
		;varN = 1/(n/(n-1))
		;varS = (total((array[*, g])^2) - ((total(array[*, g]))^2)/n )
		;var = sqrt(varN * varS)
		;se = N*var

		print, mean
		print, se


	ENDIF ELSE BEGIN

			;this is the non-bootstrap variance of the mean

		a = moment(array[*,g] )
		oldmean = [mean, a[0]]
		oldsd =  [oldsd, sqrt(a[1])]


			;this is the bootstrap variance, this probably only applies to replacement
			;Mark says we want an estimate for our SAMPLE not the POPULATION

		meanZ = total(array[*, g])/n

		sum = total(array[*, g])
		ssq = total(array[*, g] * array[*, g])
		var1 = ssq - (sum*sum)/n
		var = var1/(n*(n-1))
		sdZ = sqrt(var)
		seZ = sd*(sqrt((n-1)/n))




 		;seZ = sqrt((n-1)/n)  * sqrt(1/(n*(n-1))*(total((array[*, g])^2) - ((total(array[*, g]))^2)/n )   )

		mean = [mean, meanZ]
		sd = [sd, sdZ]
		se  = [se, seZ]
		;help, mean
		;help, se

	ENDELSE


endfor
print, 'a', a
window, !d.window + 1
!p.multi = [0, 1, 1]
plot, oldmean + oldsd, title = 'mean +/- SD'
oplot, oldmean
oplot, mean - oldsd
;window, !d.window + 1
;plot, mean + se, title = 'mean +/- SEboot'
;oplot, mean
;oplot, mean - se

output = {mean:mean, sd:oldsd, bootse:se}

return

END
;---------------------------------------------------------------------------


;----------------------------------------------------------------------------
PRO SPATBOOT, OUTPUT, NBEASTS = NBEASTS, ITERS = ITERS, COSINE = COSINE, SKIP = SKIP

IF n_elements(iters) EQ 0 THEN iters = 10000
IF n_elements(nbeasts) EQ 0 THEN nbeasts = 10
IF n_elements(skip) EQ 0 THEN skip = 1
IF NOT keyword_set(skip) THEN store_cellsmod, /all_fns

restore, 'eachfn.xdr'
prcells = seal_cells.map_bins
lats = seal_cells.ygrid



help, prcells, /stru


	;first turn the cell times into arrays of ones and zeros
beasts = tag_names(prcells)
FOR n = 0, n_tags(prcells) - 1 DO BEGIN

	pres = where(prcells.(n))
	mask = prcells.(n)*0.0
	mask(pres) = 1.0
	IF keyword_set(cosine) THEN mask = cos_corr(mask, lats)
	;stop
;	imdisp, mask
	;stop
	prcells.(n) = mask
	;window, !d.window + 1
;	imdisp, prcells.(n)

endfor

   ;pick out nbeasts at random if required

seed = long( ( systime(1) - long(systime(1)) ) * 1.e8 )
	;no the following line is with replacement
;IF nbeasts LT n_elements(beasts) THEN beasts2 = beasts(fix(randomu(seed, nbeasts)*n_elements(beasts)))

	;this reduces the number of beasts at random, without replacement

IF nbeasts LT n_elements(beasts) THEN beasts = ranplex(beasts, seed, number = nbeasts)
;print, beasts
help, beasts

for boot = 1, iters  DO BEGIN

		;randomize each subsequent time
	IF boot GT 1 THEN beasts = ranplex(beasts, seed)

	for n = 0, n_elements(beasts) - 1 DO BEGIN

		beast_no = where(tag_names(prcells) EQ beasts(n))

		IF n EQ 0 THEN BEGIN
			mask = prcells.(beast_no(0))



			tot = total(mask)
			;stop
			;plot, beast_no
		ENDIF ELSE BEGIN
			mask = mask + prcells.(beast_no(0))
			ones = where(mask)
			mask(ones) = 1
			tot = [tot, total(mask)]
			;oplot, beast_no
		ENDELSE




	ENDFOR
	;stop
	;help, tot
	cum_tot = reform(tot, 1, nbeasts)

	IF boot EQ 1 THEN cum_array = cum_tot ELSE cum_array = [cum_array, cum_tot]


ENDFOR

;stop
;window, !d.window + 1
wset, 0
!p.multi = [0, 2, 2]
;!p.multi = [0, 1, 1]
plot, cum_array(0, *), title = strcompress(string(iters) + ' cumulatives ' $
	  + string(nbeasts) + ' beasts');, yrange = [0, 100], xrange = [0, 50]
oplopt, cum_array, iters -1


meancum, cum_array, output

mean = output.mean
sd = output.sd

filename = strcompress(string(iters) + string(nbeasts) + '.csv', /remove_all)

openw, lun, filename, /get_lun
printf, lun, iters, ' iterations', ',', nbeasts, ' seals'
printf, lun, 'mean', ',', 'sd'
for n = 0, n_elements(mean) - 1 do begin
	printf, lun, mean(n), ',', sd(n)

endfor
free_lun, lun



end

;----------------------------------------------------------------------------