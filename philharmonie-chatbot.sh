# Prerequisites :
# sudo apt install python3-venv python3-pip

export dir_home=$(dirname $0)

export xml_output_file=$dir_home/10-XML
export rdf_output_folder=$dir_home/05-RDF
export log_file=$dir_home/20-log
export xsl_stylesheet=$dir_home/03-XSLT
export dir_vocabularies_source=$dir_home/01-CONTROLLED_VOCABULARIES
export dir_vocabularies=$dir_home/07-CONTROLLED_VOCABULARIES_RDF-XML


# Creation the folders 

mkdir $xml_output_file
mkdir $rdf_output_folder
mkdir $log_file
mkdir $dir_vocabularies

rm -rf $dir_vocabularies/*.rdf
rm -rf $rdf_output_folder/*.rdf

#conversion des fichiers ttl à fichiers rdf's

for d in $dir_vocabularies_source/*;
do
	
	Vocabularies_name=$(basename $d .ttl)
	
	java -jar -Dfile.encoding=UTF-8 rdf-toolkit-0.6.1-onejar.jar \
	serialize --input $d -o $dir_vocabularies/$Vocabularies_name.rdf
done


export start_xml_rdf="$(date +"%r")"

# Step 1 - Convert xml file to rdf file
echo "#######################################################################"
echo "###  Etape 1 - Transformer des fichier xml à fichier RDF   		 ###"
echo "#######################################################################"

for f in $(find $xml_output_file -name '*.xml');
do

	FILENAME=$(basename $f .xml)

	java -Xmx2048M -jar saxon-he-10.1.jar \
		-s:$xml_output_file/$FILENAME.xml \
		-xsl:$xsl_stylesheet/Partitions.xsl \
		-o:$rdf_output_folder/philharmonie_chatbot.rdf >> $log_file/philharmonie_chatbot.tsv 2>&1

done

echo "Step 1 - Converting xml file to rdf file" $start_xml_rdf "-" $end_xml_rdf