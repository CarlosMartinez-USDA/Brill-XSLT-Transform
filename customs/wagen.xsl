<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:f="http://functions"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:ali="http://www.niso.org/schemas/ali/1.0/" 
    xmlns="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xd xs f saxon xlink xsi xml ali"
    version="2.0">
<!--    DOCUMENTATION COMMENTED OUT BECAUSE THE SERVER'S SAXON DOES NOT WANT ANY CONTENT BEFORE AN IMPORT
        
        <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jan 08, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> Rachel Donahue</xd:p>
            <xd:p><xd:b>Vendor:</xd:b> Wageningen Academic Publishers</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Import the default/standards-compliant stylesheet.</xd:p>
        </xd:desc>
    </xd:doc>
    -->
    <xsl:import href="../jats_to_mods_30.xsl"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p><xd:b>Function: </xd:b>f:join-date-strings</xd:p>
            <xd:p><xd:b>Usage: </xd:b>f:join-date-strings(XPath)</xd:p>
            <xd:p><xd:b>Purpose: </xd:b> Join year, month, and day sub-elements</xd:p>            
        </xd:desc>
        <xd:param name="thePath">Parent XPath for the sub-elements. Will generally be <xd:i>current()</xd:i> .</xd:param>
    </xd:doc>
    <xsl:function name="f:join-date-strings">
        <xsl:param name="thePath"/>
        <xsl:value-of select="($thePath/year, f:checkMonthType($thePath/month), format-number($thePath/day,'00'))[. != 'NaN']" separator="-"/>
    </xsl:function>
    
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Don't include figure captions in the abstract.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="abstract[@abstract-type='graphical']/fig"/>
        
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Wageningen sometimes includes text abstracts within the graphical abstract element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="abstract[@abstract-type='graphical'][@xml:lang='en']">
        <xsl:variable name="this"><xsl:apply-templates/></xsl:variable>
        <abstract>
            <xsl:value-of select="normalize-space($this)"/>
        </abstract>
    </xsl:template>       
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Articles from 2015 have pub-dates with no attributes.</xd:p>
            <xd:p> This template has also been simplified from the originInfo in the base JATS template, but other functionality is identical. The apply-templates order reflects the order of preference. e.g. copyright-year will only generate output when there is no pub-date or accepted date. </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="originInfo">
        <originInfo>
            <xsl:for-each select="article/front/article-meta">
                <xsl:apply-templates
                    select="pub-date[(@pub-type = ('ppub', 'epub-ppub') or @date-type = 'pub' or @publication-format = ('print', 'electronic'))]"
                    mode="origin"/>

                <xsl:if test="not(pub-date/@pub-type)">
                    <xsl:apply-templates select="pub-date[not(@*)]" mode="origin"/>
                </xsl:if>

                <xsl:apply-templates select="history/date[@date-type = 'accepted']" mode="origin"/>
                <xsl:apply-templates select="permissions/copyright-year" mode="origin"/>                

                <xsl:apply-templates
                    select="pub-date[(@pub-type = 'epub' or @date-type = 'issue-pub' or @publication-format = 'online')]"
                    mode="origin"/>
            </xsl:for-each>
        </originInfo>
    </xsl:template>
    
    <xsl:template match="copyright-year" mode="origin">
        <xsl:if test="not(../../history/date[@date-type = 'accepted']) and not(../../pub-date)">
            <dateIssued encoding="w3cdtf" keyDate="yes">
                <xsl:value-of select="."/>
            </dateIssued>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="date[@date-type = 'accepted']" mode="origin">
        <xsl:if test="not(../../pub-date)">
            <dateIssued encoding="w3cdtf" keyDate="yes">
                <xsl:value-of
                    select="f:join-date-strings(current())"
                />
            </dateIssued>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="pub-date[(@pub-type = 'epub' or @date-type = 'issue-pub' or @publication-format = 'online')][1]" mode="origin">
        <xsl:choose>
            <xsl:when test="not(../pub-date[(@pub-type = ('ppub', 'epub-ppub') or @date-type = 'pub' or @publication-format = ('print', 'electronic'))])">
                <dateIssued encoding="w3cdtf" keyDate="yes">
                    <xsl:value-of select="f:join-date-strings(current())"/>
                </dateIssued>
            </xsl:when>
            <xsl:otherwise>
                <dateOther encoding="w3cdtf" type="electronic">
                    <xsl:value-of select="f:join-date-strings(current())"/>
                </dateOther>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="pub-date[not(@*)]" mode="origin">
        <dateIssued encoding="w3cdtf" keyDate="yes">
            <xsl:value-of select="f:join-date-strings(current())"/>
        </dateIssued>     
    </xsl:template>  
</xsl:stylesheet>