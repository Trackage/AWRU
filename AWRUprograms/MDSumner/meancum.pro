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
;window, !d.window + 1
;plot, oldmean + oldsd, title = 'mean +/- SD'
;oplot, oldmean
;oplot, mean - oldsd
;window, !d.window + 1
;plot, mean + se, title = 'mean +/- SEboot'
;oplot, mean
;oplot, mean - se

output = {mean:mean, sd:oldsd, bootse:se}

return

END


