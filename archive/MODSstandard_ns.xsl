<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

    <xsl:output encoding="UTF-8" indent="yes" method="xml"/>

    <!-- string for default namespace uri and schema location -->
    <xsl:variable name="ns" select="'http://www.loc.gov/mods/v3'"/>
    <xsl:variable name="xlink" select="'http://www.w3.org/1999/xlink'"/>
    <xsl:variable name="schemaLoc"
        select="'http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd'"/>

    <xsl:param name="id"/>
    <xsl:variable name="pid" select="concat( 'Ag:', $id)"/>
    <!-- recieve new PID -->

    <!-- template for root element -->
    <!-- adds default namespace and schema location -->
    <xsl:template match="/*" priority="1">
        <xsl:element name="{local-name()}" namespace="{$ns}">
            <xsl:namespace name="xlink">
                <xsl:value-of select="$xlink"/>
            </xsl:namespace>
            <xsl:attribute name="xsi:schemaLocation"
                namespace="http://www.w3.org/2001/XMLSchema-instance">
                <xsl:value-of select="$schemaLoc"/>
            </xsl:attribute>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <!--template for elements without a namespace -->
    <xsl:template match="*[namespace-uri() = '']">
        <xsl:element name="{local-name()}" namespace="{$ns}">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <!--template for elements with a namespace -->
    <xsl:template match="*[not(namespace-uri() = '')]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!--template to copy attributes, text, PIs and comments -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="name">
        <xsl:element name="name" namespace="http://www.loc.gov/mods/v3">
            <xsl:attribute name="type">personal</xsl:attribute>
            <xsl:if test="position()=1">
                <xsl:attribute name="usage">primary</xsl:attribute>                
            </xsl:if>
            <xsl:choose>
                <xsl:when test="namePart[not(@type)]">
                    <xsl:element name="namePart" namespace="http://www.loc.gov/mods/v3">
                        <xsl:value-of select="namePart"/>
                    </xsl:element>
                    <xsl:element name="displayForm" namespace="http://www.loc.gov/mods/v3">
                        <xsl:value-of select="namePart"/>
                    </xsl:element>
                    <xsl:if test="affiliation">
                        <xsl:element name="affiliation" namespace="http://www.loc.gov/mods/v3">
                            <xsl:value-of select="affiliation"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="role/roleTerm">
                        <xsl:element name="role" namespace="http://www.loc.gov/mods/v3">
                            <xsl:element name="roleTerm" namespace="http://www.loc.gov/mods/v3">
                                <xsl:value-of select="role/roleTerm"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="namePart" namespace="http://www.loc.gov/mods/v3">
                        <xsl:attribute name="type">given</xsl:attribute>
                        <xsl:value-of select="namePart[@type='given']"/>
                    </xsl:element>
                    <xsl:if test="namePart[@type='middle']">
                        <xsl:element name="namePart" namespace="http://www.loc.gov/mods/v3">
                            <xsl:attribute name="type">given</xsl:attribute>
                            <xsl:value-of select="namePart[@type='middle']"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:element name="namePart" namespace="http://www.loc.gov/mods/v3">
                        <xsl:attribute name="type">family</xsl:attribute>
                        <xsl:value-of select="namePart[@type='family']"/>
                    </xsl:element>
                    <xsl:if test="namePart[@type='termsOfAddress']">
                        <xsl:element name="namePart" namespace="http://www.loc.gov/mods/v3">
                            <xsl:attribute name="type">termsOfAddress</xsl:attribute>
                            <xsl:value-of select="namePart[@type='termsOfAddress']"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:element name="displayForm" namespace="http://www.loc.gov/mods/v3">
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
                    </xsl:element>

                    <xsl:if test="affiliation">
                        <xsl:element name="affiliation" namespace="http://www.loc.gov/mods/v3">
                            <xsl:value-of select="affiliation"/>
                        </xsl:element>
                    </xsl:if>
                    <xsl:if test="role/roleTerm">
                        <xsl:element name="role" namespace="http://www.loc.gov/mods/v3">
                            <xsl:element name="roleTerm" namespace="http://www.loc.gov/mods/v3">
                                <xsl:value-of select="role/roleTerm"/>
                            </xsl:element>
                        </xsl:element>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>

    </xsl:template>


    <xsl:template match="originInfo/dateIssued">
        <xsl:choose>
            <xsl:when test="originInfo/dateIssued[@encoding='w3cdtf'][@keyDate='yes']">
                <!-- Do nothing -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="dateIssued" namespace="http://www.loc.gov/mods/v3">
                    <xsl:attribute name="encoding">w3cdtf</xsl:attribute>
                    <xsl:attribute name="keyDate">yes</xsl:attribute>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="language">
        <xsl:element name="language" namespace="http://www.loc.gov/mods/v3">
            <xsl:element name="languageTerm" namespace="http://www.loc.gov/mods/v3">
                <xsl:attribute name="type">code</xsl:attribute>
                <xsl:attribute name="authority">iso639-2b</xsl:attribute>

                <xsl:if test="languageTerm[@type='code'][@authority='iso639-2b']">
                    <xsl:value-of select="languageTerm[@type='code'][@authority='iso639-2b']"/>
                </xsl:if>
                <xsl:if test="not (languageTerm[@type='code'][@authority='iso639-2b'])">
                    <xsl:text>eng</xsl:text>
                </xsl:if>
            </xsl:element>
            <xsl:element name="languageTerm" namespace="http://www.loc.gov/mods/v3">
                <xsl:attribute name="type">text</xsl:attribute>
                <xsl:if test="languageTerm[@type='text']">
                    <xsl:value-of select="languageTerm[@type='text']"/>
                </xsl:if>
                <xsl:if test="not (languageTerm[@type='text'])">
                    <xsl:text>English</xsl:text>
                </xsl:if>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="location">
        <xsl:if test="url">
            <xsl:element name="location" namespace="http://www.loc.gov/mods/v3">                
                <xsl:element name="url" namespace="http://www.loc.gov/mods/v3">
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
                    <xsl:value-of select="url"/>
                </xsl:element>
            </xsl:element>
        </xsl:if>

        <xsl:if test="shelfLocator">
            <xsl:element name="location" namespace="http://www.loc.gov/mods/v3">
                <xsl:element name="physicalLocation" namespace="http://www.loc.gov/mods/v3">
                    <xsl:text>DNAL</xsl:text>
                </xsl:element>
                <xsl:element name="shelfLocator" namespace="http://www.loc.gov/mods/v3">
                    <xsl:value-of select="shelfLocator"/>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="mods/identifier[@type='local']">
        <!-- replace old PID and new PID -->
        <xsl:element name="identifier" namespace="http://www.loc.gov/mods/v3">
            <xsl:attribute name="type">local</xsl:attribute>
            <xsl:value-of select="$pid"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="extension/affiliation">
        <xsl:choose>
            <xsl:when test="affiliationPart[@type='agency']">
                <xsl:element name="note" namespace="http://www.loc.gov/mods/v3">
                    <xsl:attribute name="type">submissionSource</xsl:attribute>
                    <xsl:value-of select="affiliationPart[@type='department']"/>
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="affiliationPart[@type='agency']"/>
                </xsl:element>
            </xsl:when>

            <xsl:otherwise>
                <xsl:if test="affiliationPart[@type='department']">
                    <xsl:element name="note" namespace="http://www.loc.gov/mods/v3">
                        <xsl:attribute name="type">submissionSource</xsl:attribute>
                        <xsl:value-of select="affiliationPart[@type='department']"/>
                    </xsl:element>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
