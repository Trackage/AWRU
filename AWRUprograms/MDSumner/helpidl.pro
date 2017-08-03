PRO helpidl

print, 'To map track data, ensure the following programs are in your IDL directory: '

print, 'CELL_MULTI.PRO, CELL_TRACK.PRO, COLORBAR.PRO, FILTER_FIXES.PRO, GL2PTT.PRO, '

print, 'IMDISP.PRO, LL2RB.PRO, MAP_CELL.PRO, MAP_DATA.PRO, POLREC.PRO, POLREC3D.PRO '

print, 'READ_FILTPTT.PRO, RECPOL.PRO, RECPOL3D.PRO, ROT_3D.PRO, YMD2JD.PRO ,YMDS2JS.PRO'

print, 'The core programs of this system are DJW''s cell_multi, read_filtptt and filter_fixes '

print, 'They filter and grid location data into specified spatial and temporal grains (i.e., for e.g. '

print, 'scales of one week and 1 degree )'

print, 'CELL_TRACK.PRO is the master program and this requires a single line input such as '

print, 'cell_track, ''inputfile'', filt_out, cells '

print, 'where inputfile is your correctly formatted location data. '

print, 'Options include time0, time1, beasts, scale, max_speed, limits, label, '
print, ' which are input as keyword = somevalue, '
print, 'i.e.: cell_track, file, filt_out, cells, time0 = ''19501013000000''

print, 'whereas other keywords have no input data, like, map_data, user
print, 'which are input as /keyword '
print, 'i.e.cell_track, file, filt_out, cells, /map_data '

print, 'filt_out and cells are optional inputs, they will be defined by cell_track as '
print, ' the filtered data and the mapped cells respectively, and if set by the user '
print, 'will still be defined after run time '

END