<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:f="http://functions"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xd xs f saxon xlink xsi xml">
    <xsl:output method="xml" indent="yes" encoding="UTF-8" saxon:next-in-chain="fix_characters.xsl"/>
    <xsl:output method="xml" indent="yes" encoding="UTF-8" name="archive-original" doctype-public="-//RSC//DTD RSC Primary Article DTD 3.7//EN" doctype-system="http://www.rsc.org/dtds/rscart37.dtd"/>

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Last modified on:</xd:b>October 2018</xd:p>
            <xd:p><xd:b>Original author:</xd:b>Emily Somach</xd:p>
            <xd:p><xd:b>Modified author:</xd:b>Amanda Xu</xd:p>
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
            <xd:p>Ignore whitespace-only (i.e. empty) elements.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:strip-space elements="*"/>

    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Root template - calls and applies specific templates</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        
        <xsl:result-document method="xml" encoding="UTF-8" indent="yes" href="file:///{$workingDir}A-{replace($originalFilename, '(.*/)(.*)(\.xml)', '$2')}_{position()}.xml" format="archive-original">            
            <xsl:copy-of select="."/>          
        </xsl:result-document>
        
        <mods version="3.7">
            <xsl:namespace name="xsi">http://www.w3.org/2001/XMLSchema-instance</xsl:namespace>
            <xsl:attribute name="xsi:schemaLocation">http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-7.xsd</xsl:attribute>
            <xsl:apply-templates select="article/art-front/titlegrp"/>
            <xsl:apply-templates select="article/art-front/authgrp"/>

            <!-- Default -->
            <typeOfResource>text</typeOfResource>
            <genre>article</genre>
            
            <xsl:call-template name="originInfo"/>

            <!-- Default language -->
            <language>
                <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
                <languageTerm type="text">English</languageTerm>
            </language>

            <xsl:apply-templates select="article/art-front/abstract"/>
         
            <relatedItem type="host">
                <xsl:apply-templates select="article/published[@type='print']"/>
                <xsl:call-template name="modsPart"/>
            </relatedItem>
            
            <xsl:apply-templates select="article/art-admin/ms-id"/>
            <xsl:apply-templates select="article/art-admin/doi"/>
            <xsl:call-template name="extension"/>
        </mods>
        
    </xsl:template>



    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Article title</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="titlegrp">
        <titleInfo>
            <title>
                <xsl:variable name="this"><xsl:apply-templates/></xsl:variable>
                <xsl:value-of select="normalize-space($this)"/>
            </title>
        </titleInfo>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>An empty template to prevent the footnote superscript from displaying in the title text string.</xd:p>
            <xd:p>Matches the 'fnoteref' and 'footnote' elements to remove footnote superscript from the value.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="title/fnoteref | title/footnote"/>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Authors. If processing the first author in the group, assign an attribute of
                    <xs:b>usage</xs:b> with a value of "primary."</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="authgrp">
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
            <xd:p>Formatting for personal names</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="name-info">
        <namePart type="given">
            <xsl:value-of select="normalize-space(person/persname/fname)"/>
        </namePart>
        <namePart type="family">
            <xsl:apply-templates select="person/persname/surname"/>
        </namePart>
        <displayForm>
            <xsl:apply-templates select="person/persname/surname"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="normalize-space(person/persname/fname)"/>
        </displayForm>
        
        <xsl:variable name="affid" select="@aff"/>
        
        <xsl:for-each select="../aff">
            <xsl:if test="contains($affid, @id)">
                <affiliation><xsl:apply-templates select="."/></affiliation>
            </xsl:if>
        </xsl:for-each>
            
        <role>
            <roleTerm type="text">author</roleTerm>
        </role>
    </xsl:template>
   
    <xsl:template match="person/persname/surname">
        <xsl:value-of select="text()"/>
    </xsl:template>
   
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Processes affiliation information in a variety of child elements.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="aff">
        <xsl:value-of select="org/orgname/* | address/*" separator=", "/>
    </xsl:template>
       
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Builds originInfo date from print and web dates.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="originInfo">
        <originInfo>
            <xsl:apply-templates select="article/published[@type='print']/pubfront/date" mode="origin"/>
            <xsl:apply-templates select="article/published[@type='web']/pubfront/date" mode="origin"/>
        </originInfo>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Print publication date added as 'dateIssued.'</xd:p>
            <xd:p>Checks that 'day' is not 'NaN'. Month function checks that 'month' is present and not 'null.'</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="published[@type='print']/pubfront/date" mode="origin">
        <dateIssued encoding="w3cdtf" keyDate="yes">
            <xsl:value-of select="string-join((year, f:checkMonthType(month), format-number(day,'00'))[. != 'NaN'], '-')"/>
        </dateIssued>        
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Electronic publication date added as 'dateOther.'</xd:p>
            <xd:p>Only adds day information if it is present, so as not to produce a NaN in the date.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="published[@type='web']/pubfront/date" mode="origin">
        <dateOther encoding="w3cdtf" keyDate="yes" type="electronic">
            <xsl:value-of select="string-join((year, f:checkMonthType(month), format-number(day,'00'))[. != 'NaN'], '-')"/>
        </dateOther>        
    </xsl:template>
    
    
    <!-- Abstract -->


    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Don't capture abstracts that only list coverage dates for a review.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="abstract/p[starts-with(., 'Covering: ')]"/>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>The 'apply-templates' variable is necessary to fix super/subscript tags.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="abstract">
        <xsl:variable name="this"><xsl:apply-templates/></xsl:variable>
        <abstract>
            <xsl:value-of select="normalize-space($this)"/>
        </abstract>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Builds relatedItem section using journal information.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="published[@type='print']">
        <xsl:apply-templates select="journalref/title[@type='full']"/>
        <xsl:apply-templates select="journalref/title[@type='abbreviated']"/>
        <xsl:apply-templates select="journalref/publisher"/>
        <xsl:apply-templates select="journalref/issn"/>
        <xsl:apply-templates select="journalref/coden"/>        
    </xsl:template>
    
    <xsl:template match="journalref/title[@type='full']">
        <titleInfo>
            <title>
                <xsl:value-of select="normalize-space(.)"/>
            </title>
        </titleInfo>
    </xsl:template>
    
    <xsl:template match="journalref/title[@type='abbreviated']">
        <titleInfo type="abbreviated">
            <title>
                <xsl:value-of select="normalize-space(.)"/>
            </title>
        </titleInfo>
    </xsl:template>
        
    <xsl:template match="issn">
        <xsl:if test="@type = 'online'">
        <identifier type="issn-e"><xsl:value-of select="."/></identifier>
        <identifier type="issn"><xsl:value-of select="."/></identifier>
        </xsl:if>
        <xsl:if test="@type = 'print'">
            <identifier type="issn-p"><xsl:value-of select="."/></identifier>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="coden">
        <identifier type="vendor"><xsl:value-of select="."/></identifier>
    </xsl:template>
    
    <xsl:template match="publisher">
        <originInfo>
            <publisher><xsl:value-of select="normalize-space(orgname/nameelt)"/></publisher>
        </originInfo>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Add volume, issue, and page data to relatedItem.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="modsPart">
        <part>
            <xsl:apply-templates select="/article/published[@type='print']/volumeref/link"/>
            <xsl:apply-templates select="/article/published[@type='print']/issueref/link"/>
            <xsl:if test="/article/published[@type='print']/pubfront/fpage">
                <xsl:call-template name="modsPages"/>
            </xsl:if>
            <xsl:apply-templates select="/article/published[@type='print']/pubfront/date" mode="part"/>            
        </part>
    </xsl:template>
    
     <xsl:template match="volumeref/link">
        <detail type="volume">
            <number><xsl:value-of select="."/></number>
            <caption>v.</caption>
        </detail>
    </xsl:template>
    
      <xsl:template match="issueref/link">
        <detail type="issue">
            <number>
                <xsl:value-of select="."/>
            </number>
            <caption>no.</caption>
        </detail>
    </xsl:template>
   
 <xd:doc scope="component">
        <xd:desc>
            <xd:p>Transform page details</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="modsPages">
        <extent unit="pages">
            <xsl:apply-templates select="/article/published[@type='print']/pubfront/fpage"/>
            <xsl:apply-templates select="/article/published[@type='print']/pubfront/lpage"/>
            <xsl:apply-templates select="/article/published[@type='print']/pubfront/no-of-pages"/>
        </extent>
    </xsl:template>

    <xsl:template match="fpage">
        <start><xsl:value-of select="."/></start>
    </xsl:template>
    
    <xsl:template match="lpage">
        <end><xsl:value-of select="."/></end>
    </xsl:template>
    
    <xsl:template match="no-of-pages">        
        <total><xsl:value-of select="."/></total>        
    </xsl:template>
    
     <xd:doc scope="component">
        <xd:desc>
            <xd:p>Builds date for part element.</xd:p>
        </xd:desc>
    </xd:doc>
      <xsl:template match="/article/published[@type='print']/pubfront/date" mode="part">
        <xsl:for-each select="year, month, day, season, string-date">
            <text type="{name()}">
                <xsl:value-of select="."/> 
            </text>
        </xsl:for-each>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Include unique publisher identifier</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="ms-id">        
        <identifier type="ms-id">
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Transform DOI and URL</xd:p>
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
            <xd:p><xd:b>vendorName:</xd:b> Name of the vendor supplying the metadata.</xd:p>
            <xd:p><xd:b>archiveFile:</xd:b> Filename of the file (xml or zip) that originally held the source data.</xd:p>
        </xd:desc>
    </xd:doc>
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
