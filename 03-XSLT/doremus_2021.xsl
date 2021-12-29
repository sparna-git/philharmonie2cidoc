<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:epvoc="https://data.europarl.europa.eu/def/epvoc#"
	xmlns:sparnaf="http://data.sparna.fr/function/sparnaf#"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:mus="http://data.doremus.org/ontology#"
	xmlns:efrbroo="http://erlangen-crm.org/efrbroo/"
	xmlns:ecrm="http://erlangen-crm.org/current/"
>
 
 	<!-- Import URI stylesheet -->
	<xsl:import href="uris.xsl" />
	<!-- Import builtins stylesheet 
	<xsl:import href="builtins.xsl" />
 	-->
 
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
			
			<efrbroo:F24_Publication_Expression rdf:about="{mus:URI-F24_Expression(@id)}">
				
				<!-- en dur -->
				<mus:U227_has_content_type rdf:resource="http://www.rdaregistry.info/termList/RDAContentType/#1010" />
				
				<!-- UNI5 -->
				<xsl:if test="@type = 'UNI:5'">
					<!-- Créer un nouvel identifiant à chaque fois que l’une de ces zones est remplie : 
							UNI5 : notice id
							UNI5 : 010$a
							UNI5 : 013$a
					 -->
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
							
				<xsl:apply-templates select="champs[@UnimarcTag != '911']"/>
			
			</efrbroo:F24_Publication_Expression>
			
			<!-- Event -->
			<xsl:apply-templates select="champs[@UnimarcTag = '911']"/>		
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
	
	<!-- 600 -->
	<xsl:template match="champs[@UnimarcTag='600']">
		<!-- 600 $a $b Faire un lien vers l’autorité personne -->
		<!--
		<ecrm:P129_is_about rdf:resource="http://...." />
		-->	
	</xsl:template>
	
	<!-- 601 -->
	<xsl:template match="champs[@UnimarcTag='601']">
		<!-- 600 $a $b Faire un lien vers l’autorité personne -->
		<!--
		<ecrm:P129_is_about rdf:resource="http://...." />
		-->	
	</xsl:template>
	
	
	
	<!-- 610 -->
	<xsl:template match="champs[@UnimarcTag='610']">
		
		<xsl:variable name="data_b" select="SOUSCHAMP[@UnimarcSubfield ='610$b']/data"/>
		
		<xsl:if test="SOUSCHAMP[@UnimarcSubfield ='610$a']">
			<xsl:choose>
				<!-- Prendre la valeur de 610$a lorsque 610$b=03 (code signifiant que le descripteur est typé comme un nom géographique) -->
				<xsl:when test="$data_b = '03'">
					<mus:U65_has_geographical_context>
						<mus:M40_Context>
							<rdfs:label><xsl:value-of select="SOUSCHAMP[@UnimarcSubfield='610$a']/data"/></rdfs:label>	
						</mus:M40_Context>
					</mus:U65_has_geographical_context>	
				</xsl:when>
				<!-- Prendre la valeur de 610$a lorsque 610$b=04 (code signifiant que le descripteur est typé comme un genre musical) -->
				<xsl:when test="$data_b = '04'">
					<mus:U12_has_genre>
	 					<mus:M5_Genre>
				 			<rdfs:label><xsl:value-of select="SOUSCHAMP[@UnimarcSubfield='610$a']/data"/></rdfs:label> 
				 		</mus:M5_Genre>
				 	</mus:U12_has_genre>
				</xsl:when>
				<!-- Prendre la valeur de 610$a pour les toutes les occurrences où le 610$b est différent 03, 04, 06, 06b, 06c -->
				<xsl:when test="$data_b != '03' 
							    or 
							    $data_b !='04' 
							    or
							    $data_b != '06'
							    or 
							    $data_b !='06b'
							    or 
							    $data_b !='06c'">
					<mus:U19_is_categorized_as>
						<mus:M19_Categorization>
							<rdfs:label><xsl:value-of select="SOUSCHAMP[@UnimarcSubfield='610$a']/data"/></rdfs:label>
						</mus:M19_Categorization>		
					</mus:U19_is_categorized_as>
				</xsl:when>
			</xsl:choose>
		</xsl:if>		
	</xsl:template>
	
	
	<!-- Event 	
		Créer une instance de F30 Publication Event si la notice comporte au moins un champ 911.	
	-->	
	<xsl:template match="champs[@UnimarcTag='911']">
	
		<!-- Description de l’activité d’édition F30 Publication Event pour le 911$a -->
		<efrbroo:F30_Publication_Event>
	
			<!-- 911$a Créer une instance de  F30 Publication Event si la notice comporte au moins un champ 911.  -->
			<!-- Lien vers la Publication Expression de Partition -->
			<mus:R24_created rdf:resource="{mus:URI-F24_Expression(../@id)}" />
			
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
			<xsl:variable name="data_has_time_210_d" select="../champs[@UnimarcTag='210']/SOUSCHAMP[@UnimarcSubfield='210$d']"/>
			<xsl:variable name="data_has_time_214_d" select="../champs[@UnimarcTag='214']/SOUSCHAMP[@UnimarcSubfield='214$d']"/>
			
			<xsl:if test="$data_has_time_210_d">
				<xsl:message><xsl:value-of select="concat('Value 210: ',sparnaf:has_time($data_has_time_210_d))"/></xsl:message>
				
			</xsl:if>
			
			<ecrm:P4_has_time-span>
				<ecrm:E52_Time-Span>
					<ecrm:P82_at_some_time_within rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear">...</ecrm:P82_at_some_time_within>
				</ecrm:E52_Time-Span>	
			</ecrm:P4_has_time-span>
			
			<!--  
			<xsl:message>Ref  <xsl:value-of select="../@id"/> ,210_time <xsl:value-of select="normalize-space($data_has_time_210_d)"/></xsl:message>
			-->
			
			<ecrm:P9_consists_of>		
				<!-- Créer une instance de E7 Activity pour chaque champ 911. -->
				<ecrm:E7_Activity>
					<!-- 911$a Lien vers l’autorité collectivité éditeur -->
					<ecrm:P14_carried_out_by rdf:resource="..." />
	
					<!-- en dure -->
					<!-- 911$a Toujours préciser le rôle “éditeur” issu du référentiel http://data.doremus.org/vocabulary/function/publisher -->
					<mus:U31_had_function rdf:resource="http://data.doremus.org/vocabulary/function/editor" />				
				</ecrm:E7_Activity>	
			</ecrm:P9_consists_of>	
		</efrbroo:F30_Publication_Event>				
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
	
	<!-- affichage seulement les resultat -->
	<xsl:template match="text()"/>

</xsl:stylesheet>