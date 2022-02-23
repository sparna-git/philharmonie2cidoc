
export HOME=$(dirname $0)

# inputs
export INPUT_FOLDER=$HOME/input
export DIR_VOCABULARIES_SOURCE=$INPUT_FOLDER/controlled_vocabularies
export DIR_PARTITIONS_SOURCE=$INPUT_FOLDER/partitions

# work
export WORK_FOLDER=$HOME/work
export LOG_FOLDER=$WORK_FOLDER/logs
export DIR_VOCABULARIES=$WORK_FOLDER/controlled_vocabularies_rdf-xml

# output
export OUTPUT_FOLDER=$HOME/output

# XSLT
export XSLT_DIR=$HOME/xslt




# Create the folders 

mkdir $OUTPUT_FOLDER
mkdir $WORK_FOLDER
mkdir $LOG_FOLDER
mkdir $DIR_VOCABULARIES

rm -rf $DIR_VOCABULARIES/*.rdf
rm -rf $OUTPUT_FOLDER/*.rdf

#conversion des fichiers ttl à fichiers rdf's

for d in $DIR_VOCABULARIES_SOURCE/*;
do
	
	VOC_NAME=$(basename $d .ttl)
	
	# java -jar -Dfile.encoding=UTF-8 rdf-toolkit-0.6.1-onejar.jar serialize --input $d -o $DIR_VOCABULARIES/$VOC_NAME.rdf
done


export start_xml_rdf="$(date +"%r")"

# Step 1 - Convert xml file to rdf file
echo "#######################################################################"
echo "###  Etape 1 - Transformer des fichier xml à fichier RDF   		 ###"
echo "#######################################################################"

for f in $(find $DIR_PARTITIONS_SOURCE -name '*.xml');
do
	echo "Converting $f..."

	FILENAME=$(basename $f .xml)

	java -Xmx2048M -jar saxon-he-10.1.jar \
		-s:$DIR_PARTITIONS_SOURCE/$FILENAME.xml \
		-xsl:$XSLT_DIR/Partitions.xsl \
		-o:$OUTPUT_FOLDER/$FILENAME.rdf >> $LOG_FOLDER/philharmonie_chatbot.tsv 2>&1

done

echo "Step 1 - Converting xml file to rdf file" $start_xml_rdf "-" $end_xml_rdf