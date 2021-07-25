<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xpath-default-namespace="http://www.loc.gov/mods/v3" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns="http://www.loc.gov/mods/v3" 
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    exclude-result-prefixes="saxon xlink">
    <xsl:output method="xml" indent="yes" encoding="UTF-8" saxon:next-in-chain="fix_characters.xsl"/>
    <xsl:output method="xml" indent="yes" encoding="UTF-8" name="archive-original"/>
    
    <!-- Pulls in source information such as Vendor and source file name -->
    
    <!-- Parameters -->
    <xsl:include href="commons/params.xsl"/>
    
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="/">
        <xsl:result-document method="xml" encoding="UTF-8" indent="yes" href="file:///{$workingDir}A-{replace($originalFilename, '(.*/)(.*)(\.xml)', '$2')}_{position()}.xml" format="archive-original">            
            <xsl:copy-of select="."/>            
        </xsl:result-document>
         
        <mods version="3.7">
            <xsl:namespace name="xlink">http://www.w3.org/1999/xlink</xsl:namespace>
            <xsl:namespace name="xsi">http://www.w3.org/2001/XMLSchema-instance</xsl:namespace>
            <!--<xsl:attribute name="xlmns">http://www.loc.gov/mods/v3</xsl:attribute>-->
            <xsl:attribute name="xsi:schemaLocation">http://www.loc.gov/standards/mods/v3/mods-3-7.xsd</xsl:attribute>
            
            <xsl:for-each select="node()">
                <xsl:apply-templates select="node()" />
            </xsl:for-each>           
            <xsl:apply-templates select="/mods/relatedItem[@type='host']/identifier[@type='uri']"/>
            <xsl:call-template name="extension" /> 
        </mods>
    </xsl:template>
     
    <xsl:template match="*[not(node())]"/>
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()[normalize-space()]|@*[normalize-space()]"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="name[position() = 1]">
        <xsl:copy>
            <xsl:attribute name="usage">primary</xsl:attribute>
            <xsl:apply-templates select="@* | node()"/>
            <xsl:call-template name="displayName"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="name[position() > 1]">
        <xsl:if test="namePart/text()">
        <xsl:copy>
            <xsl:apply-templates select="@* | *"/>
            <xsl:call-template name="displayName"/>
        </xsl:copy>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="displayName">
        <displayForm xmlns="http://www.loc.gov/mods/v3">
            <xsl:choose>
                <xsl:when test="@type = 'personal'">
                    <xsl:value-of select="namePart[@type = 'family']"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of
                        select="string-join((string-join(namePart[@type = 'given'], ' '), namePart[@type = 'middle']), ' ')"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="namePart"/>
                </xsl:otherwise>
            </xsl:choose>
        </displayForm>
    </xsl:template>

    <xsl:template match="language">
        <xsl:copy>
            <xsl:apply-templates select="@* | *"/>
            <xsl:if test="languageTerm[@type='code'] = 'eng' and not(languageTerm[@type='text'])">
                <languageTerm type="text" xmlns="http://www.loc.gov/mods/v3"><xsl:text>English</xsl:text></languageTerm>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
        
    <xsl:template match="relatedItem[@type='host']/part/detail[@type='number']">         
        <detail type="issue" xmlns="http://www.loc.gov/mods/v3">
            <xsl:copy-of select="node()"></xsl:copy-of>
         </detail>  
   </xsl:template> 
    
 
    <xsl:template match="relatedItem[@type='host']">
        <xsl:copy>
            <xsl:apply-templates select="@*, titleInfo, title, originInfo, publisher, identifier[@type='issn'], part, detail, number, caption, detail, number, caption, text"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/mods/relatedItem[@type='host']/identifier[@type='uri']">
        <location xmlns="http://www.loc.gov/mods/v3">
            <url displayLabel="Available from publisher's site">  
                <xsl:value-of select="."/>
            </url>
        </location>
    </xsl:template>
    
            
    <xsl:template name="extension">
        <extension>
            <vendorName>
                <xsl:value-of select="$vendorName"/>
            </vendorName>
            <archiveFile>
                <xsl:value-of select="$archiveFile"/>
            </archiveFile>
            <originalFile>
                <xsl:value-of select="$originalFilename"/>
            </originalFile>
            <workingDirectory>
                <xsl:value-of select="$workingDir"/>
            </workingDirectory>
        </extension>
    </xsl:template>

</xsl:stylesheet>
