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

	<xsl:output indent="yes" method="xml" />
	
	<!-- Root URI -->
	<xsl:variable name="rootUri">https://ark.philharmoniedeparis.fr/ark:49250/</xsl:variable> 


	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>


	<xsl:template match="NOTICES">
		<rdf:RDF>
			<xsl:apply-templates />
		</rdf:RDF>
	</xsl:template>

	<!-- Id's -->
	<xsl:template match="NOTICE">
		<ecrm:E74_Group rdf:about="{concat($rootUri,@id)}">
			<!-- rdfs:label -->
			<xsl:apply-templates select="champs[@UnimarcTag = '110'][SOUSCHAMP/@UnimarcSubfield ='110$a']" />
			<!-- skos:altLabel -->
			<xsl:apply-templates select="champs[@UnimarcTag = '410'][SOUSCHAMP/@UnimarcSubfield ='410$a']" />
		</ecrm:E74_Group>
	</xsl:template>

	<xsl:template match="champs">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="champs[@UnimarcTag = '110']">
		<xsl:variable name="SC_110_a"
			select="SOUSCHAMP[@UnimarcSubfield ='110$a']/data" />
		<xsl:variable name="SC_110_c"
			select="SOUSCHAMP[@UnimarcSubfield ='110$c']/data" />

		<xsl:variable name="value" select="concat(
			$SC_110_a,
			if($SC_110_c != '') then concat(' (',$SC_110_c, ')') else ''			
		)" />

		<rdfs:label xml:lang="fr">
			<xsl:value-of select="$value" />
		</rdfs:label>
	</xsl:template>

	<xsl:template match="champs[@UnimarcTag = '410']">
		<xsl:variable name="SC_410_a"
			select="SOUSCHAMP[@UnimarcSubfield ='410$a']/data" />
		<xsl:variable name="SC_410_c"
			select="SOUSCHAMP[@UnimarcSubfield ='410$c']/data" />

		<xsl:variable name="value" select="concat(
			$SC_410_a,
			if($SC_410_c != '') then concat(' (',$SC_410_c, ')') else ''			
		)" />

		<skos:altLabel xml:lang="fr">
			<xsl:value-of select="$value" />
		</skos:altLabel>
	</xsl:template>

	<xsl:template match="text()"></xsl:template>

</xsl:stylesheet>