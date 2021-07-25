<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:saxon="http://saxon.sf.net/"   
    xmlns:mods="http://www.loc.gov/mods/v3"

    exclude-result-prefixes="xs saxon mods"
    version="2.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:template match="/">
        <submissions>
        <xsl:for-each select="fileList/file">            
            <xsl:variable name="thisFile"><xsl:value-of select="./text()"/></xsl:variable>
         
            <xsl:apply-templates select="document($thisFile)/mods:mods"/>
        </xsl:for-each>
        </submissions>
    </xsl:template>
    
    <xsl:template match="mods:mods">
        <submissionInfo>
            <fileName><xsl:value-of select="saxon:system-id()"/></fileName>
            <itemTitle><xsl:value-of select="mods:titleInfo/mods:title"/></itemTitle>
            <xsl:call-template name="getAuthors"/>
            <xsl:call-template name="getIDs"/>
            <xsl:call-template name="getIDtypes"/>
            <xsl:apply-templates select="mods:relatedItem"/>
            <doi><xsl:value-of select="mods:location/mods:url"/></doi>
        </submissionInfo>
    </xsl:template>
    
    <xsl:template match="mods:mods/mods:relatedItem">
        <relatedType><xsl:value-of select="@type"/></relatedType>
        <relatedTitle><xsl:value-of select="mods:titleInfo/mods:title"/></relatedTitle>
        <xsl:call-template name="relatedIdentifier"/>
    </xsl:template>
    
    <xsl:template name="relatedIdentifier">
        <relatedIdentifier>
            <relatedIDvalue>            <xsl:call-template name="join">
                <xsl:with-param name="list" select="mods:identifier"/>
                <xsl:with-param name="separator" select="'; '"/>
            </xsl:call-template></relatedIDvalue>
            <relatedIDtype>            <xsl:call-template name="join">
                <xsl:with-param name="list" select="mods:identifier/@type"/>
                <xsl:with-param name="separator" select="'; '"/>
            </xsl:call-template></relatedIDtype>
        </relatedIdentifier>
    </xsl:template>
    
    <xsl:template name="getAuthors">
        <authors>
            <xsl:call-template name="join">
                <xsl:with-param name="list" select="mods:name/mods:displayForm"/>
                <xsl:with-param name="separator" select="'; '"/>
            </xsl:call-template>
        </authors>
    </xsl:template>
    
    <xsl:template name="getIDs">
        <articleIDs>
            <xsl:call-template name="join">
                <xsl:with-param name="list" select="mods:identifier"/>
                <xsl:with-param name="separator" select="'; '"/>
            </xsl:call-template>
        </articleIDs>
    </xsl:template>
    
    <xsl:template name="getIDtypes">
        <articleIDtypes>
            <xsl:call-template name="join">
                <xsl:with-param name="list" select="mods:identifier/@type"/>
                <xsl:with-param name="separator" select="'; '"/>
            </xsl:call-template>
        </articleIDtypes>
    </xsl:template>
    

    
    <xsl:template name="join">
        <xsl:param name="list" />
        <xsl:param name="separator"/>
        
        <xsl:for-each select="$list">
            <xsl:value-of select="." />
            <xsl:if test="position() != last()">
                <xsl:value-of select="$separator" />
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>