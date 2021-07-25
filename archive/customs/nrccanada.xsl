<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs xd"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jul 10, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> rdonahue</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Include the default/standards-compliant stylesheet.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:include href="../jats_to_mods_30.xsl"/>
    
    <xsl:template match="contrib-group[@content-type = 'authors' or not(@content-type)]" priority="3">
        <xsl:for-each select="contrib">
            <name type="personal">                
                <xsl:if test="position() = 1">
                    <xsl:attribute name="usage">primary</xsl:attribute>
                </xsl:if>
                <xsl:call-template name="name-info-nrc"/>
            </name>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="name-info-nrc">
        <xsl:if test="string-name/given-names">
            <namePart type="given">
                <xsl:value-of select="normalize-space (string-name/given-names)" />
            </namePart>
            <namePart type="family">
                <xsl:value-of select="string-name/surname" />
            </namePart>
            
            <displayForm>
                <xsl:value-of select="string-name/surname" />
                <xsl:text>, </xsl:text>
                <xsl:value-of select="normalize-space (string-name/given-names)" />
            </displayForm>
        </xsl:if>
        <xsl:if test="name/given-names">
            <namePart type="given">
                <xsl:value-of select="normalize-space (name/given-names)" />
            </namePart>
            <namePart type="family">
                <xsl:value-of select="name/surname" />
            </namePart>
            
            <displayForm>
                <xsl:value-of select="name/surname" />
                <xsl:text>, </xsl:text>
                <xsl:value-of select="normalize-space (name/given-names)" />
            </displayForm>
        </xsl:if>
        <!-- affiliation matched by the reference super script character -->   
        <xsl:variable name="affid" select="xref[@ref-type='aff']/@rid" />
        <xsl:choose>
            
            <xsl:when test="$affid">
                <xsl:for-each select="../aff[@id=$affid]">
                    <affiliation>
                        <xsl:for-each select="text()">
                            <xsl:value-of select="normalize-space(.)"/>
                        </xsl:for-each>
                    </affiliation>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="../aff">
                <xsl:for-each select="../aff">
                    <affiliation>
                        <xsl:for-each select="text()">
                            <xsl:value-of select="normalize-space(.)"/>
                        </xsl:for-each>
                    </affiliation>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
        <role>
            <roleTerm type="text">author</roleTerm>
        </role>
    </xsl:template>
    
    <xsl:template match="affiliation" priority="3">
        <xsl:value-of select="child::*" separator=", "/>
    </xsl:template>
    
</xsl:stylesheet>