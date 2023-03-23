qui {
	
	if 0 { //import adult.sas 
       
	   global url https://wwwn.cdc.gov/nchs/data/nhanes3/1a/
	   cls 
	   import delimited "${url}adult.sas", clear 
		
	}
	
	if 0 { //split, concatenate
		
		drop v2
		drop in 1/5
		drop in 1/1381
		
		preserve
		   keep in 1/1238
		   split v1, p(" ")
		   g v2 = v12+v13+v14+v15+v16
		   keep v11 v2
		   gen v3= " ///"
		   outfile using "adultinfix.do", replace  
		restore 
		
		drop in 1/1238
		split v1, p("=")
		g v2="lab var   "
		keep v11 v2 v12
		order v11 v2 v12
		format v12 %-10s
		drop in 1/2
		drop in 1239
		order v2 v11 v12
        outfile using "adultlabvar.do", noquote replace	 	
	}
	
	if 0 { //edit, find, replace 
		
		//adultinfix.do 
		//find: ", replace:
		//edit: infix ... using adult.dat 
		
		//adultlabvar.do
		//find: """", replace ??
		//find: " ", replace ??
		//find: ", replace:
		//find: ??, replace: "
		
	}
	
	if 4 { //after edit, do 
	
		do adultinfix.do 
		do adultlabvar.do
		
	}
	
	if 5 {
		
		lab data "NHANES III, adult"
		save "adult.sas2stata", replace 
		
	}

}
