@echo off

set DIR_HOME=%CD%

echo inputs

:: Source
set SHACL_DIR=%DIR_HOME%\shacl
set RDF_DIR=%DIR_HOME%\output
set DIR_VOCABULAIRES=%DIR_HOME%\work\vocabulaires_rdf-xml

echo Validate
set DIR_VALIDATE=%DIR_HOME%\validation-report
set REPORT_DIR=%DIR_VALIDATE%\report
set LOG_DIR=%DIR_VALIDATE%\logs


:: créer les dossiers s'ils n'existent pas.
mkdir %REPORT_DIR%
mkdir %SHACL_TTL_DIR%
mkdir %LOG_DIR%

:: 
:: Nettoyer les dosiers des fichiers à valider

del %REPORT_DIR%\*.ttl
del %REPORT_DIR%\*.html


echo ###
echo ### Etape 4 - Validation des data et Generation du rapport
echo ###

java -Xmx4048M -jar shacl-play-app-0.6.2-onejar.jar validate -i %RDF_DIR% -i %DIR_VOCABULAIRES%  -s %SHACL_DIR%\scorebot-shacl.ttl -o %REPORT_DIR%\scorebot_report.ttl -o %REPORT_DIR%\scorebot_report.html > %LOG_DIR%\scorebot_report.log

echo ###
echo ### Fin
echo ###