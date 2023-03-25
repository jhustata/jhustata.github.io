qui {
	
	if 1 { //settings,logfile,macros
		
		cls
		clear 
		
		capture log close 
		log using ael.log, replace 
		
		
        global url https://wwwn.cdc.gov/nchs/data/nhanes3/1a/ 
		global fyl adult exam lab 
		global range 1387/2624 2627/3865 2892/5259 5262/7629 640/995 998/1353 
		
	}
	
	if 2 { //translate .sas -> .do
		
		local range=1
		forvalues i=1/3 { 

		   if 2.2 { //import .sas read-in commands
		   	
				local file: di word("$fyl",`i')
		        import delimited using "${url}`file'.sas",clear
				noi di "import delimited using ${url}`file'.sas"

		   }

		   if 2.3 { //export .do read-in commands
		       preserve 
                  local num: di word("$range",`range')
		          keep in `num'
			      local range=`range'+1		          
				  keep v1
		          g id=_n+2
		          insobs 1
		          replace v1="#delimit ;" in `c(N)'
		          insobs 1
		          replace v1="infix" in `c(N)'
		          insobs 1
		          replace v1="using ${url}`file'.dat ;" in `c(N)'
		          insobs 1
		          replace v1="#delimit cr" in `c(N)'
		          replace id=1 if v1=="#delimit ;"
		          replace id=2 if v1=="infix"
		          replace id=`c(N)' if v1=="using ${url}`file'.dat ;"
		          replace id=id-1 if v1=="using ${url}`file'.dat ;"
		          replace id=`c(N)' if v1=="#delimit cr"
		          sort id
		          drop id
		          tempfile vars
		          format v1 %-20s
		          rename v1 concat 
		          keep concat 
		          save `vars'
		       restore 
		       
               local num: di word("$range",`range')
		       keep in `num'
			   local range=`range'+1
	           split v1, p(" = ")
	           gen concat="lab var "+v11+" "+v12
		       keep concat 
		       format concat %-20s
	           drop in `c(N)'
		       tempfile labs
		       save `labs'

		       use `vars', clear
		       append using `labs'
    	       noi outfile using "`file'.do", noquote replace
			   noi di "outfile using `file'.do"
			    
			
		   }
		   
		} 
		
		log close 
	}
	
}
