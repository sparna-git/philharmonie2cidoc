<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:mus="http://data.doremus.org/ontology#"
	xmlns:efrbroo="http://erlangen-crm.org/efrbroo/"
	xmlns:ecrm="http://erlangen-crm.org/current/"
	xmlns:sparnaf="http://data.sparna.fr/function/sparnaf#"
>
 
 	<!-- Import URI stylesheet -->
	<xsl:import href="uris.xsl" />
	
 	<!-- Format -->
	<xsl:output indent="yes" method="xml" />

	<xsl:template match="/">
		<rdf:RDF>
			<xsl:apply-templates />
		</rdf:RDF>
	</xsl:template>
	
	<xsl:template match="NOTICES/TYPREG">
		<xsl:apply-templates />
	</xsl:template>
	
	
	<xsl:template match="NOTICE">
		<xsl:if test="@type = 'UNI:5'">
			
			<efrbroo:F24_Publication_Expression rdf:about="{mus:URI-Publication_Expression(@id)}">
				
				<!-- en dur -->
				<mus:U227_has_content_type rdf:resource="http://www.rdaregistry.info/termList/RDAContentType/#1010" />
				
				<!-- UNI5 -->
				<xsl:if test="@type = 'UNI:5'">
					<!-- Créer un nouvel identifiant à chaque fois que l’une de ces zones est remplie : 
							UNI5 : notice id
							UNI5 : 010$a
							UNI5 : 013$a
					 -->
					 <xsl:comment> Identifiant UNI5  </xsl:comment>
					 <ecrm:P1_is_identified_by>
						<ecrm:E42_Identifier>
							<rdfs:label><xsl:value-of select="@id"/></rdfs:label>
							<!-- UNI5 : notice id
									UNI5 : 010$a
									UNI5 : 013$a
			
								Indiquer “CMPP-ALOES”
								Indiquer “ISBN” pour l’identifiant décrit en 010
								Indiquer “ISMN” pour l’identifiant décrit en 013
						 	-->
						 	<ecrm:P2_has_type>
								<ecrm:E55_Type>
									<rdfs:label>CMPP-ALOES</rdfs:label>
								</ecrm:E55_Type>
							</ecrm:P2_has_type>
						</ecrm:E42_Identifier>
					</ecrm:P1_is_identified_by>
				</xsl:if>
							
				<xsl:apply-templates select="champs[
													not(index-of(('700','701','702','710','711','712','911'),@UnimarcTag))													
													]" />
			
			</efrbroo:F24_Publication_Expression>
			
			<xsl:if test="champs[@UnimarcTag = '700' or 
								 @UnimarcTag = '701' or 
								 @UnimarcTag = '702' or
								 @UnimarcTag = '710' or
								 @UnimarcTag = '711' or
								 @UnimarcTag = '712' or			
								 @UnimarcTag = '911']">
				
				<!-- Description de l’activité d’édition F30 Publication Event pour le 911$a -->
				<efrbroo:F30_Publication_Event>
	
					<!-- 911$a Créer une instance de  F30 Publication Event si la notice comporte au moins un champ 911.  -->
					<!-- Lien vers la Publication Expression de Partition -->
					<xsl:comment> Lien vers la Publication Expression de Partition </xsl:comment>
					<mus:R24_created rdf:resource="{mus:URI-Publication_Expression(@id)}" />
					
					<!-- 911 -->
					<xsl:apply-templates select="champs[@UnimarcTag = '911']"/>
					
					<!-- 700, 701, 702, 710, 711, 712 -->
					<xsl:apply-templates select="champs[@UnimarcTag = '700']" mode="Activity_Event"/>
					<xsl:apply-templates select="champs[@UnimarcTag = '701']" mode="Activity_Event"/>
					<xsl:apply-templates select="champs[@UnimarcTag = '702']" mode="Activity_Event"/>
					<xsl:apply-templates select="champs[@UnimarcTag = '710']" mode="Activity_Event"/>
					<xsl:apply-templates select="champs[@UnimarcTag = '711']" mode="Activity_Event"/>
					<xsl:apply-templates select="champs[@UnimarcTag = '712']" mode="Activity_Event"/>
					
				</efrbroo:F30_Publication_Event>
				
			</xsl:if>
			
			
			
			
		</xsl:if>
	</xsl:template>
	
	<!-- Title 
		UNI5:200$a $e $h $i

		Cas 1 : 
		Respecter l'ordre des sous-zones et générer une ponctuation entre elles, en faisant précéder 
		- le $e de deux points, précédés et suivis d'un espace ( : ) 
		- le $h d'un point suivi d'un espace (. )
		- le $i d'une virgule suivie d'un espace (, ) s'il suit un $h, ou d'un point suivi d'un espace (. ) en l'absence de $h
		
		Cas 2 : 
		Ne pas prendre en compte les $e qui suivent un $d	
	-->
	<xsl:template match="champs[@UnimarcTag='200']">
		
		<xsl:variable name="data_a">
			<xsl:if test="SOUSCHAMP[@UnimarcSubfield ='200$a']">
				<xsl:value-of select="SOUSCHAMP[@UnimarcSubfield ='200$a']/data"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="data_e">
			<xsl:if test="SOUSCHAMP[@UnimarcSubfield ='200$e']">
				<xsl:variable name="suivi" select="SOUSCHAMP[@UnimarcSubfield ='200$e']/following-sibling::*[1]/@UnimarcSubfield"></xsl:variable>
				<xsl:if test="$suivi != '200$d'">
					<xsl:for-each select="SOUSCHAMP[@UnimarcSubfield ='200$e']/data">
						<xsl:value-of select="concat(' : ',.)"/>
					</xsl:for-each>
				</xsl:if>				
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="data_h">
			<xsl:if test="SOUSCHAMP[@UnimarcSubfield ='200$h']">
				<xsl:value-of select="concat('. ',SOUSCHAMP[@UnimarcSubfield ='200$h']/data)"/>
			</xsl:if>
		</xsl:variable>	
		<xsl:variable name="data_i">
			<xsl:if test="SOUSCHAMP[@UnimarcSubfield ='200$i'] and SOUSCHAMP[@UnimarcSubfield ='200$h']">
				<xsl:value-of select="concat(', ',SOUSCHAMP[@UnimarcSubfield ='200$i']/data)"/>
			</xsl:if>
			<xsl:if test="SOUSCHAMP[@UnimarcSubfield ='200$i'] and SOUSCHAMP[@UnimarcSubfield !='200$h']">
				<xsl:value-of select="concat('. ',SOUSCHAMP[@UnimarcSubfield ='200$i']/data)"/>
			</xsl:if>
		</xsl:variable>		
		
		 
		<xsl:if test="$data_a">
			<xsl:comment> Title  UNI5:200 </xsl:comment>
			<mus:U170_has_title_statement>
				<mus:M156_Title_Statement>
					<rdfs:label><xsl:value-of select="concat($data_a,$data_e,$data_h,$data_i)"/></rdfs:label>
				</mus:M156_Title_Statement>
			</mus:U170_has_title_statement>
		</xsl:if>
		 
		
		<!-- 200$f et 200$g  
			U172 has statement of responsibility relating to title
		-->		
		<xsl:variable name="data_f">
			<xsl:if test="SOUSCHAMP[@UnimarcSubfield ='200$f']">
				<xsl:value-of select="SOUSCHAMP[@UnimarcSubfield ='200$f']/data"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="data_g">
			<xsl:if test="SOUSCHAMP[@UnimarcSubfield ='200$f'] and SOUSCHAMP[@UnimarcSubfield ='200$g']/data">
				<!--  
				<xsl:message>Ref <xsl:value-of select="../@id"/>,Value_200$g <xsl:value-of select="SOUSCHAMP[@UnimarcSubfield ='200$g']/data"/></xsl:message>
				-->
				<xsl:for-each select="SOUSCHAMP[@UnimarcSubfield ='200$g']/data">
					<xsl:value-of select="concat('; ',.)"/>
				</xsl:for-each>				
			</xsl:if>
			<xsl:if test="SOUSCHAMP[@UnimarcSubfield !='200$f'] and SOUSCHAMP[@UnimarcSubfield ='200$g']">
				<xsl:value-of select="SOUSCHAMP[@UnimarcSubfield ='200$g']/data"/>
			</xsl:if>
		</xsl:variable>
		<xsl:if test="$data_f or $data_g">
			<mus:U172_has_statement_of_responsibility_relating_to_title>
				<mus:M157_Statement_of_Responsibility>
					<rdfs:label><xsl:value-of select="concat($data_f,$data_g)"/></rdfs:label>
				</mus:M157_Statement_of_Responsibility>
			</mus:U172_has_statement_of_responsibility_relating_to_title>
		</xsl:if>
		
		
		<!-- UNI5:200$d $e
			Créer autant de titres parallèles qu’il y a de sous-zones $d. 
			Si un $e suit un $d, alors concaténer les deux en les séparant par un ( ; )
		 -->
		<xsl:if test="SOUSCHAMP[@UnimarcSubfield ='200$e']">
			<xsl:variable name="suivi" select="SOUSCHAMP[@UnimarcSubfield ='200$e']/following-sibling::*[1]/@UnimarcSubfield"></xsl:variable>
			<xsl:if test="$suivi = '200$d'">
				<!--  
				<xsl:message>Reference <xsl:value-of select="../@id"/>,200_$e_$d <xsl:value-of select="concat(SOUSCHAMP[@UnimarcSubfield ='200$a']/data,':',SOUSCHAMP[@UnimarcSubfield ='200$d']/data)"/></xsl:message>
				-->
				<mus:U168_has_parallel_title>
					<ecrm:E35_Title>
						<rdfs:label>
							<xsl:value-of select="concat(SOUSCHAMP[@UnimarcSubfield ='200$e']/data,';',SOUSCHAMP[@UnimarcSubfield ='200$d']/data)"/>
						</rdfs:label>
					</ecrm:E35_Title>		
				</mus:U168_has_parallel_title>
			</xsl:if>	
		</xsl:if>		
	</xsl:template>
	
	
	<!-- 214 or 210 -->
	<xsl:template match="champs[@UnimarcTag='210' or @UnimarcTag='214']">
		
		<xsl:variable name="data">
			<xsl:choose>
				<xsl:when test="@UnimarcTag='210'">
					<xsl:variable name="data_a">
						<xsl:if test="SOUSCHAMP[@UnimarcSubfield ='210$a']">
							<xsl:value-of select="SOUSCHAMP[@UnimarcSubfield ='210$a']/data"/>
						</xsl:if>
					</xsl:variable>
					<xsl:variable name="data_c">
						<xsl:if test="SOUSCHAMP[@UnimarcSubfield ='210$c']">
							<xsl:value-of select="concat(': ',SOUSCHAMP[@UnimarcSubfield ='210$c']/data)"/>
						</xsl:if>
					</xsl:variable>
					<xsl:variable name="data_d">
						<xsl:if test="SOUSCHAMP[@UnimarcSubfield ='210$d']">
							<xsl:value-of select="concat(', ',SOUSCHAMP[@UnimarcSubfield ='210$d']/data)"/>
						</xsl:if>
					</xsl:variable>		
					<xsl:value-of select="concat($data_a,$data_c,$data_d)"/>
				</xsl:when>
				<xsl:when test="@UnimarcTag='214'">
					<xsl:variable name="data_a">
						<xsl:if test="SOUSCHAMP[@UnimarcSubfield ='214$a']">
							<xsl:value-of select="SOUSCHAMP[@UnimarcSubfield ='210$a']/data"/>
						</xsl:if>
					</xsl:variable>
					<xsl:variable name="data_c">
						<xsl:if test="SOUSCHAMP[@UnimarcSubfield ='214$c']">
							<xsl:value-of select="concat(': ',SOUSCHAMP[@UnimarcSubfield ='210$c']/data)"/>
						</xsl:if>
					</xsl:variable>
					<xsl:variable name="data_d">
						<xsl:if test="SOUSCHAMP[@UnimarcSubfield ='214$d']">
							<xsl:value-of select="concat(', ',SOUSCHAMP[@UnimarcSubfield ='210$d']/data)"/>
						</xsl:if>
					</xsl:variable>		
					<xsl:value-of select="concat($data_a,$data_c,$data_d)"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="$data">
			<mus:U182_has_music_format_statement>
				<mus:M163_Music_Format_Statement>
					<rdfs:label>
						<xsl:value-of select="$data"/>
					</rdfs:label>
				</mus:M163_Music_Format_Statement>	
			</mus:U182_has_music_format_statement>
		</xsl:if>
	</xsl:template>
	
	<!-- 330, 324 et 327 -->
	<xsl:template match="champs[@UnimarcTag='324' or @UnimarcTag='327' or @UnimarcTag='330']">
		
		<xsl:variable name="data_324">
			<xsl:if test="@UnimarcTag='324'">
				<xsl:value-of select="SOUSCHAMP[@UnimarcSubfield ='324$a']/data"/>
			</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="data_327">
			<xsl:if test="@UnimarcTag='327'">
				<xsl:value-of select="SOUSCHAMP[@UnimarcSubfield ='327$a']/data"/>
			</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="data_330">
			<xsl:if test="@UnimarcTag='330'">
				<xsl:value-of select="SOUSCHAMP[@UnimarcSubfield ='330$a']/data"/>
			</xsl:if>
		</xsl:variable>
		
		<xsl:comment> Note </xsl:comment>
		<ecrm:P3_has_note><xsl:value-of select="concat(sparnaf:isTrue($data_330),sparnaf:isTrue($data_324),sparnaf:isTrue($data_327))"/></ecrm:P3_has_note>
		
		
	</xsl:template>	
	
	
	<!-- 449 -->
	<xsl:template match="champs[@UnimarcTag='449']">
		
		<!-- UNI5:449$a $f
			Générer une ponctuation entre le contenu des sous-zones : un ( / ) si le $a est suivi d’un $f		
		 -->
		<xsl:if test="SOUSCHAMP[@UnimarcSubfield ='449$a']">
			<xsl:variable name="suivi" select="SOUSCHAMP[@UnimarcSubfield ='449$a']/following-sibling::*[1]/@UnimarcSubfield"></xsl:variable>
			<xsl:if test="$suivi = '449$f'">
				<!--  
				<xsl:message>Reference <xsl:value-of select="../@id"/>, 449_$a_$f <xsl:value-of select="concat(SOUSCHAMP[@UnimarcSubfield ='449$a']/data,':',SOUSCHAMP[@UnimarcSubfield ='449$f']/data)"/></xsl:message>
				-->
				<mus:U68_has_variant_title>
					<ecrm:E35_Title>
						<rdfs:label>
							<xsl:value-of select="concat(SOUSCHAMP[@UnimarcSubfield ='449$a']/data,'/',SOUSCHAMP[@UnimarcSubfield ='449$f']/data)"/>
						</rdfs:label>
					</ecrm:E35_Title>
				</mus:U68_has_variant_title>
			</xsl:if>				
		</xsl:if>
	</xsl:template>
	
	<!-- 541 -->
	<xsl:template match="champs[@UnimarcTag='541']">
		
		<!-- UNI5:541 $a $e
			Générer une ponctuation entre le contenu des sous-zones : deux ( : ) si le $a est suivi d'un $e		
		 -->
		<xsl:if test="SOUSCHAMP[@UnimarcSubfield ='541$a']">
			<xsl:variable name="suivi" select="SOUSCHAMP[@UnimarcSubfield ='541$a']/following-sibling::*[1]/@UnimarcSubfield"></xsl:variable>
			<xsl:if test="$suivi = '541$e'">
				<!--  
				<xsl:message>Reference <xsl:value-of select="../@id"/>,541_$a_$e <xsl:value-of select="concat(SOUSCHAMP[@UnimarcSubfield ='541$a']/data,':',SOUSCHAMP[@UnimarcSubfield ='541$e']/data)"/></xsl:message>
				-->
				<mus:U68_has_variant_title>
					<ecrm:E35_Title>
						<rdfs:label>
							<xsl:value-of select="concat(SOUSCHAMP[@UnimarcSubfield ='541$a']/data,':',SOUSCHAMP[@UnimarcSubfield ='541$e']/data)"/>
						</rdfs:label>
					</ecrm:E35_Title>
				</mus:U68_has_variant_title>
			</xsl:if>				
		</xsl:if>
	</xsl:template>
	
	
	
	<!-- Event 	
		Créer une instance de F30 Publication Event si la notice comporte au moins un champ 911.	
	-->	
	<xsl:template match="champs[@UnimarcTag='911']">
	
			<!-- 214$d or 210$d  -->
			<!-- 214 $d
				et, si le 214$d n’est pas renseigné: 210 $d
				Cas 1 : 
					la sous-zone ne comporte qu’une année, reprendre les données telles quelles. 
				Cas 2 : 
					Si la sous-zone $d comporte une chaîne de caractères qui précède l’année (Ex : “cop.”, “copyright”, “DL”) et qui a une valeur autre que “impr.”, ne conserver que l’année. 
				Cas 3 : 
					Ne pas conserver les années qui sont précédées de la mention “impr.”
			-->
			<xsl:variable name="data_has_time_210_d" select="../champs[@UnimarcTag='210']/SOUSCHAMP[@UnimarcSubfield='210$d'][1]"/>
			<xsl:variable name="data_has_time_214_d" select="../champs[@UnimarcTag='214']/SOUSCHAMP[@UnimarcSubfield='214$d'][1]"/>
			
			<xsl:if test="$data_has_time_210_d != '' or string-length($data_has_time_210_d) &gt; 0">
				<xsl:variable name="data_year_210" select="ecrm:has_time(../@id,normalize-space($data_has_time_210_d))"/>
				<xsl:if test="$data_year_210">
					<ecrm:P4_has_time-span>
						<ecrm:E52_Time-Span>
							<ecrm:P82_at_some_time_within rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear"><xsl:value-of select="$data_year_210"/></ecrm:P82_at_some_time_within>
						</ecrm:E52_Time-Span>
					</ecrm:P4_has_time-span>
				</xsl:if>
			</xsl:if>
			<xsl:if test="$data_has_time_214_d != '' or string-length($data_has_time_214_d) &gt; 0">
				<xsl:variable name="data_year_214" select="ecrm:has_time(../@id,normalize-space($data_has_time_210_d))"/>
				<xsl:if test="$data_year_214">
					<ecrm:P4_has_time-span>
						<ecrm:E52_Time-Span>
							<ecrm:P82_at_some_time_within rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear"><xsl:value-of select="$data_year_214"/></ecrm:P82_at_some_time_within>
						</ecrm:E52_Time-Span>
					</ecrm:P4_has_time-span>
				</xsl:if>
			</xsl:if>
			
			<xsl:comment>Description de l’activité d’édition F30 Publication Event pour le 911$a</xsl:comment>
			<ecrm:P9_consists_of>		
				<!-- Créer une instance de E7 Activity pour chaque champ 911. -->
				<ecrm:E7_Activity>
					<!-- 911$a Lien vers l’autorité collectivité éditeur -->
					<xsl:comment>Lien vers l’autorité collectivité éditeur</xsl:comment>
					<ecrm:P14_carried_out_by rdf:resource="{mus:reference_collectivite(SOUSCHAMP[@UnimarcSubfield ='911$3']/data)}" />
	
					<!-- en dure -->
					<!-- 911$a Toujours préciser le rôle “éditeur” issu du référentiel http://data.doremus.org/vocabulary/function/publisher -->
					<mus:U31_had_function rdf:resource="http://data.doremus.org/vocabulary/function/publisher" />				
				</ecrm:E7_Activity>	
			</ecrm:P9_consists_of>
			
	</xsl:template>	
	
	<!-- ******* CASTING ******* -->
	<xsl:template match="champs[@UnimarcTag='954']">
	
		<!-- Variables Id's -->
		<!-- Id Notice -->
		<xsl:variable name="idNoticies" select="../@id"/>
		<!-- Nombre de balise pour creer le casting -->
		<xsl:variable name="positionId954" select="position()"/>
		<!-- Nombre total d’instrument dans cette famille -->
		<xsl:variable name="NoInstuments" select="sum(SOUSCHAMP[@UnimarcSubfield='954$t']/data)"/>
		
		<!-- Creation de Id - Notice + positionID954 + NoInstuments	-->
		<xsl:variable name="idCasting" select="concat($idNoticies,'_',$positionId954,'_',$NoInstuments)"/>
		
		<xsl:variable name="VoixSolistes_a" select="../champs[@UnimarcTag='940']/SOUSCHAMP[@UnimarcSubfield='940$a']/data"/>
		<xsl:variable name="InstrumentSolistes_a" select="../champs[@UnimarcTag='942']/SOUSCHAMP[@UnimarcSubfield='942$a']/data"/>
		<xsl:variable name="Choeur_a" select="../champs[@UnimarcTag='941']/SOUSCHAMP[@UnimarcSubfield='941$a']/data"/>
		<xsl:variable name="Gestique_a" select="../champs[@UnimarcTag='943']/SOUSCHAMP[@UnimarcSubfield='943$a']/data"/>
		<!-- ######## Instruments non solistes ######## -->
		<xsl:variable name="FamBois_a" select="../champs[@UnimarcTag='945']/SOUSCHAMP[@UnimarcSubfield='945$a']/data"/>
		<xsl:variable name="FamSaxo_a" select="../champs[@UnimarcTag='946']/SOUSCHAMP[@UnimarcSubfield='946$a']/data"/>
		<xsl:variable name="FamCuivre_a" select="../champs[@UnimarcTag='947']/SOUSCHAMP[@UnimarcSubfield='947$a']/data"/>
		<xsl:variable name="FamPercussions_a" select="../champs[@UnimarcTag='948']/SOUSCHAMP[@UnimarcSubfield='948$a']/data"/>
		<xsl:variable name="FamClaviers_a" select="../champs[@UnimarcTag='949']/SOUSCHAMP[@UnimarcSubfield='949$a']/data"/>
		<xsl:variable name="FamCordesPincees_a" select="../champs[@UnimarcTag='950']/SOUSCHAMP[@UnimarcSubfield='950$a']/data"/>
		<xsl:variable name="FamCordesFrottees_a" select="../champs[@UnimarcTag='951']/SOUSCHAMP[@UnimarcSubfield='951$a']/data"/>
		<xsl:variable name="InstrumentsDivers_a" select="../champs[@UnimarcTag='952']/SOUSCHAMP[@UnimarcSubfield='952$a']/data"/>
		<xsl:variable name="Electro_a" select="../champs[@UnimarcTag='953']/SOUSCHAMP[@UnimarcSubfield='953$a']/data"/>
		<xsl:variable name="Ensemble_a" select="../champs[@UnimarcTag='956']/SOUSCHAMP[@UnimarcSubfield='956$a']/data"/>
		
		
		<xsl:variable name="niveau_333_a" select="../champs[@UnimarcTag='333']/SOUSCHAMP[@UnimarcSubfield='333$a']/data"/>
		
		<!-- Créer une instance de M6 Casting dès que l’une des zones citées ci-dessus est remplie -->
		<xsl:if test="SOUSCHAMP[@UnimarcSubfield='954$t']/data">
			<xsl:comment> M6 Casting </xsl:comment>
			<mus:M6_Casting rdf:resource="{mus:URI-Casting($idNoticies,$idCasting)}">
				
				<!-- U48 foresees quantity of actors  -->
				<mus:U48_foresees_quantity_of_actors>
					<E60_Number rdf:datatype="http://www.w3.org/2001/XMLSchema#Integer">
						<xsl:value-of select="$NoInstuments"/>
					</E60_Number>				
				</mus:U48_foresees_quantity_of_actors>
				
				<!-- Création des M23 Casting Detail (cas simples) : -->
				<xsl:if test="$VoixSolistes_a or
							  $InstrumentSolistes_a or
							  $Choeur_a or 
							  $Gestique_a or
							  $FamBois_a or $FamSaxo_a or 
							  $FamCuivre_a or $FamPercussions_a or 
							  $FamClaviers_a or $FamCordesPincees_a or $FamCordesFrottees_a or 
							  $InstrumentsDivers_a or $Electro_a or $Ensemble_a">
					
					<mus:M23_Casting_Detail rdf:about="{mus:URI-Casting_Detail($idNoticies,$idCasting,1)}">
						
						<!-- Retourne les << Nombre d'instruments >> et 
							<< U2 foresees use of medium of performance of type >> -->
						<xsl:apply-templates select="../champs[@UnimarcTag='940']" mode="Voix_Solistes"/>
						
						<xsl:if test="$FamBois_a or $FamSaxo_a or $FamCuivre_a or $FamPercussions_a or $FamClaviers_a or
									  $FamCordesPincees_a or $FamCordesFrottees_a or $InstrumentsDivers_a or $Electro_a or $Ensemble_a">
							<xsl:apply-templates select="../champs[@UnimarcTag='942']" mode="Instruments_solistes"/>
						</xsl:if>
						
						<xsl:apply-templates select="../champs[@UnimarcTag='941']" mode="Choeur"/>
						<xsl:apply-templates select="../champs[@UnimarcTag='943']" mode="Gestique"/>
						
						<xsl:apply-templates select="../champs[@UnimarcTag='945']" mode="Fam_des_bois"/>
						<xsl:apply-templates select="../champs[@UnimarcTag='946']" mode="Fam_des_sax"/>
						<xsl:apply-templates select="../champs[@UnimarcTag='947']" mode="Fam_des_cuivres"/>
						<xsl:apply-templates select="../champs[@UnimarcTag='948']" mode="Fam_des_percussions"/>
						<xsl:apply-templates select="../champs[@UnimarcTag='949']" mode="Fam_des_claviers"/>
						<xsl:apply-templates select="../champs[@UnimarcTag='950']" mode="Fam_des_cordes_pincées"/>
						<xsl:apply-templates select="../champs[@UnimarcTag='951']" mode="Fam_des_cordes_frot"/>
						<xsl:apply-templates select="../champs[@UnimarcTag='952']" mode="Instruments_Divers"/>
						<xsl:apply-templates select="../champs[@UnimarcTag='953']" mode="Electroacoustique"/>
						<xsl:apply-templates select="../champs[@UnimarcTag='956']" mode="Ensemble"/>
						
						<!-- Processus 333a Niveau -->
						<xsl:for-each select="$niveau_333_a">
							<xsl:if test="mus:NiveauDifficulte(.)">
								<mus:M60_Intended_Audience>
									<xsl:value-of select="mus:NiveauDifficulte(.)"/>
								</mus:M60_Intended_Audience>
							</xsl:if>
						</xsl:for-each>
						
					</mus:M23_Casting_Detail>
				</xsl:if>
				
				
				<xsl:message>***** notice *****: <xsl:value-of select="$idNoticies"/></xsl:message>	
				<!-- Casting Alternatif  -->
				<!-- Création des M23 Casting Detail (avec casting alternatif) -->
	            <!-- Voix Soliste -->
	            <xsl:variable name="VoixSoliste_TotalInstruments" select="sum(../champs[@UnimarcTag='940']/SOUSCHAMP[@UnimarcSubfield='940$a']/number(sparnaf:isNumber(substring-before(substring-after(normalize-space(data),'('),')'))))"/>	            
	            <!-- Instruments solistes -->
	            <xsl:variable name="InstSoliste_TotalInstruments" select="sum(../champs[@UnimarcTag='942']/SOUSCHAMP[@UnimarcSubfield='942$a']/number(sparnaf:isNumber(substring-before(substring-after(normalize-space(data),'('),')'))))"/>
	            <!-- Choeur -->
	            <xsl:variable name="Choeur_TotalInstruments" select="sum(../champs[@UnimarcTag='941']/SOUSCHAMP[@UnimarcSubfield='941$a']/number(sparnaf:isNumber(substring-before(substring-after(normalize-space(data),'('),')'))))"/>
	            <!-- Gestique -->
	            <xsl:variable name="Gestique_TotalInstruments" select="sum(../champs[@UnimarcTag='943']/SOUSCHAMP[@UnimarcSubfield='943$a']/number(sparnaf:isNumber(substring-before(substring-after(normalize-space(data),'('),')'))))"/>
	            <!-- Famille des bois -->
	            <xsl:variable name="FamBois_TotalInstruments" select="sum(../champs[@UnimarcTag='945']/SOUSCHAMP[@UnimarcSubfield='945$a']/number(sparnaf:isNumber(substring-before(substring-after(normalize-space(data),'('),')'))))"/>
	            <!-- Famille des saxophones -->
	            <xsl:variable name="FamSax_TotalInstruments" select="sum(../champs[@UnimarcTag='946']/SOUSCHAMP[@UnimarcSubfield='946$a']/number(sparnaf:isNumber(substring-before(substring-after(normalize-space(data),'('),')'))))"/>
	            <!-- Famille des cuivres -->
	            <xsl:variable name="FamCuivres_TotalInstruments" select="sum(../champs[@UnimarcTag='947']/SOUSCHAMP[@UnimarcSubfield='947$a']/number(sparnaf:isNumber(substring-before(substring-after(normalize-space(data),'('),')'))))"/>
	            <!-- Famille des percussions -->
	            <xsl:variable name="FamPercu_TotalInstruments" select="sum(../champs[@UnimarcTag='948']/SOUSCHAMP[@UnimarcSubfield='948$a']/number(sparnaf:isNumber(substring-before(substring-after(normalize-space(data),'('),')'))))"/>
	            <!-- Famille des claviers -->
	            <xsl:variable name="FamClaviers_TotalInstruments" select="sum(../champs[@UnimarcTag='949']/SOUSCHAMP[@UnimarcSubfield='949$a']/number(sparnaf:isNumber(substring-before(substring-after(normalize-space(data),'('),')'))))"/>
	            <!-- Famille des cordes pincées -->
	            <xsl:variable name="FamCordesPincees_TotalInstruments" select="sum(../champs[@UnimarcTag='950']/SOUSCHAMP[@UnimarcSubfield='950$a']/number(sparnaf:isNumber(substring-before(substring-after(normalize-space(data),'('),')'))))"/>
	            <!-- Famille des cordes frottées -->
	            <xsl:variable name="FamCordesFrot_TotalInstruments" select="sum(../champs[@UnimarcTag='951']/SOUSCHAMP[@UnimarcSubfield='951$a']/number(sparnaf:isNumber(substring-before(substring-after(normalize-space(data),'('),')'))))"/>
	            <!-- Instruments divers -->
	            <xsl:variable name="InstDivers_TotalInstruments" select="sum(../champs[@UnimarcTag='952']/SOUSCHAMP[@UnimarcSubfield='952$a']/number(sparnaf:isNumber(substring-before(substring-after(normalize-space(data),'('),')'))))"/>
	            <!-- Electroacoustique -->
	            <xsl:variable name="Electroacoustique_TotalInstruments" select="sum(../champs[@UnimarcTag='953']/SOUSCHAMP[@UnimarcSubfield='953$a']/number(sparnaf:isNumber(substring-before(substring-after(normalize-space(data),'('),')'))))"/>
	            <!-- Ensemble -->
	            <xsl:variable name="Ensemble_TotalInstruments" select="sum(../champs[@UnimarcTag='956']/SOUSCHAMP[@UnimarcSubfield='956$a']/number(sparnaf:isNumber(substring-before(substring-after(normalize-space(data),'('),')'))))"/>
	            
	            <!-- auter façon de faire une casting alternatif -->
	            <xsl:variable name="VoixSolistes_t" select="../champs[@UnimarcTag='940']/SOUSCHAMP[@UnimarcSubfield='940$x']/mus:casting_alternatif_note(data)"/>
				<xsl:variable name="InstrumentSolistes_t" select="../champs[@UnimarcTag='942']/SOUSCHAMP[@UnimarcSubfield='942$x']/mus:casting_alternatif_note(data)"/>
				<xsl:variable name="Choeur_t" select="../champs[@UnimarcTag='941']/SOUSCHAMP[@UnimarcSubfield='941$x']/mus:casting_alternatif_note(data)"/>
				<xsl:variable name="Gestique_t" select="../champs[@UnimarcTag='943']/SOUSCHAMP[@UnimarcSubfield='943$x']/mus:casting_alternatif_note(data)"/>
				<!-- ######## Instruments non solistes ######## -->
				<xsl:variable name="FamBois_t" select="../champs[@UnimarcTag='945']/SOUSCHAMP[@UnimarcSubfield='945$x']/mus:casting_alternatif_note(data)"/>
				<xsl:variable name="FamSaxo_t" select="../champs[@UnimarcTag='946']/SOUSCHAMP[@UnimarcSubfield='946$x']/mus:casting_alternatif_note(data)"/>
				<xsl:variable name="FamCuivre_t" select="../champs[@UnimarcTag='947']/SOUSCHAMP[@UnimarcSubfield='947$x']/mus:casting_alternatif_note(data)"/>
				<xsl:variable name="FamPercussions_t" select="../champs[@UnimarcTag='948']/SOUSCHAMP[@UnimarcSubfield='948$x']/mus:casting_alternatif_note(data)"/>
				<xsl:variable name="FamClaviers_t" select="../champs[@UnimarcTag='949']/SOUSCHAMP[@UnimarcSubfield='949$x']/mus:casting_alternatif_note(data)"/>
				<xsl:variable name="FamCordesPincees_t" select="../champs[@UnimarcTag='950']/SOUSCHAMP[@UnimarcSubfield='950$x']/mus:casting_alternatif_note(data)"/>
				<xsl:variable name="FamCordesFrottees_t" select="../champs[@UnimarcTag='951']/SOUSCHAMP[@UnimarcSubfield='951$x']/mus:casting_alternatif_note(data)"/>
				<xsl:variable name="InstrumentsDivers_t" select="../champs[@UnimarcTag='952']/SOUSCHAMP[@UnimarcSubfield='952$x']/mus:casting_alternatif_note(data)"/>
				<xsl:variable name="Electro_t" select="../champs[@UnimarcTag='953']/SOUSCHAMP[@UnimarcSubfield='953$x']/mus:casting_alternatif_note(data)"/>
				<xsl:variable name="Ensemble_t" select="../champs[@UnimarcTag='956']/SOUSCHAMP[@UnimarcSubfield='956$x']/mus:casting_alternatif_note(data)"/>
	            
	            
	           <!--  
	            <xsl:message>InstSoliste: <xsl:value-of select="$InstSoliste_TotalInstruments"/></xsl:message>
	            <xsl:message>Choeur: <xsl:value-of select="$Choeur_TotalInstruments"/></xsl:message>
	            <xsl:message>Gestique: <xsl:value-of select="$Gestique_TotalInstruments"/></xsl:message>
	            <xsl:message>FamBois: <xsl:value-of select="$FamBois_TotalInstruments"/></xsl:message>
	            <xsl:message>FamSax: <xsl:value-of select="$FamSax_TotalInstruments"/></xsl:message>
	            <xsl:message>FamCuivres: <xsl:value-of select="$FamCuivres_TotalInstruments"/></xsl:message>
	            <xsl:message>FamPercu: <xsl:value-of select="$FamPercu_TotalInstruments"/></xsl:message>
	            <xsl:message>FamClaviers: <xsl:value-of select="$FamClaviers_TotalInstruments"/></xsl:message>
	            <xsl:message>FamCordesPincees: <xsl:value-of select="$FamCordesPincees_TotalInstruments"/></xsl:message>
	            <xsl:message>FamCordesFrot: <xsl:value-of select="$FamCordesFrot_TotalInstruments"/></xsl:message>
	            <xsl:message>InstDivers: <xsl:value-of select="$InstDivers_TotalInstruments"/></xsl:message>
	            <xsl:message>Electroacoustique: <xsl:value-of select="$Electroacoustique_TotalInstruments"/></xsl:message>
	            <xsl:message>Ensemble: <xsl:value-of select="$Ensemble_TotalInstruments"/></xsl:message>	            
	            -->
	            <xsl:message>VoixSolistes: <xsl:value-of select="VoixSolistes_t"/></xsl:message>
	            <xsl:message>InstSoliste: <xsl:value-of select="$InstrumentSolistes_t"/></xsl:message>
	            <xsl:message>Choeur: <xsl:value-of select="$Choeur_t"/></xsl:message>
	            <xsl:message>Gestique: <xsl:value-of select="$Gestique_t"/></xsl:message>
	            <xsl:message>FamBois: <xsl:value-of select="$FamBois_t"/></xsl:message>
	            <xsl:message>FamSax: <xsl:value-of select="$FamSaxo_t"/></xsl:message>
	            <xsl:message>FamCuivres: <xsl:value-of select="$FamCuivre_t"/></xsl:message>
	            <xsl:message>FamPercu: <xsl:value-of select="$FamPercussions_t"/></xsl:message>
	            <xsl:message>FamClaviers: <xsl:value-of select="$FamClaviers_t"/></xsl:message>
	            <xsl:message>FamCordesPincees: <xsl:value-of select="$FamCordesPincees_t"/></xsl:message>
	            <xsl:message>FamCordesFrot: <xsl:value-of select="$FamCordesFrottees_t"/></xsl:message>
	            <xsl:message>InstDivers: <xsl:value-of select="$InstrumentsDivers_t"/></xsl:message>
	            <xsl:message>Electroacoustique: <xsl:value-of select="$Electro_t"/></xsl:message>
	            <xsl:message>Ensemble: <xsl:value-of select="$Ensemble_t"/></xsl:message>	
	            
	            
	            
	            <xsl:variable name="sum_total_instruments" select="$VoixSoliste_TotalInstruments +
	            												   $InstSoliste_TotalInstruments +
	            												   $Choeur_TotalInstruments + 
	            												   $Gestique_TotalInstruments +
	            												   $FamBois_TotalInstruments +
	            												   $FamSax_TotalInstruments +
	            												   $FamCuivres_TotalInstruments +
	            												   $FamPercu_TotalInstruments +
	            												   $FamClaviers_TotalInstruments +
	            												   $FamCordesPincees_TotalInstruments +
	            												   $FamCordesFrot_TotalInstruments +
	            												   $InstDivers_TotalInstruments +
	            												   $Electroacoustique_TotalInstruments +
	            												   $Ensemble_TotalInstruments
	            												   "/>  
				<xsl:message>Total: <xsl:value-of select="$sum_total_instruments"/></xsl:message>
				
				<xsl:if test="$NoInstuments !=  $sum_total_instruments">
					<xsl:message>Creer Casting Alternatif</xsl:message>				
				</xsl:if>	
				
							
			</mus:M6_Casting>
			
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="champs">
		<xsl:apply-templates/>
	</xsl:template>
	
	
	<!-- 010$a -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield ='010$a']">
	
		<!-- Créer un nouvel identifiant à chaque fois que l’une de ces zones est remplie : 
				UNI5 : notice id
				UNI5 : 010$a
				UNI5 : 013$a
		 	-->
		<ecrm:P1_is_identified_by>
			<ecrm:E42_Identifier>				
				<rdfs:label><xsl:value-of select="data"/></rdfs:label>
				
				<!-- UNI5 : notice id
						UNI5 : 010$a
						UNI5 : 013$a

					Indiquer “CMPP-ALOES”
					Indiquer “ISBN” pour l’identifiant décrit en 010
					Indiquer “ISMN” pour l’identifiant décrit en 013
			 	-->
			 	<ecrm:P2_has_type>
					<ecrm:E55_Type>
						<rdfs:label>ISBN</rdfs:label>
					</ecrm:E55_Type>
				</ecrm:P2_has_type>
			</ecrm:E42_Identifier>	
		</ecrm:P1_is_identified_by>
	</xsl:template>
	
	<!-- 013$a -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield ='013$a']">
	
		<!-- Créer un nouvel identifiant à chaque fois que l’une de ces zones est remplie : 
				UNI5 : notice id
				UNI5 : 010$a
				UNI5 : 013$a
		 	-->
		<ecrm:P1_is_identified_by>
			<ecrm:E42_Identifier>
				
				<rdfs:label><xsl:value-of select="data"/></rdfs:label>
				<!-- UNI5 : notice id
						UNI5 : 010$a
						UNI5 : 013$a

					Indiquer “CMPP-ALOES”
					Indiquer “ISBN” pour l’identifiant décrit en 010
					Indiquer “ISMN” pour l’identifiant décrit en 013
			 	-->
			 	<ecrm:P2_has_type>
					<ecrm:E55_Type>
						<rdfs:label>ISMN</rdfs:label>
					</ecrm:E55_Type>
				</ecrm:P2_has_type>
			</ecrm:E42_Identifier>	
		</ecrm:P1_is_identified_by>
	</xsl:template>
	
	<!-- UNI5:101$a -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield ='101$a']">
		<ecrm:P72_has_language>
			<ecrm:E56_Language>
				<rdfs:label><xsl:value-of select="data"/></rdfs:label>
			</ecrm:E56_Language>
		</ecrm:P72_has_language>
	</xsl:template>
	
	<!-- 205$a -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield ='205$a']">
		<mus:U176_has_edition_statement>
			<mus:M159_Edition_Statement>
				<rdfs:label>
					<xsl:value-of select="."/>
				</rdfs:label>
			</mus:M159_Edition_Statement>	
		</mus:U176_has_edition_statement>
	</xsl:template>
	
	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield = '208$a']">
		<!-- 208$a. et 
			 200$e s’il contient l’une des valeurs suivantes
			- partition de poche
			- tablature
			- réduction 
		-->
		<xsl:if test=".">
			<xsl:comment> 208$a </xsl:comment>
			<mus:U182_has_music_format_statement>
				<mus:M163_Music_Format_Statement>
					<rdfs:label><xsl:value-of select="normalize-space(.)"/></rdfs:label>
				</mus:M163_Music_Format_Statement>	
			</mus:U182_has_music_format_statement>
		</xsl:if>
		
		<xsl:variable name="data_200e" select="../../champs[@UnimarcTag='200']/SOUSCHAMP[@UnimarcSubfield ='200$e']/data"/>
		<xsl:for-each select="$data_200e">
			<xsl:variable name="data200e" select="normalize-space(.)"/>
			<xsl:message>Valeur 208a: <xsl:value-of select="normalize-space(.)"/>,Valeur 200e: <xsl:value-of select="$data200e"/></xsl:message>
			<xsl:if test="contains($data200e,'partition de poche') or 
					  contains($data200e,'tablature') or
					  contains($data200e,'réduction')">
				<xsl:comment> 200$e - partition de poche, tablature, réduction </xsl:comment>
				<mus:U182_has_music_format_statement>
					<mus:M163_Music_Format_Statement>
						<rdfs:label><xsl:value-of select="$data_200e"/></rdfs:label>
					</mus:M163_Music_Format_Statement>	
				</mus:U182_has_music_format_statement>					  
			</xsl:if>
			
		</xsl:for-each>
	</xsl:template>
	
	<!-- Parties de partitions M167 Publication Expression Fragment -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield ='462$3']">
		<!-- UNI5:462$3
				Pour chaque champ 462 présent dans une notice UNI5, créer une partie de partition.
				Les informations détaillant la partie sont présentes dans la notice de dépouillement UNI45
				dont l’identifiant est mentionné dans l’UNI5 en 462$3
 		-->
 		
 		<xsl:variable name="partition" select="normalize-space(.)"/>
 		<xsl:if test="$partition">
	 		<xsl:comment> Parties de partitions </xsl:comment>
	 		<ecrm:P148_has_component>
	 			<mus:M167_Publication_Expression_Fragment rdf:about="{concat(mus:URI-Publication_Expression(../../@id),'/',$partition)}">
	 				<!-- on peut retrouver les même éléments XML que pour la partition "mère" -->
	 			</mus:M167_Publication_Expression_Fragment>
	 		</ecrm:P148_has_component>
	 	</xsl:if>
	</xsl:template>
	
	
	<!-- 500$3 lien vers le titre uniforme musical (notice d’autorité de type AIC14).-->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield ='500$3']">
		<xsl:variable name="idAIC14" select="normalize-space(.)"/>
		
		<!-- TUM-Compositeur-->
		<!-- a- Nom du compositeur : 
			Données : AIC14:322$a $m
			séparer le 322$a et le 322$m par une virgule, si le $m est rempli.
			Faire suivre par un point et un tiret (. -)
			 -->
		<xsl:variable name="AIC14_compositeur" select="mus:Titre_Uniforme_Musical(../../@id,$idAIC14,'322','')"/>
		
		
		<xsl:variable name="qualificatif" select="../SOUSCHAMP[@UnimarcSubfield ='500$w']"/>
		<!-- b- Nom de l’oeuvre : --> 
		<xsl:variable name="AIC14_oeuvre_144" select="mus:Titre_Uniforme_Musical(../../@id,$idAIC14,'144',$qualificatif)"/>
		<xsl:variable name="AIC14_oeuvre_444" select="mus:Titre_Uniforme_Musical(../../@id,$idAIC14,'444',$qualificatif)"/>
		
		<!--  
		<xsl:message>Notice <xsl:value-of select="../../@id"/>, Code AIC14 <xsl:value-of select="$idAIC14"/>, Data_144 <xsl:value-of select="$AIC14_oeuvre_144"/> </xsl:message>
		<xsl:message>Notice <xsl:value-of select="../../@id"/>, Code AIC14 <xsl:value-of select="$idAIC14"/>, Data_444 <xsl:value-of select="$AIC14_oeuvre_444"/> </xsl:message>
		-->
		
		<xsl:comment> Nom du compositeur + Nom de l’oeuvre  </xsl:comment>
		<mus:U68_has_variant_title>
			<ecrm:E35_Title>
				<rdfs:label>
					<xsl:value-of select="concat($AIC14_compositeur,'. - ',$AIC14_oeuvre_144)"/>	
				</rdfs:label>
			</ecrm:E35_Title>
		</mus:U68_has_variant_title>
		
	</xsl:template>
	
	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='600$3']">
		<xsl:comment> 600$3 Lien vers l’autorité </xsl:comment>
		<ecrm:P129_is_about rdf:resource="{mus:reference_personne(normalize-space(.))}"/>
	</xsl:template>
	
	
	<!-- 601 -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='601$3']">		
		<!-- Faire un lien vers l’autorité collectivité -->
		<xsl:comment> Lien vers l’autorité collectivité </xsl:comment>	
		<ecrm:P129_is_about rdf:resource="{mus:reference_collectivite(normalize-space(.))}" />		
	</xsl:template>
	
	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='610$b']">
		<xsl:variable name="data_b" select="./data"/>
		<xsl:variable name="data_610_3" select="../SOUSCHAMP[@UnimarcSubfield ='610$3']/data"/>
		<xsl:if test="$data_b = '03'">
			<xsl:for-each select="$data_610_3">
				<xsl:comment> 603 Geographical </xsl:comment>
				<mus:U65_has_geographical_context rdf:resource="{mus:reference_thesaurus(.)}"/>
			</xsl:for-each>
		</xsl:if>
		
		<xsl:if test="$data_b = '04'">
			<xsl:for-each select="$data_610_3">
				<xsl:comment> 604 Genre </xsl:comment>
				<mus:U12_has_genre rdf:resource="{mus:reference_thesaurus($data_610_3)}"/>
			</xsl:for-each>
		</xsl:if>
		
		<xsl:if test="not(index-of(('03','04','06','06b','06c'),$data_b))">
			<xsl:for-each select="$data_610_3">
				<xsl:comment>  </xsl:comment>
				<mus:U19_is_categorized_as rdf:resource="{mus:reference_thesaurus(.)}"/>
			</xsl:for-each>
		</xsl:if>		
	</xsl:template>
	
	
	
	<!-- Activitiy Event 700$a -->
	<!-- 700, 701, 702$a Lien vers une autorité personne -->	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='700$3']" mode="Activity_Event">
		
		<xsl:variable name="idFunction" select="../SOUSCHAMP[@UnimarcSubfield='700$4']/data"/>
		
		<xsl:comment>700$a Lien vers une autorité personne</xsl:comment>
		<ecrm:P9_consists_of>
			<ecrm:E7_Activity>			
				<!-- 700, 701, 702$a Lien vers une autorité personne -->
				<xsl:for-each select="./data">
					<xsl:variable name="id700_3" select="."/>
					<ecrm:P14_carried_out_by rdf:resource="{mus:reference_personne($id700_3)}" />
				</xsl:for-each>
				
				<!-- 700, 701, 710 ou 711 $4 Convertir les fonctions d’Aloes vers le référentiel DOREMUS : http://data.doremus.org/vocabulary/function -->
				<mus:U31_had_function rdf:resource="http://data.doremus.org/vocabulary/function/author" />
			</ecrm:E7_Activity>
		</ecrm:P9_consists_of>							
	</xsl:template>
	
	<!-- Activitiy Event 701$a -->
	<!-- 700, 701, 702$a Lien vers une autorité personne -->	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='701$3']" mode="Activity_Event">
		
		<xsl:variable name="idPerson" select="../SOUSCHAMP[@UnimarcSubfield='701$3']/data"/>
		<xsl:variable name="idFunction" select="../SOUSCHAMP[@UnimarcSubfield='701$4']/data"/>
		<xsl:comment>701$a Lien vers une autorité personne</xsl:comment>
		<ecrm:P9_consists_of>
			<ecrm:E7_Activity>			
				<!-- 700, 701, 702$a Lien vers une autorité personne -->
				<xsl:for-each select="./data">
					<xsl:variable name="id701_3" select="."/>
					<ecrm:P14_carried_out_by rdf:resource="{mus:reference_personne($id701_3)}" />
				</xsl:for-each>
				<!-- 700, 701, 710 ou 711 $4 Convertir les fonctions d’Aloes vers le référentiel DOREMUS : http://data.doremus.org/vocabulary/function -->
				<mus:U31_had_function rdf:resource="http://data.doremus.org/vocabulary/function/author" />
			</ecrm:E7_Activity>
		</ecrm:P9_consists_of>							
	</xsl:template>
	
	<!-- Activitiy Event 702$a -->
	<!-- 700, 701, 702$a Lien vers une autorité personne -->	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='702$3']" mode="Activity_Event">
	
		<xsl:comment>702$a Lien vers une autorité personne</xsl:comment>
		<ecrm:P9_consists_of>
			<ecrm:E7_Activity>			
				<!-- 700, 701, 702$a Lien vers une autorité personne -->
				<xsl:for-each select="./data">
					<xsl:variable name="id702_3" select="."/>
					<ecrm:P14_carried_out_by rdf:resource="{mus:reference_personne($id702_3)}" />
				</xsl:for-each>
				<!-- 7700, 701, 710 ou 711 $4 Convertir les fonctions d’Aloes vers le référentiel DOREMUS : http://data.doremus.org/vocabulary/function -->
				<mus:U31_had_function rdf:resource="http://data.doremus.org/vocabulary/function/author" />
			</ecrm:E7_Activity>
		</ecrm:P9_consists_of>							
	</xsl:template>
	
	
	<!-- 710, 711, 712$a Lien vers une autorité collectivité --> 	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='710$3']" mode="Activity_Event">
	
		<xsl:variable name="idFunction" select="../SOUSCHAMP[@UnimarcSubfield='710$4']/data"/>
		<xsl:comment>710$a Lien vers une autorité collectivité</xsl:comment>
		<ecrm:P9_consists_of>
			<ecrm:E7_Activity>			
				<xsl:for-each select="./data">
					<xsl:variable name="id710_3" select="."/>
					<ecrm:P14_carried_out_by rdf:resource="{mus:reference_collectivite($id710_3)}" />
				</xsl:for-each>
				<!-- 7700, 701, 710 ou 711 $4 Convertir les fonctions d’Aloes vers le référentiel DOREMUS : http://data.doremus.org/vocabulary/function -->
				<mus:U31_had_function rdf:resource="http://data.doremus.org/vocabulary/function/author" />
			</ecrm:E7_Activity>
		</ecrm:P9_consists_of>							
	</xsl:template>
	
	<!-- Activitiy Event 711$a -->
	<!-- 710, 711, 712$a Lien vers une autorité collectivité -->	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='711$3']" mode="Activity_Event">
	
		<xsl:variable name="idFunction" select="../SOUSCHAMP[@UnimarcSubfield='711$4']/data"/>
		<xsl:comment>711$a Lien vers une autorité collectivité</xsl:comment>
		<ecrm:P9_consists_of>
			<ecrm:E7_Activity>			
				
				<xsl:for-each select="./data">
					<xsl:variable name="id711_3" select="."/>
					<ecrm:P14_carried_out_by rdf:resource="{mus:reference_collectivite($id711_3)}" />
				</xsl:for-each>
				<!-- 7700, 701, 710 ou 711 $4 Convertir les fonctions d’Aloes vers le référentiel DOREMUS : http://data.doremus.org/vocabulary/function -->
				<mus:U31_had_function rdf:resource="http://data.doremus.org/vocabulary/function/author" />
			</ecrm:E7_Activity>
		</ecrm:P9_consists_of>							
	</xsl:template>
	
	<!-- Activitiy Event 712$a -->
	<!-- 710, 711, 712$a Lien vers une autorité collectivité -->	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='712$3']" mode="Activity_Event">
	
		<xsl:comment>712$a Lien vers une autorité collectivité</xsl:comment>
		<ecrm:P9_consists_of>
			<ecrm:E7_Activity>			
				
				<xsl:for-each select="./data">
					<xsl:variable name="id712_3" select="."/>
					<ecrm:P14_carried_out_by rdf:resource="{mus:reference_collectivite($id712_3)}" />
				</xsl:for-each>
				
				<!-- 7700, 701, 710 ou 711 $4 Convertir les fonctions d’Aloes vers le référentiel DOREMUS : http://data.doremus.org/vocabulary/function -->
				<mus:U31_had_function rdf:resource="http://data.doremus.org/vocabulary/function/author" />
			</ecrm:E7_Activity>
		</ecrm:P9_consists_of>							
	</xsl:template>
	
	<!-- Casting Detail Simple 940 -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='940$a']" mode="Voix_Solistes">
		<xsl:comment>940</xsl:comment>
		<xsl:variable name="data" select="normalize-space(.)"/>
		
		<xsl:choose>
			<xsl:when test="$data='voix'">
				<mus:U36_foresees_responsibility rdf:resource="http://data.doremus.org/vocabulary/responsibility/soloist"/>
			</xsl:when>
			<xsl:otherwise>
				
				<mus:U2_foresees_use_of_medium_of_performance rdf:resource="{mus:medium_vocabulary(mus:DataCastingDetail_a(normalize-space(data)))}"/>
			</xsl:otherwise>
		</xsl:choose>
		
		<mus:U30_foresees_quantity_of_mop>
			<mus:E60_Number><xsl:value-of select="mus:NoInstrument(data)"/></mus:E60_Number>
		</mus:U30_foresees_quantity_of_mop>
		
	</xsl:template>
	
	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='940$x']" mode="Voix_Solistes">
		<ecrm:P3_has_note><xsl:value-of select="normalize-space(data)"/></ecrm:P3_has_note>		
	</xsl:template>
	
	<!-- Casting Detail Simple 942 -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='942$a']" mode="Instruments_solistes">
		<xsl:comment>942</xsl:comment>
		<mus:U2_foresees_use_of_medium_of_performance rdf:resource="{mus:medium_vocabulary(mus:DataCastingDetail_a(data))}"/>		
		
		<mus:U30_foresees_quantity_of_mop>
			<mus:E60_Number><xsl:value-of select="mus:NoInstrument(data)"/></mus:E60_Number>
		</mus:U30_foresees_quantity_of_mop>
	</xsl:template>
	
		
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='942$x']" mode="Instruments_solistes">
		<ecrm:P3_has_note><xsl:value-of select="normalize-space(data)"/></ecrm:P3_has_note>
	</xsl:template>
		
	<!-- Casting Detail Choeur 941 -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='941$a']" mode="Choeur">
	
		<xsl:comment>941</xsl:comment>
		<mus:U2_foresees_use_of_medium_of_performance rdf:resource="{mus:DataCastingDetail_a(data)}"/>
		
		<mus:U30_foresees_quantity_of_mop>
			<mus:E60_Number><xsl:value-of select="mus:NoInstrument(data)"/></mus:E60_Number>
		</mus:U30_foresees_quantity_of_mop>
	</xsl:template>
	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='941$x']" mode="Choeur">
		<ecrm:P3_has_note><xsl:value-of select="normalize-space(data)"/></ecrm:P3_has_note>
	</xsl:template>	
	
	<!-- Casting Detail Gestique 943 -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='943$a']" mode="Gestique">
		<xsl:comment>943</xsl:comment>
		<mus:U2_foresees_use_of_medium_of_performance rdf:resource="{mus:medium_vocabulary(mus:DataCastingDetail_a(normalize-space(data)))}"/>
		
		<mus:U30_foresees_quantity_of_mop>
			<mus:E60_Number><xsl:value-of select="mus:NoInstrument(data)"/></mus:E60_Number>
		</mus:U30_foresees_quantity_of_mop>
	</xsl:template>
	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='943$x']" mode="Gestique">
		<ecrm:P3_has_note><xsl:value-of select="normalize-space(data)"/></ecrm:P3_has_note>
	</xsl:template>
	
	<!-- Famille des bois 945 -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='945$a']" mode="Famille_des_bois">
	
		<xsl:comment>945</xsl:comment>
		
		<mus:U2_foresees_use_of_medium_of_performance rdf:resource="{mus:medium_vocabulary(mus:DataCastingDetail_a(data))}"/>
		
		<mus:U30_foresees_quantity_of_mop>
			<mus:E60_Number><xsl:value-of select="mus:NoInstrument(data)"/></mus:E60_Number>
		</mus:U30_foresees_quantity_of_mop>
	</xsl:template>
	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='945$x']" mode="Fam_des_bois">
		<ecrm:P3_has_note><xsl:value-of select="normalize-space(data)"/></ecrm:P3_has_note>
	</xsl:template>
	
	<!-- Famille des saxophones 946 -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='946$a']" mode="Fam_des_sax">
		<xsl:comment>946</xsl:comment>
		<mus:U2_foresees_use_of_medium_of_performance rdf:resource="{mus:DataCastingDetail_a(data)}"/>
		
		<mus:U30_foresees_quantity_of_mop>
			<mus:E60_Number><xsl:value-of select="mus:NoInstrument(data)"/></mus:E60_Number>
		</mus:U30_foresees_quantity_of_mop>
	</xsl:template>
		
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='946$x']" mode="Fam_des_sax">
		<ecrm:P3_has_note><xsl:value-of select="normalize-space(data)"/></ecrm:P3_has_note>
	</xsl:template>
	
	<!-- Famille des cuivres 947 -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='947$a']" mode="Fam_des_cuivres">
	
		<xsl:comment>947</xsl:comment>
		<mus:U2_foresees_use_of_medium_of_performance rdf:resource="{mus:DataCastingDetail_a(data)}"/>
		
		<mus:U30_foresees_quantity_of_mop>
			<mus:E60_Number><xsl:value-of select="mus:NoInstrument(data)"/></mus:E60_Number>
		</mus:U30_foresees_quantity_of_mop>
	</xsl:template>
		
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='947$x']" mode="Fam_des_cuivres">
		<ecrm:P3_has_note><xsl:value-of select="normalize-space(data)"/></ecrm:P3_has_note>
	</xsl:template>	
		
	<!-- Famille des percussions 948 -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='948$a']" mode="Fam_des_percussions">
		<xsl:comment>948</xsl:comment>
		<mus:U2_foresees_use_of_medium_of_performance rdf:resource="{mus:DataCastingDetail_a(data)}"/>
		
		<mus:U30_foresees_quantity_of_mop>
			<mus:E60_Number><xsl:value-of select="mus:NoInstrument(data)"/></mus:E60_Number>
		</mus:U30_foresees_quantity_of_mop>
	</xsl:template>
	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='948$x']" mode="Fam_des_percussions">
		<ecrm:P3_has_note><xsl:value-of select="normalize-space(data)"/></ecrm:P3_has_note>
	</xsl:template>	
	
	<!-- Famille des claviers 949 -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='949$a']" mode="Fam_des_claviers">
	
		<xsl:comment>949</xsl:comment>
		
		<mus:U2_foresees_use_of_medium_of_performance rdf:resource="{mus:medium_vocabulary(mus:DataCastingDetail_a(data))}"/>
		
		<mus:U30_foresees_quantity_of_mop>
			<mus:E60_Number><xsl:value-of select="mus:NoInstrument(data)"/></mus:E60_Number>
		</mus:U30_foresees_quantity_of_mop>
	</xsl:template>
	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='949$x']" mode="Fam_des_claviers">
		<ecrm:P3_has_note><xsl:value-of select="normalize-space(data)"/></ecrm:P3_has_note>
	</xsl:template>
	
	<!-- Famille des cordes pincées 950 -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='950$a']" mode="Fam_des_cordes_pincées">
	
		<xsl:comment>950</xsl:comment>
		
		<mus:U2_foresees_use_of_medium_of_performance rdf:resource="{mus:medium_vocabulary(mus:DataCastingDetail_a(normalize-space(data)))}"/>
		
		<mus:U30_foresees_quantity_of_mop>
			<mus:E60_Number><xsl:value-of select="mus:NoInstrument(data)"/></mus:E60_Number>
		</mus:U30_foresees_quantity_of_mop>
	</xsl:template>
	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='950$x']" mode="Fam_des_cordes_pincées">
		<ecrm:P3_has_note><xsl:value-of select="normalize-space(data)"/></ecrm:P3_has_note>
	</xsl:template>
	
	<!-- Famille des cordes frottées 951 -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='951$a']" mode="Fam_des_cordes_frot">
	
		<xsl:comment>951</xsl:comment>
		
		<mus:U2_foresees_use_of_medium_of_performance rdf:resource="{mus:medium_vocabulary(mus:DataCastingDetail_a(normalize-space(data)))}"/>
		
		<mus:U30_foresees_quantity_of_mop>
			<mus:E60_Number><xsl:value-of select="mus:NoInstrument(data)"/></mus:E60_Number>
		</mus:U30_foresees_quantity_of_mop>
	</xsl:template>
	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='951$x']" mode="Fam_des_cordes_frot">
		<ecrm:P3_has_note><xsl:value-of select="normalize-space(data)"/></ecrm:P3_has_note>
	</xsl:template>
	
	<!-- Instruments divers 952 -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='952$a']" mode="Instruments_Divers">
	
		<xsl:comment>952</xsl:comment>
		<xsl:comment><xsl:value-of select="mus:DataCastingDetail_a(data)"/></xsl:comment>		
		<mus:U2_foresees_use_of_medium_of_performance rdf:resource="{mus:medium_vocabulary(mus:DataCastingDetail_a(normalize-space(data)))}"/>
		
		<mus:U30_foresees_quantity_of_mop>
			<mus:E60_Number><xsl:value-of select="mus:NoInstrument(data)"/></mus:E60_Number>
		</mus:U30_foresees_quantity_of_mop>
	</xsl:template>
	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='952$x']" mode="Instruments_Divers">
		<ecrm:P3_has_note><xsl:value-of select="normalize-space(data)"/></ecrm:P3_has_note>
	</xsl:template>
	
	<!-- Electroacoustique 953 -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='953$a']" mode="Electroacoustique">
	
		<xsl:comment>953</xsl:comment>
		
		<mus:U2_foresees_use_of_medium_of_performance rdf:resource="{mus:medium_vocabulary(mus:DataCastingDetail_a(normalize-space(data)))}"/>
		
		<mus:U30_foresees_quantity_of_mop>
			<mus:E60_Number><xsl:value-of select="mus:NoInstrument(data)"/></mus:E60_Number>
		</mus:U30_foresees_quantity_of_mop>
	</xsl:template>
	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='953$x']" mode="Electroacoustique">
		<ecrm:P3_has_note><xsl:value-of select="normalize-space(data)"/></ecrm:P3_has_note>
	</xsl:template>
	
	<!-- Ensemble 956 -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='956$a']" mode="Ensemble">
	
		<xsl:comment>956</xsl:comment>
		
		<mus:U2_foresees_use_of_medium_of_performance rdf:resource="{mus:medium_vocabulary(mus:DataCastingDetail_a(normalize-space(data)))}"/>
		
		<mus:U30_foresees_quantity_of_mop>
			<mus:E60_Number><xsl:value-of select="mus:NoInstrument(data)"/></mus:E60_Number>
		</mus:U30_foresees_quantity_of_mop>
	</xsl:template>
	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='956$x']" mode="Ensemble">
		<ecrm:P3_has_note><xsl:value-of select="normalize-space(data)"/></ecrm:P3_has_note>
	</xsl:template>
	
	
	
	
	<!-- affichage seulement les resultat -->
	<xsl:template match="text()" mode="#all"></xsl:template>

</xsl:stylesheet>