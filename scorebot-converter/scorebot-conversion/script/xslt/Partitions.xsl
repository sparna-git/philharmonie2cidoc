<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:mus="http://data.doremus.org/ontology#"
	xmlns:efrbroo="http://erlangen-crm.org/efrbroo/"
	xmlns:ecrm="http://erlangen-crm.org/current/"
	xmlns:philhar="http://data.philharmoniedeparis.fr/ontology/partitions#"
	xmlns:sparnaf="http://data.sparna.fr/function/sparnaf#"
	xmlns:schema="http://schema.org/" exclude-result-prefixes="xsl"
>
 
 	<!-- Format -->
	<xsl:output indent="yes" method="xml" />
	
 	<!-- Import URI stylesheet -->
	<xsl:import href="uris.xsl" />
	
 	<xsl:template match="/">
		<rdf:RDF>
			<xsl:apply-templates />
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="NOTICES">
		<xsl:apply-templates select="TYPREG" />
	</xsl:template>
	
	<!--
		<NOTICES>
			<TYPREG type="UNI:5">
				<NOTICE type="UNI:5">

				</NOTICE>
				<TYPREG type="UNI:45">
					<NOTICE type="UNI:45">

					</NOTICE>
				</TYPREG>
			</TYPREG>
		</NOTICES>
	-->

	<xsl:template match="NOTICES/TYPREG">
		<xsl:apply-templates select="NOTICE" />
	</xsl:template>
	
	
	<xsl:template match="NOTICE[@type = 'UNI:5']">		
		<xsl:message>::::: Notice <xsl:value-of select="@id"/> :::::</xsl:message>
		<xsl:variable name="notice_for_casting" select="./."/>
		
		<efrbroo:F24_Publication_Expression rdf:about="{mus:URI-Publication_Expression(@id)}">
			
			<!-- en dur -->
			<mus:U227_has_content_type rdf:resource="http://www.rdaregistry.info/termList/RDAContentType/#1010" />
			
			<!-- Créer un nouvel identifiant à chaque fois que l’une de ces zones est remplie : UNI5 : notice id -->
			
			<xsl:if test="@type = 'UNI:5'">
				<ecrm:P1_is_identified_by>
					<ecrm:E42_Identifier rdf:about="{mus:URI-Identifier(@id,@id,'CMPP-ALOES',@type)}">
						<rdfs:label><xsl:value-of select="@id"/></rdfs:label>
							<!-- UNI5 : notice id - Indiquer “CMPP-ALOES” -->
						<ecrm:P2_has_type rdf:resource="http://data.philharmoniedeparis.fr/vocabulary/CMPP-ALOES"/>								
					</ecrm:E42_Identifier>
				</ecrm:P1_is_identified_by>				
			</xsl:if>
			
			<xsl:apply-templates select="champs[
				not(index-of(('700','701','702','710','711','712','911'),@UnimarcTag))
			]" />
			
			<!-- Casting  - Call all data of the one Notice -->
			<xsl:apply-templates select="$notice_for_casting" mode="casting"/>
			
			<!--  Parties de Partitions -->								
			<xsl:apply-templates select="../TYPREG[@type='UNI:45']/NOTICE[@type='UNI:45']" />
			
		</efrbroo:F24_Publication_Expression>
		
		<xsl:if test="champs[@UnimarcTag = '700' or 
							 @UnimarcTag = '701' or 
							 @UnimarcTag = '702' or
							 @UnimarcTag = '710' or
							 @UnimarcTag = '711' or
							 @UnimarcTag = '712' or			
							 @UnimarcTag = '911']">
			
			<!-- Description de l’activité d’édition F30 Publication Event pour le 911$a -->
			<efrbroo:F30_Publication_Event rdf:about="{mus:URI-Publication_Event(@id)}">

				<!-- 911$a Créer une instance de  F30 Publication Event si la notice comporte au moins un champ 911.  -->
				<!-- Lien vers la Publication Expression de Partition -->
				
				<mus:R24_created rdf:resource="{mus:URI-Publication_Expression(@id)}" />
				
				<xsl:apply-templates select="champs[@UnimarcTag = '911' or
													@UnimarcTag = '700' or
													@UnimarcTag = '701' or
													@UnimarcTag = '702' or
													@UnimarcTag = '710' or
													@UnimarcTag = '711' or
													@UnimarcTag = '712']"/>
			</efrbroo:F30_Publication_Event>
			
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
		
		
		<xsl:variable name="typeNotice" select="../@type"/>
		<xsl:variable name="idNotice" select="../@id"/>
		<xsl:variable name="idNoticeMere">
			<xsl:if test="$typeNotice ='UNI:45'">
				<xsl:value-of select="$idNotice/../../../NOTICE/@id"/>
			</xsl:if>
		</xsl:variable>
		
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
				<xsl:choose>
					<xsl:when test="count(SOUSCHAMP[@UnimarcSubfield ='200$h']/data) &gt; 1 ">
						<xsl:variable name="data">
							<xsl:for-each select="SOUSCHAMP[@UnimarcSubfield ='200$h']/data">
								<xsl:value-of select="concat(.,',')"/>
							</xsl:for-each>
						</xsl:variable>
						<xsl:value-of select="concat('. ',substring($data,1,string-length($data)-1))"/>							
					</xsl:when>
					<xsl:otherwise><xsl:value-of select="concat('. ',SOUSCHAMP[@UnimarcSubfield ='200$h']/data)"/></xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:variable>	
		<xsl:variable name="data_i">
			<xsl:if test="SOUSCHAMP[@UnimarcSubfield ='200$i'] and SOUSCHAMP[@UnimarcSubfield ='200$h']">
				<xsl:choose>
					<xsl:when test="count(SOUSCHAMP[@UnimarcSubfield ='200$i']/data) &gt; 1">
						<xsl:variable name="data">
							<xsl:for-each select="SOUSCHAMP[@UnimarcSubfield ='200$i']/data">
								<xsl:value-of select="concat(', ',.)"/>
							</xsl:for-each>
						</xsl:variable>
						<xsl:value-of select="$data"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat(', ',SOUSCHAMP[@UnimarcSubfield ='200$i']/data)"/>
					</xsl:otherwise>
				</xsl:choose>				
			</xsl:if>
			<xsl:if test="SOUSCHAMP[@UnimarcSubfield ='200$i'] and SOUSCHAMP[@UnimarcSubfield !='200$h']">
				<xsl:choose>
					<xsl:when test="count(SOUSCHAMP[@UnimarcSubfield ='200$i']/data) &gt; 1">
						<xsl:variable name="data">
							<xsl:for-each select="SOUSCHAMP[@UnimarcSubfield ='200$i']/data">
								<xsl:value-of select="concat('. ',.)"/>
							</xsl:for-each>
						</xsl:variable>
						<xsl:value-of select="$data"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat('. ',SOUSCHAMP[@UnimarcSubfield ='200$i']/data)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:variable>		
		
		
		<xsl:if test="$data_a">
			<xsl:variable name="idTitleStatement" select="count(preceding-sibling::champs[@UnimarcTag='200'])+1"/>
			<mus:U170_has_title_statement>
				<mus:M156_Title_Statement rdf:about="{mus:URI-Title($idNotice,$idTitleStatement,$typeNotice,$idNoticeMere)}">
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
			<xsl:if test="SOUSCHAMP[@UnimarcSubfield ='200$g']/data">
				<xsl:for-each select="SOUSCHAMP[@UnimarcSubfield ='200$g']/data">
					<xsl:value-of select="concat('; ',.)"/>
				</xsl:for-each>				
			</xsl:if>			
		</xsl:variable>
		
		<xsl:if test="$data_f or $data_g">
			<xsl:variable name="sequence" select="count(preceding-sibling::champs[@UnimarcTag='200'])+1"/>

			<mus:U172_has_statement_of_responsibility_relating_to_title>
				<mus:M157_Statement_of_Responsibility rdf:about="{mus:URI-Responsability($idNotice,$sequence,$typeNotice,$idNoticeMere)}">
					<rdfs:label><xsl:value-of select="concat($data_f,$data_g)"/></rdfs:label>
				</mus:M157_Statement_of_Responsibility>
			</mus:U172_has_statement_of_responsibility_relating_to_title>
		</xsl:if>
		
		
		<!-- UNI5:200$d $e
			Créer autant de titres parallèles qu’il y a de sous-zones $d. 
			Si un $e suit un $d, alors concaténer les deux en les séparant par un ( ; )
		 -->
		 
		 <!-- -->
		<xsl:if test="SOUSCHAMP[@UnimarcSubfield ='200$e']">
			<xsl:variable name="suivi" select="SOUSCHAMP[@UnimarcSubfield ='200$e']/following-sibling::*[1]/@UnimarcSubfield"></xsl:variable>
			
			<xsl:if test="$suivi = '200$d'">
			
				<xsl:variable name="idSequence" select="generate-id()"/>
				
				<xsl:variable name="resultat_e">
					<xsl:choose>
						<xsl:when test="count(SOUSCHAMP[@UnimarcSubfield ='200$e']/data) &gt; 1">
							<xsl:variable name="data">
								<xsl:for-each select="SOUSCHAMP[@UnimarcSubfield ='200$e']/data">
									<xsl:value-of select="concat(.,',')"/>
								</xsl:for-each>
							</xsl:variable>
							<xsl:value-of select="substring($data,1,string-length($data)-1)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="SOUSCHAMP[@UnimarcSubfield ='200$e']/data"/>
						</xsl:otherwise>
					</xsl:choose>				
				</xsl:variable>
				
				<xsl:variable name="resultat_d">
					<xsl:choose>
						<xsl:when test="count(SOUSCHAMP[@UnimarcSubfield ='200$d']/data) &gt; 1">
							<xsl:variable name="data">
								<xsl:for-each select="SOUSCHAMP[@UnimarcSubfield ='200$d']/data">
									<xsl:value-of select="concat(.,',')"/>
								</xsl:for-each>
							</xsl:variable>
							<xsl:value-of select="substring($data,1,string-length($data)-1)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="SOUSCHAMP[@UnimarcSubfield ='200$d']/data"/>
						</xsl:otherwise>
					</xsl:choose>				
				</xsl:variable>
				
				
				<mus:U168_has_parallel_title>
					<ecrm:E35_Title rdf:about="{mus:URI-Title_parallel($idNotice,$idSequence,$typeNotice,$idNoticeMere)}">
						<rdfs:label>
							<xsl:value-of select="concat($resultat_e,';',$resultat_d)"/>
						</rdfs:label>
					</ecrm:E35_Title>		
				</mus:U168_has_parallel_title>
			</xsl:if>
				
		</xsl:if>		
	</xsl:template>
	
	
	<!-- 214 or 210 -->
	<xsl:template match="champs[@UnimarcTag='210' or @UnimarcTag='214']">
	
		<xsl:variable name="typeNotice" select="../@type"/>
		
		<xsl:variable name="idNotice" select="../@id"/>
		<xsl:variable name="idNoticeMere">
			<xsl:if test="$typeNotice ='UNI:45'">
				<xsl:value-of select="$idNotice/../../../NOTICE/@id"/>			
			</xsl:if>			
		</xsl:variable>
		
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
							<xsl:choose>
								<xsl:when test="count(SOUSCHAMP[@UnimarcSubfield ='210$d']/data) &gt; 1">
									<xsl:variable name="data">
										<xsl:for-each select="SOUSCHAMP[@UnimarcSubfield ='210$d']/data">
											<xsl:value-of select="concat(normalize-space(.),',')"/>
										</xsl:for-each>										
									</xsl:variable>
									<xsl:value-of select="concat(', ',substring($data,1,string-length($data)-1))"/>									
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat(', ',SOUSCHAMP[@UnimarcSubfield ='210$d']/data)"/>
								</xsl:otherwise>
							</xsl:choose>
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
			
			<xsl:variable name="idSequence" select="generate-id()"/>
			
			<mus:U184_has_publication_statement>
				<mus:M160_Publication_Statement rdf:about="{mus:URI-Publication($idNotice,$idSequence,$typeNotice,$idNoticeMere)}">
					<rdfs:label><xsl:value-of select="$data"/></rdfs:label>
				</mus:M160_Publication_Statement>	
			</mus:U184_has_publication_statement>
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
	
		<xsl:variable name="typeNotice" select="../@type"/>
		<xsl:variable name="idNotice" select="../@id"/>
		<xsl:variable name="idSequence" select="generate-id()"/>
		<xsl:variable name="idNoticeMere">
			<xsl:if test="$typeNotice ='UNI:45'">
				<xsl:value-of select="$idNotice/../../../NOTICE/@id"/>
			</xsl:if>
		</xsl:variable>
		
	
	
		<!-- UNI5:449$a $f
			Générer une ponctuation entre le contenu des sous-zones : un ( / ) si le $a est suivi d’un $f		
		 -->
		<xsl:if test="SOUSCHAMP[@UnimarcSubfield ='449$a']">
			<xsl:variable name="suivi" select="SOUSCHAMP[@UnimarcSubfield ='449$a']/following-sibling::*[1]/@UnimarcSubfield"></xsl:variable>
			<xsl:if test="$suivi = '449$f'">
				<mus:U68_has_variant_title>
					<ecrm:E35_Title rdf:about="{mus:URI-Title_variant($idNotice,$idSequence,$typeNotice,$idNoticeMere)}">
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
	
		<xsl:variable name="typeNotice" select="../@type"/>
		<xsl:variable name="idNotice" select="../@id"/>
		<xsl:variable name="idSequence" select="generate-id()"/>
		<xsl:variable name="idNoticeMere">
			<xsl:if test="$typeNotice ='UNI:45'">
				<xsl:value-of select="$idNotice/../../../NOTICE/@id"/>
			</xsl:if>
		</xsl:variable>
		
		<!-- UNI5:541 $a $e Générer une ponctuation entre le contenu des sous-zones : deux ( : ) si le $a est suivi d'un $e -->
		<xsl:if test="SOUSCHAMP[@UnimarcSubfield ='541$a']">
			<xsl:variable name="suivi" select="SOUSCHAMP[@UnimarcSubfield ='541$a']/following-sibling::*[1]/@UnimarcSubfield"></xsl:variable>
			
			<xsl:if test="$suivi = '541$e'">
				
				<xsl:variable name="suivi_e">
					<xsl:variable name="data">
						<xsl:for-each select="SOUSCHAMP[@UnimarcSubfield ='541$e']/data">
							<xsl:value-of select="concat(.,',')"/>
						</xsl:for-each>
					</xsl:variable>
					<xsl:value-of select="substring($data,1,string-length($data)-1)"/>
				</xsl:variable>
			
				<mus:U68_has_variant_title>
					<ecrm:E35_Title rdf:about="{mus:URI-Title_variant($idNotice,$idSequence,$typeNotice,$idNoticeMere)}">
						<rdfs:label>
							<xsl:value-of select="concat(SOUSCHAMP[@UnimarcSubfield ='541$a']/data,':',$suivi_e)"/>
						</rdfs:label>
					</ecrm:E35_Title>
				</mus:U68_has_variant_title>
			</xsl:if>				
		</xsl:if>
	</xsl:template>
	

	<xsl:template match="champs[@UnimarcTag='610']">
		<xsl:variable name="data_610_a" select="SOUSCHAMP[@UnimarcSubfield ='610$a']/data"/>
		<xsl:variable name="data_610_b" select="SOUSCHAMP[@UnimarcSubfield ='610$b']/data"/>
		<xsl:variable name="data_610_3" select="SOUSCHAMP[@UnimarcSubfield ='610$3']/data"/>

		<xsl:if test="$data_610_b = '02'">
			<xsl:for-each select="$data_610_3">
				<mus:U66_has_historical_context rdf:resource="{mus:reference_thesaurus(.)}"/>
			</xsl:for-each>
		</xsl:if>


		<xsl:if test="$data_610_b = '03'">
			<xsl:for-each select="$data_610_3">
				<mus:U65_has_geographical_context rdf:resource="{mus:reference_thesaurus(.)}"/>
			</xsl:for-each>
		</xsl:if>
		
		<xsl:if test="$data_610_b = '04' or $data_610_b = '05'">
			<xsl:for-each select="$data_610_3">
				<mus:U12_has_genre rdf:resource="{mus:reference_thesaurus(.)}"/>
			</xsl:for-each>
		</xsl:if>

		<xsl:if test="$data_610_b = '01' or not(SOUSCHAMP[@UnimarcSubfield ='610$b'])">
			<xsl:for-each select="$data_610_3">
				<mus:U19_is_categorized_as rdf:resource="{mus:reference_thesaurus(.)}"/>
			</xsl:for-each>
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
			
		<xsl:variable name="idNotice" select="../@id"/>
		<xsl:variable name="source" select="SOUSCHAMP[@UnimarcSubfield ='911$3']/data"/>
		<xsl:variable name="data_has_time_210_d" select="../champs[@UnimarcTag='210']/SOUSCHAMP[@UnimarcSubfield='210$d'][1]"/>
		<xsl:variable name="data_has_time_214_d" select="../champs[@UnimarcTag='214']/SOUSCHAMP[@UnimarcSubfield='214$d'][1]"/>
		
		<xsl:if test="$data_has_time_210_d != '' or string-length($data_has_time_210_d) &gt; 0">
			<xsl:variable name="data_year_210" select="ecrm:has_time($idNotice,normalize-space($data_has_time_210_d))"/>
			<xsl:if test="$data_year_210">
				<ecrm:P4_has_time-span>
					<ecrm:E52_Time-Span rdf:about="{concat(mus:URI-Publication_Event($idNotice),'/time-span')}">
						<ecrm:P82_at_some_time_within rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear"><xsl:value-of select="$data_year_210"/></ecrm:P82_at_some_time_within>
					</ecrm:E52_Time-Span>
				</ecrm:P4_has_time-span>
			</xsl:if>
		</xsl:if>
		<xsl:if test="$data_has_time_214_d != '' or string-length($data_has_time_214_d) &gt; 0">
			<xsl:variable name="data_year_214" select="ecrm:has_time($idNotice,normalize-space($data_has_time_210_d))"/>
			<xsl:if test="$data_year_214">
				<ecrm:P4_has_time-span>
					<ecrm:E52_Time-Span  rdf:about="{concat(mus:URI-Publication_Event($idNotice),'/time-span')}">
						<ecrm:P82_at_some_time_within rdf:datatype="http://www.w3.org/2001/XMLSchema#gYear"><xsl:value-of select="$data_year_214"/></ecrm:P82_at_some_time_within>
					</ecrm:E52_Time-Span>
				</ecrm:P4_has_time-span>
			</xsl:if>
		</xsl:if>
			
		<ecrm:P9_consists_of>		
			<!-- Créer une instance de E7 Activity pour chaque champ 911. -->
			<ecrm:E7_Activity rdf:about="{mus:URI-Publication_Event_Activity($idNotice,$source,'publisher')}">
				<ecrm:P14_carried_out_by rdf:resource="{mus:reference_collectivite(SOUSCHAMP[@UnimarcSubfield ='911$3']/data)}" />
				<!-- en dur -->
				<!-- 911$a Toujours préciser le rôle “éditeur” issu du référentiel http://data.doremus.org/vocabulary/function/publisher -->
				<!-- <mus:U31_had_function rdf:resource="http://data.doremus.org/vocabulary/function/publisher" /> -->
				<mus:U31_had_function rdf:resource="http://data.bnf.fr/vocabulary/roles/r3250/" />
			</ecrm:E7_Activity>	
		</ecrm:P9_consists_of>			
	</xsl:template>	
	
	<!-- ******* CASTING ******* -->
	<xsl:template match="NOTICE" mode="casting">
		
		<xsl:variable name="idNotice" select="@id"/>
		<xsl:variable name="typeNotice" select="@type"/>
		<xsl:variable name="idNoticeMere">
			<xsl:if test="$typeNotice ='UNI:45'">
				<xsl:value-of select="$idNotice/../../../NOTICE/@id"/>				
			</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="positionCasting" select="position()"/>
		
		<xsl:choose>
			<xsl:when test="./not(champs[@UnimarcTag='954'])">
				<!-- section for the construct one casting simple -->
				<xsl:if test="champs[@UnimarcTag='940' or 
									 @UnimarcTag='942' or
									 @UnimarcTag='941' or
									 @UnimarcTag='943' or
									 @UnimarcTag='945' or
									 @UnimarcTag='946' or
									 @UnimarcTag='947' or
									 @UnimarcTag='948' or
									 @UnimarcTag='949' or
									 @UnimarcTag='950' or
									 @UnimarcTag='951' or
									 @UnimarcTag='953' or
									 @UnimarcTag='956']">
					
					<mus:U13_has_casting>
						<mus:M6_Casting rdf:about="{mus:URI-Casting($idNotice,$positionCasting,$typeNotice,$idNoticeMere)}">
								
							<xsl:apply-templates select="./*" mode="casting_detail">
								<xsl:with-param name="idCasting" select="$positionCasting" tunnel="yes" />							
							</xsl:apply-templates>
							
						</mus:M6_Casting>
					</mus:U13_has_casting>					
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<!-- Nombre total d’instrument dans cette famille -->
				<xsl:variable name="Valide_Option_Casting" select="count(champs[@UnimarcTag='954']/SOUSCHAMP[@UnimarcSubfield='954$t'])"/>
			    			
				<xsl:choose>
					<xsl:when test="$Valide_Option_Casting = 1">
						<xsl:variable name="NoInstuments" select="champs[@UnimarcTag='954']/SOUSCHAMP[@UnimarcSubfield='954$t']/data"/>		
			
						<xsl:variable name="VoixSolistes_a" select="champs[@UnimarcTag='940']/SOUSCHAMP[@UnimarcSubfield='940$a']/data"/>
						<xsl:variable name="InstrumentSolistes_a" select="champs[@UnimarcTag='942']/SOUSCHAMP[@UnimarcSubfield='942$a']/data"/>
						<xsl:variable name="Choeur_a" select="champs[@UnimarcTag='941']/SOUSCHAMP[@UnimarcSubfield='941$a']/data"/>
						<xsl:variable name="Gestique_a" select="champs[@UnimarcTag='943']/SOUSCHAMP[@UnimarcSubfield='943$a']/data"/>
						<!-- ######## Instruments non solistes ######## -->
						<xsl:variable name="FamBois_a" select="champs[@UnimarcTag='945']/SOUSCHAMP[@UnimarcSubfield='945$a']/data"/>
						<xsl:variable name="FamSaxo_a" select="champs[@UnimarcTag='946']/SOUSCHAMP[@UnimarcSubfield='946$a']/data"/>
						<xsl:variable name="FamCuivre_a" select="champs[@UnimarcTag='947']/SOUSCHAMP[@UnimarcSubfield='947$a']/data"/>
						<xsl:variable name="FamPercussions_a" select="champs[@UnimarcTag='948']/SOUSCHAMP[@UnimarcSubfield='948$a']/data"/>
						<xsl:variable name="FamClaviers_a" select="champs[@UnimarcTag='949']/SOUSCHAMP[@UnimarcSubfield='949$a']/data"/>
						<xsl:variable name="FamCordesPincees_a" select="champs[@UnimarcTag='950']/SOUSCHAMP[@UnimarcSubfield='950$a']/data"/>
						<xsl:variable name="FamCordesFrottees_a" select="champs[@UnimarcTag='951']/SOUSCHAMP[@UnimarcSubfield='951$a']/data"/>
						<xsl:variable name="InstrumentsDivers_a" select="champs[@UnimarcTag='952']/SOUSCHAMP[@UnimarcSubfield='952$a']/data"/>
						<xsl:variable name="Electro_a" select="champs[@UnimarcTag='953']/SOUSCHAMP[@UnimarcSubfield='953$a']/data"/>
						<xsl:variable name="Ensemble_a" select="champs[@UnimarcTag='956']/SOUSCHAMP[@UnimarcSubfield='956$a']/data"/>
						
						<!-- Create alternatif -->
						<!-- Si le total d'instrument est different de  -->
						<!-- Voix Soliste -->
						<xsl:variable name="VoixSoliste_TotalInstruments" select="sum(champs[@UnimarcTag='940']/SOUSCHAMP[@UnimarcSubfield='940$a']/sparnaf:isNumber(normalize-space(data)))"/>	            
						<!-- Instruments solistes -->
						<xsl:variable name="InstSoliste_TotalInstruments" select="sum(champs[@UnimarcTag='942']/SOUSCHAMP[@UnimarcSubfield='942$a']/sparnaf:isNumber(normalize-space(data)))"/>
						<!-- Choeur -->
						<xsl:variable name="Choeur_TotalInstruments" select="sum(champs[@UnimarcTag='941']/SOUSCHAMP[@UnimarcSubfield='941$a']/sparnaf:isNumber(normalize-space(data)))"/>
						<!-- Gestique -->
						<xsl:variable name="Gestique_TotalInstruments" select="sum(champs[@UnimarcTag='943']/SOUSCHAMP[@UnimarcSubfield='943$a']/sparnaf:isNumber(normalize-space(data)))"/>
						<!-- Famille des bois -->
						<xsl:variable name="FamBois_TotalInstruments" select="sum(champs[@UnimarcTag='945']/SOUSCHAMP[@UnimarcSubfield='945$a']/sparnaf:isNumber(normalize-space(data)))"/>
						<!-- Famille des saxophones -->
						<xsl:variable name="FamSax_TotalInstruments" select="sum(champs[@UnimarcTag='946']/SOUSCHAMP[@UnimarcSubfield='946$a']/sparnaf:isNumber(normalize-space(data)))"/>
						<!-- Famille des cuivres -->
						<xsl:variable name="FamCuivres_TotalInstruments" select="sum(champs[@UnimarcTag='947']/SOUSCHAMP[@UnimarcSubfield='947$a']/sparnaf:isNumber(normalize-space(data)))"/>
						<!-- Famille des percussions -->
						<xsl:variable name="FamPercu_TotalInstruments" select="sum(champs[@UnimarcTag='948']/SOUSCHAMP[@UnimarcSubfield='948$a']/sparnaf:isNumber(normalize-space(data)))"/>
						<!-- Famille des claviers -->
						<xsl:variable name="FamClaviers_TotalInstruments" select="sum(champs[@UnimarcTag='949']/SOUSCHAMP[@UnimarcSubfield='949$a']/sparnaf:isNumber(normalize-space(data)))"/>
						<!-- Famille des cordes pincées -->
						<xsl:variable name="FamCordesPincees_TotalInstruments" select="sum(champs[@UnimarcTag='950']/SOUSCHAMP[@UnimarcSubfield='950$a']/sparnaf:isNumber(normalize-space(data)))"/>
						<!-- Famille des cordes frottées -->
						<xsl:variable name="FamCordesFrot_TotalInstruments" select="sum(champs[@UnimarcTag='951']/SOUSCHAMP[@UnimarcSubfield='951$a']/sparnaf:isNumber(normalize-space(data)))"/>
						<!-- Instruments divers -->
						<xsl:variable name="InstDivers_TotalInstruments">
							<xsl:variable name="filterInstrument" select="normalize-space(substring-before(data,'('))"/>
							<xsl:choose>
								<xsl:when test="filterInstrument != 'basse_continue'">
									<xsl:value-of select="sum(champs[@UnimarcTag='952']/SOUSCHAMP[@UnimarcSubfield='952$a']/sparnaf:isNumber(normalize-space(data)))"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="sum(0)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<!-- Electroacoustique -->
						<xsl:variable name="Electroacoustique_TotalInstruments" select="sum(champs[@UnimarcTag='953']/SOUSCHAMP[@UnimarcSubfield='953$a']/sparnaf:isNumber(normalize-space(data)))"/>
						<!-- Ensemble -->
						<xsl:variable name="Ensemble_TotalInstruments">
							<xsl:variable name="filterInstrument" select="normalize-space(substring-before(data,'('))"/>
							<xsl:choose>
								<xsl:when test="filterInstrument != 'ensemble_instrumental'">
									<xsl:value-of select="sum(champs[@UnimarcTag='956']/SOUSCHAMP[@UnimarcSubfield='956$a']/sparnaf:isNumber(normalize-space(data)))"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="sum(0)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
			 	
						<!-- Total d'instruments  -->
						<xsl:variable name="sum_total_instruments" select="sum($VoixSoliste_TotalInstruments +
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
						            												   )"/>
						            												   
						 <xsl:choose>
						 	<!-- number($x) = $x ensures that $x is actually a number -->
							<xsl:when test="(number($NoInstuments) = number($NoInstuments)) and ($NoInstuments != $sum_total_instruments)">
								<xsl:comment>Number of total instruments (<xsl:value-of select="$sum_total_instruments" />) is different from 954$t (<xsl:value-of select="$NoInstuments" />) - triggering Casting alternatif</xsl:comment>
							 	<xsl:apply-templates select="./*" mode="casting_alternatif"/>
							</xsl:when>
							<xsl:otherwise>
								<!-- Création des M23 Casting Detail (cas simples) : -->
								<xsl:if test="$VoixSolistes_a or $InstrumentSolistes_a or $Choeur_a or  $Gestique_a or
														  $FamBois_a or $FamSaxo_a or $FamCuivre_a or $FamPercussions_a or 
														  $FamClaviers_a or $FamCordesPincees_a or $FamCordesFrottees_a or 
														  $InstrumentsDivers_a or $Electro_a or $Ensemble_a">
									<!-- Créer une instance de M6 Casting dès que l’une des zones citées ci-dessus est remplie -->
									<mus:U13_has_casting>
										<mus:M6_Casting rdf:about="{mus:URI-Casting($idNotice,$positionCasting,$typeNotice,$idNoticeMere)}">
										
											<!-- U48 foresees quantity of actors  -->
											<mus:U48_foresees_quantity_of_actors rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">
												<xsl:value-of select="$NoInstuments"/>
											</mus:U48_foresees_quantity_of_actors>		
												
											<!-- Casting Detail -->
											<xsl:apply-templates select="./*" mode="casting_detail">
												<xsl:with-param name="idCasting" select="$positionCasting" tunnel="yes" />							
											</xsl:apply-templates>
										</mus:M6_Casting>
									</mus:U13_has_casting>	
								</xsl:if>			
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>					
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>
	
	<!-- By default, for any champs not matched above, recurse down on SOUSCHAMP -->
	<xsl:template match="champs" mode="#all">
		<xsl:apply-templates mode="#current" />
	</xsl:template>
	
	
	<!-- 010$a Identifier -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield ='010$a']">
		
		<xsl:variable name="typeNotice" select="../../@type"/>
		<xsl:variable name="idNotice" select="../../@id"/>
		<!-- Créer un nouvel identifiant à chaque fois que l’une de ces zones est remplie : 
				UNI5 : 010$a				
				Indiquer “ISBN” pour l’identifiant décrit en 010 -->
		
		<xsl:variable name="idIdentifier">
			<xsl:choose>
				<xsl:when test="count(data) &gt; 1">
					<xsl:value-of select="translate(tokenize(data,' ')[1],' ','')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="translate(translate(data,'.-',''),' ','')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		 
		<ecrm:P1_is_identified_by>
			<ecrm:E42_Identifier rdf:about="{mus:URI-Identifier($idNotice,$idIdentifier,'ISBN',../../@type)}">				
				<rdfs:label><xsl:value-of select="data"/></rdfs:label>
				<ecrm:P2_has_type rdf:resource="http://data.philharmoniedeparis.fr/vocabulary/ISBN" />				
			</ecrm:E42_Identifier>	
		</ecrm:P1_is_identified_by>
		
	</xsl:template>
	
	<!-- 013$a Identifier -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield ='013$a']">
	
		<xsl:variable name="typeNotice" select="../../@type"/>
		<xsl:variable name="idNotice" select="../../@id"/>
	
		<!-- Créer un nouvel identifiant à chaque fois que l’une de ces zones est remplie : 
				UNI5 : 013$a	-->
				
		<xsl:variable name="idIdentifier">
			<xsl:choose>
				<xsl:when test="count(data) &gt; 1">
					<xsl:value-of select="translate(tokenize(data,' ')[1],' ','')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="translate(translate(data,'.-',''),' ','')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
				
		<ecrm:P1_is_identified_by>
			<ecrm:E42_Identifier rdf:about="{mus:URI-Identifier($idNotice,$idIdentifier,'ISMN',../../@type)}">				
				<rdfs:label><xsl:value-of select="$idIdentifier"/></rdfs:label>
			 	<ecrm:P2_has_type rdf:resource="http://data.philharmoniedeparis.fr/vocabulary/ISMN" />				
			</ecrm:E42_Identifier>	
		</ecrm:P1_is_identified_by>		
	</xsl:template>


	<!-- 997$g Cote -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield ='997$g']">
		<xsl:variable name="idNotice" select="../../@id"/>
		<ecrm:U19_is_categorized_as>
			<ecrm:M19_Categorization rdf:about="{mus:URI-Cote($idNotice)}">
				<rdfs:label><xsl:value-of select="data"/></rdfs:label>			
			</ecrm:M19_Categorization>	
		</ecrm:U19_is_categorized_as>
		
	</xsl:template>
	
	<!-- UNI5:101$a -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield ='101$a']">
		<xsl:if test="mus:Lookup_Language_3LettersCode(normalize-space(data))">
			<ecrm:P72_has_language rdf:resource="{mus:Lookup_Language_3LettersCode(normalize-space(data))}"/>
		</xsl:if>
	</xsl:template>
	
	
	<!-- 205$a -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield ='205$a']">
		
		<xsl:variable name="typeNotice" select="../../@type"/>
		<xsl:variable name="idNotice" select="../../@id"/>
		<xsl:variable name="idNoticeMere">
			<xsl:if test="$typeNotice ='UNI:45'">
				<xsl:value-of select="$idNotice/../../../NOTICE/@id"/>
			</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="idSequence" select="generate-id()"/>
		
		<mus:U176_has_edition_statement>
			<mus:M159_Edition_Statement rdf:about="{mus:URI-Edition_Statement($idNotice,$idSequence,$typeNotice,$idNoticeMere)}">
				<rdfs:label><xsl:value-of select="normalize-space(.)"/></rdfs:label>
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
		
		<xsl:variable name="typeNotice" select="../../@type"/>
		<xsl:variable name="idNotice" select="../../@id"/>
		<xsl:variable name="idNoticeMere">
			<xsl:if test="$typeNotice ='UNI:45'">
				<xsl:value-of select="$idNotice/../../../NOTICE/@id"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="idSequence" select="generate-id()"/>
		
		
		
		<xsl:if test=".">
			<mus:U182_has_music_format_statement>
				<mus:M163_Music_Format_Statement rdf:about="{mus:URI-Format($idNotice,$idSequence,$typeNotice,$idNoticeMere)}">
					<rdfs:label><xsl:value-of select="normalize-space(.)"/></rdfs:label>
				</mus:M163_Music_Format_Statement>	
			</mus:U182_has_music_format_statement>
		</xsl:if>
		
		<xsl:variable name="data_200e" select="../../champs[@UnimarcTag='200']/SOUSCHAMP[@UnimarcSubfield ='200$e']/data"/>
		<xsl:for-each select="$data_200e">
			<xsl:variable name="data200e" select="normalize-space(.)"/>
			<xsl:if test="contains($data200e,'partition de poche') or 
					  contains($data200e,'tablature') or
					  contains($data200e,'réduction')">
					  
				<xsl:variable name="nSequence" select="generate-id()"/>
								
				<mus:U182_has_music_format_statement>
					<mus:M163_Music_Format_Statement rdf:about="{mus:URI-Format($idNotice,$nSequence,$typeNotice,$idNoticeMere)}">
						<rdfs:label><xsl:value-of select="$data_200e"/></rdfs:label>
					</mus:M163_Music_Format_Statement>	
				</mus:U182_has_music_format_statement>					  
			</xsl:if>
			
		</xsl:for-each>
	</xsl:template>
	
	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield = '333$a']" mode="NiveauDificulte">
		<xsl:variable name="Niveau" select="normalize-space(.)"/>
		<xsl:if test="mus:NiveauDificulte($Niveau)">
			<ecrm:P103_was_intended_for rdf:resource="{mus:NiveauDificulte($Niveau)}"/>
		</xsl:if>
	</xsl:template>
	
	
	<!-- Parties de partitions M167 Publication Expression Fragment -->
	<xsl:template match="NOTICE[@type = 'UNI:45']">
 		<xsl:variable name="idNotice" select="../../NOTICE[@type='UNI:5']/@id"/>
 		
 		<ecrm:P148_has_component>
 			<mus:M167_Publication_Expression_Fragment rdf:about="{mus:URI-Publication_Expression_Fragment($idNotice,@id)}">
		
				<!-- en dur -->
				<mus:U227_has_content_type rdf:resource="http://www.rdaregistry.info/termList/RDAContentType/#1010" />

				<!-- son identifiant en dur -->
				<ecrm:P1_is_identified_by>
					<ecrm:E42_Identifier rdf:about="{mus:URI-Identifier($idNotice,@id,'CMPP-ALOES',@type)}">
						<rdfs:label><xsl:value-of select="@id"/></rdfs:label>
							<!-- UNI5 : notice id - Indiquer “CMPP-ALOES” -->
						<ecrm:P2_has_type rdf:resource="http://data.philharmoniedeparis.fr/vocabulary/CMPP-ALOES"/>								
					</ecrm:E42_Identifier>
				</ecrm:P1_is_identified_by>	

	 			<!-- Language -->
				<xsl:apply-templates select="champs[@UnimarcTag='101']/SOUSCHAMP[@UnimarcSubfield ='101$a']"/>
	 			<!-- Title Statement and Responsability -->
	 			<xsl:apply-templates select="champs[@UnimarcTag='200']"/>
	 			<!-- M159_Edition_Statement -->
				<xsl:apply-templates select="champs[@UnimarcTag='205']/SOUSCHAMP[@UnimarcSubfield ='205$a']"/>
				<!-- M163_Music_Format_Statement -->
				<xsl:apply-templates select="champs[@UnimarcTag='208']/SOUSCHAMP[@UnimarcSubfield = '208$a']"/>		 			
	 			<!--  -->
	 			<xsl:apply-templates select="champs[@UnimarcTag='210' or @UnimarcTag='214']"/>
 				<!--  -->
 				<xsl:apply-templates select="champs[@UnimarcTag='324' or @UnimarcTag='327' or @UnimarcTag='330']"/>
				<!--  -->
				<xsl:apply-templates select="champs[@UnimarcTag='449']"/>
 				<!--  -->
 				<xsl:apply-templates select="champs[@UnimarcTag='541']"/>
	 			<!-- Le titre uniforme musical -->
				<xsl:apply-templates select="champs[@UnimarcTag='503']/SOUSCHAMP[@UnimarcSubfield ='503$3']"/>
	 			<!-- l’autorité -->
				<xsl:apply-templates select="champs[@UnimarcTag='600']/SOUSCHAMP[@UnimarcSubfield ='600$3']"/>
				<!-- l’autorité collectivité -->
				<xsl:apply-templates select="champs[@UnimarcTag='601']/SOUSCHAMP[@UnimarcSubfield ='601$3']"/>
	 			<!-- Context,Genre,Categorization   -->
	 			<xsl:apply-templates select="champs[@UnimarcTag='610']"/>
	 			<!--  
				<xsl:apply-templates select="champs[@UnimarcTag='610']/SOUSCHAMP[@UnimarcSubfield ='610$b']"/>
	 			-->
	 			
	 			<!-- Casting --> 
	 			<xsl:comment>Casting for parties de partitions <xsl:value-of select="$idNotice"/></xsl:comment>
	 			<xsl:apply-templates select="./." mode="casting"></xsl:apply-templates>
	 			
	 			<!-- 
	 			<xsl:apply-templates select="champs[@UnimarcTag='954']"/>
	 			-->
 				
 			</mus:M167_Publication_Expression_Fragment>
 		</ecrm:P148_has_component>

	</xsl:template>

	
	
	<!-- 500$3 lien vers le titre uniforme musical (notice d’autorité de type AIC14).-->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield ='500$3']">

		<xsl:variable name="typeNotice" select="../../@type"/>
		<xsl:variable name="idNotice" select="../../@id"/>
		<xsl:variable name="idNoticeMere">
			<xsl:if test="$typeNotice ='UNI:45'">
				<xsl:value-of select="$idNotice/../../../NOTICE/@id"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="idSequence" select="generate-id()"/>
		
		<xsl:variable name="idAIC14" select="normalize-space(.)"/>
		
		<!-- TUM-Compositeur-->
		<!-- a- Nom du compositeur : 
			Données : AIC14:322$a $m
			séparer le 322$a et le 322$m par une virgule, si le $m est rempli.
			Faire suivre par un point et un tiret (. -)
			 -->
		<xsl:variable name="AIC14_compositeur" select="mus:Titre_Uniforme_Musical($idNotice,$idAIC14,'322','')"/>
		
		
		<xsl:variable name="qualificatif" select="../SOUSCHAMP[@UnimarcSubfield ='500$w']"/>
		<!-- b- Nom de l’oeuvre : --> 
		<xsl:variable name="AIC14_oeuvre_144" select="mus:Titre_Uniforme_Musical($idNotice,$idAIC14,'144',$qualificatif)"/>
		<xsl:variable name="AIC14_oeuvre_444" select="mus:Titre_Uniforme_Musical($idNotice,$idAIC14,'444',$qualificatif)"/>
		
		<!-- Nom du compositeur + Nom de l’oeuvre  -->
		<xsl:choose>
			<xsl:when test="$AIC14_oeuvre_144 != ''">
				<mus:U68_has_variant_title>
					<ecrm:E35_Title rdf:about="{mus:URI-Title_variant($idNotice,$idSequence,$typeNotice,$idNoticeMere)}">
						<rdfs:label>
							<xsl:value-of select="concat($AIC14_compositeur,'. - ',$AIC14_oeuvre_144)"/>	
						</rdfs:label>
					</ecrm:E35_Title>
				</mus:U68_has_variant_title>	
			</xsl:when>
			<xsl:when test="AIC14_oeuvre_444 != ''">
				<mus:U68_has_variant_title>
					<ecrm:E35_Title rdf:about="{mus:URI-Title_variant($idNotice,$idSequence,$typeNotice,$idNoticeMere)}">
						<rdfs:label>
							<xsl:value-of select="concat($AIC14_compositeur,'. - ',$AIC14_oeuvre_444)"/>	
						</rdfs:label>
					</ecrm:E35_Title>
				</mus:U68_has_variant_title>				
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='600$3']">
		<!-- Lien vers l’autorité -->
		<ecrm:P129_is_about rdf:resource="{mus:reference_personne(normalize-space(.))}"/>
	</xsl:template>
	
	
	<!-- 601 -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='601$3']">		
		<!-- Lien vers l’autorité collectivité -->
		<ecrm:P129_is_about rdf:resource="{mus:reference_collectivite(normalize-space(.))}" />		
	</xsl:template>
	
	
	<!-- 	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='610$b']">
		<xsl:variable name="data_b" select="data"/>
		<xsl:variable name="data_610_3" select="../SOUSCHAMP[@UnimarcSubfield ='610$3']/data"/>
		
		<xsl:if test="$data_b = '03'">
			<xsl:for-each select="$data_610_3">
				<mus:U65_has_geographical_context rdf:resource="{mus:reference_thesaurus(.)}"/>
			</xsl:for-each>
		</xsl:if>
		
		<xsl:if test="$data_b = '04'">
			<xsl:for-each select="$data_610_3">
				<mus:U12_has_genre rdf:resource="{mus:reference_thesaurus($data_610_3)}"/>
			</xsl:for-each>
		</xsl:if>
		
		<xsl:if test="not(index-of(('03','04','06','06b','06c'),$data_b))">
			<xsl:for-each select="$data_610_3">
				<mus:U19_is_categorized_as rdf:resource="{mus:reference_thesaurus(.)}"/>
			</xsl:for-each>
		</xsl:if>		
	</xsl:template>
	-->


	<!-- Activitiy Event 700 -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='700$3' or
								   @UnimarcSubfield='701$3' or
								   @UnimarcSubfield='702$3' or
								   @UnimarcSubfield='710$3' or
								   @UnimarcSubfield='711$3' or
								   @UnimarcSubfield='712$3'
								   ]">
		
		<xsl:variable name="source" select="data"/>
		
		<xsl:variable name="idLocal" select="concat(substring-before(@UnimarcSubfield,'$'),'$4')"/>
		<xsl:variable name="idNotice" select="../../@id"/>						   
		<xsl:variable name="idFunction" select="../SOUSCHAMP[@UnimarcSubfield=$idLocal]/data"/>
		<xsl:variable name="function">
			<xsl:choose>
				<xsl:when test="count($idFunction) &gt; 1">
					<xsl:value-of select="count($idFunction)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="translate($idFunction,' ','')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<ecrm:P9_consists_of>
			<ecrm:E7_Activity rdf:about="{mus:URI-Publication_Event_Activity($idNotice,$source,$function)}">
				
				<!-- Vers Personne -->
				<xsl:if test="index-of(('700$3','701$3','702$3'),@UnimarcSubfield)">
					<ecrm:P14_carried_out_by rdf:resource="{mus:reference_personne(normalize-space($source))}" />
				</xsl:if>
				
				<!-- Vers Collectivite -->
				<xsl:if test="index-of(('710$3','711$3','712$3'),@UnimarcSubfield)">
					<ecrm:P14_carried_out_by rdf:resource="{mus:reference_collectivite($source)}" />
				</xsl:if>
				
				<!-- rol Vocabulary -->
				<xsl:if test="index-of(('700$3','701$3','710$3','711$3'),@UnimarcSubfield)">
					<xsl:if test="$function">
						<xsl:for-each select="$idFunction">
							<xsl:if test="mus:role_vocab(normalize-space(.))">
								<mus:U31_had_function rdf:resource="{mus:role_vocab(normalize-space(.))}" />
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
				</xsl:if>
			</ecrm:E7_Activity>
		</ecrm:P9_consists_of>
		
	</xsl:template>	
	
	
	<!-- Template Generale pour creer une casting simple -->
	<!-- Voix solistes 940 -->
	<!-- Choeur 941 -->
	<!-- Instruments solistes 942 -->
	<!-- Gestique 943 -->
	<!-- Famille des bois 945 -->
	<!-- Famille des saxophones 946 -->
	<!-- Famille des cuivres 947 -->
	<!-- Famille des percussions 948 -->
	<!-- Famille des claviers 949 -->
	<!-- Famille des cordes pincées 950 -->
	<!-- Famille des cordes frottées 951 -->
	<!-- Instruments divers 952 -->
	<!-- Electroacoustique 953 -->
	<!-- Ensemble 956 --> 
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='940$a' or 
								   @UnimarcSubfield='941$a' or
								   @UnimarcSubfield='942$a' or
								   @UnimarcSubfield='943$a' or
								   @UnimarcSubfield='945$a' or
								   @UnimarcSubfield='946$a' or 
								   @UnimarcSubfield='947$a' or
								   @UnimarcSubfield='948$a' or
								   @UnimarcSubfield='949$a' or
								   @UnimarcSubfield='950$a' or
								   @UnimarcSubfield='951$a' or
								   @UnimarcSubfield='952$a' or
								   @UnimarcSubfield='953$a' or
								   @UnimarcSubfield='956$a']" mode="casting_detail">
		
		<xsl:param name="idCasting" tunnel="yes" />
		
		<xsl:variable name="idNotice" select="../../@id"/>
		<xsl:variable name="typeNotice" select="../../@type"/>
		<xsl:variable name="idNoticeMere">
			<xsl:if test="$typeNotice ='UNI:45'">
				<xsl:value-of select="$idNotice/../../../NOTICE/@id"/>
			</xsl:if>
		</xsl:variable>	
		
		
		<xsl:variable name="data_instrument">
			<xsl:choose>
				<xsl:when test="contains(data,'_')"><xsl:value-of select="translate(normalize-space(substring-before(data,'(')),'_',' ')"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="normalize-space(substring-before(data,'('))"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- Generation d'id -->
		<xsl:variable name="id" select="generate-id()"/>
		
		<xsl:if test="not(index-of(('basse_continue','basse continue','Ensemble_instrumental','ensemble_instrumental','ensemble instrumental'),$data_instrument))">
			<xsl:comment>Notice: <xsl:value-of select="$idNotice"/>, SOUSCHAMP: <xsl:value-of select="@UnimarcSubfield"/></xsl:comment>
			<mus:U23_has_casting_detail>
				<mus:M23_Casting_Detail rdf:about="{mus:URI-Casting_Detail($idNotice,$idCasting,$id,$typeNotice,$idNoticeMere)}">
				
					<xsl:variable name="mediumInstrument">
						<xsl:choose>
							<xsl:when test="index-of(('940$a', '941$a', '943$a','956$a'),@UnimarcSubfield)">
								<!-- IAML -->
								<xsl:variable name="medium_instrument" select="mus:medium($data_instrument,'IAML')"/>
								<xsl:variable name="medium_instrument_complex">
									<xsl:if test="$medium_instrument = '' and $data_instrument != ''">
										<xsl:value-of select="mus:chercher_medium_complex($data_instrument,'IAML')"/>						
									</xsl:if>
								</xsl:variable>
								<xsl:choose>
									<xsl:when test="$medium_instrument != ''">
										<xsl:value-of select="$medium_instrument"/>
									</xsl:when>
									<xsl:when test="$medium_instrument = '' and $medium_instrument_complex != ''">
										<xsl:value-of select="$medium_instrument_complex"/>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="index-of(('942$a','945$a', '946$a', '947$a', '948$a', '949$a', '950$a', '951$a', '952$a', '953$a'),@UnimarcSubfield)">
								<!-- MIMO -->
								<xsl:variable name="medium_instrument" select="mus:medium($data_instrument,'MIMO')"/>
								<xsl:variable name="medium_instrument_complex">
									<xsl:if test="$medium_instrument = '' and $data_instrument != ''">
										<xsl:value-of select="mus:chercher_medium_complex($data_instrument,'MIMO')"/>						
									</xsl:if>
								</xsl:variable>
								<xsl:choose>
									<xsl:when test="$medium_instrument != ''">
										<xsl:value-of select="$medium_instrument"/>
									</xsl:when>
									<xsl:when test="$medium_instrument = '' and $medium_instrument_complex != ''">
										<xsl:value-of select="$medium_instrument_complex"/>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
						</xsl:choose>
					</xsl:variable>				
					
					<!-- if the result  -->
					<xsl:variable name="vMediumInstrument">
						<xsl:choose>
							<xsl:when test="count(tokenize($mediumInstrument,' ')) &gt; 1">
								<xsl:value-of select="tokenize($mediumInstrument,' ')[1]"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$mediumInstrument"/>
							</xsl:otherwise>
						</xsl:choose>					
					</xsl:variable>
					
					<xsl:choose>
						<xsl:when test="$vMediumInstrument != ''">
							<xsl:comment> <xsl:value-of select="$data_instrument"/> </xsl:comment>
							<xsl:choose>
								<xsl:when test="index-of(('940$a', '941$a', '943$a','956$a'),@UnimarcSubfield)">
									<!-- IAML -->
									<philhar:S2_foresees_use_of_medium_of_performance_vocal rdf:resource="{normalize-space($vMediumInstrument)}"/>
								</xsl:when>
								<xsl:when test="index-of(('942$a','945$a', '946$a', '947$a', '948$a', '949$a', '950$a', '951$a', '952$a', '953$a'),@UnimarcSubfield)">
									<!-- MIMO -->
									<philhar:S1_foresees_use_of_medium_of_performance_instrument rdf:resource="{normalize-space($vMediumInstrument)}"/>
								</xsl:when>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:comment>Medium not found: <xsl:value-of select="$data_instrument"/></xsl:comment>
							<xsl:if test="string-length($data_instrument) &gt; 0">
								<ecrm:P3_has_note><xsl:value-of select="normalize-space($data_instrument)"/></ecrm:P3_has_note>
							</xsl:if>									
						</xsl:otherwise>				
					</xsl:choose>
					
					<xsl:if test="@UnimarcSubfield='942$a' and (../../champs/SOUSCHAMP[
						@UnimarcSubfield='945$a'
						or
						@UnimarcSubfield='946$a'
						or
						@UnimarcSubfield='947$a'
						or
						@UnimarcSubfield='948$a'
						or
						@UnimarcSubfield='949$a'
						or
						@UnimarcSubfield='950$a'
						or
						@UnimarcSubfield='951$a'
						or
						@UnimarcSubfield='952$a'
						or
						@UnimarcSubfield='953$a'
						or
						@UnimarcSubfield='956$a'
					])">
						<mus:U36_foresees_responsibility rdf:resource="http://data.doremus.org/vocabulary/responsibility/soloist"/>
					</xsl:if>
					
					<!-- contains(data,'voix') -->
					<xsl:if test="@UnimarcSubfield='940$a' and (../../champs/SOUSCHAMP[@UnimarcSubfield='941$a'])">
						<mus:U36_foresees_responsibility rdf:resource="http://data.doremus.org/vocabulary/responsibility/soloist"/>
					</xsl:if>
					
					<xsl:choose>
						<xsl:when test="mus:NoInstrument(data) &gt; 0">
							<mus:U30_foresees_quantity_of_mop rdf:datatype="http://www.w3.org/2001/XMLSchema#integer"><xsl:value-of select="mus:NoInstrument(data)"/></mus:U30_foresees_quantity_of_mop>
						</xsl:when>
						<xsl:otherwise>
							<xsl:comment>source number of instrument: <xsl:value-of select="data"/></xsl:comment>	
						</xsl:otherwise>
					</xsl:choose>
					
					<!-- P103 was intended for 333$a-->
					<xsl:variable name="NiveauDificulte" select="../../champs[@UnimarcTag='333']/SOUSCHAMP[@UnimarcSubfield='333$a']/data"/>
					<xsl:if test="$NiveauDificulte">
						<xsl:for-each select="$NiveauDificulte">
							<xsl:variable name="texte" select="normalize-space(.)"/>
							<xsl:variable name="instrument_niveau_dificulte" select="mus:NiveauDificulte_instrument($texte)"/>
	
							<xsl:if test="boolean($instrument_niveau_dificulte)">
								<xsl:for-each select="tokenize($instrument_niveau_dificulte,' ')">
									<xsl:variable name="instrument" select="normalize-space(.)"/>								
									<xsl:if test="$data_instrument = $instrument">
										<xsl:variable name="niveauDifficulte" select="mus:NiveauDificulte($texte)" />
										<xsl:if test="$niveauDifficulte">
											<ecrm:P103_was_intended_for rdf:resource="{$niveauDifficulte}"/>
										</xsl:if>
									</xsl:if>
								</xsl:for-each>
							</xsl:if>																		
						</xsl:for-each>
					</xsl:if>
					
					
					<xsl:variable name="note" select="../SOUSCHAMP[@UnimarcSubfield='940$x' or 
									   @UnimarcSubfield='941$x' or
									   @UnimarcSubfield='942$x' or
									   @UnimarcSubfield='943$x' or
									   @UnimarcSubfield='945$x' or
									   @UnimarcSubfield='946$x' or 
									   @UnimarcSubfield='947$x' or
									   @UnimarcSubfield='948$x' or
									   @UnimarcSubfield='949$x' or
									   @UnimarcSubfield='950$x' or
									   @UnimarcSubfield='951$x' or
									   @UnimarcSubfield='952$x' or
									   @UnimarcSubfield='953$x' or
									   @UnimarcSubfield='956$x']/data"/>
					<xsl:if test="$note">
						<xsl:for-each select="$note">
							<ecrm:P3_has_note><xsl:value-of select="normalize-space(.)"/></ecrm:P3_has_note>							
						</xsl:for-each>
					</xsl:if>				
				</mus:M23_Casting_Detail>
			</mus:U23_has_casting_detail>
		</xsl:if>
	</xsl:template>
	
	
	<!-- Casting Alternatif -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='940$x' or 
								   @UnimarcSubfield='941$x' or
								   @UnimarcSubfield='942$x' or
								   @UnimarcSubfield='943$x' or
								   @UnimarcSubfield='945$x' or
								   @UnimarcSubfield='946$x' or 
								   @UnimarcSubfield='947$x' or
								   @UnimarcSubfield='948$x' or
								   @UnimarcSubfield='949$x' or
								   @UnimarcSubfield='950$x' or
								   @UnimarcSubfield='951$x' or
								   @UnimarcSubfield='952$x' or
								   @UnimarcSubfield='953$x' or
								   @UnimarcSubfield='956$x']" mode="casting_alternatif">		
		<xsl:variable name="currentDocument" select="."/>		
		
		<xsl:variable name="idNotice" select="../../@id"/>
		<xsl:variable name="typeNotice" select="../../@type"/>
		<xsl:variable name="idNoticeMere">
			<xsl:if test="$typeNotice ='UNI:45'">
				<xsl:value-of select="$idNotice/../../../NOTICE/@id"/>
			</xsl:if>
		</xsl:variable>	
		
		<xsl:variable name="data_source" select="normalize-space(.)"/>
		<xsl:variable name="data_medium">
			<xsl:choose>
				<xsl:when test="index-of(('940$x', '941$x', '943$x','956$x'),@UnimarcSubfield)">
					<!-- IAML -->
					<xsl:value-of select="sparnaf:split_and_extract_mediums($data_source,'IAML')"/>
				</xsl:when>
				<xsl:when test="index-of(('942$x', '945$x', '946$x', '947$x', '948$x', '949$x', '950$x', '951$x', '952$x', '953$x'),@UnimarcSubfield)">
					<!-- MIMO -->
					<xsl:value-of select="sparnaf:split_and_extract_mediums($data_source,'MIMO')"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="id" select="generate-id(@UnimarcSubfield)"/>
		
		<xsl:choose>
			<xsl:when test="$data_medium and $data_medium != '0'">
			<xsl:comment>Casting alternatif: Notice: <xsl:value-of select="$idNotice"/>, Input: <xsl:value-of select="$data_source"/></xsl:comment>
			
			<xsl:for-each select="$data_medium">
				<xsl:variable name="source_alternatif" select="normalize-space(.)"/>
				<!-- Generation d'id -->
				<xsl:variable name="idCastingAlternatif" select="concat($id,'_',position())"/>		
				
				<mus:U13_has_casting>
					<mus:M6_Casting rdf:about="{mus:URI-Casting($idNotice,$idCastingAlternatif,$typeNotice,$idNoticeMere)}">
					
						<!-- Afficher l'instrument pour le casting alternatif -->						
						<!-- 940 -->
						<xsl:for-each select="$currentDocument/../../champs[@UnimarcTag='940']/SOUSCHAMP[@UnimarcSubfield='940$a']/data">
							<xsl:variable name="data_originale" select="."/>
							<xsl:variable name="data_transformer" select="lower-case(translate(normalize-space(substring-before($data_originale,'(')),'_',' '))"/>
							<xsl:variable name="trouve_instrument_note">
								<xsl:for-each select="$data_medium">
									<xsl:if test="$data_transformer = lower-case(normalize-space(.)) and lower-case(normalize-space(.)) != lower-case($source_alternatif)">
										<xsl:value-of select="1"/>										
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:if test="$trouve_instrument_note != '1'">
								<xsl:apply-templates select="$currentDocument/../../champs[@UnimarcTag='940']/SOUSCHAMP[@UnimarcSubfield='940$a']/self::*[data = $data_originale]" mode="casting_detail">
									<xsl:with-param name="idCasting" select="$idCastingAlternatif"/>
								</xsl:apply-templates>
							</xsl:if>
						</xsl:for-each>
						<!-- 941 -->
						<xsl:for-each select="$currentDocument/../../champs[@UnimarcTag='941']/SOUSCHAMP[@UnimarcSubfield='941$a']/data">
							<xsl:variable name="data_originale" select="."/>
							<xsl:variable name="data_transformer" select="lower-case(translate(normalize-space(substring-before($data_originale,'(')),'_',' '))"/>
							<xsl:variable name="trouve_instrument_note">
								<xsl:for-each select="$data_medium">
									<xsl:if test="$data_transformer = lower-case(normalize-space(.)) and lower-case(normalize-space(.)) != lower-case($source_alternatif)">
										<xsl:value-of select="1"/>										
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:if test="$trouve_instrument_note != '1'">
								<xsl:apply-templates select="$currentDocument/../../champs[@UnimarcTag='941']/SOUSCHAMP[@UnimarcSubfield='941$a']/self::*[data = $data_originale]" mode="casting_detail">
									<xsl:with-param name="idCasting" select="$idCastingAlternatif"/>
								</xsl:apply-templates>
							</xsl:if>
						</xsl:for-each>
						<!-- 942 -->
						<xsl:for-each select="$currentDocument/../../champs[@UnimarcTag='942']/SOUSCHAMP[@UnimarcSubfield='942$a']/data">
							<xsl:variable name="data_originale" select="."/>
							<xsl:variable name="data_transformer" select="lower-case(translate(normalize-space(substring-before($data_originale,'(')),'_',' '))"/>
							<xsl:variable name="trouve_instrument_note">
								<xsl:for-each select="$data_medium">
									<xsl:if test="$data_transformer = lower-case(normalize-space(.)) and lower-case(normalize-space(.)) != lower-case($source_alternatif)">
										<xsl:value-of select="1"/>										
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:if test="$trouve_instrument_note != '1'">
								<xsl:apply-templates select="$currentDocument/../../champs[@UnimarcTag='942']/SOUSCHAMP[@UnimarcSubfield='942$a']/self::*[data = $data_originale]" mode="casting_detail">
									<xsl:with-param name="idCasting" select="$idCastingAlternatif"/>
								</xsl:apply-templates>
							</xsl:if>
						</xsl:for-each>
						<!-- 943 -->
						<xsl:for-each select="$currentDocument/../../champs[@UnimarcTag='943']/SOUSCHAMP[@UnimarcSubfield='943$a']/data">
							<xsl:variable name="data_originale" select="."/>
							<xsl:variable name="data_transformer" select="lower-case(translate(normalize-space(substring-before($data_originale,'(')),'_',' '))"/>
							<xsl:variable name="trouve_instrument_note">
								<xsl:for-each select="$data_medium">
									<xsl:if test="$data_transformer = lower-case(normalize-space(.)) and lower-case(normalize-space(.)) != lower-case($source_alternatif)">
										<xsl:value-of select="1"/>										
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:if test="$trouve_instrument_note != '1'">
								<xsl:apply-templates select="$currentDocument/../../champs[@UnimarcTag='943']/SOUSCHAMP[@UnimarcSubfield='943$a']/self::*[data = $data_originale]" mode="casting_detail">
									<xsl:with-param name="idCasting" select="$idCastingAlternatif"/>
								</xsl:apply-templates>
							</xsl:if>
						</xsl:for-each>
						<!-- 945 -->
						<xsl:for-each select="$currentDocument/../../champs[@UnimarcTag='945']/SOUSCHAMP[@UnimarcSubfield='945$a']/data">
							<xsl:variable name="data_originale" select="."/>
							<xsl:variable name="data_transformer" select="lower-case(translate(normalize-space(substring-before($data_originale,'(')),'_',' '))"/>
							<xsl:variable name="trouve_instrument_note">
								<xsl:for-each select="$data_medium">
									<xsl:if test="$data_transformer = lower-case(normalize-space(.)) and lower-case(normalize-space(.)) != lower-case($source_alternatif)">
										<xsl:value-of select="1"/>										
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:if test="$trouve_instrument_note != '1'">
								<xsl:apply-templates select="$currentDocument/../../champs[@UnimarcTag='945']/SOUSCHAMP[@UnimarcSubfield='945$a']/self::*[data = $data_originale]" mode="casting_detail">
									<xsl:with-param name="idCasting" select="$idCastingAlternatif"/>
								</xsl:apply-templates>
							</xsl:if>
						</xsl:for-each>
						<!-- 946 -->
						<xsl:for-each select="$currentDocument/../../champs[@UnimarcTag='946']/SOUSCHAMP[@UnimarcSubfield='946$a']/data">
							<xsl:variable name="data_originale" select="."/>
							<xsl:variable name="data_transformer" select="lower-case(translate(normalize-space(substring-before($data_originale,'(')),'_',' '))"/>
							<xsl:variable name="trouve_instrument_note">
								<xsl:for-each select="$data_medium">
									<xsl:if test="$data_transformer = lower-case(normalize-space(.)) and lower-case(normalize-space(.)) != lower-case($source_alternatif)">
										<xsl:value-of select="1"/>										
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:if test="$trouve_instrument_note != '1'">
								<xsl:apply-templates select="$currentDocument/../../champs[@UnimarcTag='946']/SOUSCHAMP[@UnimarcSubfield='946$a']/self::*[data = $data_originale]" mode="casting_detail">
									<xsl:with-param name="idCasting" select="$idCastingAlternatif"/>
								</xsl:apply-templates>
							</xsl:if>
						</xsl:for-each>
						<!-- 947 -->
						<xsl:for-each select="$currentDocument/../../champs[@UnimarcTag='947']/SOUSCHAMP[@UnimarcSubfield='947$a']/data">
							<xsl:variable name="data_originale" select="."/>
							<xsl:variable name="data_transformer" select="lower-case(translate(normalize-space(substring-before($data_originale,'(')),'_',' '))"/>
							<xsl:variable name="trouve_instrument_note">
								<xsl:for-each select="$data_medium">
									<xsl:if test="$data_transformer = lower-case(normalize-space(.)) and lower-case(normalize-space(.)) != lower-case($source_alternatif)">
										<xsl:value-of select="1"/>										
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:if test="$trouve_instrument_note != '1'">
								<xsl:apply-templates select="$currentDocument/../../champs[@UnimarcTag='947']/SOUSCHAMP[@UnimarcSubfield='947$a']/self::*[data = $data_originale]" mode="casting_detail">
									<xsl:with-param name="idCasting" select="$idCastingAlternatif"/>
								</xsl:apply-templates>
							</xsl:if>
						</xsl:for-each>
						<!-- 948 -->
						<xsl:for-each select="$currentDocument/../../champs[@UnimarcTag='948']/SOUSCHAMP[@UnimarcSubfield='948$a']/data">
							<xsl:variable name="data_originale" select="."/>
							<xsl:variable name="data_transformer" select="lower-case(translate(normalize-space(substring-before($data_originale,'(')),'_',' '))"/>
							<xsl:variable name="trouve_instrument_note">
								<xsl:for-each select="$data_medium">
									<xsl:if test="$data_transformer = lower-case(normalize-space(.)) and lower-case(normalize-space(.)) != lower-case($source_alternatif)">
										<xsl:value-of select="1"/>										
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:if test="$trouve_instrument_note != '1'">
								<xsl:apply-templates select="$currentDocument/../../champs[@UnimarcTag='948']/SOUSCHAMP[@UnimarcSubfield='948$a']/self::*[data = $data_originale]" mode="casting_detail">
									<xsl:with-param name="idCasting" select="$idCastingAlternatif"/>
								</xsl:apply-templates>
							</xsl:if>
						</xsl:for-each>
						<!-- 949 -->
						<xsl:for-each select="$currentDocument/../../champs[@UnimarcTag='949']/SOUSCHAMP[@UnimarcSubfield='949$a']/data">
							<xsl:variable name="data_originale" select="."/>
							<xsl:variable name="data_transformer" select="lower-case(translate(normalize-space(substring-before($data_originale,'(')),'_',' '))"/>
							<xsl:variable name="trouve_instrument_note">
								<xsl:for-each select="$data_medium">
									<xsl:if test="$data_transformer = lower-case(normalize-space(.)) and lower-case(normalize-space(.)) != lower-case($source_alternatif)">
										<xsl:value-of select="1"/>										
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:if test="$trouve_instrument_note != '1'">
								<xsl:apply-templates select="$currentDocument/../../champs[@UnimarcTag='949']/SOUSCHAMP[@UnimarcSubfield='949$a']/self::*[data = $data_originale]" mode="casting_detail">
									<xsl:with-param name="idCasting" select="$idCastingAlternatif"/>
								</xsl:apply-templates>
							</xsl:if>
						</xsl:for-each>
						<!-- 950 -->
						<xsl:for-each select="$currentDocument/../../champs[@UnimarcTag='950']/SOUSCHAMP[@UnimarcSubfield='950$a']/data">
							<xsl:variable name="data_originale" select="."/>
							<xsl:variable name="data_transformer" select="lower-case(translate(normalize-space(substring-before($data_originale,'(')),'_',' '))"/>
							<xsl:variable name="trouve_instrument_note">
								<xsl:for-each select="$data_medium">
									<xsl:if test="$data_transformer = lower-case(normalize-space(.)) and lower-case(normalize-space(.)) != lower-case($source_alternatif)">
										<xsl:value-of select="1"/>										
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:if test="$trouve_instrument_note != '1'">
								<xsl:apply-templates select="$currentDocument/../../champs[@UnimarcTag='950']/SOUSCHAMP[@UnimarcSubfield='950$a']/self::*[data = $data_originale]" mode="casting_detail">
									<xsl:with-param name="idCasting" select="$idCastingAlternatif"/>
								</xsl:apply-templates>
							</xsl:if>
						</xsl:for-each>
						<!-- 951 -->
						<xsl:for-each select="$currentDocument/../../champs[@UnimarcTag='951']/SOUSCHAMP[@UnimarcSubfield='951$a']/data">
							<xsl:variable name="data_originale" select="."/>
							<xsl:variable name="data_transformer" select="lower-case(translate(normalize-space(substring-before($data_originale,'(')),'_',' '))"/>
							<xsl:variable name="trouve_instrument_note">
								<xsl:for-each select="$data_medium">
									<xsl:if test="$data_transformer = lower-case(normalize-space(.)) and lower-case(normalize-space(.)) != lower-case($source_alternatif)">
										<xsl:value-of select="1"/>										
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:if test="$trouve_instrument_note != '1'">
								<xsl:apply-templates select="$currentDocument/../../champs[@UnimarcTag='951']/SOUSCHAMP[@UnimarcSubfield='951$a']/self::*[data = $data_originale]" mode="casting_detail">
									<xsl:with-param name="idCasting" select="$idCastingAlternatif"/>
								</xsl:apply-templates>
							</xsl:if>
						</xsl:for-each>
						<!-- 952 -->
						<xsl:for-each select="$currentDocument/../../champs[@UnimarcTag='952']/SOUSCHAMP[@UnimarcSubfield='952$a']/data">
							<xsl:variable name="data_originale" select="."/>
							<xsl:variable name="data_transformer" select="lower-case(translate(normalize-space(substring-before($data_originale,'(')),'_',' '))"/>
							<xsl:variable name="trouve_instrument_note">
								<xsl:for-each select="$data_medium">
									<xsl:if test="$data_transformer = lower-case(normalize-space(.)) and lower-case(normalize-space(.)) != lower-case($source_alternatif)">
										<xsl:value-of select="1"/>										
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:if test="$trouve_instrument_note != '1'">
								<xsl:apply-templates select="$currentDocument/../../champs[@UnimarcTag='952']/SOUSCHAMP[@UnimarcSubfield='952$a']/self::*[data = $data_originale]" mode="casting_detail">
									<xsl:with-param name="idCasting" select="$idCastingAlternatif"/>
								</xsl:apply-templates>
							</xsl:if>
						</xsl:for-each>
						<!-- 953 -->
						<xsl:for-each select="$currentDocument/../../champs[@UnimarcTag='953']/SOUSCHAMP[@UnimarcSubfield='953$a']/data">
							<xsl:variable name="data_originale" select="."/>
							<xsl:variable name="data_transformer" select="lower-case(translate(normalize-space(substring-before($data_originale,'(')),'_',' '))"/>
							<xsl:variable name="trouve_instrument_note">
								<xsl:for-each select="$data_medium">
									<xsl:if test="$data_transformer = lower-case(normalize-space(.)) and lower-case(normalize-space(.)) != lower-case($source_alternatif)">
										<xsl:value-of select="1"/>										
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:if test="$trouve_instrument_note != '1'">
								<xsl:apply-templates select="$currentDocument/../../champs[@UnimarcTag='953']/SOUSCHAMP[@UnimarcSubfield='953$a']/self::*[data = $data_originale]" mode="casting_detail">
									<xsl:with-param name="idCasting" select="$idCastingAlternatif"/>
								</xsl:apply-templates>
							</xsl:if>
						</xsl:for-each>
						<!-- 956 -->
						<xsl:for-each select="$currentDocument/../../champs[@UnimarcTag='956']/SOUSCHAMP[@UnimarcSubfield='956$a']/data">
							<xsl:variable name="data_originale" select="."/>
							<xsl:variable name="data_transformer" select="lower-case(translate(normalize-space(substring-before($data_originale,'(')),'_',' '))"/>
							<xsl:variable name="trouve_instrument_note">
								<xsl:for-each select="$data_medium">
									<xsl:if test="$data_transformer = lower-case(normalize-space(.)) and lower-case(normalize-space(.)) != lower-case($source_alternatif)">
										<xsl:value-of select="1"/>										
									</xsl:if>
								</xsl:for-each>
							</xsl:variable>
							<xsl:if test="$trouve_instrument_note != '1'">
								<xsl:apply-templates select="$currentDocument/../../champs[@UnimarcTag='956']/SOUSCHAMP[@UnimarcSubfield='956$a']/self::*[data = $data_originale]" mode="casting_detail">
									<xsl:with-param name="idCasting" select="$idCastingAlternatif"/>
								</xsl:apply-templates>
							</xsl:if>
						</xsl:for-each>
						
					</mus:M6_Casting>
				</mus:U13_has_casting>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:comment>Casting alternatif: Could not extract any medium from <xsl:value-of select="@UnimarcSubfield" /> '<xsl:value-of select="$data_source" />'</xsl:comment>
			<xsl:message>Warning : Casting alternatif: Could not extract any medium from <xsl:value-of select="@UnimarcSubfield" /> '<xsl:value-of select="$data_source" />'</xsl:message>
		</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	
	<!-- aby default, discard all unmatched text -->
	<xsl:template match="text()" mode="#all"></xsl:template>

	<!-- Overwrite built-in template to match all unmatched elements and discard them -->
	<xsl:template match="*" mode="#all" />

</xsl:stylesheet>