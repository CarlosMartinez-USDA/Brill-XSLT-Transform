<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xs mods" version="1.0">
      
    <xsl:output encoding="UTF-8" indent="yes" method="xml"/>

    <xsl:param name="id"/>
    <xsl:variable name="pid" select="concat( 'agid:', $id)"/> <!-- recieve new PID -->

    <xsl:strip-space elements="*"/>
    <xsl:template match="*[not(node())]"/>
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()[normalize-space()]|@*[normalize-space()]"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="name [position()=1]">
        <name type="personal" usage="primary">
            <xsl:choose>
                <xsl:when test="namePart[not(@type)]">
                    <namePart>
                    <xsl:value-of select="namePart"/>
                        </namePart>
                    <displayForm>
                        <xsl:value-of select="namePart"/>
                    </displayForm>
                    <xsl:if test="affiliation">
                        <affiliation>
                            <xsl:value-of select="affiliation"/>
                        </affiliation>
                    </xsl:if>
                    <xsl:if test="role/roleTerm">
                        <role>
                            <roleTerm type="text">
                                <xsl:value-of select="role/roleTerm"/>
                            </roleTerm>
                        </role>
                    </xsl:if>   
                </xsl:when>
          <xsl:otherwise>
            <namePart type="given">
                <xsl:value-of select="namePart[@type='given']"/>
            </namePart>
            <xsl:if test="namePart[@type='middle']">
                <namePart type="given">
                    <xsl:value-of select="namePart[@type='middle']"/>
                </namePart>
            </xsl:if>
            <namePart type="family">
                <xsl:value-of select="namePart[@type='family']"/>
            </namePart>
            <xsl:if test="namePart[@type='termsOfAddress']">
            <namePart type="termsOfAddress">
                <xsl:value-of select="namePart[@type='termsOfAddress']"/>
            </namePart>
            </xsl:if>
            <displayForm>
                <xsl:value-of select="namePart[@type='family']"/>
                <xsl:text>, </xsl:text>
                <xsl:value-of select="namePart[@type='given']"/>
                <xsl:if test="namePart[@type='middle']">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="namePart[@type='middle']"/>
                </xsl:if>
                <xsl:if test="namePart[@type='termsOfAddress']">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="namePart[@type='termsOfAddress']"/>
                </xsl:if>
            </displayForm>
 
            <xsl:if test="affiliation">
                <affiliation>
                <xsl:value-of select="affiliation"/>
                </affiliation>
            </xsl:if>
            <xsl:if test="role/roleTerm">
                <role>
                    <roleTerm type="text">
                        <xsl:value-of select="role/roleTerm"/>
                    </roleTerm>
                </role>
            </xsl:if>   
          </xsl:otherwise>
            </xsl:choose>
        </name>
        
    </xsl:template>
    
    <xsl:template match="name [position()>1]">
        <name type="personal">
            <xsl:choose>
                <xsl:when test="namePart[not(@type)]">
                    <namePart>
                        <xsl:value-of select="namePart"/>
                    </namePart>
                    <displayForm>
                        <xsl:value-of select="namePart"/>
                    </displayForm>
                    <xsl:if test="affiliation">
                        <affiliation>
                            <xsl:value-of select="affiliation"/>
                        </affiliation>
                    </xsl:if>
                    <xsl:if test="role/roleTerm">
                        <role>
                            <roleTerm type="text">
                                <xsl:value-of select="role/roleTerm"/>
                            </roleTerm>
                        </role>
                    </xsl:if>   
                </xsl:when>
                <xsl:otherwise>
            <namePart type="given">
                <xsl:value-of select="namePart[@type='given']"/>
            </namePart>
            <xsl:if test="namePart[@type='middle']">
                <namePart type="given">
                    <xsl:value-of select="namePart[@type='middle']"/>
                </namePart>
            </xsl:if>
            <namePart type="family">
                <xsl:value-of select="namePart[@type='family']"/>
            </namePart>
            <xsl:if test="namePart[@type='termsOfAddress']">
                <namePart type="termsOfAddress">
                    <xsl:value-of select="namePart[@type='termsOfAddress']"/>
                </namePart>
            </xsl:if>
            <displayForm>
                <xsl:value-of select="namePart[@type='family']"/>
                <xsl:text>, </xsl:text>
                <xsl:value-of select="namePart[@type='given']"/>
                <xsl:if test="namePart[@type='middle']">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="namePart[@type='middle']"/>
                </xsl:if>
                <xsl:if test="namePart[@type='termsOfAddress']">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="namePart[@type='termsOfAddress']"/>
                </xsl:if>
 
            </displayForm>
            <xsl:if test="affiliation">
                <affiliation>
                    <xsl:value-of select="affiliation"/>
                </affiliation>
            </xsl:if>
            <xsl:if test="role/roleTerm">
                <role>
                    <roleTerm type="text">
                        <xsl:value-of select="role/roleTerm"/>
                    </roleTerm>
                </role>
            </xsl:if>   
                </xsl:otherwise>
            </xsl:choose>
        </name>
    </xsl:template>

    <xsl:template match="originInfo/dateIssued[@encoding='w3cdtf'][not(@keyDate='yes')]">
         <dateIssued>
             <xsl:attribute name="encoding">w3cdtf</xsl:attribute>
             <xsl:attribute name="keyDate">yes</xsl:attribute>
             <xsl:value-of select="."/>
         </dateIssued>
    </xsl:template>
    
    <xsl:template match="originInfo/dateIssued[not(@encoding='w3cdtf')][(@keyDate='yes')]">
        <dateIssued>
            <xsl:attribute name="encoding">
                <xsl:value-of select="@encoding"/>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </dateIssued>
    </xsl:template>
    
    <xsl:template match="relatedItem/publisher">
        <originInfo>
            <publisher>
                <xsl:value-of select="."/>
            </publisher>
        </originInfo>
    </xsl:template>
    
    <!-- Remove the Journal PID from article MODS -->
    <xsl:template match="relatedItem/identifier[@type='local']"/>
    
    <xsl:template match="abstract[@type]">
        <abstract>
            <xsl:value-of select="."/>
        </abstract>
    </xsl:template>

    <xsl:template match="language">
        <language>
            <languageTerm type="code" authority="iso639-2b">
                <xsl:if test="languageTerm[@type='code'][@authority='iso639-2b']">
                    <xsl:value-of select="languageTerm[@type='code'][@authority='iso639-2b']"/>
                </xsl:if>
                <xsl:if test="not (languageTerm[@type='code'][@authority='iso639-2b'])">
                    <xsl:text>eng</xsl:text>
                </xsl:if>
            </languageTerm>
            <languageTerm type="text">
                <xsl:if test="languageTerm[@type='text']">
                    <xsl:value-of select="languageTerm[@type='text']"/>
                </xsl:if>
                <xsl:if test="not (languageTerm[@type='text'])">
                    <xsl:text>English</xsl:text>
                </xsl:if>
            </languageTerm>
        </language>
    </xsl:template>
        
    <xsl:template match="/mods/location">
        <location>
                <xsl:if test="url">
                    <xsl:call-template name="url"/>
                </xsl:if>
       </location>
        
        <xsl:if test="shelfLocator">
        <location>
            <physicalLocation>
                <xsl:if test="physicalLocation">
                    <xsl:value-of select="physicalLocation"/>
                </xsl:if>
            </physicalLocation>
            <shelfLocator>
                <xsl:if test="shelfLocator">
                    <xsl:value-of select="shelfLocator"/>
                </xsl:if>
            </shelfLocator>
        </location>
        </xsl:if>
    </xsl:template>    
            
    <xsl:template name="url">
        <xsl:element name="url">
            <xsl:if test="url/@displayLabel">
                <xsl:attribute name="displayLabel">
                    <xsl:value-of select ="url/@displayLabel"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="url/@note">
                <xsl:attribute name="note">
                    <xsl:value-of select ="url/@note"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="url/@usage">
                <xsl:attribute name="usage">
                    <xsl:value-of select ="url/@usage"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="url/@access">
                <xsl:attribute name="access">
                    <xsl:value-of select ="url/@access"/>
                </xsl:attribute>
            </xsl:if>                     
            <xsl:value-of select="url"/>
        </xsl:element>        
    </xsl:template>
    
    <xsl:template match="mods/identifier[@type='local']"> <!-- replace old PID and new PID -->
        <identifier type="local">
            <xsl:value-of select="$pid"/>
        </identifier>
    </xsl:template>

    <xsl:template match="extension/affiliation">
        <xsl:choose>
            <xsl:when test="affiliationPart[@type='agency']">
                <submissionSource>
                    <xsl:value-of select="affiliationPart[@type='department']"/>
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="affiliationPart[@type='agency']"/>
                </submissionSource>
            </xsl:when>

            <xsl:otherwise>
                <xsl:if test="affiliationPart[@type='department']">
                    <submissionSource>
                        <xsl:value-of select="affiliationPart[@type='department']"/>
                    </submissionSource>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="mods/extension/location">
        <xsl:element name="fileLocation">
            <xsl:if test="url/@displayLabel">
                <xsl:attribute name="displayLabel">
                    <xsl:value-of select ="url/@displayLabel"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="url/@note">
                <xsl:attribute name="note">
                    <xsl:value-of select ="url/@note"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="url/@usage">
                <xsl:attribute name="usage">
                    <xsl:value-of select ="url/@usage"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="url/@access">
                <xsl:attribute name="access">
                    <xsl:value-of select ="url/@access"/>
                </xsl:attribute>
            </xsl:if>                     
            <xsl:value-of select="url"/>
        </xsl:element>            
    </xsl:template>
    
    <xsl:template match="mods/extension/note[@type='note'][.='New version']"/>
    
    <xsl:template match="mods/subject[@authority='nal']">
        <subject authority='atg'>
            <xsl:copy-of select="child::node()"/>
        </subject>
    </xsl:template>

</xsl:stylesheet>
