*! inspired by 340.600.71 
*! by Vincent Jin & Abi Muzaale
*! July 5, 2022 
*! version 3.0

capture program drop table1_options
program define table1_options
     syntax [if],  title(string) ///  
	              [cont(varlist)] ///  
			      [binary(varlist)]  /// 
			      [multi(varlist)] /// 
				  [foot(string)] ///  
				  [by(varname)] ///
				  [excel(string)]
				  
	quietly {
		
		// sreen if if syntax is called
		if "`if'" != "" {
			local if_helper = substr("`if'", 3, .)
			local if_helper : di "& " "`if_helper'"
		}
		
		// screen if excel option got called
		if "`excel'" == "" {
			local excel_name : di "table1_option_output"
		}
		else {
			local excel_name : di "`excel'"
		}
		
		// generate an excel file
		putexcel set `excel_name', replace
		local alphabet "`c(ALPHA)'"
		tokenize `alphabet'
		if "`by'" == "" {		 
			
			// generate row and col indicator in excel
			local excel_row_c = 1
			local excel_col_c = 1
			
			//columns
			local col1: di "_col(40)"
			capture local col2: di "_col(50)"
			
			//title string
			noisily di "`title'"
			ind_translator, row(`excel_row_c') col(`excel_col_c')
			putexcel $ul_cell = "`title'"
			 local excel_row_c = `excel_row_c'
			 count `if'
			 local total_N=r(N)
			 di `col1' "N=`total_N'"
			 local excel_row_c = `excel_row_c' + 1
			 ind_translator, row(`excel_row_c') col(`excel_col_c')
			 putexcel $ul_cell = "N=`total_N'"
			 
			 foreach v of varlist `cont' {
				 quietly sum `v' `if', detail
				 local row_lab_c: variable label `v'
				 local excel_row_c = `excel_row_c' + 1
				 local excel_col_c = 1
				 ind_translator, row(`excel_row_c') col(`excel_col_c')
				 putexcel $ul_cell = "`row_lab_c'"
				 local D %2.0f
				 local med_iqr_c: di ///
									 `D' `col1' r(p50) "[" ///
									 `D' r(p25) "," ///
									 `D' r(p75) "]"
				 local med_iqr_c2: di ///
									 `D' r(p50) " [" ///
									 `D' r(p25) "," ///
									 `D' r(p75) " ]"
				 local row_c: di "`row_lab_c' `med_iqr_c'"
				 local excel_col_c = `excel_col_c' + 1
				 ind_translator, row(`excel_row_c') col(`excel_col_c')
				 putexcel $ul_cell = "`med_iqr_c2'"
				 
				 //continuous varlist
				 noisily di "`row_c'"
			 }
			 
			 foreach v of varlist `binary' {
				 local excel_row_c = `excel_row_c' + 1
				 local excel_col_c = 1
				 ind_translator, row(`excel_row_c') col(`excel_col_c')
				 quietly sum `v' `if', detail
				 local row_lab_b: variable label `v'
				 putexcel $ul_cell = "`row_lab_b'"
				 local D %2.0f
				 local percent: di `D' `col1' r(mean)*100 
				 local percent2: di `D' r(mean)*100
				 local row_b: di "`row_lab_b' `percent'"
				 local excel_col_c = `excel_col_c' + 1
				 ind_translator, row(`excel_row_c') col(`excel_col_c')
				 putexcel $ul_cell = "`percent2'"
				 //binary varlist
				 noisily di "`row_b'"
			 }
			 
				foreach v of varlist `multi' { 
					 local row_var_lab: variable label `v'
					 local row_lab_m: value label `v'
					 
					 // count without missing
					 quietly count if !missing(`v') `if_helper'
					 local total = r(N)
					 
					 quietly levelsof `v' `if', local(levels)
					 
					 // putexcel the variable name
					 local excel_row_c = `excel_row_c' + 1
					 local excel_col_c = 1
				  	 ind_translator, row(`excel_row_c') col(`excel_col_c')
					 putexcel $ul_cell = "`row_var_lab'"
					 
					 //multinomial varlist
					 noisily di "`row_var_lab'"
					 
					 local nlevels=r(r)
					 
					 forvalues l=1/`nlevels' {
						 local excel_col_c = 1
						 local excel_row_c = `excel_row_c' + 1
						 capture local levels: label `row_lab_m' `l'
						 ind_translator, row(`excel_row_c') col(`excel_col_c')
						 putexcel $ul_cell = "     `levels'"
						 local excel_col_c = `excel_col_c' + 1
						 quietly count if `v'==`l' `if_helper'
						 local num=r(N)
						 local percent_v: di `D' `col1' `num'*100/`total'
						 local percent_v2: di `D' `num'*100/`total'
						 
						 ind_translator, row(`excel_row_c') col(`excel_col_c')
						 putexcel $ul_cell = "`percent_v2'"
					 noisily di "     `levels' `percent_v'"	
						 local l=`l'+1
						 
					 }
			 
			}
			

			local  oldvarname: di "`cont' `binary' `multi'"
			preserve
			rename (`oldvarname')(`foot')
			local missvar "`foot'"
			di ""
			foreach v of varlist `missvar' {
				 local excel_row_c = `excel_row_c' + 1
				 local excel_col_c = 1

				 quietly count `if'
				 local denom=r(N)
				 quietly count if missing(`v') `if_helper'
				 local vlab: variable label `v'
				 local num=r(N) 
				 local missing=round(`num'*100/`denom',.1)
				 local missingness: di _col(25) `missing'
				 noisily di "`v':  `missingness'% missing"
				 ind_translator, row(`excel_row_c') col(`excel_col_c')
				 putexcel $ul_cell = "`v': `missing'% missing"
			}
			noisily di "`if'"
			local excel_row_c = `excel_row_c' + 1
			local excel_col_c = 1
			ind_translator, row(`excel_row_c') col(`excel_col_c')
			putexcel $ul_cell = "`if'"
			restore
		} 
		else {
			
			// generate a screener to see if user inputted a by varaible in table 1
			// this will not influence the table but will influence the footnote missing value section
			local dual_screener = 0
			local var_screener `cont' `binary' `multi'
			foreach var in `var_screener' {
				if "`by'" == "`var'"{
					local dual_screener = 1
				}
			}
			if `dual_screener' == 1 {
				noisily di "Wrong Input: The stratifying variable should not be inputted as table 1 variable"
			} 
			else {
				
				// generate row and col indicator in excel
				local excel_row_c = 1
				local excel_col_c = 1
				
				// first detect how many categories the variable has
				levelsof(`by')
				// save values to a macro
				local by_var_val = r(levels)
				/*
				// count how many values the variable has
				local val_count = 0
				foreach count in `by_var_val' {
					val_count = `val_count' + 1
				}
				*/
				// prepare a spacing factor to separate columns
				local col_fac = 20
				// prepare a spacing parameter for actual separation
				// and the default should be 40 for the first column
				local col_sep = 40
				// prepare for column heading
				local col_lab_m: value label `by'
				// display first line
				noisily di "`title'"
				
				// put the title line into excel
				ind_translator, row(`excel_row_c') col(`excel_col_c')
				putexcel $ul_cell = "`title'"
				
				// di second line (the column heading)
				local col_header_count = 0
				// for second line, add excel row count for 1
				local excel_row_c = `excel_row_c' + 1
				foreach col_h in `by_var_val' {
					// calculate appropriate identation for each column header
					// an identation is calculated based on basic identation for second column + identation factor per column * column number of each heading
					local col_sep_temp = `col_sep' + `col_header_count' * `col_fac'
					// adjust for the excel column counts to make sure it gets inputted to correct place
					local excel_col_c = `excel_col_c' + 1
					local col_s "_col(`col_sep_temp')"
					ind_translator, row(`excel_row_c') col(`excel_col_c')
					capture local col_level : label `col_lab_m' `col_h'
					noisily di `col_s' "`col_level'" _continue
					// output to excel cells
					putexcel $ul_cell = "`col_level'"
					// correctly counting for the header numbers
					local col_header_count = `col_header_count' + 1
				}
				// use this to stop _continue
				noisily di ""
				
				// reset col_header_count
				local col_header_count = 0
				// reset excel_col_c to 1 so that new lines can be inputted to first cell of each lines
				local excel_col_c = 1
				
				// the third line (N=xxx)
				// first set the excel row count to correct numbers
				local excel_row_c = `excel_row_c' + 1
				foreach col_h in `by_var_val' {
					// calculate correct identation
					local col_sep_temp = `col_sep' + `col_header_count' * `col_fac'
					local col_s "_col(`col_sep_temp')"
					// adjust for the excel column counts to make sure it gets inputted to correct place
					local excel_col_c = `excel_col_c' + 1
					count if `by' == `col_h' `if_helper'
					local col_count = r(N)
					noisily di `col_s' "N=`col_count'" _continue
					// output to excel cells
					ind_translator, row(`excel_row_c') col(`excel_col_c')
					putexcel $ul_cell = "N=`col_count'"
					local col_header_count = `col_header_count' + 1
				}
				// use this to stop _continue
				noisily di ""
				
				// for counting variables
				foreach v of varlist `cont' {
					 // reset header count
					 local col_header_count = 0
					 // count for excel row numbers
					 local excel_row_c = `excel_row_c' + 1
					 // reset excel_col_c to 1 so that new lines can be inputted to first cell of each lines
					 local excel_col_c = 1
					 // label name and displaying status
					 local row_lab_c: variable label `v'
					 // set format
					 local D %1.0f
					 // print variable name
					 noisily di "`row_lab_c'" _continue
					 // put variable name into cell
					 ind_translator, row(`excel_row_c') col(`excel_col_c')
					 putexcel $ul_cell = "`row_lab_c'"
					 // print for each column
					 foreach col_h in `by_var_val' {
						// get correct separation space
						local col_sep_temp = `col_sep' + `col_header_count' * `col_fac'
						local col_s "_col(`col_sep_temp')"
						// count for excel columns
						local excel_col_c = `excel_col_c' + 1
						// get median and IQR info
						quietly sum `v' if `by' == `col_h' `if_helper', detail
						// display each column
						local col_percent : di `D' r(p50) "[" ///
											`D' r(p25) "," ///
											`D' r(p75) "]"
						noisily di `col_s' "`col_percent'", _continue
						// output to excel for median & IQR
						ind_translator, row(`excel_row_c') col(`excel_col_c')
						putexcel $ul_cell = "`col_percent'"
						local col_header_count = `col_header_count' + 1
					 }
					// finish the line
					noisily di ""
				 }
				 
				 // for binary variables
				 foreach v of varlist `binary' {
					 // reset header count
					 local col_header_count = 0
					 // label name and displaying status
					 local row_lab_b: variable label `v'
					 // set format
					 local D %1.0f
					 // count for excel row numbers
					 local excel_row_c = `excel_row_c' + 1
					 // reset excel_col_c to 1 so that new lines can be inputted to first cell of each lines
					 local excel_col_c = 1
					 // put variable name into cell
					 ind_translator, row(`excel_row_c') col(`excel_col_c')
					 putexcel $ul_cell = "`row_lab_b'"
					 // print variable name
					 noisily di "`row_lab_b'" _continue
					 // print for each column
					 foreach col_h in `by_var_val' {
						// get correct separation space
						local col_sep_temp = `col_sep' + `col_header_count' * `col_fac'
						local col_s "_col(`col_sep_temp')"
						// count for excel columns
						local excel_col_c = `excel_col_c' + 1
						quietly sum `v' if `by' == `col_h' `if_helper', detail
						local percent: di `D' `col1' r(mean)*100 
						noisily di `D' `col_s' `percent', _continue
						// output to excel for median & IQR
						ind_translator, row(`excel_row_c') col(`excel_col_c')
						putexcel $ul_cell = "`percent'"
						local col_header_count = `col_header_count' + 1
					 }
					 noisily di ""
					 
				 }
				 
				 // for categorical variables
				 foreach v of varlist `multi' { 
					// set format
					 local D %1.0f
					local row_var_lab: variable label `v'
					local row_lab_m: value label `v'
					// get levels of the categorical variable
					levelsof `v'
					local var_level = r(levels)
					// count for excel row numbers
					local excel_row_c = `excel_row_c' + 1
					// reset excel_col_c to 1 so that new lines can be inputted to first cell of each lines
					local excel_col_c = 1
					// put variable name into cell
					ind_translator, row(`excel_row_c') col(`excel_col_c')
					putexcel $ul_cell = "`row_lab_m'"
					// display variable name
					noisily di "`row_var_lab'"
					// get value range in case some variables have extreme values like 0	 
					sum `v' `if', detail
					local v_min = r(min)
					local v_max = r(max)
					// loop from min to max
					forvalues v_val = `v_min'/`v_max' {
						// when loop from min to max, it is necessary to get rid off non-existing values
						// achieve this by count if the variable has the value or not
						count if `v' == `v_val' `if_helper'
						local v_level_count = r(N)
						if `v_level_count' != 0 {
							// reset header count
							local col_header_count = 0
							// reset excel_col_c to 1 so that new lines can be inputted to first cell of each lines
							local excel_col_c = 1
							// label name and displaying variable value
							local v_level: label `row_lab_m' `v_val'
							// count for excel row and output variable values
							local excel_row_c = `excel_row_c' + 1
							ind_translator, row(`excel_row_c') col(`excel_col_c')
							putexcel $ul_cell = "     `v_level'"
							noisily di _col(5) "`v_level'", _continue
							foreach col_h in `by_var_val' {
								// get correct separation space
								local col_sep_temp = `col_sep' + `col_header_count' * `col_fac'
								local col_s "_col(`col_sep_temp')"
								// count for excel colmns
								local excel_col_c = `excel_col_c' + 1
								count if `v'==`v_val' & `by' == `col_h' & !missing(`v') `if_helper'
								local num=r(N)
								count if `by' == `col_h' & !missing(`v') `if_helper'
								local t_num = r(N)
								local v_percent = `num' * 100 / `t_num'
								local v_percent2 : di `D' `v_percent'
								noisily di `D' `col_s' `v_percent', _continue
								// output to excel
								ind_translator, row(`excel_row_c') col(`excel_col_c')
								putexcel $ul_cell = "`v_percent2'"
								local col_header_count = `col_header_count' + 1
							}
							noisily di ""
						}					 
					}
				}
				
				// missing values
				local  oldvarname: di "`cont' `binary' `multi'"
				preserve
				rename (`oldvarname')(`foot')
				local missvar "`foot'"
				// a line spacer
				noisily di ""
				// put the line separator into excel
				local excel_col_c = 1
				local excel_row_c = `excel_row_c' + 1
				ind_translator, row(`excel_row_c') col(`excel_col_c')
				putexcel $ul_cell = ""
				foreach v of varlist `missvar' {
					noisily di "`v'", _continue
					// output variable name into excel
					local excel_row_c = `excel_row_c' + 1
					local excel_col_c = 1
					ind_translator, row(`excel_row_c') col(`excel_col_c')
					putexcel $ul_cell = "`v'"
					// reset col_header_count
					local col_header_count = 0
					foreach col_h in `by_var_val' {
						local col_sep_temp = `col_sep' + `col_header_count' * `col_fac'
						local col_s "_col(`col_sep_temp')"
						// count for excel col
						local excel_col_c = `excel_col_c' + 1
						count if `by' == `col_h'
						local denom = r(N)
						count if missing(`v') & `by' == `col_h'
						local neu = r(N)
						local per = `neu' / `denom' * 100
						local per2 : di %2.1f `per'
						// output to excel
						ind_translator, row(`excel_row_c') col(`excel_col_c')
						putexcel $ul_cell = "`per2'% missing"
						noisily di `col_s' %2.1f `per' "% missing", _continue
						local col_header_count = `col_header_count' + 1
					}
					noisily di ""
				}
				noisily di "`if'"
				local excel_row_c = `excel_row_c' + 1
				local excel_col_c = 1
				ind_translator, row(`excel_row_c') col(`excel_col_c')
				putexcel $ul_cell = "`if'"
				restore
			}
			
			
			
			
		}
		
		
		
		
		
	}
	
end
