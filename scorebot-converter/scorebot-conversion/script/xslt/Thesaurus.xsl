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

	<!-- lecture de recine -->
	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>

	<!-- Template racine -->
	<xsl:template match="NOTICES">
		<rdf:RDF>
			<skos:ConceptScheme rdf:about="https://data.philharmoniedeparis.fr/vocabulary/thesaurus">
				<rdfs:label xml:lang="fr">Thesaurus Cité de la Musique/Philharmonie de Paris</rdfs:label>
				<dcterms:title xml:lang="fr">Thesaurus Cité de la Musique/Philharmonie de Paris</dcterms:title>
			</skos:ConceptScheme>
			<xsl:apply-templates />
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="NOTICE">
		<skos:Concept rdf:about="{concat('https://ark.philharmoniedeparis.fr/ark:49250/',@id)}">
			<skos:inScheme rdf:resource="https://data.philharmoniedeparis.fr/vocabulary/thesaurus" />
			<xsl:apply-templates />
		</skos:Concept>
	</xsl:template>
	
	<xsl:template match="champs">
	   <xsl:apply-templates/>
	</xsl:template>
	
	<!-- 900$a -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='900$a']">
	   <skos:prefLabel xml:lang="fr"><xsl:value-of select="data"/></skos:prefLabel>
	</xsl:template>
	
	<!-- 910$a -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='910$a']">
	   <skos:altLabel xml:lang="fr"><xsl:value-of select="data"/></skos:altLabel>
	</xsl:template>

	<!-- 940$3 -->
	<xsl:template match="SOUSCHAMP[@UnimarcSubfield='940$3']">
	   <skos:broader rdf:resource="{concat('https://ark.philharmoniedeparis.fr/ark:49250/',normalize-space(.))}" />
	</xsl:template>
	
	<xsl:template match="text()"></xsl:template>

</xsl:stylesheet>