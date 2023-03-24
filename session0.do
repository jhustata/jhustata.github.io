qui {
	
	if 1 { //settings,logfile,macros
	
	    cls 
		clear 
		
		capture log close 
		log using session0.log, replace 
		
		global url https://wwwn.cdc.gov/Nchs/Nhanes/1999-2000/
		global datafile DEMO.XPT 
		
		
	}
	
	if 2 { //import datafile
		
		import sasxport5 "${url}${datafile}", clear
		noi di "no of vars `c(k)' x " " no of obs " _N
	}
	
}
