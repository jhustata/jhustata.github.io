qui {
	
	if 1 { //settings,logfile,macros
	
		timer on 1
		
		cls
		clear
		version 12 
        capture log close
        global date: di %td date(c(current_date),"DMY")
		
        log using "nh.dfs.log", replace

        global nh3 https://wwwn.cdc.gov/nchs/data/nhanes3/1a/
        global nhanes "https://wwwn.cdc.gov/Nchs/Nhanes" 
	    global github https://raw.githubusercontent.com/
	    global adultdo jhustata/jhustata.github.io/main/adult.do
	    global examdo jhustata/jhustata.github.io/main/exam.do
	    global labdo jhustata/jhustata.github.io/main/lab.do
        global start = clock(c(current_time),"hms")/10^3
        
		global continuous "1999 2001 2003 2005 2007 2009 2011 2013 2015 2017"
       
	    global nchs https://ftp.cdc.gov/pub/Health_Statistics/NCHS/
        global linkage datalinkage/linked_mortality/
	    global nh3 NHANES_III
        global mort _MORT_2019_PUBLIC.dat
		global mortlab https://raw.githubusercontent.com/jhustata/jhustata.github.io/main/mortlab.do

		#delimit ;
        global varlist  
           seqn 1-6  
           eligstat 15  
	       mortstat 16  
	       ucod_leading 17-19  
           diabetes 20  
	       hyperten 21  
	       permth_int 43-45  
	       permth_exm 46-48 ;
	    #delimit cr
     
	    global nhfiles nhdemo nhdiet nhexam nhlab nhqa nhmort
		timer off 1
	}
	
	if 2 { //1988-1994: q&a,exam,lab
		
		timer on 2
		
	    noi di "infix... 1988-1994/ADULT.DAT" 
		clear 
        do $github$adultdo
        tempfile qa 
	    rename *, lower
        save `qa'  
        
		noi di "infix... 1988-1994/EXAM.DAT" 
		clear 
        do $github$examdo
        tempfile exam
	    rename *,lower
        save `exam'
     
	    noi di "infix... 1988-1994/LAB.DAT" 
		clear 
	    do $github$labdo
        tempfile lab
	    rename *,lower
        save `lab'

        use `qa', clear 
        merge 1:1 seqn using `exam', nogen
        merge 1:1 seqn using `lab', nogen 
	 	  
        gen surv=1
	    tempfile surv1
		replace seqn=seqn*-1
        save `surv1' 
	 
	    timer off 2
		
	}
	
	if 3 { //1999-2018: demo,append
		
		timer on 3
		
		tokenize "`c(ALPHA)'"  
	    local Letter=1  
        local N=2   
		
		foreach y of numlist $continuous {
			
			local yplus1=`y' + 1
			
		    if `y' == 1999 {
				local letter: di ""
			   }
		
		    if `y' >= 2001 {
				local letter: di "_``Letter''"  
		       }
			   
			import sasxport5 "$nhanes/`y'-`yplus1'/DEMO`letter'.XPT", clear 
			 
	        noi di "import... `y'-`yplus1' from $nhanes: demo"
	        tempfile surv`N'
		    gen surv=`N'
            save `surv`N'' 
	        local N=`N' + 1
	        local Letter=`Letter' + 1
			   
		   }
		   
		forvalues i=1/11 {
			
			 noi di "append... demo `i'"
			 append using `surv`i''
			 
		}
		
	noi di "compress..."
	compress
	local sample=100
	sample `sample'
	lab dat "`sample'% of NHANES 1988-2018, Demographics"

	save "nhdemo", replace 
		
	timer off 3
		
	}
	
	if 4 { //1999-2018: diet,append
		
		timer on 4
		
		tokenize "`c(ALPHA)'"  
	    local Letter=1 
        local N=2 
		
		foreach y of numlist $continuous {
			
			local yplus1=`y' + 1
			
		    if `y' == 1999 {
				local letter: di ""
				local filename: di "DRXTOT"
			   }
		
		    if `y' == 2001 {
				local letter: di "_``Letter''"  
				local filename: di "DRXTOT"
		       }
			   
		    if `y' >= 2003 {
				local letter: di "_``Letter''"  
				local filename: di "DR1TOT"
		       }
			   
			import sasxport5 "$nhanes/`y'-`yplus1'/`filename'`letter'.XPT", clear 
			 
	        noi di "import... `y'-`yplus1' from $nhanes: diet"
	        tempfile surv`N'
		    gen surv=`N'
            save `surv`N'' 
	        local N=`N' + 1
	        local Letter=`Letter' + 1
			   
		   }
		   
		forvalues i=1/11 {
			
			 noi di "append... diet `i'"
			 append using `surv`i''
			 
		}
		
	noi di "compressing..."
	compress
	local sample=100
	sample `sample'
	lab dat "`sample'% of NHANES 1988-2018, Diet"

	save "nhdiet", replace 
		
	timer off 4
		
	}
	
	if 5 { //1999-2018: exam,append
		
		timer on 5
		
		tokenize "`c(ALPHA)'"  
	    local Letter=1
        local N=2   

		foreach y of numlist $continuous {
			
			global y=`y'
			global yplus1=$y + 1

			forvalues j=1/2 {
				
				local DATA BPX BMX
				
		        if $y == 1999 {   
					local letter: di ""
			    }

		        if $y >= 2001 {
				    local letter: di "_``Letter''"  
		        }
				
			    local DATA: di word("`DATA'",`j')
				
				import sasxport5 "$nhanes/$y-$yplus1/`DATA'`letter'.XPT", clear 
		        noi di "import... $y-$yplus1/`DATA'`letter'.XPT: exam"
                tempfile dat$y`j'
                save `dat$y`j'' 
			
			}
			
		local Letter=`Letter'+1
			   
		}
		   
		foreach y of numlist $continuous {
			
			append using `dat`y'1'
			noi di "append... exam `y' BPX"
			duplicates drop seqn, force 
			
		}
			
		foreach y of numlist $continuous {
			
			merge 1:1 seqn using `dat`y'2', nogen
			noi di "merge... exam `y' BMX"
			
		}
			
	noi di "compressing..."
	compress
	local sample=100
	sample `sample'
	lab dat "`sample'% of NHANES 1988-2018, Exam"
	save "nhexam", replace
		
	timer off 5	 
	
	}
	
	if 6 { //1999-2018: lab,append
		
		timer on 6
		
		tokenize "`c(ALPHA)'"  
	    local Letter=1
        local N=2   

		foreach y of numlist $continuous {
			
			global y=`y'
			global yplus1=$y + 1

			forvalues j=1/4 {
				local DATA1 LAB16  LAB10 LAB10AM LAB18 
				local DATA2 L16    L10   L10AM   L40
				local DATA3 ALB_CR GHB   GLU     BIOPRO

		        if $y == 1999 {
					local letter: di ""

					local DATA: di "`DATA1'"

			    }
				
				if inlist($y, 2001, 2003) {
					local letter: di "_``Letter''"
					local DATA: di "`DATA2'"
				}

		        if $y >= 2005 { 
				    local letter: di "_``Letter''"  
					local DATA: di "`DATA3'"
		        }

			    local DATA: di word("`DATA'",`j')

				import sasxport5 "$nhanes/$y-$yplus1/`DATA'`letter'.XPT", clear 
				
		        noi di "import... $y-$yplus1/`DATA'`letter'.XPT: lab"
                tempfile dat$y`j'
                save `dat$y`j'' 
			
			}
			
			local Letter=`Letter'+1
			   
		}
		   
		foreach y of numlist $continuous {
			
			append using `dat`y'1'
			noi di "`y'"
			
			}

		duplicates drop seqn, force 
		
		foreach y of numlist $continuous {
			
			forvalues j=2/4{
				
				merge 1:1 seqn using `dat`y'`j'', nogen

			}
			
		}
				
		noi di "compressing..."
	    compress
	    local sample=100
	    sample `sample'
	    lab dat "`sample'% of NHANES 1988-2018, Labs"
	    noi save "nhlab", replace 
	    timer off 6		
		
		}
		
	if 7 { //1999-2018: q&a,append
		
		timer on 7
		
		tokenize "`c(ALPHA)'"  
	    local Letter=1
        local N=2   

		foreach y of numlist $continuous {
			
			global y=`y'
			global yplus1=$y + 1

			forvalues j=1/9 {
				local DATA1 BPQ CDQ HSQ DIQ HIQ KIQ   MCQ PAQ SMQ
				local DATA2 BPQ CDQ HSQ DIQ HIQ KIQ_U MCQ PAQ SMQ

		        if $y == 1999 {
					local letter: di ""

					local DATA: di "`DATA1'"

			    }

		        if $y >= 2001 { 
				    local letter: di "_``Letter''"  
					local DATA: di "`DATA2'"
		        }

			    local DATA: di word("`DATA'",`j')

				import sasxport5 "$nhanes/$y-$yplus1/`DATA'`letter'.XPT", clear 
				
		        noi di "import... $y-$yplus1/`DATA'`letter'.XPT: q&a"
                save dat$y`j', replace 
			
			}
			
			local Letter=`Letter'+1
			   
		}
		    
			clear 
		foreach y of numlist $continuous {
			
			global y=`y'
			append using "dat${y}1"
			rm "dat${y}1.dta"
			
			}

		duplicates drop seqn, force 
		
		foreach y of numlist $continuous {
			
			global y=`y'
			forvalues j=2/9{
				
				merge 1:1 seqn using "dat${y}`j'", nogen
			    rm "dat${y}`j'.dta"

			}
			
		}
				
		noi di "compressing..."
	    compress
	    local sample=100
	    sample `sample'
	    lab dat "`sample'% of NHANES 1988-2018, q&a"
	    noi save "nhqa", replace 
	    timer off 7
		
	}
	
	if 8 { //mortality: 1988-2018
		
		timer on 8
		
		infix $varlist using $nchs$linkage$nh3$mort, clear
		replace seqn=-1*seqn
		tempfile dat0
		save `dat0'
		local N=1
		foreach y of numlist $continuous {
			local yplus1=`y' + 1  
         	
	        local nhanes NHANES_`y'_`yplus1'
            infix $varlist using $nchs$linkage`nhanes'$mort, clear
	        tempfile dat`N'
	        save `dat`N''
	        local N=`N'+1
			
		}
		
		use `dat0', clear
        forvalues i=1/10 {
	       append using `dat`i''
        }
		
		do $mortlab
		drop if inlist(eligstat,2,3)
		duplicates drop 
		
		lab dat "NHANES 1988-2018, mortality"
		noi save "nhmort", replace 
		timer off 9
		
	}

	if 9 { //merge files: blocks 3-7

		timer on 9
		local dat: di word("$nhfiles",1)
		use `dat',clear 
		forvalues i=2/6 {
		   local dat: di word("$nhfiles",`i')
		   duplicates drop seqn,force
		   merge 1:m seqn using `dat',nogen
		   noi di word("$nhfiles",`i')
		   duplicates drop seqn,force 
		}
		
        save nhdataset,replace 
		timer off 9
		noi di "obs `c(N)', vars `c(k)'"
		noi timer list 
		timer clear 
        global finish  = clock(c(current_time),"hms")/10^3
        global duration = round(($finish - $start)/60,1)
        noi di "runtime = $duration minute(s)"		
		log close 
	}

}
