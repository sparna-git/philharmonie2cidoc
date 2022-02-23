@echo off
echo 
echo
set dir_home=%CD%

set start_json=%time%

:: Log folder
if not exist %dir_home%\20-log\ (
	mkdir %dir_home%\20-log
	set log_file=%dir_home%\20-log
) else (
	set log_file=%dir_home%\20-log
)


:: RDF dossier
set rdf_output_folder=%dir_home%\05-RDF

:: Créer le dossier XML, si lui n'existe pas.
if not exist %rdf_output_folder% (
	mkdir %dir_home%\05-RDF
	set rdf_output_folder=%dir_home%\05-RDF
) else (
	set rdf_output_folder=%dir_home%\05-RDF
)

set dir_vocabularies_source=01-CONTROLLED_VOCABULARIES
set dir_vocabularies=%dir_home%\07-CONTROLLED_VOCABULARIES_RDF-XML

:: Supprimer tous les fichier vocabulaires RDF 
del %dir_vocabularies_result%\*.rdf

:: Convert vocabularies files ttl to rdf
for /D %%f in (%dir_vocabularies_source%\*) do (
	
	set namefile=%dir_Test%\%%~nf.rdf
	java -jar -Dfile.encoding=UTF-8 "%dir_home%\rdf-toolkit-0.6.1-onejar.jar" serialize --input %%f -o %dir_vocabularies%\%%~nf.rdf
)

:: Supprimer log
del %log_file%\*.tsv


:: 1 etape 
:: utiliser les fichiers xml et xsl pour créer le fichier RDF

echo #######################################################################
echo ###   Etape 1 - Transformer des fichier xml à fichier RDF   		 ###
echo #######################################################################

set start_rdf=%time%

set xml_source=%dir_home%\10-XML
set xsl_stylesheet=%dir_home%\03-XSLT

:: Supprimer tous les fichier RDF
del %rdf_output_folder%\*.rdf

:: Boucle pour trouver chaque fichier xml et le transformer en fichier rdf.
FOR %%f IN (%xml_source%\*.xml) DO (
	java.exe -Xmx2048M -jar "%dir_home%\saxon-he-10.1.jar" -s:%%f -xsl:%xsl_stylesheet%\Partitions.xsl -o:%rdf_output_folder%\%%~nf.rdf >> %log_file%\log_%%~nf.tsv 2>&1	
)
