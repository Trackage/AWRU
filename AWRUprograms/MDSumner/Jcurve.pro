;------------------------------------------------------------------------
; NAME:
;       JCURVE
;
; PURPOSE:
;       This procedures runs A.K. Dewdney's multispecies logistical
;			(MSL) model, a simple model of community dynamics and
;			species abundance distributions.
;
; CATEGORY:
;       Ecological modelling
;
; CALLING SEQUENCE:
;       	Jcurve, [abunds, xbar = xbar, arr = arr, iters = iters, $
;			 /plot4, /image, /cnbl, /rnd, /keep, /noplot
;
; INPUTS:	(OPTIONAL)
;			abunds - array of abundances (default is all equal to start)
;			xbar - mean, starting, abundance
;			arr - number of species  (R)
;
; KEYWORD PARAMETERS:
;
;			iters - number of iterations to run
;			plot4 - produce a fancy, 4 piece plot over a 10000 iters run
;			image - write a jpeg of the finish plot
;			cnbl - don't exclude cannibalizing (no effect probably)
;			rnd	- randomly select species for cumulative sum
;			keep - don't redefine the abundance array (good for long iters)
;     		noplot - don't plot during run time
;
; EXAMPLES:
;			Simplest is just to type JCURVE for default run, then use ITERS
;			to increase iterations, XBAR to change mean abundance, ARR to
;           change number of species.  Most of the rest is just display
;           foolery.
;
; PROCEDURES:
;			SELSP
;				selsp, abunds, s, rnd = rnd
;			Makes the selection of donor/receptor species.

;
; REFERENCE:
;			Dewdney, A.K., (2001).  Mathematical Intelligencer, 23:27-34.
;
; MODIFICATION HISTORY:
;			Written late September by MDSumner, 2001.
;			Elaborated and commented, MDS 2Oct01.
;---------------------------------------------------------------
PRO selsp, abunds, s, rnd = rnd

	    ;select a number between 0 and total abundance

	ran = floor(randomu(seed) * total(abunds))

	;print, total(abunds)
	;stop
	   ;initialize count and sum variables

	s = -1
	sum = 0

	REPEAT BEGIN

			;this is summing for all species' abundance, maybe should pick them at random
			;this would still bias the selection to abundant species(?)
		IF keyword_set(rnd) THEN BEGIN
			s = floor(randomu(seed) * n_elements(abunds))
		ENDIF ELSE s = s + 1   ;increment the count

		sum = sum + abunds(s)   ;add to sum

	ENDREP UNTIL sum GE ran


END
;---------------------------------------------------------------------
;----------------------------------------------------------------------
PRO jcurve, abunds, $
	xbar = xbar, $
	arr = arr, $
	iters = iters,$
	plot4 = plot4, $
	image = image, $
	cnbl = cnbl, $
	rnd = rnd, $
	keep = keep, $
	noplot = noplot

  ;close the window to save calluses
wdelete, 0
wdelete, 1
   ;initialize variables, see Dewdney,(2001) V23:3, p:27-34
IF n_elements(xbar) EQ 0 THEN xbar = 10  ;mean abundance
IF n_elements(arr) EQ 0 THEN arr = 100		;n species
IF n_elements(iters) EQ 0 THEN iters = 2000  ;iterations
     ;create species abundance array
IF n_elements(abunds) EQ 0 OR NOT keyword_set(keep) THEN abunds = replicate(xbar, arr)
tot = arr * xbar				;total abundance

window, 0, /pixmap
window, 1
IF keyword_set(plot4) THEN !p.multi = [0, 2, 2] ELSE !p.multi = 0
window, 2

for n = 0, iters - 1 do begin

	;IF n LT 100 THEN BEGIN
	;	win = !d.window
	;	winstat = !p.multi
	;	wset, 2
	;	IF n EQ  0 THEN plot, abunds, yrange = [0, xbar + 100] $
	;		 ELSE oplot, histogram(abunds)
			 ;stop
	;	wset, win
	;	!p.multi = 	winstat
	;ENDIF

  		;select a species, biassed to abundant ones

	selsp,  abunds, s, rnd = rnd
	abunds(s) = abunds(s) + 1    ;add to abundance

	   ;set key to remember not to cannibalize

	IF keyword_set(cnbl) THEN old = -1 ELSE old = s

	   ;select another, remembering the first one (if don't cannibalize)
	REPEAT BEGIN

		selsp, abunds, s, rnd = rnd

	ENDREP UNTIL s NE old
	abunds(s) = abunds(s) - 1   	;subtract from abundance

	IF NOT keyword_set(noplot) THEN BEGIN
			;plot abundance histogram

		;IF fix(n/100.0) EQ n/100 THEN plot, histogram(abunds, binsize = 2) ;& stop
		wset, 0  ;work in hidden window
		IF keyword_set(plot4) THEN BEGIN

			IF n EQ 500 OR n EQ 5000 OR n EQ 7500 OR n EQ iters - 1 THEN BEGIN
				plot, histogram(abunds, binsize = 2), $
					title = strcompress(string(n) + ' iterations, xbar = ' $
					+ string(xbar) + ' N = ' +  string(R) + ', binsize = 2 '), charsize = .8, ymargin = [6, 4]
			ENDIF
		ENDIF ELSE BEGIN
			IF n/100.0 EQ n/100 THEN $
			plot, histogram(abunds, binsize = 2), xrange = [0, 10], yrange = [0, 30], $
			 	title = strcompress(string(n-1) + ' iterations')
			;stop
		ENDELSE
		wset, 1  ;copy result to display window
		device,  copy = [0, 0, !d.x_size, !d.y_size, 0, 0, 0]
	ENDIF ELSE BEGIN
		IF abunds(0) GE max(abunds) THEN plot, histogram(abunds), title = string(n)
	ENDELSE
endfor

IF keyword_set(image) THEN BEGIN
	   ;make a jpg
	image = tvrd()
	jpgnm = string(n) + 'iters.jpg'
	write_jpeg, jpgnm, image
ENDIF
END
;--------------------------------------------------------------------



