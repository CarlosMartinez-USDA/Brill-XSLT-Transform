<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:saxon="http://saxon.sf.net/"
    exclude-result-prefixes="xs rdf saxon"
    version="2.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    <xsl:template match="/">
        <articles>
            <xsl:for-each select="fileList/file">            
                <xsl:variable name="thisFile"><xsl:value-of select="./text()"/></xsl:variable>
                <article>
                <xsl:apply-templates select="document($thisFile)/rdf:RDF"/>
                <xsl:apply-templates select="document($thisFile)/rdf:RDF/rdf:Description[1]/*[namespace-uri()='http://purl.org/ontology/bibo/' and local-name()='issn'][1]"/>
                <xsl:apply-templates select="document($thisFile)/rdf:RDF/rdf:Description[1]/*[namespace-uri()='http://purl.org/ontology/bibo/' and local-name()='status'][1]"/>
                </article>
            </xsl:for-each>
        </articles>
    </xsl:template>
    
    <xsl:template match="/rdf:RDF/rdf:Description[1]">
        <pid><xsl:value-of select="@rdf:about"/></pid>
    </xsl:template>
    
    <xsl:template match="/rdf:RDF/rdf:Description[1]/*[namespace-uri()='http://purl.org/ontology/bibo/' and local-name()='issn'][1]">
        <issn><xsl:value-of select="."/></issn>
    </xsl:template>
    
    <xsl:template match="/rdf:RDF/rdf:Description[1]/*[namespace-uri()='http://purl.org/ontology/bibo/' and local-name()='status'][1]">
        <status><xsl:value-of select="."/></status>
    </xsl:template>
</xsl:stylesheet>