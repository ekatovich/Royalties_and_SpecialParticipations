# Royalties_and_SpecialParticipations
Construct Balanced Panel of Oil Royalty and Special Participation Transfers to Brazilian Municipalities (1999-2017)

This repository contains raw .csv files on monthly oil royalty and quarterly special participations transfers from 
the Brazilian National Oil Agency (ANP) to Brazilian municipalities. 

The repository also contains Stata do-files that clean these data and build a balanced monthly panel of royalty and 
special participation transfers to Brazilian municipalities from 1999-2017. 

To execute these do-files, simply open the MASTER_Royalties_and_SpecialParticipations do-file in Stata, adjust the 
user file-path to your computer, download the raw Royalties and SpecialParticipations folders and save them as 
specified in the MASTER do-file, and run the scripts. 

Data were extracted from raw open access PDFs published by the ANP using Adobe Pro's PDF to csv conversion feature. 
Data were downloaded from http://www.anp.gov.br/conteudo-do-menu-superior/31-dados-abertos/5549-participacoes-governamentais
Note that this site now makes available .csv versions of the data rather than PDFs. 

The final panel produced by these scripts is balanced, e.g. contains observations for each of Brazil's 5570 municipalities
for each of the months between January 1999 and December 2017. The scripts produce datasets at the monthly and yearly levels,
and quarterly for special participations. All monetary values are deflated into constant 2010 Brazilian Reals using Brazil's
Indice Nacional de Precos ao Consumidor, published by IBGE. Geographical unit codes for municipality, microregion, mesoregion,
and UF (state) are attached to each municipality name string reported in the raw royalties and special participations datasets,
facilitating merges with other municipality-level datasets.

I welcome comments and suggestions on these scripts. Feel free to download the scripts and data for research purposes. Please
cite or acknowledge these scripts if they are useful for your research.
