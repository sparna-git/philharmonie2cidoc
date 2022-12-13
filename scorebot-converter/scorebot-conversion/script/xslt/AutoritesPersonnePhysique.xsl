<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:ecrm="http://erlangen-crm.org/current/"
    xmlns:efrbroo="http://erlangen-crm.org/efrbroo/"
    xmlns:mus="http://data.doremus.org/ontology#"
	xmlns:wgs84_pos="http://www.w3.org/2003/01/geo/wgs84_pos#"
	xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:dcterms="http://purl.org/dc/terms/">

	<!-- Format -->
	<xsl:output indent="yes" method="xml" />

	<!-- Root URI -->
	<xsl:variable name="rootUri">https://ark.philharmoniedeparis.fr/ark:49250/</xsl:variable> 

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
		<ecrm:E21_Person rdf:about="{concat($rootUri,@id)}">
			<!-- rdfs:label -->
			<xsl:apply-templates select="champs[@UnimarcTag = '100'][SOUSCHAMP/@UnimarcSubfield ='100$a']" />
			<!-- skos:altLabel -->
			<xsl:apply-templates select="champs[@UnimarcTag = '400'][SOUSCHAMP/@UnimarcSubfield ='400$a']" />
		</ecrm:E21_Person>
	</xsl:template>


	<xsl:template match="champs[@UnimarcTag = '100']">
		<xsl:variable name="SC_100_a"
			select="SOUSCHAMP[@UnimarcSubfield ='100$a']/data" />
		<xsl:variable name="SC_100_m"
			select="SOUSCHAMP[@UnimarcSubfield ='100$m']/data" />

		<xsl:variable name="value" select="concat(
			if($SC_100_m != '') then concat($SC_100_m, ' ') else '' ,
			$SC_100_a
		)" />

		<rdfs:label xml:lang="fr">
			<xsl:value-of select="$value" />
		</rdfs:label>
	</xsl:template>

	<xsl:template match="champs[@UnimarcTag = '400']">
		<xsl:variable name="SC_400_a"
			select="SOUSCHAMP[@UnimarcSubfield ='400$a']/data" />
		<xsl:variable name="SC_400_m"
			select="SOUSCHAMP[@UnimarcSubfield ='400$m']/data" />

		<xsl:choose>
			<xsl:when test="$SC_400_m != ''">
				<xsl:for-each select="$SC_400_m">
					<skos:altLabel xml:lang="fr">
						<xsl:value-of select="concat(., ' ',$SC_400_a)" />
					</skos:altLabel>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<skos:altLabel xml:lang="fr">
					<xsl:value-of select="$SC_400_a" />
				</skos:altLabel>				
			</xsl:otherwise>
		</xsl:choose>	
		
	</xsl:template>

	<xsl:template match="text()"></xsl:template>
</xsl:stylesheet> 