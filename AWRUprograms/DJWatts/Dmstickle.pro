;+
; NAME:
;    DMSTICKLE
;
; Purpose:
;    This routine returns arrays TIkVALS and TIKLABS, which specify
;    the values and labels of major tick marks to used when plotting
;    in quantities which vary like Degrees, Minutes, Seconds such as
;    geographic positions. The LO and HI values of the data range are
;    passed in. Also returned is MINOR, which is the number of minor
;    intervals per major interval.
;
; Usage:
;    dmstickle, lo, hi, tikvals, tiklabs, minor, mon_ticks=abc
;
;    Mark Conde, Aurora Australis, 08-FEB-1992.
;-

pro DMSTICKLE, lo, hi, tikvals, tiklabs, minor, min_ticks=mint

if not keyword_set(mint) then mint=3

; Setup arrays of possible tick spacings and numbers of minor ticks,
; then choose the largest that will give at least MINT tick lines

range   = abs(hi - lo)
degtix  = [30., 20., 15., 10., 5., 2., 1.]
minum   = [6,     4,   3,   5,  5,  4, 6]
tix     = [degtix, degtix/60., degtix/3600.]
minum   = [minum, minum, minum]
enough  = where(range/tix gt mint)
tick    = tix(enough(0))
minor   = minum(enough(0))

start   = fix(lo/tick)
if        start lt 0 then start = start -1
start   = tick*start
tikvals = start + findgen(fix(range/tick)+ 2)*tick
tikvals = tikvals(where((tikvals ge lo) and (tikvals le hi)))
tikvals_abs = abs(tikvals) + 0.25/3600.0

tikdegs = fix(      tikvals_abs )
tikmins = fix(  60*(tikvals_abs - tikdegs))
tiksecs = fix(3600*(tikvals_abs - tikdegs - tikmins/60.))

nneg    = 0
nmnz    = 0
nsnz    = 0
negs    = where (tikvals lt 0, nneg)
minsnz  = where (tikmins ne 0, nmnz)
secsnz  = where (tiksecs ne 0, nsnz)

tiklabs = strtrim(string(tikdegs), 2)
if (nneg gt 0) then tiklabs(negs)   = "-" + tiklabs(negs)
if (nmnz gt 0) then tiklabs(minsnz) = tiklabs(minsnz) + " " + $
                                      string(tikmins(minsnz)) + "' "
if (nsnz gt 0) then tiklabs(secsnz) = tiklabs(secsnz) + " " + $
                                      string(tiksecs(secsnz)) + '"'
tiklabs = strcompress(strtrim(tiklabs, 2))
end