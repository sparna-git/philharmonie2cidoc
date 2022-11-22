@echo off

set DIR_HOME=%CD%

echo inputs

:: Source
set SHACL_DIR=%DIR_HOME%\04-shacl
set RDF_DIR=%DIR_HOME%\06-output

echo Validate
set DIR_VALIDATE=%DIR_HOME%\07-validate
set SHACL_TTL_DIR=%DIR_VALIDATE%\shacl-ttl
::set DOCUMENTATION_DIR=%DIR_VALIDATE%\documentation
set REPORT_DIR=%DIR_VALIDATE%\report
set LOG_DIR=%DIR_VALIDATE%\logs


:: créer les dossiers s'ils n'existent pas.
mkdir %REPORT_DIR%
mkdir %SHACL_TTL_DIR%
::mkdir %DOCUMENTATION_DIR%
mkdir %LOG_DIR%

:: 
:: Nettoyer les dosiers des fichiers à valider

del %SHACL_TTL_DIR%\*.ttl
del %REPORT_DIR%\*.ttl
del %REPORT_DIR%\*.html

::set SHACL_HTML_DOC=%DOCUMENTATION_DIR%\PHILHARMONIE-General.html
::set SHACL_PNG=%DOCUMENTATION_DIR%\PHILHARMONIE-General.png
FOR %%f IN (%SHACL_DIR%\*.xlsx) DO (

	echo ###
	echo ### Etape 1 - %%f - Conversion en ttl vers %name_file%
	echo ###
	
	java -jar xls2rdf-app-2.1.3-onejar.jar convert -i %%f -o %SHACL_TTL_DIR%\PHILHARMONIE-General.ttl -l en
)



	::echo ###
	::echo ### Etape 2 - %%f - Generation de la doc
	::echo ###

	::java -jar shacl-play-app-0.5-onejar.jar doc -i %SHACL_TTL_DIR%\PHILHARMONIE-General.ttl -o %SHACL_HTML_DOC% -l en
	
	::echo ###
	::echo ### Etape 3 - %%f - Generation du diagramme
	::echo ###

	::java -jar shacl-play-app-0.5-onejar.jar draw -i %SHACL_TTL_DIR%\PHILHARMONIE-General.ttl -o %SHACL_PNG%


echo ###
echo ### Etape 4 - Validation des data et Generation du rapport
echo ###

java -Xmx4048M -jar %DIR_HOME%\shacl-play-app-0.6.2-onejar.jar validate -i %RDF_DIR%\Partitions.rdf -s %SHACL_TTL_DIR%\PHILHARMONIE-General.ttl -o %REPORT_DIR%\PHILHARMONIE-General-report.ttl -o %REPORT_DIR%\PHILHARMONIE-General-report.html > %LOG_DIR%\log_validation.log

echo ###
echo ### Fin
echo ###