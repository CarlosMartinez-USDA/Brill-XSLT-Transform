<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" xmlns="http://www.loc.gov/mods/v3"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs xd">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jun 22, 2017</xd:p>
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
                <xsl:call-template name="name-info-cambridge"/>
            </name>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="name-info-cambridge">
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
        
        <!-- Use id to get affiliation  -->
        <xsl:variable name="affid" select="xref[@ref-type='aff']/@rid"/>
        <xsl:if test="$affid">
            <xsl:for-each select="/article/front/article-meta/aff[@id=$affid]">
                <affiliation>
                    <xsl:variable name="aff-string" select="string-join((addr-line|institution|country), ', ')"/>
                    <xsl:value-of select="normalize-space($aff-string)"/>
                </affiliation>
            </xsl:for-each>
        </xsl:if>
        <role>
            <roleTerm type="text">author</roleTerm>
        </role>
    </xsl:template>
    
    <xsl:template match="affiliation" priority="3">
        <xsl:value-of select="child::*" separator=", "/>
    </xsl:template>
    
    <xsl:template match="/article/front/article-meta/custom-meta-group/custom-meta/meta-value"
        priority="3">
        <xsl:if test="preceding-sibling::node()/text() = 'pdf'">
            <fileLocation note="nonpublic" usage="primary">
                <xsl:text>file://</xsl:text>
                <xsl:value-of select="."/>
            </fileLocation>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="/article/front/article-meta/custom-meta-wrap/custom-meta/meta-value"
        priority="3">
        <xsl:if test="preceding-sibling::node()/text() = 'pdf'">
            <fileLocation note="nonpublic" usage="primary">
                <xsl:text>file://</xsl:text>
                <xsl:value-of select="."/>
            </fileLocation>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>