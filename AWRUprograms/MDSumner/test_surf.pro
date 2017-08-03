PRO test_surf, R, Z

N = 15	;Number of random points.

X = RANDOMU(seed, N)
Y = RANDOMU(seed, N)
Z = EXP(-2 * ((X-.5)^2 + (Y-.5)^2))	;The Gaussian.

;Use a 26 by 26 grid over the rectangle bounding x and y:

R = MIN_CURVE_SURF(Z, X, Y)	;Get the surface.

end