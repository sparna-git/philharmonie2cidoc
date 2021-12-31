<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:mus="http://data.doremus.org/ontology#"
	xmlns:efrbroo="http://erlangen-crm.org/efrbroo/"
	xmlns:ecrm="http://erlangen-crm.org/current/"
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
							
				<xsl:apply-templates select="champs[@UnimarcTag != '911' and @UnimarcTag != '700']" />
			
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
					<mus:R24_created rdf:resource="{mus:URI-F24_Expression(@id)}" />
					
					<!-- 911 -->
					<xsl:apply-templates select="champs[@UnimarcTag = '911']"/>
					
					<!-- 700, 701, 702, 710, 711, 712 -->
					<xsl:apply-templates select="champs[@UnimarcTag = '700']" mode="Activity_Event"/>
					
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
			
			<xsl:if test="$data_has_time_210_d">
				<ecrm:P4_has_time-span>
					<ecrm:E52_Time-Span>
						<xsl:value-of select="ecrm:has_time(../@id,normalize-space($data_has_time_210_d))"/>
					</ecrm:E52_Time-Span>
				</ecrm:P4_has_time-span>
			</xsl:if>
			<xsl:if test="$data_has_time_214_d">
				<ecrm:P4_has_time-span>
					<ecrm:E52_Time-Span>
						<xsl:value-of select="ecrm:has_time(../@id,normalize-space($data_has_time_214_d))"/>
					</ecrm:E52_Time-Span>
				</ecrm:P4_has_time-span>
			</xsl:if>
			
			<xsl:comment>Description de l’activité d’édition F30 Publication Event pour le 911$a</xsl:comment>
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
	
	
	<!-- 500$3 lien vers le titre uniforme musical (notice d’autorité de type AIC14).-->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield ='500$3']">
		<xsl:variable name="idAIC14" select="normalize-space(.)"/>
		
		<!-- TUM-Compositeur-->
		<!-- a- Nom du compositeur : 
			Données : AIC14:322$a $m
			séparer le 322$a et le 322$m par une virgule, si le $m est rempli.
			Faire suivre par un point et un tiret (. -)
			 -->
		<xsl:variable name="AIC14_compositeur" select="mus:Titre_Uniforme_Musical(../../@id,$idAIC14,'322')"/>
		
		<!-- b- Nom de l’oeuvre : -->
		<xsl:variable name="AIC14_oeuvre_144" select="mus:Titre_Uniforme_Musical(../../@id,$idAIC14,'144')"/>
		<xsl:message>Ref <xsl:value-of select="../../@id"/>,AIC <xsl:value-of select="$idAIC14"/>,Oeuvre144 <xsl:value-of select="$AIC14_oeuvre_144"/></xsl:message>
		
		
		<xsl:variable name="AIC14_oeuvre_444" select="'1'"/>
		
		<!--  Regles  -->
		<!-- Données : 
			AIC14:144 ou AIC14:444 {$a $c $e $g $h $i $j $k $n $p $q $r $t $u.}			
			AIC14:444 ou AIC14:444 {$a $c $e $g $h $i $j $k $n $p $r $t $u.}
			
			Cas 1- si 144 ou 444 $g, $c, $h et $i sont vides (le plus courant pour reconstituer un TUM ) : 
			 * concaténer les sous-zones suivantes (si elles sont remplies), en respectant l'ordre indiqué et en séparant 
			 	chaque occurence par un point et un espace : {$a. $r. $n. $k. $p. $t. $u}
			
				puis (si $e, $j ou $q ne sont pas vides), ajouter à la suite : une parenthèse, 
				chaque occurrence non vides (séparées par un point-virgule) de $e; $q); $j puis fermer la parenthèse. 
			
			Cas 2- si $i ou $h sont remplis mais que $g ou $c sont vides :
				Reprendre les instructions précédentes et ajouter à la fin, séparés par un point et un espace : $h. $i. 
			
			Cas 3- si $g ou $c ne sont pas vides : {$a. $g. $c. $i. $h. $r. $n. $k. $p. $t . $u}
			
			si besoin, voici la signification des sous-champs : 
					$a (titre), 
					$c (Titre original de l'oeuvre), 
					$e (qualificatif), $g (Auteur du thème adapté), 
					$h (Numéro de partie), $i (titre de partie), 
					$j (année), $k (cat.thématique), 
					$n (n° d'ordre), 
					$p (opus), 
					$q (version), 
					$r (instrumentation), 
					$t (tonalité), 
					$u (surnom).
			
				c- Elément additionnel présent dans la notice de la partition
				Dans la notice UNI5, un qualificatif est parfois ajouté à la suite du titre uniforme musical en 500$w. 
				Lorsque c’est le cas, l’ajouter dans la variante de titre, à la suite des autres formes.: ??
 			-->
		
		
		<!--  
		<xsl:message>Validar_function <xsl:value-of select="mus:Titre_Uniforme_Musical_result(../@id,$idAIC14,$AIC14_oeuvre_144)"/></xsl:message>
		-->
		 
	</xsl:template>
	
	
	<!-- Activitiy Event 700$a -->
	<!-- 700, 701, 702$a Lien vers une autorité personne -->	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='700$a']" mode="Activity_Event">
		
		<xsl:comment>700$a Lien vers une autorité personne</xsl:comment>
		<ecrm:P9_consists_of>
			<ecrm:E7_Activity>			
				<!-- 700, 701, 702$a Lien vers une autorité personne -->
				<ecrm:P14_carried_out_by rdf:resource="..." />
				
				<!-- 7700, 701, 710 ou 711 $4 Convertir les fonctions d’Aloes vers le référentiel DOREMUS : http://data.doremus.org/vocabulary/function -->
				<mus:U31_had_function rdf:resource="http://data.doremus.org/vocabulary/function/author" />
			</ecrm:E7_Activity>
		</ecrm:P9_consists_of>							
	</xsl:template>
	
	<!-- Activitiy Event 701$a -->
	<!-- 700, 701, 702$a Lien vers une autorité personne -->	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='701$a']" mode="Activity_Event">
		<xsl:comment>701$a Lien vers une autorité personne</xsl:comment>
		<ecrm:P9_consists_of>
			<ecrm:E7_Activity>			
				<!-- 700, 701, 702$a Lien vers une autorité personne -->
				<ecrm:P14_carried_out_by rdf:resource="..." />
				
				<!-- 7700, 701, 710 ou 711 $4 Convertir les fonctions d’Aloes vers le référentiel DOREMUS : http://data.doremus.org/vocabulary/function -->
				<mus:U31_had_function rdf:resource="http://data.doremus.org/vocabulary/function/author" />
			</ecrm:E7_Activity>
		</ecrm:P9_consists_of>							
	</xsl:template>
	
	<!-- Activitiy Event 702$a -->
	<!-- 700, 701, 702$a Lien vers une autorité personne -->	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='702$a']" mode="Activity_Event">
		<xsl:comment>702$a Lien vers une autorité personne</xsl:comment>
		<ecrm:P9_consists_of>
			<ecrm:E7_Activity>			
				<!-- 700, 701, 702$a Lien vers une autorité personne -->
				<ecrm:P14_carried_out_by rdf:resource="..." />
				
				<!-- 7700, 701, 710 ou 711 $4 Convertir les fonctions d’Aloes vers le référentiel DOREMUS : http://data.doremus.org/vocabulary/function -->
				<mus:U31_had_function rdf:resource="http://data.doremus.org/vocabulary/function/author" />
			</ecrm:E7_Activity>
		</ecrm:P9_consists_of>							
	</xsl:template>
	
	
	<!-- Activitiy Event 700$a -->
	<!-- 710, 711, 712$a Lien vers une autorité collectivité --> 	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='710$a']" mode="Activity_Event">
		<xsl:comment>710$a Lien vers une autorité collectivité</xsl:comment>
		<ecrm:P9_consists_of>
			<ecrm:E7_Activity>			
				<!-- 700, 701, 702$a Lien vers une autorité personne -->
				<ecrm:P14_carried_out_by rdf:resource="..." />
				
				<!-- 7700, 701, 710 ou 711 $4 Convertir les fonctions d’Aloes vers le référentiel DOREMUS : http://data.doremus.org/vocabulary/function -->
				<mus:U31_had_function rdf:resource="http://data.doremus.org/vocabulary/function/author" />
			</ecrm:E7_Activity>
		</ecrm:P9_consists_of>							
	</xsl:template>
	
	<!-- Activitiy Event 711$a -->
	<!-- 710, 711, 712$a Lien vers une autorité collectivité -->	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='711$a']" mode="Activity_Event">
		<xsl:comment>711$a Lien vers une autorité collectivité</xsl:comment>
		<ecrm:P9_consists_of>
			<ecrm:E7_Activity>			
				<!-- 700, 701, 702$a Lien vers une autorité personne -->
				<ecrm:P14_carried_out_by rdf:resource="..." />
				
				<!-- 7700, 701, 710 ou 711 $4 Convertir les fonctions d’Aloes vers le référentiel DOREMUS : http://data.doremus.org/vocabulary/function -->
				<mus:U31_had_function rdf:resource="http://data.doremus.org/vocabulary/function/author" />
			</ecrm:E7_Activity>
		</ecrm:P9_consists_of>							
	</xsl:template>
	
	<!-- Activitiy Event 712$a -->
	<!-- 710, 711, 712$a Lien vers une autorité collectivité -->	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='712$a']" mode="Activity_Event">
		<xsl:comment>712$a Lien vers une autorité collectivité</xsl:comment>
		<ecrm:P9_consists_of>
			<ecrm:E7_Activity>			
				<!-- 700, 701, 702$a Lien vers une autorité personne -->
				<ecrm:P14_carried_out_by rdf:resource="..." />
				
				<!-- 7700, 701, 710 ou 711 $4 Convertir les fonctions d’Aloes vers le référentiel DOREMUS : http://data.doremus.org/vocabulary/function -->
				<mus:U31_had_function rdf:resource="http://data.doremus.org/vocabulary/function/author" />
			</ecrm:E7_Activity>
		</ecrm:P9_consists_of>							
	</xsl:template>
	
	<!-- affichage seulement les resultat -->
	<xsl:template match="text()" mode="#all"></xsl:template>

</xsl:stylesheet>