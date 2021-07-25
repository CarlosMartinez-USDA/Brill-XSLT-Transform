<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:f="http://functions"
    xmlns:saxon="http://saxon.sf.net/" xmlns="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xd xs f saxon xlink xsi xml">
    <xsl:output method="xml" indent="yes" encoding="UTF-8" name="archive-original"/>
    <xsl:output method="xml" indent="yes" encoding="UTF-8" name="n-file" xmlns="http://www.loc.gov/mods/v3" xpath-default-namespace="http://www.loc.gov/mods/v3"
        extension-element-prefixes="#default" 
        saxon:next-in-chain="commons/split_modsCollection.xsl"/>        

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> June 25, 2018</xd:p>
            <xd:p><xd:b>Created by:</xd:b>Emily Somach</xd:p>
        </xd:desc>
    </xd:doc>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Include external stylesheets.</xd:p>
            <xd:ul>
                <xd:li><xd:b>common.xsl:</xd:b> templates shared across all stylesheets</xd:li>
                <xd:li><xd:b>params.xsl:</xd:b> parameters shared across all stylesheets</xd:li>
                <xd:li><xd:b>functions.xsl: </xd:b>functions shared across all stylesheets</xd:li>
            </xd:ul>
        </xd:desc>
    </xd:doc>
    <xsl:include href="commons/common.xsl"/>
    <xsl:include href="commons/params.xsl"/>
    <xsl:include href="commons/functions.xsl"/>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Root template - calls and applies specific templates</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <modsCollection>
            <!-- Archive -->
            <xsl:for-each select="nodes/node">
        <xsl:result-document method="xml" encoding="UTF-8" indent="yes"
            href="file:///{$workingDir}A-{replace($originalFilename, '(.*/)(.*)(\.xml)', '$2')}_{position()}.xml"
            format="archive-original">
            <!-- Archive Split -->
            <nodes xmlns="">
                <xsl:copy-of select="." copy-namespaces="no"/>
            </nodes>
        </xsl:result-document>
                <!-- MODS -->
        <xsl:result-document method="xml" encoding="UTF-8" indent="yes"
            href="file:///{$workingDir}N-{replace($originalFilename, '(.*/)(.*)(\.xml)', '$2')}_{position()}.xml" format="n-file">
            <!-- MODS Split -->
            <mods version="3.7">
                <xsl:namespace name="xsi">http://www.w3.org/2001/XMLSchema-instance</xsl:namespace>
                <xsl:attribute name="xsi:schemaLocation">http://www.loc.gov/mods/v3
                    http://www.loc.gov/standards/mods/v3/mods-3-7.xsd</xsl:attribute>
                
                <xsl:apply-templates select="title"/>
                <xsl:call-template name="personal-info"/>
                
                <!-- Include default resource type and genre information -->
                <typeOfResource>text</typeOfResource>
                <genre>article</genre>

                <xsl:call-template name="abstract-info"/>
                <xsl:call-template name="journal-info"/>
                <xsl:apply-templates select="doi"/>
                <xsl:apply-templates select="aris"/>
                
                <!-- Include default access conditions -->
                <accessCondition type="use and reproduction">Works produced by employees of the U.S.
                    Government as part of their official duties are not copyrighted within the U.S. The
                    content of this document is not copyrighted.</accessCondition>
                
                <xsl:call-template name="extension"/>
                <xsl:call-template name="record-info"/>
            </mods>
        </xsl:result-document>
            </xsl:for-each>
        </modsCollection>
    </xsl:template>


    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Article title.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="title">
        <titleInfo>
            <title>
                <xsl:value-of select="."/>
            </title>
        </titleInfo>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Authors. If processing the first author in the group, assign an attribute of
                    <xs:b>usage</xs:b> with a value of "primary."</xd:p>
            <xd:p>Give all authors the same affiliation pulled from 'agency' tag</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="personal-info">
        <xsl:for-each select="author">
            <name type="personal">
                <xsl:if test="position() = 1">
                    <xsl:attribute name="usage">primary</xsl:attribute>
                </xsl:if>
                <xsl:call-template name="name-info"/>
            </name>
        </xsl:for-each>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Template to account for alternative format of author information.</xd:p>
            <xd:p>Removed 'middlename' since middle initials/names appear in the 'firstname'
                field.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="name-info">
        <namePart type="given">
            <xsl:value-of select="given"/>
        </namePart>
        <namePart type="family">
            <xsl:value-of select="family"/>
        </namePart>
        <displayForm>
            <xsl:value-of select="family"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="given"/>
        </displayForm>
        <xsl:apply-templates select="orcid"/>
        <!-- uses 'agency' as each author's affiliation -->
        <affiliation>
            <xsl:value-of select="../agency"/>
        </affiliation>
        <role>
            <roleTerm type="text">author</roleTerm>
        </role>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Adds authors' ORCID if provided.</xd:p>
            <xd:p>Turns ORCID into a URI if only the 16-digit number is given.</xd:p>
            <xd:p>If URI provided, ensures it begins with HTTPS</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="orcid">
        <nameIdentifier type="orcid">
            <xsl:choose>
                <xsl:when test="contains(., 'orcid.org/')">
                    <xsl:value-of select="replace(., 'http:', 'https:')"/>
                </xsl:when>
                <xsl:when test="string(.)">
                    <xsl:value-of select="concat('https://orcid.org/', .)"/>
                </xsl:when>
            </xsl:choose>
        </nameIdentifier>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Concatenates date elements and makes sure day and month are 2-digits</xd:p>
            <xd:p>Adds default English language tags</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="abstract-info">
        <originInfo>
            <dateIssued encoding="w3cdtf" keyDate="yes">
                <xsl:value-of
                    select="string-join((date-year, f:checkMonthType(date-month), format-number(date-day, '00'))[. != 'NaN'], '-')"
                />
            </dateIssued>
        </originInfo>

        <!-- Default language -->
        <language>
            <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
            <languageTerm type="text">English</languageTerm>
        </language>

        <abstract>
            <xsl:value-of select="abstract"/>
        </abstract>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Adds journal title, ISSN, volume, and issue.</xd:p>
            <xd:p>Breaks date down into 'parts' element.</xd:p>
            <xd:p>Adds page information (even though only first page currently captured).</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="journal-info">
        <relatedItem type="host">
            <titleInfo>
                <title>
                    <xsl:value-of select="journal-title"/>
                </title>
            </titleInfo>

            <identifier type="issn">
                <xsl:value-of select="issn"/>
            </identifier>
            <part>
                <xsl:apply-templates select="volume | issue"/>
                <xsl:apply-templates select="date-year | date-month | date-day | date-other"
                    mode="part"/>
                <extent unit="pages">
                    <xsl:apply-templates select="first-page | last-page"/>
                    <xsl:sequence
                        select="f:calculateTotalPgs(first-page, last-page)"/>
                </extent>
            </part>
        </relatedItem>
    </xsl:template>

    <xsl:template match="volume">
        <detail type="volume">
            <number>
                <xsl:value-of select="."/>
            </number>
            <caption>v.</caption>
        </detail>
    </xsl:template>

    <xsl:template match="issue">
        <detail type="issue">
            <number>
                <xsl:value-of select="."/>
            </number>
            <caption>no.</caption>
        </detail>
    </xsl:template>

    <xsl:template match="first-page">
        <start>
            <xsl:value-of select="."/>
        </start>
    </xsl:template>

    <xsl:template match="last-page">
        <end>
            <xsl:value-of select="."/>
        </end>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Builds date for part element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="date-year" mode="part">
        <text type="year">
            <xsl:value-of select="."/>
        </text>
    </xsl:template>
    <xsl:template match="date-month" mode="part">
        <text type="month">
            <xsl:value-of select="."/>
        </text>
    </xsl:template>
    <xsl:template match="date-day" mode="part">
        <text type="day">
            <xsl:value-of select="."/>
        </text>
    </xsl:template>
    <xsl:template match="date-other" mode="part">
        <text type="season">
            <xsl:value-of select="."/>
        </text>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Transform DOI and URL.</xd:p>
            <xd:p>Submitters only asked to submit DOI number - not URL.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="doi">
        <identifier type="doi">
            <xsl:value-of select="."/>
        </identifier>
        <location>
            <url>
                <xsl:text>http://dx.doi.org/</xsl:text>
                <xsl:value-of select="."/>
            </url>
        </location>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Adds ARIS log number.</xd:p>
            <xd:p>No longer captures NALDC related information.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="aris">
        <identifier type="aris">
                <xsl:value-of select="."/>
        </identifier>        
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Builds extension tag to capture internal information.</xd:p>
            <xd:p>Includes status, collection name, and locations of supplementary docs.</xd:p>
            <xd:p>No longer captures NALDC related information.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="extension">
        <extension>
            <note type="note">USDA Scientist Submission</note>
            <note type="status">
                <xsl:value-of select="current-state"/>
            </note>
            <fileLocation note="ARS submission" usage="primary">
                <xsl:value-of select="document"/>
            </fileLocation>
            <xsl:for-each select="supplementary-documents">
                <fileLocation note="ARS submission">
                    <xsl:value-of select="."/>
                </fileLocation>
            </xsl:for-each>
        </extension>
    </xsl:template>
    
    <xsl:template name="record-info">
        <recordInfo>
            <recordCreationDate encoding="w3cdtf">
                <xsl:value-of select="date-created"/>
            </recordCreationDate>
            <recordChangeDate encoding="w3cdtf">
                <xsl:value-of select="last-updated"/>
            </recordChangeDate>
            <recordIdentifier>
                <xsl:value-of select="nid"/>
            </recordIdentifier>
            <recordOrigin>USDA submission converted from Drupal to MODS version 3.7 using
                submissions-2mods.xsl (Revision 1.003 2018/06/26)</recordOrigin>
        </recordInfo>
    </xsl:template>

</xsl:stylesheet>
