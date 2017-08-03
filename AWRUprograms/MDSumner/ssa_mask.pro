FUNCTION ssa_mask, arr, nan = nan


 bad = where(arr GE 32766)
 good = where(arr LT 32766)
 maxv = max(arr(good))

 arr2 = arr
 arr2(bad) = maxv + 1
 IF keyword_set(nan) THEN BEGIN
 	arr2 = arr2*1.0
 	arr2(bad) = !values.f_nan
 ENDIF

return, arr2

end