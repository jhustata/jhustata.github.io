qui {
	
	if 1 { //settings,logfile,macros
		
		cls
		clear 
		
		capture log close 
		log using adultlab.log, replace 
		
		
        global url https://wwwn.cdc.gov/nchs/data/nhanes3/1a/ 
		global sasprogram adult.sas
		global datafile adult.dat
		
	}
	
	if 2 { //import .sas read-in commands
		
		import delimited ${url}$sasprogram


	}
	
	if 3 { //output .do file read-in commands  
		
		
		preserve 
		   keep in 1387/2624
		   split v1, p(" ")
		   g v3=v12+v13+v14+v15+v16
		   format v11 %-5s
		   format v3 %-5s
		   keep v11 v3
		   g id=_n+2
		   insobs 1
		   replace v11="#delimit ;" in `c(N)'
		   insobs 1
		   replace v11="infix" in `c(N)'
		   insobs 1
		   replace v11="using ${url}$datafile ;" in `c(N)'
		   insobs 1
		   replace v11="#delimit cr" in `c(N)'
		   replace id=1 if v11=="#delimit ;"
		   replace id=2 if v11=="infix"
		   replace id=`c(N)' if v11=="using ${url}$datafile ;"
		   replace id=id-1 if v11=="using ${url}$datafile ;"
		   replace id=`c(N)' if v11=="#delimit cr"
		   sort id
		   drop id
		   outfile using "adultvar.do", noquote replace
		restore 
		
		keep in 2627/3865
	    split v1, p("=")
		format v12 %-20s
	    gen v3="lab var"
	    order v3 v11 v12
	    keep v3 v11 v12	
	    drop in `c(N)'
    	outfile using "adultlab.do", noquote replace
		
		log close 
		
	}
	
}
