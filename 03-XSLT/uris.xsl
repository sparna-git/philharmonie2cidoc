<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:sparnaf="http://data.sparna.fr/function/sparnaf#"
	xmlns:mus="http://data.doremus.org/ontology#"
	xmlns:efrbroo="http://erlangen-crm.org/efrbroo/"
	xmlns:ecrm="http://erlangen-crm.org/current/"
>

	<xsl:function name="mus:URI-F24_Expression">
		<xsl:param name="idReferenceNotice" />
		<xsl:value-of select="concat('http://data.philharmoniedeparis.fr/',$idReferenceNotice)" />
	</xsl:function>
	
	<xsl:function name="ecrm:has_time">
		<xsl:param name="data_find_year"/>
		<xsl:choose>
			<xsl:when test="contains($data_find_year, )"></xsl:when>
		</xsl:choose>
	</xsl:function>

</xsl:stylesheet>