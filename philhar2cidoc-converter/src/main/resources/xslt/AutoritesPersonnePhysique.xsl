<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:edm="http://www.europeana.eu/schemas/edm/"
	xmlns:wgs84_pos="http://www.w3.org/2003/01/geo/wgs84_pos#"
	xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:rdaGr2="http://rdvocab.info/ElementsGr2/"
	xmlns:oai="http://www.openarchives.org/OAI/2.0/"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:ore="http://www.openarchives.org/ore/terms/"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:dcterms="http://purl.org/dc/terms/">

	<!-- Format -->
	<xsl:output indent="yes" method="xml" />

	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>

	<!-- Template racine -->
	<xsl:template match="NOTICES">
		<rdf:RDF>
			<xsl:apply-templates />
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="NOTICE">
		<edm:Agent rdf:about="{concat('http://fake.philharmoniedeparis.fr/',replace(@type,':',''),'/',@id)}">
			<!-- prefLabel -->
			<xsl:apply-templates select="champs[@UnimarcTag = '100'][SOUSCHAMP/@UnimarcSubfield ='100$a']" />
			<!-- altLabel -->
			<xsl:apply-templates select="champs[@UnimarcTag = '400']" />
			<!-- identifier -->
			<xsl:apply-templates select="champs[@UnimarcTag = '031']" />
			<xsl:apply-templates select="champs[@UnimarcTag = '994']/SOUSCHAMP[@UnimarcSubfield='994$a']" />
			<!-- begin / end -->
			<xsl:apply-templates select="champs[@UnimarcTag = '602']/SOUSCHAMP[@UnimarcSubfield='602$a']" mode="date" />
			<!-- foaf:name -->
			<xsl:apply-templates select="champs[@UnimarcTag = '100'][SOUSCHAMP/@UnimarcSubfield = '100$a']" mode="foaf" />
			<!-- biographicalInfo -->
			<xsl:apply-templates select="
				champs[@UnimarcTag='100']/SOUSCHAMP[@UnimarcSubfield ='100$e']" />
			<xsl:apply-templates select="champs[@UnimarcTag='641']" />
			<!-- dateOfBirth -->
			<!-- dateOfDeath -->
			<xsl:apply-templates select="champs[@UnimarcTag='100']/SOUSCHAMP[@UnimarcSubfield ='100$d']" />
			<!-- professionOrOccupation -->
			<xsl:apply-templates select="champs[@UnimarcTag='100']/SOUSCHAMP[@UnimarcSubfield ='100$9']" />
			<!-- placeOfBirth / placeOfDeath -->
			<xsl:apply-templates select="champs[@UnimarcTag = '602']/SOUSCHAMP[@UnimarcSubfield='602$a']" mode="place" />
			<!-- sameAs -->
			<xsl:apply-templates select="champs[@UnimarcTag = '994']/SOUSCHAMP[@UnimarcSubfield='994$b']" />
		</edm:Agent>
	</xsl:template>


	<xsl:template match="champs[@UnimarcTag = '100']">
		<xsl:variable name="SC_100_a"
			select="SOUSCHAMP[@UnimarcSubfield ='100$a']/data" />
		<xsl:variable name="SC_100_m"
			select="SOUSCHAMP[@UnimarcSubfield ='100$m']/data" />

		<xsl:variable name="PREF" select="concat(
			if($SC_100_m != '') then concat($SC_100_m, ' ') else '' 
			,$SC_100_a)" />

		<skos:prefLabel>
			<xsl:value-of select="$PREF" />
		</skos:prefLabel>
	</xsl:template>

	<xsl:template match="champs[@UnimarcTag = '100']" mode="foaf">
		<xsl:variable name="SC_100_a"
			select="SOUSCHAMP[@UnimarcSubfield ='100$a']/data" />
		<xsl:variable name="SC_100_m"
			select="SOUSCHAMP[@UnimarcSubfield ='100$m']/data" />

		<xsl:variable name="PREF" select="concat(
			if($SC_100_m != '') then concat($SC_100_m, ' ') else '' 
			,$SC_100_a)" />

		<foaf:name>
			<xsl:value-of select="$PREF" />
		</foaf:name>
	</xsl:template>

	<xsl:template match="champs[@UnimarcTag = '400' and (SOUSCHAMP[@UnimarcSubfield ='400$a'] or SOUSCHAMP[@UnimarcSubfield ='400$m'])]">
		<xsl:if test="count(SOUSCHAMP[@UnimarcSubfield ='400$m']) > 1">
			<xsl:message>Warning notice <xsl:value-of select="../@id" /> : more than 1 value for 400$m : <xsl:value-of select="SOUSCHAMP[@UnimarcSubfield ='400$m']/data" separator=", " /> (taking first one)</xsl:message>
		</xsl:if>

		<xsl:variable name="SC_400_a"
			select="SOUSCHAMP[@UnimarcSubfield ='400$a']/data" />
		<xsl:variable name="SC_400_m"
			select="SOUSCHAMP[@UnimarcSubfield ='400$m'][1]/data" />
		<skos:altLabel>
			<xsl:value-of select="concat(
				if($SC_400_m != '') then concat($SC_400_m, ' ') else '' ,
				$SC_400_a)
			" />
		</skos:altLabel>
	</xsl:template>


	<xsl:template match="champs">
		<xsl:apply-templates />
	</xsl:template>

    <!-- URI ISNI -->
    <xsl:template match="SOUSCHAMP[@UnimarcSubfield ='010$a']">
		<owl:sameAs rdf:about="{concat('https://isni.org/isni/',data)}"/>		
	</xsl:template> 

	<!-- ISNI -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield ='031$a']">
		<dc:identifier>ISNI<xsl:value-of select="data" /></dc:identifier>
	</xsl:template>

	<xsl:template match="SOUSCHAMP[@UnimarcSubfield ='100$e']">
		<rdaGr2:biographicalInformation>
			<xsl:value-of select="data" />
		</rdaGr2:biographicalInformation>
	</xsl:template>

	<xsl:template match="SOUSCHAMP[@UnimarcSubfield ='100$9']">
		<rdaGr2:professionOrOccupation>
			<xsl:value-of select="lower-case(data)" />
		</rdaGr2:professionOrOccupation>
	</xsl:template>

	<xsl:template match="SOUSCHAMP[@UnimarcSubfield ='100$d']">
		<xsl:analyze-string
			regex="([0-9]{{4}})(-|\.)([0-9]{{4}})" select="data">
			<xsl:matching-substring>
				<rdaGr2:dateOfBirth>
					<xsl:value-of select="regex-group(1)" />
				</rdaGr2:dateOfBirth>
				<rdaGr2:dateOfDeath>
					<xsl:value-of select="regex-group(3)" />
				</rdaGr2:dateOfDeath>
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:template>

	<!-- le lieu de naissance -->

	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='602$a']" mode="date">

		<!-- <xsl:message>602$A : <xsl:value-of select="data" /></xsl:message> -->
		<xsl:choose>
			<xsl:when
				test="contains(data,'né') or contains(data,'mort')">
				<xsl:analyze-string regex="né(\D+)|mort(\D+)"
					select="data">
					<xsl:matching-substring>
						<xsl:if test="regex-group(1)">
							<edm:begin>
								<xsl:value-of
									select="normalize-space(substring-before(substring-after(regex-group(1),'à'),'le'))" />
							</edm:begin>
						</xsl:if>
						<xsl:if test="regex-group(2)">
							<edm:end>
								<xsl:value-of
									select="normalize-space(substring-before(substring-after(regex-group(2),'à'),'le'))" />
							</edm:end>
						</xsl:if>
					</xsl:matching-substring>
				</xsl:analyze-string>
			</xsl:when>

			<xsl:otherwise>
				<xsl:message>Warning notice <xsl:value-of select="../../@id" /> : cannot extract date/place of birth/death from 602$a, value '<xsl:value-of select="data" />' (expecting "né le ... à ..." ou "mort le ... à ...")</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='602$a']" mode="place">

		<!-- <xsl:message>602$A : <xsl:value-of select="data" /></xsl:message> -->
		<xsl:choose>
			<xsl:when
				test="contains(data,'né') or contains(data,'mort')">
				<xsl:analyze-string regex="né(\D+)|mort(\D+)"
					select="data">
					<xsl:matching-substring>
						<xsl:if test="regex-group(1)">
							<rdaGr2:placeOfBirth>
								<xsl:value-of
									select="normalize-space(substring-before(substring-after(regex-group(1),'à'),'le'))" />
							</rdaGr2:placeOfBirth>
						</xsl:if>
						<xsl:if test="regex-group(2)">
							<rdaGr2:placeOfDeath>
								<xsl:value-of
									select="normalize-space(substring-before(substring-after(regex-group(2),'à'),'le'))" />
							</rdaGr2:placeOfDeath>
						</xsl:if>
					</xsl:matching-substring>
				</xsl:analyze-string>
			</xsl:when>

			<xsl:otherwise>
				<xsl:message>Warning notice <xsl:value-of select="../../@id" /> : cannot extract date/place of birth/death from 602$a, value '<xsl:value-of select="data" />' (expecting "né le ... à ..." ou "mort le ... à ...")</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="SOUSCHAMP[@UnimarcSubfield ='641$a']">
		<rdaGr2:biographicalInformation>
			<xsl:value-of select="data" />
		</rdaGr2:biographicalInformation>
	</xsl:template>

	<!-- identifiant BNF ou SUDOC -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield ='994$a']">
		<dc:identifier>
			<xsl:value-of select="data" />
		</dc:identifier>
	</xsl:template>
	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield ='994$b']">
		<owl:sameAs rdf:resource="{data}" />
	</xsl:template>

	<xsl:template match="text()"></xsl:template>
</xsl:stylesheet> 