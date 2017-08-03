imdisp, drift_sum, title = 'drift', /axis, /noscale, channel = 1
colorbar, range = [min(drift_sum), max(drift_sum)], position =  [0.05, 0.96, 0.45, 0.99 ]
imdisp, dslope_sum, title = 'slope', /axis, /noscale, channel = 1
colorbar, range = [min(dslope_sum), max(dslope_sum)], position =  [0.55, 0.96, 0.98, 0.99]

imdisp, pslope_sum, title = 'pos', /axis, /noscale, channel = 1
colorbar, range = [min(pslope_sum), max(pslope_sum)], position =  [0.05, 0.45, 0.45, 0.49]

imdisp, nslope_sum, title = 'neg', /axis, /noscale, channel = 1
colorbar, range = [min(nslope_sum), max(nslope_sum)], position =  [0.55, 0.45, 0.98, 0.49]


end