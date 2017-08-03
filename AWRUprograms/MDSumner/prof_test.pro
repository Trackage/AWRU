pro prof_test, b

openr, 1, filepath('nyny.dat', subdir=['examples', 'data'])
a=assoc(1, bytarr(768,512))
help, a

b=a[0]
close, 1
TV, b

end