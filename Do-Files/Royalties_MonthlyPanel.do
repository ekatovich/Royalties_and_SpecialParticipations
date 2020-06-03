/*******************************************************************************
Constructing Monthly Panel of Municipal Oil Royalties Transfers

Last Modified: June 2, 2020

By: Erik Katovich

Table of Contents:
1) Import month-year .csv files with municipal royalty transfers, clean, save as .dta
2) Append all month-year files into long panel (1999-2017), clean, label, deflate
3) Attach municipality/microregion/mesoregion codes 
4) Create balanced monthly royalty panel
5) Clean and save balanced yearly panel
*/


********************************************************************************
* 0 -Setup
********************************************************************************
clear all 

*Set working directory to file path that contains original .csv files
cd "$data/Raw/Royalties"


********************************************************************************
* 1 - Import month-year .csv files, clean, save as .dta
********************************************************************************

*Define months as locals; loop through all months and years
local months "January February March April May June July August September October November December"
forvalues i=1999(1)2017{

	
	foreach j of local months {
	
		import delimited "Royalties_`j'_`i'.csv"

			*Drop observations that contain problematic text strings. These strings appear 
			*because data were extracted from multiple-paged PDF >> Excel >> csv and contain
			*remnants of page headers and footnotes
			forvalues m=1(1)40{
			capture drop if strpos(v`m',"Superintendência")>0
			capture drop if strpos(v`m',"Participações")>0
			capture drop if strpos(v`m',"Controle")>0
			capture drop if strpos(v`m',"Valor sem a retenção de 1% (um por cento) de PASEP")>0
			capture drop if strpos(v`m',"parágrafo")>0
			capture drop if strpos(v`m',"Medida Provisória")>0
			capture drop if strpos(v`m',"n.º2.158")>0
			capture drop if strpos(v`m',",,")>0
			capture drop if strpos(v`m',"1%")>0
			capture drop if strpos(v`m',"um por cento")>0
			}
		
		*Drop all columns that only have missing variables
		dropmiss *, force

		*Rename remaning variables
		rename (v#) (v1 v2 v3 v4 v5 v6)
		rename v1 munic_uf
		rename v2 uf 
		rename v3 to_5 
		rename v4 past_5
		rename v5 royalties_total
		rename v6 cumulative_total
		
		*Drop observations that contain state-level totals. These observations all have "uf" missing
		drop if uf == ""
		
		gen year = 	`i'
		
		gen month = .
		replace month = 1 if "`j'" == "January"
		replace month = 2 if "`j'" == "February"
		replace month = 3 if "`j'" == "March"
		replace month = 4 if "`j'" == "April"
		replace month = 5 if "`j'" == "May"
		replace month = 6 if "`j'" == "June"
		replace month = 7 if "`j'" == "July"
		replace month = 8 if "`j'" == "August"
		replace month = 9 if "`j'" == "September"
		replace month = 10 if "`j'" == "October"
		replace month = 11 if "`j'" == "November"
		replace month = 12 if "`j'" == "December"
		
		*Quarterly data will be relevant when merging monthly royalties with quarterly Special Participations
		gen quarter = .
		replace quarter = 1 if month == 1
		replace quarter = 1 if month == 2
		replace quarter = 1 if month == 3
		replace quarter = 2 if month == 4
		replace quarter = 2 if month == 5
		replace quarter = 2 if month == 6
		replace quarter = 3 if month == 7
		replace quarter = 3 if month == 8
		replace quarter = 3 if month == 9
		replace quarter = 4 if month == 10
		replace quarter = 4 if month == 11
		replace quarter = 4 if month == 12

		*Begin standard cleaning of municipal strings. This cleaning procedure is used for all datasets
		*Remove all accents and special characters from municipality using ustrnormalize:
		replace munic_uf = ustrto(ustrnormalize(munic_uf, "nfd"), "ascii", 2)	
		*Remove hyphens, apostrophes, and spaces	
		replace munic_uf =subinstr(munic_uf,"-","",.)
		replace munic_uf =subinstr(munic_uf,"'","",.)
		replace munic_uf =subinstr(munic_uf," ","",.)	
		*Convert all letters to uppercase
		replace munic_uf = upper(munic_uf)

		*Identify problematic .csv files, which either lack -UF on end of municipality strings
		*or have exceptions to the standard ., usage
		gen problem_uf = 0
		replace problem_uf = 1 if year == 2000 & month == 11
		replace problem_uf = 1 if year == 2003
		replace problem_uf = 1 if year == 2004 & (month < 10)
		gen problem_commas = 0 
		replace problem_commas = 1 if year == 2000 & month == 11
		
		*Remove -UF suffix from municipal strings
		generate str munic = substr( munic_uf , 1, strlen( munic_uf) - 2) if problem_uf != 1
		replace munic = munic_uf if problem_uf == 1

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
		egen municipality = concat(munic UF_NO) 
		drop munic munic_uf problem_uf uf

		*Define locals as all royalty value variables and loop through them to clean and destring
		local vars "to_5 past_5 royalties_total cumulative_total"
		foreach k of local vars {
		replace `k' =subinstr(`k',".","",.) if year != 2016 & year != 2017 & problem_commas == 0
		replace `k' =subinstr(`k',",",".",.) if year != 2016 & year != 2017 & problem_commas == 0
		replace `k' =subinstr(`k',",","",.) if year == 2016 | year == 2017 | problem_commas == 1
		replace `k' =subinstr(`k',"-","",.) 
		destring `k', replace
		} 
		
		*Save and clear for next file
		save "Royalties_`j'_`i'.dta", replace
		clear
		}
		
}		



********************************************************************************
* 2 - Append month-year .dta files into long panel (1999-2017)
********************************************************************************

*Append all year-month .dta files into long panel
use "Royalties_January_1999.dta", clear
local months "January February March April May June July August September October November December"
forvalues i=1999(1)2017{

	foreach j of local months {
	
		append using "Royalties_`j'_`i'.dta", force
		}
}

*Organize data
order municipality UF_NO year month quarter 
sort municipality year month
duplicates drop
drop if municipality == "."
destring UF_NO, replace

*Label variables
label variable to_5 "Monthly Royalties up to 5% tax rate (R$)"
label variable past_5 "Monthly Royalties beyond 5% tax rate (R$)"
label variable royalties_total "Total Monthly royalties, up to 5% + beyond 5%"
label variable cumulative_total "Cumulative Total Royalties in year since January"

drop problem_commas 


*Drop observations that report state totals
local state_totals "TOTALAMAZONAS13 TOTALSERGIPE28 TOTALRIOGRANDEDOSUL43 TOTALRIOGRANDEDONORTE24 TOTALPARA15 TOTALMINASGERAIS31 TOTALCEARA23 TOTALBAHIA29 TOTALAMAPA16 TOTALESPIRITOSANTO32 TOTALPARANA41 TOTALRIODEJANEIRO33 TOTALALAGOAS27 TOTALSAOPAULO35 TOTALSANTACATARINA42 TOTALMINASGERAIS31"
foreach i of local state_totals {

drop if municipality == "`i'"

}

*Deflate monetary values to constant 2010 reais using the IBGE Indice Nacional de Precos ao Consumidor:
*https://www.ibge.gov.br/estatisticas/economicas/precos-e-custos/9258-indice-nacional-de-precos-ao-consumidor.html?t=downloads
local royalty_vars "to_5 past_5 royalties_total cumulative_total"
foreach i of local royalty_vars {

replace `i' = (`i'/47.19018421)*100 if year == 1999
replace `i' = (`i'/51.14760814)*100 if year == 2000
replace `i' = (`i'/53.93022184)*100 if year == 2001 
replace `i' = (`i'/59.19750637)*100 if year == 2002
replace `i' = (`i'/68.86416877)*100 if year == 2003
replace `i' = (`i'/74.79838452)*100 if year == 2004
replace `i' = (`i'/79.18080109)*100 if year == 2005 
replace `i' = (`i'/83.01981592)*100 if year == 2006 
replace `i' = (`i'/85.44880247)*100 if year == 2007
replace `i' = (`i'/90.03283452)*100 if year == 2008 
replace `i' = (`i'/95.82015899)*100 if year == 2009 
replace `i' = (`i'/100)*100 if year == 2010
replace `i' = (`i'/106.5285014)*100 if year == 2011
replace `i' = (`i'/112.5241619)*100 if year == 2012
replace `i' = (`i'/119.9852149)*100 if year == 2013
replace `i' = (`i'/126.2957795)*100 if year == 2014
replace `i' = (`i'/135.2948706)*100 if year == 2015
replace `i' = (`i'/150.5955657)*100 if year == 2016
replace `i' = (`i'/158.7811544)*100 if year == 2017

}



********************************************************************************
* 3 - Attach municipality/microregion/mesoregion codes
********************************************************************************

*Correct types and name changes in municipality names to improve merging on names
replace municipality = "BALNEARIOPICARRAS42" if (municipality == "PICARRAS42")
replace municipality = "CASTROALVES29" if (municipality == "ASTROALVES29")
replace municipality = "BALNEARIOPICARRAS42" if municipality == "PICARRAS42"
replace municipality = "PARATI33" if municipality == "PARATY33"
replace municipality = "TRAJANODEMORAIS33" if municipality == "TRAJANODEMORAES33"
replace municipality = "PRESIDENTECASTELOBRANCO42" if municipality == "PRESIDENTECASTELLOBRANCO42"
replace municipality = "COUTOMAGALHAES17" if municipality == "COUTODEMAGALHAES17"
replace municipality = "MOGIDASCRUZES35" if municipality == "MOJIDASCRUZES35"
replace municipality = "LAGOADOITAENGA26" if municipality == "LAGOADEITAENGA26" 
replace municipality = "BELEMDESAOFRANCISCO26" if municipality == "BELEMDOSAOFRANCISCO26"
replace municipality = "ILHADEITAMARACA26" if municipality == "ITAMARACA26"
replace municipality = "ITABIRINHA31" if municipality == "ITABIRINHADEMANTENA31"
replace municipality = "SAOVALERIO17" if municipality == "SAOVALERIODANATIVIDADE17"
replace municipality = "AROEIRASDOITAIM22" if municipality == "AROEIRASDEITAIM22"
replace municipality = "SAOMIGUELDOGOSTOSO24" if municipality == "SAOMIGUELDETOUROS24"
replace municipality = "SAODOMINGOS25" if municipality == "SAODOMINGOSDEPOMBAL25"
replace municipality = "TACIMA25" if municipality == "CAMPODESANTANA25"
replace municipality = "GOVERNADORLOMANTOJUNIOR29" if municipality == "BARROPRETO29"
replace municipality = "ALTOPARAISO41" if municipality == "VILAALTA41"
replace municipality = "ASSU24" if municipality == "ACU24"
replace municipality = "AGUADOCEDOMARANHAO21" if municipality == "AGUADOCE21"
replace municipality = "ALAGOINHADOPIAUI22" if municipality == "ALAGOINHA22"
replace municipality = "ALMEIRIM15" if municipality == "ALMERIM15"
replace municipality = "AMPARODESAOFRANCISCO28" if municipality == "AMPARODOSAOFRANCISCO28"
replace municipality = "BADYBASSITT35" if municipality == "BADYBASSIT35"
replace municipality = "BALNEARIOBARRADOSUL42" if municipality == "BALNEARIODEBARRADOSUL42"
replace municipality = "BALNEARIOCAMBORIU42" if municipality == "BALNEARIODECAMBORIU42"
replace municipality = "BARAUNA25" if municipality == "BARAUNAS25"
replace municipality = "BELAVISTADOMARANHAO21" if municipality == "BELAVISTA21"
replace municipality = "BERNARDINODECAMPOS35" if municipality == "BERNADINODECAMPOS35"
replace municipality = "CABODESANTOAGOSTINHO26" if municipality == "CABO26"
replace municipality = "CAMPOGRANDE24" if municipality == "AUGUSTOSEVERO24"
replace municipality = "CAMPOSDOSGOYTACAZES33" if municipality == "CAMPOS33"
replace municipality = "CANINDEDESAOFRANCISCO28" if municipality == "CANINDEDOSAOFRANCISCO28"
replace municipality = "CONSELHEIROMAIRINCK41" if municipality == "CONSELHEIROMAYRINCK41"
replace municipality = "DEPUTADOIRAPUANPINHEIRO23" if municipality == "DEPIRAPUANPINHEIRO23"
replace municipality = "DIAMANTEDOESTE41" if municipality == "DIAMANTEDOOESTE41"
replace municipality = "ELDORADODOSCARAJAS15" if municipality == "ELDORADODOCARAJAS15"
replace municipality = "EMBUDASARTES35" if municipality == "EMBU35"
replace municipality = "EUSEBIO23" if municipality == "EUZEBIO23"
replace municipality = "FERNANDOPEDROZA24" if municipality == "FERNANDOPEDROSA24"
replace municipality = "FLORINIA35" if municipality == "FLORINEA35"
replace municipality = "GOVERNADOREDISONLOBAO21" if municipality == "GOVERNADOREDSONLOBAO21"
replace municipality = "GRACHOCARDOSO28" if municipality == "GRACCHOCARDOSO28"
replace municipality = "GRANJEIRO23" if municipality == "GRANGEIRO23"
replace municipality = "HERVALDOESTE42" if municipality == "HERVALDOOESTE42"
replace municipality = "ITAGUAJE41" if municipality == "ITAGUAGE41"
replace municipality = "ITAPEJARADOESTE41" if municipality == "ITAPEJARADOOESTE41"
replace municipality = "JABOATAODOSGUARARAPES26" if municipality == "JABOATAO26"
replace municipality = "LAGEADOGRANDE42" if municipality == "LAGEADOGRANDE42"
replace municipality = "LUIZALVES42" if municipality == "LUISALVES42"
replace municipality = "LUISDOMINGUESDOMARANHAO21" if municipality == "LUISDOMINGUES21"
replace municipality = "LUIZIANIA35" if municipality == "LUISIANIA41"
replace municipality = "MOJIMIRIM35" if municipality == "MOGIMIRIM35"
replace municipality = "MOREIRASALES41" if municipality == "MOREIRASALLES41"
replace municipality = "MUNHOZDEMELO41" if municipality == "MUNHOZDEMELLO41"
replace municipality = "MUQUEMDESAOFRANCISCO29" if municipality == "MUQUEMDOSAOFRANCISCO29"
replace municipality = "PATYDOALFERES33" if municipality == "PATIDOALFERES33"
replace municipality = "QUIJINGUE29" if municipality == "QUINJINGUE29"
replace municipality = "SALMOURAO35" if municipality == "SALMORAO35"
replace municipality = "SANTANADOITARARE41" if municipality == "SANTAANADOITARARE41"
replace municipality = "SANTACRUZDEMONTECASTELO41" if municipality == "SANTACRUZDOMONTECASTELO41"
replace municipality = "SANTAISABELDOIVAI41" if municipality == "SANTAIZABELDOIVAI41"
replace municipality = "SANTAISABELDOPARA15" if municipality == "SANTAIZABELDOPARA15"
replace municipality = "SANTAMARIADEJETIBA32" if municipality == "SANTAMARIADOJETIBA32"
replace municipality = "SANTATERESINHA29" if municipality == "SANTATEREZINHA29"
replace municipality = "SANTOANTONIODEPOSSE35" if municipality == "SANTOANTONIODAPOSSE35"
replace municipality = "SAOCAETANO26" if municipality == "SAOCAITANO26"
replace municipality = "SAODOMINGOSDONORTE32" if municipality == "SAODOMINGOS32"
replace municipality = "SAOJOSEDOCAMPESTRE24" if municipality == "SAOJOSEDECAMPESTRE24"
replace municipality = "SAOJOSEDOBREJODOCRUZ25" if municipality == "SAOJOSEDOBREJOCRUZ25"
replace municipality = "SAOLUIZGONZAGA43" if municipality == "SAOLUISGONZAGA43"
replace municipality = "SAORAIMUNDODODOCABEZERRA21" if municipality == "SAORAIMUNDODADOCABEZERRA21"
replace municipality = "SAOSEBASTIAODELAGOADEROCA25" if municipality == "SAOSEB.DELAGOADEROCA25"
replace municipality = "SAOVICENTEDOSERIDO25" if municipality == "SERIDO25"
replace municipality = "SENADORLAROCQUE21" if municipality == "SENADORLAROQUE21"
replace municipality = "TEOTONIOVILELA27" if municipality == "SENADORTEOTONIOVILELA27"
replace municipality = "SERRACAIADA24" if municipality == "SERRACAIADA24"
replace municipality = "SUDMENNUCCI35" if municipality == "SUDMENUCCI35"
replace municipality = "SUZANAPOLIS35" if municipality == "SUZANOPOLIS35"
replace municipality = "TEJUCUOCA23" if municipality == "TEJUSSUOCA23"
replace municipality = "TRINDADEDOSUL43" if municipality == "TRINDADE43"
replace municipality = "VALPARAISO35" if municipality == "VALPARAIZO35"
replace municipality = "VARRESAI33" if municipality == "VARREESAI33"
replace municipality = "VISEU15" if municipality == "VIZEU15"
replace municipality = "LAJEADOGRANDE42" if municipality == "LAGEADOGRANDE42"
replace municipality = "SENADORCATUNDA23" if municipality == "CATUNDA23"
replace municipality = "LAGOAALEGRE22" if municipality == "LOGOAALEGRE22"
replace municipality = "ITAPAJE23" if municipality == "ITAPAGE23"
replace municipality = "SAOLUIZDOPARAITINGA35" if municipality == "SAOLUISDOPARAITINGA35"
replace municipality = "SAOLUIZDOPARAITINGA35" if municipality == "SAOLUISDOPARAITINGA35"
replace municipality = "ARRAIALDOCABO33" if municipality == "ARRABALDOCABO33"
replace municipality = "LARANJADATERRA32" if municipality == "NARANJADATERRA32"
replace municipality = "LARANJADATERRA32" if municipality == "LAJARANJADATERRA32"
replace municipality = "AQUIRAZ23" if municipality == "AQUIRAZCE23"
replace municipality = "CAUCAIA23" if municipality == "CAUCAIACE23"
replace municipality = "JIJOCADEJERICOACOARA23" if municipality == "JIJONADEJERICOACOARA23"
replace municipality = "ANGIC0S24" if municipality == "ANGIC24"
replace municipality = "LAJEDODOTABOCAL29" if municipality == "LAREDODOTABOCAL29"
replace municipality = "LAREJODOTABOCAL29" if municipality == "LAREDODOTABOCAL29"
replace municipality = "TENENTELAURENTINOCRUZ24" if municipality == "TENENTELAURENTINORUZ24"

*Merge in municipality/microregion/mesoregion codes
merge m:1 municipality using "brazil_geographical_codes.dta"

*[!] 1 observation (ANGICOS24 in 2015) remains unmatched 
drop if _merge == 1

*Fill in default dates for unmatched observations to facilitate expansion to balanced panel
replace year = 1999 if year == .
replace month = 1 if month == .
replace quarter = 1 if quarter == .

drop _merge


********************************************************************************
* 4 - Create balanced monthly royalty panel (1999-2017)
********************************************************************************
*Preliminaries: create numeric ID variables and drop observations with missing IDs
egen id = group(municipality)
gen ym = ym(year, month)
format ym %tm

*Specify data as time series and expand missing years for each municipality
tsset id ym
tsfill, full

*Carry forward date variables
bysort id: replace ym = ym[_n-1]+1 if _n>1
replace year = yofd(dofm(ym)) if year == .
replace month = month(dofm(ym)) if month == .
replace quarter = quarter(dofm(ym)) if quarter == .
sort id ym

*Carry forward time invariant variables
bysort id: carryforward municipality, gen(new_municipality)
bysort id: carryforward UF_NO, gen(new_UF_NO)
bysort id: carryforward munic_code, gen(new_munic_code)
bysort id: carryforward micro_code, gen(new_micro_code)
bysort id: carryforward meso_code, gen(new_meso_code)

*Reverse sort and carryforward time invariant variables
gsort id - year
bysort id: carryforward municipality, gen(new_municipality2)
bysort id: carryforward UF_NO, gen(new_UF_NO2)
bysort id: carryforward munic_code, gen(new_munic_code2)
bysort id: carryforward micro_code, gen(new_micro_code2)
bysort id: carryforward meso_code, gen(new_meso_code2)

*Drop redundant variables
drop municipality UF_NO munic_code micro_code meso_code
rename new_municipality2 municipality
rename new_UF_NO2 UF_NO
rename new_munic_code2 munic_code
rename new_micro_code2 micro_code
rename new_meso_code2 meso_code
replace municipality = new_municipality if municipality == ""
replace UF_NO = new_UF_NO if UF_NO == .
replace munic_code = new_munic_code if munic_code == .
replace micro_code = new_micro_code if micro_code == .
replace meso_code = new_meso_code if meso_code == .

*Drop redundant variables
drop new_municipality new_UF_NO new_munic_code new_micro_code new_meso_code id ym

*Reorganize data
sort municipality year month
order municipality UF_NO munic_code micro_code meso_code year quarter month ///
to_5 past_5 royalties_total cumulative_total

*Replace time variant values with zero if missing in filled in observations
replace to_5 = 0 if to_5 == .
replace past_5 = 0 if past_5 == .
replace royalties_total = 0 if royalties_total == .
replace cumulative_total = 0 if cumulative_total == .

drop if municipality == ""

*Label variables
label variable year "Year"
label variable quarter "Quarter"
label variable month "Month"
label variable municipality "Municipality Name"
label variable munic_code "Municipality Code (7-digit)"
label variable UF_NO "UF (State) Code"
label variable micro_code "Microregion Code"
label variable meso_code "Mesoregion Code"

save "$data/Analysis/Royalties_MonthlyPanel.dta", replace

********************************************************************************
* 4 - Clean and save balanced yearly royalties panel
********************************************************************************

use "$data/Analysis/Royalties_MonthlyPanel.dta", clear

*Calculate annual royalties by summing montly receipts
bysort municipality year: egen annual_royalties = sum(royalties_total)
keep if month == 12

keep municipality munic_code UF_NO micro_code meso_code year annual_royalties 

label variable annual_royalties "Total Annual Royalty Receipts (Constant 2010 BRL R$)"

save "$data/Analysis/RoyaltiesPanel_Annual.dta", replace


	