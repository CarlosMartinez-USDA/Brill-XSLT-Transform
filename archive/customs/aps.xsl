<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="xs xd"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jul 17, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> rdonahue</xd:p>
            <xd:p><xd:b>Vendor:</xd:b> American Phytopathological Society</xd:p>
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
                <xsl:call-template name="name-info-aps"/>
            </name>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="name-info-aps">
        <namePart type="given">
            <xsl:value-of select="normalize-space((string-name|name)/given-names)"/>
        </namePart>
        <namePart type="family">
            <xsl:value-of select="(string-name|name)/surname"/>
        </namePart>
        <displayForm>
            <xsl:value-of select="(string-name|name)/surname"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="normalize-space((string-name|name)/given-names)"/>
        </displayForm>
        
        <!-- Use id to get affiliation  -->
        <xsl:variable name="affid" select="xref[@ref-type='aff']/@rid"/>
        <xsl:if test="$affid">
            <xsl:choose>
                <xsl:when test="/article/front/article-meta/aff[@id=$affid]">
                    <xsl:for-each select="/article/front/article-meta/aff[@id=$affid]|/article/front/article-meta/aff/target[@id=$affid]|.//aff[@id=$affid]|/article/front/article-meta/contrib-group/aff[@id=$affid]">
                        <affiliation>
                            <xsl:for-each select="text()">
                                <xsl:value-of select="normalize-space(.)"/>
                            </xsl:for-each>
                        </affiliation>
                    </xsl:for-each>
                </xsl:when>
                
                <xsl:when test="/article/front/article-meta/aff/target[@id=$affid]">
                    <xsl:for-each select="/article/front/article-meta/aff/target[@id=$affid]">
                        <affiliation>
                            <xsl:for-each select="text()">
                                <xsl:value-of select="normalize-space(.)"/>
                            </xsl:for-each>
                        </affiliation>
                    </xsl:for-each>
                </xsl:when>  
                <xsl:when test=".//aff[@id=$affid]">
                    <xsl:for-each select=".//aff[@id=$affid]">
                        <affiliation>
                            <xsl:for-each select="text()">
                                <xsl:value-of select="normalize-space(.)"/>
                            </xsl:for-each>
                        </affiliation>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="/article/front/article-meta/contrib-group/aff[@id=$affid]">
                    <xsl:for-each select="/article/front/article-meta/contrib-group/aff[@id=$affid]">
                        <affiliation>
                            <xsl:apply-templates mode="affiliation"/>
                        </affiliation>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="not($affid)">
                    <xsl:for-each select="/article/front/article-meta/contrib-group/aff">
                        <affiliation>
                            <xsl:apply-templates mode="affiliation"/>
                        </affiliation>
                    </xsl:for-each>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
        <role>
            <roleTerm type="text">author</roleTerm>
        </role>
    </xsl:template>
    
</xsl:stylesheet>