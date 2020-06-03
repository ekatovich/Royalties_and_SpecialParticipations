/*******************************************************************************
Monthly and Annual Panels (Balanced) (1999-2017) of Oil Royalties and Special 
Participations Distributed by National Oil Agency (ANP) to Municipal Governments

Last Modified: June 2, 2020

By: Erik Katovich

*Description: This MASTER do-file executes three subscripts, which collectively 
*import raw .csv data on monthly oil royalty transfers and quarterly special
participations transfers to municipal governments in Brazil, clean these files,
attach geographic identifiers, expand to a balanced panel, and merge together
to create final balanced panel of total oil and gas royalty transfers received
by municipal governments between 1999 and 2017. 

Data sources: All data on royalties and special participations are drawn from 
ANP, the Agencia Nacional do Petroleo e Biocombustiveis. Data on geographic 
identifiers and currency deflators (INPC) are drawn from IBGE.
*/


*Required Stata packages: dropmiss, carryforward
*To install dropmiss:
net from http://www.stata-journal.com/software/sj15-4
net install dm0085

*To install carryforward
ssc install carryforward


/*Required file structure and data:
Folders: Royalties_and_SpecialParticipations
			Data 
				Raw
					Royalties 
						Data: Royalties_Month_Year.csv files (1999-2017)
				              Brazil_GeographicalUnits.csv
					SpecialParticipations 
						Data: sp_Month_Year.csv files (2000-2017)	
				Analysis
			Do-Files			   
*/

********************************************************************************
*0. Setup 

version 16             // Set Version number for backward compatibility
set more off            // Disable partitioned output
clear all               // Start with a clean slate
set linesize 80         // Line size limit to make output more readable
macro drop _all         // clear all macros

*Adjust user path to match the desired file path on your computer
global user "C:/Users/17637/Documents/GitHub"

	global	data			"$user/Royalties_and_SpecialParticipations/Data"
	global 	dofiles		"$user/Royalties_and_SpecialParticipations/Do-Files"


********************************************************************************
cd "$dofiles"
********************************************************************************
*1. Import and clean geographical units to attach municipality/microregion/meso
*region/state codes to the municipality names that appear in royalty and special
*participations datasets 

do "$dofiles/Brazil_GeographicalUnits.do"

*2. Import and clean monthly royalties data, attach geographical codes, create
*balanced monthly and annual panels
do "$dofiles/Royalties_MonthlyPanel.do"

*3. Import and clean quarterly special participations data, merge with royalties
*data and create monthly and annual panel of total oil revenue transfers to 
*municipal governments (1999-2017)
do "$dofiles/SpecialParticipations_QuarterlyPanel.do"

*Final panel datasets are saved to Data > Analysis Folder

