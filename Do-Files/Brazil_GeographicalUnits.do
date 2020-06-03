*Cleaning Municipality Names for Merging

*By: Erik Katovich
*Last modified: Nov. 16, 2019

*Municipality-Level Datasets frequently appear without the unique 7-digit IBGE code required for 1-1 merging, requiring merging on names

*This do-file creates a unique municipality-UF string that allows merging on names
*This file also corrects common naming errors to improve merging


*Set working directory
cd "$data/Raw/Royalties"

*Import .csv file containing information on geographical units
import delimited "Munic_Micro_Meso_Region_Codes.csv", clear

rename uf_no UF_NO

*Remove all accents and special characters from munic using ustrnormalize:
		replace munic = ustrto(ustrnormalize(munic, "nfd"), "ascii", 2)	
		*Remove hyphens, apostrophes, and spaces	
		replace munic =subinstr(munic,"-","",.)
		replace munic =subinstr(munic,"'","",.)
		replace munic =subinstr(munic," ","",.)	
		*Convert all letters to uppercase
		replace munic = upper(munic)

		*Generate unique municipality-state text identifier
		egen municipality = concat(munic UF_NO) 
		drop microregion mesoregion munic 
		order municipality munic_code UF_NO micro_code meso_code 
			
*Correct common naming variations to improve merging
*These corrections should be run on all datasets prior to merging on "municipality"
*Corrections account for 1) spelling variations, 2) abbreviations, 3) name changes, 4) data entry errors
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
replace municipality = "ARMACAODOSBUZIOS33" if municipality == "ARMACAODEBUZIOS33"
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


save "brazil_geographical_codes.dta", replace
