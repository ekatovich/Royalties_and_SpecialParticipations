/*******************************************************************************
Construct quarterly panel of Special Participations transfers to municipalities

Last Modified: June 2, 2020

By: Erik Katovich

Table of Contents:
1. Import and clean csv files with data on special participations, which are distributed quarterly in February, May, August, and November
2. Append quarterly datasets into quarterly panel, clean and label
3. Merge special participations quarterly data with monthly royalties data
4. Construct annual panel of royalties and special participations; expand dataset to strongly balanced panel
*/


*Required datasets: 
*1. Quarterly Special Participations .csv files

*2. Brazil Geographical Codes .csv file: "brazil_geographical_codes.dta""


********************************************************************************
* 0 -Setup
********************************************************************************
clear all 

*Set working directory to file path that contains original .csv files
cd "$data/Raw/SpecialParticipations"


**************************************************************************************
* 1 - Import and clean csv files with data on special participations, which are distributed quarterly in February, May, August, and November
**************************************************************************************
*Define months as locals and loop over months and years to import, clean, and save each .csv file
local months "February May August November"
forvalues i=2000(1)2017{

	
	foreach j of local months {
	
		import delimited "sp_`j'_`i'.csv", varnames(1)
		
		gen year = 	`i'
		
		gen month = .
		replace month = 2 if "`j'" == "February"
		replace month = 5 if "`j'" == "May"
		replace month = 8 if "`j'" == "August"
		replace month = 11 if "`j'" == "November"
		
		gen quarter = .
		replace quarter = 1 if month == 2
		replace quarter = 2 if month == 5
		replace quarter = 3 if month == 8
		replace quarter = 4 if month == 11
		
		*Remove all accents and special characters from municipality using ustrnormalize:
		replace munic = ustrto(ustrnormalize(munic, "nfd"), "ascii", 2)	
		*Remove hyphens, apostrophes, and spaces	
		replace munic =subinstr(munic,"-","",.)
		replace munic =subinstr(munic,"'","",.)
		replace munic =subinstr(munic," ","",.)	
		*Convert all letters to uppercase
		replace munic = upper(munic)
		
		generate str uf = substr( munic, -2, .) 
		generate str munic_short = substr( munic , 1, strlen( munic) - 2) 

		*Generate numeric UF labels
		generate UF_NO = .
		replace UF_NO = 11 if uf == "RO"
		replace UF_NO = 12 if uf == "AC"
		replace UF_NO = 13 if uf == "AM"
		replace UF_NO = 14 if uf == "RR"
		replace UF_NO = 15 if uf == "PA"
		replace UF_NO = 16 if uf == "AP"
		replace UF_NO = 17 if uf == "TO"

		replace UF_NO = 21 if uf == "MA"
		replace UF_NO = 22 if uf == "PI"
		replace UF_NO = 23 if uf == "CE"
		replace UF_NO = 24 if uf == "RN"
		replace UF_NO = 25 if uf == "PB"
		replace UF_NO = 26 if uf == "PE"
		replace UF_NO = 27 if uf == "AL"
		replace UF_NO = 28 if uf == "SE"
		replace UF_NO = 29 if uf == "BA"

		replace UF_NO = 31 if uf == "MG"
		replace UF_NO = 32 if uf == "ES"
		replace UF_NO = 33 if uf == "RJ"
		replace UF_NO = 35 if uf == "SP"

		replace UF_NO = 41 if uf == "PR"
		replace UF_NO = 42 if uf == "SC"
		replace UF_NO = 43 if uf == "RS"

		replace UF_NO = 50 if uf == "MS"
		replace UF_NO = 51 if uf == "MT"
		replace UF_NO = 52 if uf == "GO"
		replace UF_NO = 53 if uf == "DF"
		

		*Generate unique municipality-state text identifier
		tostring UF_NO, replace
		egen municipality = concat(munic_short UF_NO) 
		drop munic munic_short uf
		destring UF_NO, replace
		
		*Clean numerical values to fix ,. confusion
		capture replace pe =subinstr(pe,".","",.)
		capture replace pe =subinstr(pe,",",".",.) 
		
		capture replace pe =subinstr(pe,"-","",.) 
		capture destring pe, replace
		
		*Save and clear for next file
		save "sp_`j'_`i'.dta", replace
		clear
		}
	}
	
	
**************************************************************************************
* 2 - Append quarterly datasets into panel; clean and label
**************************************************************************************
	
*Append all quarter-year files into long-format panel of Special Participations transfers to municipalities	
use "sp_February_2000.dta", clear
local months "February May August November"
forvalues i=2000(1)2017{

	foreach j of local months {
	
		append using "sp_`j'_`i'.dta", force
		}
}

*Organize data
order municipality UF_NO year month quarter pe
sort municipality year quarter
duplicates drop

*Deflate special participation values to constant 2010 reais using the IBGE Indice Nacional de Precos ao Consumidor:
*https://www.ibge.gov.br/estatisticas/economicas/precos-e-custos/9258-indice-nacional-de-precos-ao-consumidor.html?t=downloads
replace pe = (pe/47.19018421)*100 if year == 1999
replace pe = (pe/51.14760814)*100 if year == 2000
replace pe = (pe/53.93022184)*100 if year == 2001 
replace pe = (pe/59.19750637)*100 if year == 2002
replace pe = (pe/68.86416877)*100 if year == 2003
replace pe = (pe/74.79838452)*100 if year == 2004
replace pe = (pe/79.18080109)*100 if year == 2005 
replace pe = (pe/83.01981592)*100 if year == 2006 
replace pe = (pe/85.44880247)*100 if year == 2007
replace pe = (pe/90.03283452)*100 if year == 2008 
replace pe = (pe/95.82015899)*100 if year == 2009 
replace pe = (pe/100)*100 if year == 2010
replace pe = (pe/106.5285014)*100 if year == 2011
replace pe = (pe/112.5241619)*100 if year == 2012
replace pe = (pe/119.9852149)*100 if year == 2013
replace pe = (pe/126.2957795)*100 if year == 2014
replace pe = (pe/135.2948706)*100 if year == 2015
replace pe = (pe/150.5955657)*100 if year == 2016
replace pe = (pe/158.7811544)*100 if year == 2017

*Label variables
label variable municipality "Municipality Name"
label variable UF_NO "UF (State) Code"
label variable year "Year"
label variable month "Month"
label variable quarter "Quarter"
label variable pe "Special Participation (Constant 2010 Brazilian Reals)"


save "$data/Analysis/SpecialParticipations_QuarterlyPanel.dta", replace


**************************************************************************************
* 3 - Merge quarterly special participations panel with monthly royalties panel to construct 
   *balanced panel of all oil-related monetary transfers to municipalities for 1999 to 2017
**************************************************************************************

use "$data/Analysis/SpecialParticipations_QuarterlyPanel.dta", clear

*Correct naming mismatch to enable merge
*Municipality Augusto Severo in RN had two official names at this time
replace municipality = "CAMPOGRANDE24" if (municipality == "AUGUSTOSEVERO24")

merge 1:1 municipality year month using "$data/Analysis/Royalties_MonthlyPanel.dta"

sort municipality year month
drop _merge
drop if municipality == ""

*Set special participations to zero when they are not reported
replace pe = 0 if pe == .

*In months where special participations transfers occur, sum total royalties with special participations to get total monthly oil-related transfers
gen month_total = royalties_total
replace month_total = royalties_total + pe if pe != .


*Since special participations occur once per quarter, graphing cumulative royalties
*and special participations results in large quarterly spikes. To smooth visualizations
*compute quarterly moving average of total oil and gas related transfers
*Compute quarterly total oil and gas transfers and average oil and gas transfers
bysort municipality quarter: egen quarter_total = sum(month_total)
bysort municipality quarter: egen quarter_avg = mean(month_total)

*Generate a unique time ID for each year-month pair
gen time_id = ym(year, month)
format time_id %tm

*Define panel and time series variables
tsset munic_code time_id

*Compute a moving average of each month and the preceding and subsequent month's total receipts
generate moveave2 = (F1.month_total + month_total + L1.month_total) / 3

*Divide the moving average by 1,000,000 to make units easier to handle (millions of reals)
gen moveave1 = moveave2 / 1000000

drop quarter_total quarter_avg time_id moveave2

*Rename variables to improve comprehensibility
rename pe special_part
rename month_total oil_transfers_total 
rename moveave1 total_transfers_moving_avg

*Label variables 
label variable oil_transfers_total "Total Oil&Gas transfers to municipality (royalties + s.p.'s)"
label variable total_transfers_moving_avg "Quarterly moving avg. of total transfers"

order municipality UF_NO munic_code micro_code meso_code year quarter month ///
to_5 past_5 royalties_total cumulative_total special_part oil_transfers_total ///
total_transfers_moving_avg

save "$data/Analysis/Royalties_and_SpecialPart_MonthlyPanel_FINAL.dta", replace

******************************************************************************************
*4. Construct balanced annual panel of royalties and special participations
****************************************************************************************
use "$data/Analysis/Royalties_and_SpecialPart_MonthlyPanel_FINAL.dta", clear

sort municipality year month 

*Sum monthly and quarterly values to annual values
bysort municipality year: egen annual_royalties = sum(royalties_total)
bysort municipality year: egen annual_specialpart = sum(special_part)

*Keep only cumulative values
keep if month == 12

keep municipality UF_NO year annual_royalties annual_specialpart munic_code micro_code meso_code

*Generate oil_revenue, which captures total oil related income from both royalties and special participations
gen oil_revenue = annual_royalties + annual_specialpart

save "$data/Analysis/Royalties_and_SpecialPart_AnnualPanel_FINAL.dta", replace