
export HOME=$(dirname $0)

# inputs
export INPUT_FOLDER=$HOME/input
export DIR_VOCABULARIES_SOURCE=$INPUT_FOLDER/vocabulaires
export DIR_PARTITIONS_SOURCE=$INPUT_FOLDER/partitions
export DIR_PERSONNE_SOURCE=$INPUT_FOLDER/personnes
export DIR_COLLECTIVITE_SOURCE=$INPUT_FOLDER/collectivites
export DIR_THESAURUS_SOURCE=$INPUT_FOLDER/thesaurus

# work
export WORK_FOLDER=$HOME/work
export LOG_FOLDER=$WORK_FOLDER/logs
export DIR_VOCABULARIES=$WORK_FOLDER/vocabulaires_rdf-xml

# output
export OUTPUT_FOLDER=$HOME/output

# XSLT
export XSLT_DIR=$HOME/xslt

# Clean logs
rm -rf $LOG_FOLDER
mkdir $LOG_FOLDER

# Create the folders 

mkdir $OUTPUT_FOLDER
mkdir $WORK_FOLDER
mkdir $DIR_VOCABULARIES

rm -rf $DIR_VOCABULARIES/*.rdf
rm -rf $OUTPUT_FOLDER/*.rdf


#conversion des fichiers ttl à fichiers rdf's
echo "#######################################################################"
echo "###  Etape 1 - Normalisation vocabulaires contrôlés                 ###"
echo "#######################################################################"


for d in $DIR_VOCABULARIES_SOURCE/*;
do
	
	VOC_NAME=$(basename $d .ttl)
	
	java -jar -Dfile.encoding=UTF-8 rdf-toolkit-0.6.1-onejar.jar serialize --input $d -o $DIR_VOCABULARIES/$VOC_NAME.rdf
done


export start_xml_rdf="$(date +"%r")"


# Convert other vocabularies
echo "#######################################################################"
echo "###  Etape 2 - Conversion Personnes / Collectivites / Thesaurus     ###"
echo "#######################################################################"


echo "Converting ExportAutoritesCollectivites..."
java -Xmx4048M -jar saxon-he-10.1.jar \
		-s:$DIR_COLLECTIVITE_SOURCE/ExportAutoritesCollectivites.xml \
		-xsl:$XSLT_DIR/AutoritesCollectivite.xsl \
		-o:$OUTPUT_FOLDER/AutoritesCollectivite.rdf &>> $LOG_FOLDER/AutoritesCollectivite.log

echo "Converting ExportAutoritesPersonnePhysique..."
java -Xmx4048M -jar saxon-he-10.1.jar \
		-s:$DIR_PERSONNE_SOURCE/ExportAutoritesPersonnePhysique.xml \
		-xsl:$XSLT_DIR/AutoritesPersonnePhysique.xsl \
		-o:$OUTPUT_FOLDER/AutoritesPersonnePhysique.rdf &>> $LOG_FOLDER/AutoritesPersonnePhysique.log

echo "Converting ExportThesaurus..."
java -Xmx4048M -jar saxon-he-10.1.jar \
		-s:$DIR_THESAURUS_SOURCE/ExportThesaurus.xml \
		-xsl:$XSLT_DIR/Thesaurus.xsl \
		-o:$OUTPUT_FOLDER/ExportThesaurus.rdf &>> $LOG_FOLDER/Thesaurus.log


# Step 1 - Convert xml file to rdf file
echo "#######################################################################"
echo "###  Etape 3 - Conversion Partitions                                ###"
echo "#######################################################################"

for f in $(find $DIR_PARTITIONS_SOURCE -name '*.xml');
do
	echo "Converting $f..."

	FILENAME=$(basename $f .xml)

	java -Xmx8048M -jar saxon-he-10.1.jar \
		-s:$DIR_PARTITIONS_SOURCE/$FILENAME.xml \
		-xsl:$XSLT_DIR/Partitions.xsl \
		-o:$OUTPUT_FOLDER/$FILENAME.rdf > $LOG_FOLDER/Partitions-$FILENAME.log 2>&1

done

export end_xml_rdf="$(date +"%r")"

echo "Step 1 - Converting xml file to rdf file from " $start_xml_rdf " to " $end_xml_rdf