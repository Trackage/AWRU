PRO snakerun

file = filepath('finallocations2.csv', subdirectory = '/resource/datafile')
UYfems = ['A020', 'A033', 'A034', 'A035', 'A037', 'A046', 'A057', 'F898', 'H355']
UYmen = ['A031', 'A036', 'A038', 'A051', 'A076', 'F230', 'F995']
Yfem = ['A188', 'A189']
Ymen = ['A180', 'A193', 'A195', 'A196']

groups = {UYfems:UYfems, UYmen:UYmen, Yfem:Yfem, Ymen:Ymen}
tags = tag_names(groups)

FOR a = 0, n_tags(groups) -1 DO BEGIN

	 cell_track, file, filt_out, cells, beasts = groups.(a), /snake, /map_data, label = tags(a)
	undefine, filt_out

ENDFOR

cell_track, file, filt_out, cells, /snake, /map_data

end