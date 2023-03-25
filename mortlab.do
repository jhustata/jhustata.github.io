     lab def premiss .z "Missing"
     lab def eligfmt 1 "Eligible" 2 "Under age 18, not available for public release" 3 "Ineligible" 
     lab def mortfmt 0 "Assumed alive" 1 "Assumed deceased" .z "Ineligible or under age 18"
     #delimit ;
	 lab def flagfmt 0 "No - Condition not listed as a multiple cause of death" 
	                      1 "Yes - Condition listed as a multiple cause of death"	
						  .z "Assumed alive, under age 18, ineligible for mortality follow-up, or MCOD not available";
     lab def qtrfmt 1 "January-March" 
	                     2 "April-June" 
						 3 "July-September" 
						 4 "October-December" 
						 .z "Ineligible, under age 18, or assumed alive";
	 #delimit cr
     lab def dodyfmt .z "Ineligible, under age 18, or assumed alive"
     lab def ucodfmt 1 "Diseases of heart (I00-I09, I11, I13, I20-I51)"                           
     lab def ucodfmt 2 "Malignant neoplasms (C00-C97)"                                            , add
     lab def ucodfmt 3 "Chronic lower respiratory diseases (J40-J47)"                             , add
     lab def ucodfmt 4 "Accidents (unintentional injuries) (V01-X59, Y85-Y86)"                    , add
     lab def ucodfmt 5 "Cerebrovascular diseases (I60-I69)"                                       , add
     lab def ucodfmt 6 "Alzheimer's disease (G30)"                                                , add
     lab def ucodfmt 7 "Diabetes mellitus (E10-E14)"                                              , add
     lab def ucodfmt 8 "Influenza and pneumonia (J09-J18)"                                        , add
     lab def ucodfmt 9 "Nephritis, nephrotic syndrome and nephrosis (N00-N07, N17-N19, N25-N27)"  , add
     lab def ucodfmt 10 "All other causes (residual)"                                             , add
     lab def ucodfmt .z "Ineligible, under age 18, assumed alive, or no cause of death data"      , add
	 
	 
	 replace mortstat = .z if mortstat >=.
     replace ucod_leading = .z if ucod_leading >=.
     replace diabetes = .z if diabetes >=.
     replace hyperten = .z if hyperten >=.
     replace permth_int = .z if permth_int >=.
     replace permth_exm = .z if permth_exm >=.
	
	
	 //3.define
	 
     label var seqn "NHANES Respondent Sequence Number"
     label var eligstat "Eligibility Status for Mortality Follow-up"
     label var mortstat "Final Mortality Status"
     label var ucod_leading "Underlying Cause of Death: Recode"
     label var diabetes "Diabetes flag from Multiple Cause of Death"
     label var hyperten "Hypertension flag from Multiple Cause of Death"
     label var permth_int "Person-Months of Follow-up from NHANES Interview date"
     label var permth_exm "Person-Months of Follow-up from NHANES Mobile Examination Center (MEC) Date"

     label values eligstat eligfmt
     label values mortstat mortfmt
     label values ucod_leading ucodfmt
     label values diabetes flagfmt
     label values hyperten flagfmt
     label value permth_int premiss
     label value permth_exm premiss
