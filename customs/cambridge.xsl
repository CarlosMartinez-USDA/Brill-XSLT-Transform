<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:f="http://functions"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:ali="http://www.niso.org/schemas/ali/1.0/" 
    xmlns="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xd xs f saxon xlink xsi xml ali">

    <xsl:import href="../jats_to_mods_30.xsl"/>
    
    <xsl:template name="originInfo">
        <originInfo>
            <xsl:for-each select="article/front/article-meta">
                <xsl:choose>
                    <xsl:when test="(pub-date[@publication-format='print'] and pub-date[@publication-format='electronic']) or (pub-date[@pub-type='epub'] and pub-date[@pub-type='ppub'])">
                            <xsl:apply-templates select="pub-date[(@pub-type = ('ppub') or @date-type = 'pub' or @publication-format = ('print'))]| date[@date-type = 'accepted']" mode="origin"/>
                            <xsl:apply-templates select="pub-date[(@publication-format='electronic' or @pub-type=('epub','epub-ppub'))]" mode="other"/>
                    </xsl:when>
                    <xsl:when test="not(pub-date)">
                        <xsl:apply-templates
                            select="history/date[@date-type = 'accepted']"
                            mode="origin"/>
                        <xsl:if
                            test="not(history/date[@date-type = 'accepted'])">
                            <originInfoSelect>choose first 2</originInfoSelect>
                            <xsl:apply-templates
                                select="permissions/copyright-year"
                                mode="origin"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when
                        test="not(pub-date[(@pub-type = ('ppub', 'epub-ppub') or @date-type = 'pub' or @publication-format = ('print', 'electronic'))])">
                        <xsl:apply-templates
                            select="pub-date[(@pub-type = 'epub'or @date-type = 'issue-pub' or @publication-format = 'online')]"
                            mode="origin"/>
                    </xsl:when>
                    <xsl:otherwise>                        
                        <xsl:apply-templates
                            select="pub-date[(@pub-type = ('ppub', 'epub-ppub') or @date-type = 'pub' or @publication-format = ('print', 'electronic'))]"
                            mode="origin"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </originInfo>
    </xsl:template>
    
    <xsl:template match="pub-date[(@pub-type = ('ppub', 'epub-ppub') or @date-type = 'pub' or @publication-format = ('print', 'electronic'))]| date[@date-type = 'accepted']" mode="origin">
        <dateIssued encoding="w3cdtf" keyDate="yes">
            <xsl:value-of select="string-join((year, f:checkMonthType(month), format-number(day,'00'))[. != 'NaN'], '-')"/>
        </dateIssued>        
    </xsl:template>
    
    <xsl:template match="pub-date[(@pub-type = 'epub'or @date-type = 'issue-pub' or @publication-format = 'online')][1]" mode="origin">
        <dateIssued encoding="w3cdtf" keyDate="yes">
            <xsl:value-of select="string-join((year, f:checkMonthType(month), format-number(day,'00'))[. != 'NaN'], '-')"/>
        </dateIssued>   
    </xsl:template>
    
    <xsl:template match="copyright-year" mode="origin">
        <dateIssued encoding="w3cdtf" keyDate="yes">
            <xsl:value-of select="."/>
        </dateIssued>    
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Electronic publication date added as 'dateOther' if print date exists.</xd:p>
            <xd:p>Only adds day information if it is present, so as not to produce a NaN in the date.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="pub-date[(@pub-type = 'epub'or @date-type = 'issue-pub' or @publication-format = ('online', 'electronic'))][1]" mode="other">
        <dateOther encoding="w3cdtf" type="electronic">
            <xsl:value-of select="string-join((year, f:checkMonthType(month), format-number(day,'00'))[. != 'NaN'], '-')"/>
        </dateOther>
    </xsl:template>
</xsl:stylesheet>