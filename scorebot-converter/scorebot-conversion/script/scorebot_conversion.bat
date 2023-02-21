set HOME=%CD%

echo inputs
set INPUT_FOLDER=%HOME%\input
set DIR_VOCABULARIES_SOURCE=%INPUT_FOLDER%\vocabulaires
set DIR_VOCABULARIES_ADDITIONNAL=%INPUT_FOLDER%\vocabulaires-complementaires
set DIR_PARTITIONS_SOURCE=%INPUT_FOLDER%\partitions
set DIR_PERSONNE_SOURCE=%INPUT_FOLDER%\personnes
set DIR_COLLECTIVITE_SOURCE=%INPUT_FOLDER%\collectivites
set DIR_THESAURUS_SOURCE=%INPUT_FOLDER%\thesaurus

echo work
set WORK_FOLDER=%HOME%\work
set LOG_FOLDER=%WORK_FOLDER%\logs
set DIR_VOCABULARIES=%WORK_FOLDER%\vocabulaires_rdf-xml

echo output
set OUTPUT_FOLDER=%HOME%\output

echo XSLT
set XSLT_DIR=%HOME%\xslt

echo Clean logs
mkdir %LOG_FOLDER%

echo Create the folders 

mkdir %OUTPUT_FOLDER%
mkdir %WORK_FOLDER%
mkdir %DIR_VOCABULARIES%


set startVC=%time%
echo "Start Normalisation vocabulaires contrôlés " %startVC%
echo "#######################################################################"
echo "###  Etape 1 - Normalisation vocabulaires contrôlés                 ###"
echo "#######################################################################"


:: Convert vocabularies files ttl to rdf
for /D %%f in (%DIR_VOCABULARIES_SOURCE%\*) do (	
	java -jar -Dfile.encoding=UTF-8 rdf-toolkit-0.6.1-onejar.jar serialize --input %%f -o %DIR_VOCABULARIES%\%%~nf.rdf
)

set endVC=%time%
echo "End Normalisation vocabulaires contrôlés " %endVC%

set startConversionVocabulairesComplementaires=%time%
echo "Debut conversion vocabulaires complementaires  " %startConversionVocabulairesComplementaires%
echo "#######################################################################"
echo "###  Etape 2 - Conversion vocabulaires contrôlés complementaires    ###"
echo "#######################################################################"

java -jar xls2rdf-app-2.2.0-onejar.jar convert -i %DIR_VOCABULARIES_ADDITIONNAL%/vocabulaires-complementaires.xlsx -o %DIR_VOCABULARIES%/vocabulaires-complementaires.rdf

set endConversionVocabulairesComplementaires=%time%
echo "Fin Conversion vocabulaires complementaires  " %endConversionVocabulairesComplementaires%


set startAut=%time%
echo "Start Conversion Personnes / Collectivites / Thesaurus " %startAut%
echo "#######################################################################"
echo "###  Etape 3 - Conversion Personnes / Collectivites / Thesaurus     ###"
echo "#######################################################################"


echo "Converting ExportAutoritesCollectivites..."
java -Xmx4048M -jar saxon-he-10.1.jar -s:%DIR_COLLECTIVITE_SOURCE%\ExportAutoritesCollectivites.xml -xsl:%XSLT_DIR%\AutoritesCollectivite.xsl -o:%OUTPUT_FOLDER%\AutoritesCollectivite.rdf >> %LOG_FOLDER%\AutoritesCollectivite.log 2>&1

echo "Converting ExportAutoritesPersonnePhysique..."
java -Xmx4048M -jar saxon-he-10.1.jar -s:%DIR_PERSONNE_SOURCE%\ExportAutoritesPersonnePhysique.xml -xsl:%XSLT_DIR%\AutoritesPersonnePhysique.xsl -o:%OUTPUT_FOLDER%\AutoritesPersonnePhysique.rdf >> %LOG_FOLDER%\AutoritesPersonnePhysique.log 2>&1

echo "Converting ExportThesaurus..."
java -Xmx4048M -jar saxon-he-10.1.jar -s:%DIR_THESAURUS_SOURCE%\ExportThesaurus.xml -xsl:%XSLT_DIR%\Thesaurus.xsl -o:%OUTPUT_FOLDER%\ExportThesaurus.rdf >> %LOG_FOLDER%\Thesaurus.log 2>&1


set endAut=%time%
echo "End Conversion Personnes / Collectivites / Thesaurus " %endAut%


set startPartitions=%time%
echo "Start Conversion Partitions  " %startPartitions%
echo "#######################################################################"
echo "###  Etape 4 - Conversion Partitions                                ###"
echo "#######################################################################"

for %%f in (%DIR_PARTITIONS_SOURCE%\*) do (	

	java -Xmx8048M -jar saxon-he-10.1.jar -s:%%f -xsl:%XSLT_DIR%\Partitions.xsl -o:%OUTPUT_FOLDER%\%%~nf.rdf >> %LOG_FOLDER%\%%~nf.tsv 2>&1
)

set endPartitions=%time%
echo "Fin Conversion Partitions  " %endPartitions%

set startSurindexation=%time%
echo "Start Surindexation calculation  " %startSurindexation%
echo "#######################################################################"
echo "###  Etape 5 - Calcul de la surindexation sur les instruments       ###"
echo "#######################################################################"

java -jar -Dfile.encoding=UTF-8 rdf-toolkit-0.6.1-onejar.jar construct --input %OUTPUT_FOLDER% --input %DIR_VOCABULARIES% --queries query --output %OUTPUT_FOLDER%/surindexation.ttl

set endSurindexation=%time%
echo "Fin Calcul surindexation  " %endSurindexation%

