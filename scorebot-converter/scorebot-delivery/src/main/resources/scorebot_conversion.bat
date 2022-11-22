set HOME=%CD%

echo inputs
set INPUT_FOLDER=%HOME%\01_input
set DIR_VOCABULARIES_SOURCE=%INPUT_FOLDER%\controlled_vocabularies
set DIR_PARTITIONS_SOURCE=%INPUT_FOLDER%\partitions
set DIR_PERSONNE_SOURCE=%INPUT_FOLDER%\personne
set DIR_COLLECTIVITE_SOURCE=%INPUT_FOLDER%\collectivites
set DIR_THESAURUS_SOURCE=%INPUT_FOLDER%\thesaurus

echo work
set WORK_FOLDER=%HOME%\05-work
set LOG_FOLDER=%WORK_FOLDER%\logs
set DIR_VOCABULARIES=%WORK_FOLDER%\vocabulaires_rdf-xml

echo output
set OUTPUT_FOLDER=%HOME%\06-output

echo XSLT
set XSLT_DIR=%HOME%\02-xslt

echo Clean logs
mkdir %LOG_FOLDER%

echo Create the folders 

mkdir %OUTPUT_FOLDER%
mkdir %WORK_FOLDER%
mkdir %DIR_VOCABULARIES%


echo "#######################################################################"
echo "###  Etape 1 - Normalisation vocabulaires contrôlés                 ###"
echo "#######################################################################"


:: Convert vocabularies files ttl to rdf
for /D %%f in (%DIR_VOCABULARIES_SOURCE%\*) do (	
	java -jar -Dfile.encoding=UTF-8 rdf-toolkit-0.6.1-onejar.jar serialize --input %%f -o %DIR_VOCABULARIES%\%%~nf.rdf
)


echo "#######################################################################"
echo "###  Etape 2 - Conversion Personnes / Collectivites / Thesaurus     ###"
echo "#######################################################################"


echo "Converting ExportAutoritesCollectivites..."
java -Xmx4048M -jar saxon-he-10.1.jar -s:%DIR_COLLECTIVITE_SOURCE%\ExportAutoritesCollectivites.xml -xsl:%XSLT_DIR%\AutoritesCollectivite.xsl -o:%OUTPUT_FOLDER%\AutoritesCollectivite.rdf >> %LOG_FOLDER%\AutoritesCollectivite.log 2>&1

echo "Converting ExportAutoritesPersonnePhysique..."
java -Xmx4048M -jar saxon-he-10.1.jar -s:%DIR_PERSONNE_SOURCE%\ExportAutoritesPersonnePhysique.xml -xsl:%XSLT_DIR%\AutoritesPersonnePhysique.xsl -o:%OUTPUT_FOLDER%\AutoritesPersonnePhysique.rdf >> %LOG_FOLDER%\AutoritesPersonnePhysique.log 2>&1

echo "Converting ExportThesaurus..."
java -Xmx4048M -jar saxon-he-10.1.jar -s:%DIR_THESAURUS_SOURCE%\ExportThesaurus.xml -xsl:%XSLT_DIR%\Thesaurus.xsl -o:%OUTPUT_FOLDER%\ExportThesaurus.rdf >> %LOG_FOLDER%\Thesaurus.log 2>&1


echo Step 1 - Convert xml file to rdf file
echo "#######################################################################"
echo "###  Etape 3 - Conversion Partitions                                ###"
echo "#######################################################################"

java -Xmx8048M -jar saxon-he-10.1.jar -s:%DIR_PARTITIONS_SOURCE%\ExportPartitions-20211201-sample-pretty.xml -xsl:%XSLT_DIR%\Partitions.xsl -o:%OUTPUT_FOLDER%\philharmonie.rdf >> %LOG_FOLDER%\philharmonie.tsv 2>&1


echo "Step 1 - Converting xml file to rdf file end " 