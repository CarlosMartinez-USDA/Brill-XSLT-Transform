<?xml version="1.0" encoding="UTF-8"?>
<!-- Fixed lccn identifier 2016-04-11 JG -->
<!-- Header -->
<xsl:stylesheet version="2.0" xmlns="http://www.loc.gov/mods/v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xhtml="http://www.w3.org/1999/xhtml/" >
    <xsl:output method="xml" indent="yes" encoding="UTF-8" />
    
    <!-- Root -->
    <xsl:template match="/">
        <mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.5" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
        
            <titleInfo>
                <title>
                    <xsl:value-of select="normalize-space(metadata/title)"/>
                </title>
                <partNumber>
                    <xsl:value-of select="metadata/volume"/>
                </partNumber>
            </titleInfo>
            <xsl:for-each select="metadata/creator">      
            <name type="corporate">
                <namePart>
                    <xsl:value-of select="normalize-space(.)"/>
                </namePart>
            </name>
            </xsl:for-each>   
            <typeOfResource>text</typeOfResource>
            <genre authority="marcgt">issue</genre>
            <originInfo>
                <dateIssued encoding="w3cdtf" keyDate="yes">
                    <xsl:value-of select="metadata/date"/>
                </dateIssued>
            </originInfo>
            <xsl:if test="(contains(metadata/language, 'eng'))">
                <language>
                    <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
                    <languageTerm type="text">English</languageTerm>
                </language>
            </xsl:if>
            <xsl:if test="not(contains(metadata/language, 'eng'))">
                <language>
                    <languageTerm type="code" authority="iso639-2b">
                        <xsl:value-of select="metadata/language"/>
                    </languageTerm>
                </language>
            </xsl:if>
            <relatedItem type="host">
                <titleInfo>
                    <title>
                        <xsl:value-of select="metadata/series"/>
                    </title>
                </titleInfo>
                <xsl:if test="metadata/lccn">
                <identifier type="lccn">
                    <xsl:value-of select="metadata/lccn"/>
                </identifier>
            </xsl:if>
            </relatedItem>
            <identifier type="agricola-IA">
                <xsl:value-of select="metadata/unique_id"/>
            </identifier>
            <location>
                <physicalLocation>DNAL</physicalLocation>
                <shelfLocator>
                    <xsl:value-of select="metadata/nal_call_number"/>
                </shelfLocator>
            </location>
            <location>
                <url>
                    <xsl:value-of select="metadata/identifier-access"/>
                </url>
            </location>
            <recordInfo>
                <recordIdentifier source="CaSfIA">
                    <xsl:value-of select="metadata/identifier"/>
                </recordIdentifier>
            </recordInfo>
        </mods>
    </xsl:template>
</xsl:stylesheet>