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
    <xsl:output method="xml" indent="yes" encoding="UTF-8" name="archive-original" doctype-public="-//NLM//DTD JATS (Z39.96) Journal Publishing DTD v1.2 20151215//EN" doctype-system="https://jats.nlm.nih.gov/publishing/1.2d1/JATS-journalpublishing1.dtd"/>

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Last modified on:</xd:b> July 25, 2018</xd:p>
            <xd:p><xd:b>Original author:</xd:b> Jennifer Gilbert</xd:p>
            <xd:p><xd:b>Modified by:</xd:b>Carlos Martinez, Emily Somach, and Amanda Xu</xd:p>
            <xd:p>This stylesheet was refactored in June/July 2017.</xd:p>
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
            <xd:p>Ignore whitespace-only (i.e. empty) elements except for <xs:b>x</xs:b>, which JATS uses to define a contcatenation character.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="x p"/>

    
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
            <xsl:apply-templates select="front/article-meta/title-group"/>
            <xsl:apply-templates select="front/article-meta/contrib-group"/>
            
            <!-- Default -->
            <typeOfResource>text</typeOfResource>
            <genre>article</genre>
            
            <xsl:call-template name="originInfo"/>

            <!-- Default language -->
            <language>
                <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
                <languageTerm type="text">English</languageTerm>
            </language>

            <xsl:apply-templates select="front/article-meta/abstract"/>
            <xsl:apply-templates select="front/article-meta/trans-abstract"/>
            <xsl:apply-templates select="front/article-meta/kwd-group"/>
         
            <relatedItem type="host">
                <xsl:apply-templates select="front/journal-meta"/>
                <xsl:call-template name="modsPart"/>
            </relatedItem>
            
            <xsl:apply-templates select="front/article-meta/article-id[@pub-id-type]"/>
            <xsl:call-template name="extension"/>
            
        </mods>
        
    </xsl:template>



    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Article title</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="title-group">
        <titleInfo>
            <title>
                <xsl:value-of select="normalize-space(article-title)"/>
            </title>
            <xsl:apply-templates select="subtitle"/>
        </titleInfo>
        <xsl:apply-templates select="trans-title-group"/>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Tanslated article title</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="trans-title-group">
        <titleInfo type="translated">
            <title>
                <xsl:value-of select="normalize-space(trans-title)"/>
            </title>
            <xsl:apply-templates select="subtitle"/>
        </titleInfo>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Authors. If processing the first author in the group, assign an attribute of
                    <xs:b>usage</xs:b> with a value of "primary."</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="contrib-group">
        <xsl:for-each select="contrib[@contrib-type = 'author']">
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
        </xd:desc>
    </xd:doc>
    <xsl:template match="contrib-group[@content-type = 'authors']">
        <xsl:for-each select="contrib">
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
        
        <!-- Get author's ORCID -->
        <xsl:apply-templates select="contrib-id[@contrib-id-type = 'orcid']"/>

        <!-- Use id to get affiliation  -->
        <xsl:variable name="affid" select="xref[@ref-type = 'aff']/@rid"/>
        <xsl:if test="$affid">
            <xsl:for-each select="/front/article-meta/aff[@id = $affid]">
                <affiliation>
                    <xsl:apply-templates mode="affiliation"/>
                </affiliation>
            </xsl:for-each>
        </xsl:if>
        <role>
            <roleTerm type="text">author</roleTerm>
        </role>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Adds authors' ORCID if provided.</xd:p>
            <xd:p>Turns ORCID into a URI if only the 16-digit number is given.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="contrib-id[@contrib-id-type = 'orcid']">
        <nameIdentifier type="orcid">
            <xsl:choose>
                <xsl:when test="contains(., 'orcid.org')">
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
            <xd:p>An empty template to prevent the footnote superscript from displaying in the affiliation text string.</xd:p>
            <xd:p>Matches the 'sup' element to remove footnote superscript from the value.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="sup" mode="affiliation"/>
    <xsl:template match="ext-link" mode="affiliation"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Matches children of 'aff' element. Only prints commas after them if they are NOT the last child node.</xd:p>
        </xd:desc>
    </xd:doc>
   <!-- This template causes transformation failed.  A sequence of more than one item is not allowed as the first argument of concat()text() -->     
   <!-- <xsl:template match="addr-line|country" mode="affiliation">
        <xsl:choose>
            <xsl:when test="position()=last() or following-sibling::*[1][self::ext-link]">
                <xsl:value-of select="text()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat(text(), ', ')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template> -->

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Matches children of 'aff' element. Seperate them with space if they are NOT the last child node or ends with country node.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="addr-line|country" mode="affiliation">
        <xsl:choose>
            <xsl:when test="position()=last() or following-sibling::*[1][self::ext-link] or child::sub">
                <xsl:value-of select="text()"/>
            </xsl:when> 
            <xsl:otherwise>
                <xsl:value-of select="concat(text(), ', ')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Builds originInfo date using one of two dates in the history element</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="originInfo">
            <xsl:choose>
                <xsl:when test="front/article-meta/history/date[@date-type = 'pub']">
                    <xsl:apply-templates select="front/article-meta/history/date[@date-type = 'pub']" mode="origin"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="front/article-meta/history/date[@date-type = 'accepted']" mode="origin"/>
                </xsl:otherwise>
            </xsl:choose>
        
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Uses date-type='pub' or date-type='accepted' for dateIssued.</xd:p>
            <xd:p>Sets is as keyDate.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="history/date[@date-type = 'pub'][1] | history/date[@date-type = 'accepted'][1]" mode="origin">
        <originInfo>
            <dateIssued encoding="w3cdtf" keyDate="yes">
                <xsl:value-of select="string-join((year, f:checkMonthType(month), format-number(day,'00'))[. != 'NaN'], '-')"/>
            </dateIssued>        
        </originInfo>
    </xsl:template>
    
    <!-- Abstract -->


    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Only matches abstracts that do not specify a language or that specify the language as English.</xd:p>
            <xd:p>Also matches foreign abstracts translated into English.</xd:p>
            <xd:p>'copy-of' is needed because abstract can have 'title' child elements, which makes normalize-space throw an error.</xd:p>
            <xd:p>The 'apply-templates' variable is necessary to fix super/subscript tags.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="abstract|trans-abstract">
        <xsl:if test="@xml:lang = ('en', 'EN') or not(@xml:lang)">
            <xsl:variable name="abstractText"><xsl:copy-of select="*[not(self::title)]"/></xsl:variable>
            <xsl:variable name="this"><xsl:apply-templates/></xsl:variable>
            <abstract>
                <xsl:value-of select="normalize-space($this)"/>
            </abstract>
        </xsl:if>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Empty templates to match 'title' children of 'abstract' or 'trans-abstract' element, graphical abstracts, and synopses.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="abstract/title|trans-abstract/title"/>    
    <xsl:template match="abstract/sec/title|trans-abstract/sec/title"/>
    <xsl:template match="abstract[@abstract-type='graphical']|abstract[@abstract-type='synopsis']"/>
  
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Turn keywords into subjects unless the group title is 'Abbreviations,' the language is not specified, or the language is specified as something other than English.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="kwd-group">
        <xsl:if test="(not(@xml:lang) or lower-case(@xml:lang) = 'en') and (not(title) or title != 'Abbreviations')">
                <xsl:for-each select="kwd">
                    <subject>
                        <topic>
                            <xsl:value-of select="normalize-space(.)"/>
                        </topic>
                    </subject>
                </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>The following section includes templates for building relatedItem from journal-meta</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="journal-meta">
        <xsl:apply-templates select="journal-title-group/journal-title|journal-title[not(parent::journal-title-group)]"/>
        <xsl:apply-templates select="journal-title-group/abbrev-journal-title|abbrev-journal-title[not(parent::journal-title-group)]"/>
        <xsl:apply-templates select="publisher"/>
        <xsl:apply-templates select="issn"/>
        <xsl:apply-templates select="journal-id"/>        
    </xsl:template>
    
    <xsl:template match="journal-title-group/journal-title|journal-title[not(parent::journal-title-group)]">
        <titleInfo>
            <title>
                <xsl:value-of select="normalize-space(.)"/>
            </title>
            <xsl:apply-templates select="../journal-subtitle"/>
        </titleInfo>
    </xsl:template>
    
    <xsl:template match="journal-title-group/abbrev-journal-title|abbrev-journal-title[not(parent::journal-title-group)]">
        <titleInfo type="abbreviated">
            <title>
                <xsl:value-of select="normalize-space(.)"/>
            </title>
            <xsl:apply-templates select="../journal-subtitle"/>
        </titleInfo>
    </xsl:template>
    
    <xsl:template match="journal-subtitle|subtitle">
        <subTitle>
            <xsl:value-of select="normalize-space(.)"/>
        </subTitle>
    </xsl:template>
        
    <xsl:template match="issn">
        <xsl:if test="@pub-type = 'epub'">
            <identifier type="issn-e"><xsl:value-of select="."/></identifier>
            <identifier type="issn"><xsl:value-of select="."/></identifier>
        </xsl:if>
        <xsl:if test="@pub-type = 'ppub'">
            <identifier type="issn-p"><xsl:value-of select="."/></identifier>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="journal-id">
        <xsl:if test="@journal-id-type = 'publisher-id'">
            <identifier type="vendor"><xsl:value-of select="."/></identifier>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="publisher">
        <originInfo>
            <publisher><xsl:value-of select="normalize-space(publisher-name)"/></publisher>
        </originInfo>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>The following section includes templates for adding information from article-meta to relatedItem.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="modsPart">
        <part>
            <xsl:apply-templates select="front/article-meta/volume"/>
            <xsl:apply-templates select="front/article-meta/issue"/>
            <xsl:apply-templates select="front/article-meta/pub-date[@pub-type = 'ppub']" mode="part"/>
            <xsl:choose>
                <xsl:when test="not(front/article-meta/pub-date[@pub-type = 'ppub']) and not(front/article-meta/pub-date[@pub-type = 'epub'])">
                    <xsl:apply-templates select="front/article-meta/history/date[@date-type = 'pub'][1]" mode="part"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="front/article-meta/pub-date[@pub-type = 'epub']" mode="part"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="front/article-meta/fpage or front[1]/article-meta[1]/counts[1]/page-count[1]/@count">
                <xsl:call-template name="modsPages"/>
            </xsl:if>            
        </part>
    </xsl:template>
    
    <xsl:template match="front/article-meta/volume">
        <detail type="volume">
            <number><xsl:value-of select="."/></number>
            <caption>v.</caption>
        </detail>
    </xsl:template>

    <xsl:template match="front/article-meta/issue[text()]">
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
            <xsl:apply-templates select="front/article-meta/fpage"/>
            <xsl:apply-templates select="front/article-meta/lpage"/>
            <xsl:sequence select="f:calculateTotalPgs(front/article-meta/fpage, front/article-meta/lpage)"/>
            <xsl:apply-templates select="front/article-meta/counts/page-count/@count"/>         
        </extent>
    </xsl:template>
    
    <xsl:template match="front/article-meta/fpage">
        <start><xsl:value-of select="."/></start>
    </xsl:template>
    
    <xsl:template match="front/article-meta/lpage">
        <end><xsl:value-of select="."/></end>
    </xsl:template>
    
   <xsl:template match="front/article-meta/counts/page-count/@count">        
        <total><xsl:value-of select="."/></total>        
    </xsl:template> 

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Builds date for part element.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:template match="front/article-meta/pub-date[@pub-type = 'ppub'][1]" mode="part">
        <xsl:for-each select="year, month, day, season, string-date">
            <text type="{name()}">
                <xsl:value-of select="."/> 
            </text>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="front/article-meta/pub-date[@pub-type = 'epub'][1]" mode="part">
        <xsl:for-each select="*">
            <text type="{name()}">
                <xsl:value-of select="."/>
            </text>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="front/article-meta/history/date[@date-type = 'pub'][1]" mode="part">
        <xsl:for-each select="year, month, day, season, string-date">
            <text type="{name()}">
                <xsl:value-of select="."/> 
            </text>
        </xsl:for-each>
     </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Transform DOI and URL</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="article-id[not(@pub-id-type = 'doi')]">        
        <identifier type="{@pub-id-type}">
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template>
    
    <xsl:template match="article-id[@pub-id-type='doi']">
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
            <!-- PDF copies of the files. -->
            <xsl:apply-templates select="front/article-meta/self-uri[@content-type = 'pdf']"/>
            <xsl:apply-templates select="front/article-meta/related-article[@related-article-type='corrected-article']"/>
            <xsl:apply-templates select="front/article-meta/custom-meta-group/custom-meta/meta-value"/>
            <xsl:apply-templates select="front/article-meta/custom-meta-wrap/custom-meta/meta-value"/>
            <!-- Funding group information -->
            <xsl:apply-templates select="front/article-meta/funding-group"/>
        </extension>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Adds funding information from source while preserving source format.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="front/article-meta/funding-group">
        <funding-group>
            <xsl:for-each select="award-group">
                <award-group>
                    <funding-source>
                        <xsl:for-each select="funding-source/named-content">
                            <named-content content-type="{@content-type}">
                                <xsl:value-of select="normalize-space(.)"/>
                            </named-content>
                        </xsl:for-each>
                        <xsl:if test="not(funding-source/named-content)">
                            <xsl:attribute name="xlink:href">
                                <xsl:value-of select="funding-source/@xlink:href"/>
                            </xsl:attribute>
                            <xsl:value-of select="funding-source"/>
                        </xsl:if>
                    </funding-source>
                    <award-id>
                        <xsl:value-of select="award-id"/>
                    </award-id>
                </award-group>
            </xsl:for-each>  
            <funding-statement>
                <xsl:value-of select="funding-statement"/>
            </funding-statement>
            <open-access>
                <xsl:value-of select="open-access"/>
            </open-access>
        </funding-group>
    </xsl:template>
    
    <xsl:template match="front/article-meta/self-uri[@content-type = 'pdf']">
        <fileLocation note="nonpublic" usage="primary">
            <xsl:text>file://</xsl:text>
            <xsl:value-of select="@xlink:href"/>
        </fileLocation>       
    </xsl:template>
    
    <xsl:template match="front/article-meta/related-article[@related-article-type='corrected-article']">
        <fileLocation note="corrected-article">
            <xsl:value-of select="normalize-space(front/article-meta/related-article[@related-article-type='corrected-article'])"/>
        </fileLocation>
    </xsl:template>
    
    
    <xd:doc scope="component">
        <xd:desc><xd:p>Add note to warn that object is not an article.</xd:p></xd:desc>
    </xd:doc>
    <xsl:template match="issue-xml">
        <note type="warning">Object is an issue, not an article.</note>
    </xsl:template>
    
</xsl:stylesheet>
