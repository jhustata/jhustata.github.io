capture program drop _all
program define ind_translator
	syntax, row(int) col(int)

	// tokenize the alphabet
	local alphabet "`c(ALPHA)'"
	tokenize `alphabet'
	// now translate col
	local col_helper = `col'
	
	
    while (`col_helper' > 0) {
		local temp_helper2 = (`col_helper' - 1)
		local temp_helper = mod(`temp_helper2', 26) + 1
        local col_name : di "``temp_helper''" "`col_name'"
        local col_helper = (`col_helper' - `temp_helper') / 26
    } 
	
	
	// generate a global macro that can be used in main program
	global ul_cell "`col_name'`row'"
	
end