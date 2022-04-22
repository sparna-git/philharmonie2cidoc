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

	<xsl:output indent="yes" method="xml" />
	
	<!-- Variable -->
	<xsl:variable name="sURI">https://ark.philharmoniedeparis.fr/ark/49250/</xsl:variable> 


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
		<!-- concat($sURI,replace(@type,':',''),'/',@id) -->
		<edm:Agent rdf:about="{concat($sURI,@id)}">
			<!-- prefLabel -->
			<xsl:apply-templates select="champs[@UnimarcTag = '110']/SOUSCHAMP[@UnimarcSubfield ='110$a']" mode="prefLabel" />
			<!-- altLabel -->
			<xsl:apply-templates select="champs[@UnimarcTag = '410']/SOUSCHAMP[@UnimarcSubfield ='410$a']" />
			<!-- identifier -->
			<xsl:apply-templates select="champs[@UnimarcTag = '031']/SOUSCHAMP[@UnimarcSubfield ='031$a']" />
			<xsl:apply-templates select="champs[@UnimarcTag = '994']/SOUSCHAMP[@UnimarcSubfield ='994$a']" />
			<!-- foaf:name -->
			<xsl:apply-templates select="champs[@UnimarcTag = '110']/SOUSCHAMP[@UnimarcSubfield ='110$a']" mode="foafname" />
			<!-- professionOrOccupation -->
			<xsl:apply-templates select="champs[@UnimarcTag='100']/SOUSCHAMP[@UnimarcSubfield ='100$9']" />
			<!-- sameAs -->
			<xsl:apply-templates select="champs[@UnimarcTag = '994']/SOUSCHAMP[@UnimarcSubfield='994$b']" />
		</edm:Agent>
	</xsl:template>

	<xsl:template match="champs">
		<xsl:apply-templates />
	</xsl:template>
	
	
	<xsl:template
		match="SOUSCHAMP[@UnimarcSubfield = '031$a']">
		<dc:identifier>
			<xsl:value-of select="data" />
		</dc:identifier>
	</xsl:template>

	<xsl:template
		match="SOUSCHAMP[@UnimarcSubfield = '110$a']" mode="prefLabel">

		<skos:prefLabel>
			<xsl:value-of select="data" />
		</skos:prefLabel>
	</xsl:template>

	<xsl:template
		match="SOUSCHAMP[@UnimarcSubfield = '110$a']" mode="foafname">
		<foaf:name>
			<xsl:value-of select="data" />
		</foaf:name>
	</xsl:template>
	
	
	<xsl:template
		match="SOUSCHAMP[@UnimarcSubfield = '100$9']">
		<rdaGr2:professionOrOccupation>
			<xsl:value-of select="lower-case(data)" />
		</rdaGr2:professionOrOccupation>		
	</xsl:template>

	<xsl:template
		match="SOUSCHAMP[@UnimarcSubfield = '410$a']">
		<skos:altLabel>
			<xsl:value-of select="data" />
		</skos:altLabel>
	</xsl:template>
	
	
	<xsl:template
		match="SOUSCHAMP[@UnimarcSubfield = '994$a']">
		<dc:identifier>
			<xsl:value-of select="data" />
		</dc:identifier>
	</xsl:template>
	
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield ='994$b']">
		<owl:sameAs rdf:resource="{data}" />
	</xsl:template>	

	<xsl:template match="text()"></xsl:template>

</xsl:stylesheet>