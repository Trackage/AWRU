

spatboot, mean42, nbeasts = 42, /cosine, /skip
spatboot, mean32, nbeasts = 32, /cosine, /skip
spatboot,  mean22, nbeasts = 22, /cosine, /skip
spatboot, mean12, nbeasts = 12, /cosine, /skip

window, !d.window + 1
!p.multi = [0, 1, 1]
plot, mean42.mean + mean42.sd
oplot, mean42.mean
oplot, mean42.mean - mean42.sd

;oplot, mean32.mean + mean32.sd
oplot, mean32.mean
;oplot, mean32.mean - mean32.sd

;oplot, mean22.mean + mean22.sd
oplot, mean22.mean
;oplot, mean22.mean - mean22.sd

;oplot, mean12.mean + mean12.sd
oplot, mean12.mean
;oplot, mean12.mean - mean12.sd
end