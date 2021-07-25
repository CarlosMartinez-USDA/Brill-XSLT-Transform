<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE transform [
         <!ENTITY % htmlmathml-f PUBLIC
         "-//W3C//ENTITIES HTML MathML Set//EN//XML"
         "http://www.w3.org/2003/entities/2007/htmlmathml-f.ent"
       >
       %htmlmathml-f;
]>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:f="http://functions"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xd xs f saxon">
    <xsl:output method="xml" indent="yes" encoding="UTF-8" saxon:next-in-chain="fix_characters.xsl"/>    
    <xsl:output method="xml" indent="yes" encoding="UTF-8" name="archive-original" doctype-public="ISO 12083:1994//DTD Article//EN" doctype-system="http://www.publish.csiro.au/scripts/DTD/CSIROAbstract.dtd"/>

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Last modified on:</xd:b> October 15, 2018</xd:p>
            <xd:p><xd:b>Original author:</xd:b> Jennifer Gilbert</xd:p>
            <xd:p><xd:b>Modified by:</xd:b> Emily Somach</xd:p>
            <xd:p>This stylesheet was refactored in August 2017.</xd:p>
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
    
    
    
    <xd:doc>
        <xd:desc>
            <xd:p>Build MODS document</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
                <xsl:result-document method="xml" encoding="UTF-8" indent="yes" href="file:///{$workingDir}A-{replace($originalFilename, '(.*/)(.*)(\.xml)', '$2')}_{position()}.xml" format="archive-original">            
                    <xsl:copy-of select="."/>            
                </xsl:result-document>
                
                <mods version="3.7">
                    <xsl:namespace name="xsi">http://www.w3.org/2001/XMLSchema-instance</xsl:namespace>
                    <xsl:attribute name="xsi:schemaLocation">http://www.loc.gov/mods/v3
                        http://www.loc.gov/standards/mods/v3/mods-3-7.xsd</xsl:attribute>

                    <xsl:apply-templates select="/front"/>

                    <xsl:call-template name="extension"/>
                </mods>
        
    </xsl:template>

    <!--  MAIN ARTICLE TEMPLATE  -->

    <xsl:template match="front">
        <xsl:apply-templates select="titlegrp" />
        <xsl:apply-templates select="authgrp/author" />
        <!-- Defaults -->
        <typeOfResource>text</typeOfResource>
        <genre>article</genre>
     
        <language>
            <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
            <languageTerm type="text">English</languageTerm>
        </language>
        <xsl:apply-templates select="abstract" />
        <xsl:apply-templates select="keywords" />
        <xsl:apply-templates select="pubfront" />
        <xsl:apply-templates select="pubfront/doi"/>
    </xsl:template>

    <!-- Article title -->
    <xsl:template match="titlegrp">
        <titleInfo>
            <title>
                <xsl:value-of select="normalize-space(title)"/>
            </title>
            <xsl:apply-templates select="subtitle/text()"/>
        </titleInfo>
    </xsl:template>

    <xsl:template match="subtitle/text()">
        <subTitle><xsl:value-of select="."/></subTitle>
    </xsl:template>
    
    <!-- Authors -->
    <xsl:template match="author">
        <name type="personal">
            <xsl:if test="position() = 1">
                <xsl:attribute name="usage">primary</xsl:attribute>
            </xsl:if>
            <namePart type="given">
                <xsl:value-of select="name/fname" />
            </namePart>
            <namePart type="family">
                <xsl:value-of select="name/surname" />
            </namePart>
            <displayForm>
                <xsl:value-of select="name/surname" />
                <xsl:text>, </xsl:text>
                <xsl:value-of select="name/fname" />
            </displayForm>            
            <affiliation>
                <xsl:value-of select="details" />
            </affiliation>
        </name>
    </xsl:template>

    <!-- Journal info -->
    <xsl:template match="pubfront">
        <relatedItem type="host">
            <xsl:apply-templates select="pubid" />
            <originInfo>
                <publisher>CSIRO Publishing</publisher>
            </originInfo>
            <xsl:apply-templates select="issn"/>
            <xsl:apply-templates select="jid"/>
            <part>
                <xsl:apply-templates select="volno"/>
                <xsl:apply-templates select="issno"/>
                <xsl:call-template name="modsPages"/>
                <xsl:apply-templates select="year"/>
            </part>
        </relatedItem>            
    </xsl:template>
    
    <xsl:template match="year">
        <text type="year">
            <xsl:value-of select="."/>
        </text>
    </xsl:template>
    
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
    
    <xsl:template name="modsPages">
        <extent unit="pages">
            <start>
                <xsl:value-of select="fpage"/>
            </start>
            <end>
                <xsl:value-of select="lpage"/>
            </end>
            <xsl:sequence select="f:calculateTotalPgs(fpage, lpage)"/>
        </extent>
    </xsl:template>
    
    <xsl:template match="issn">
        <identifier type="issn">
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template>
    
    <xsl:template match="issno">
        <detail type="issue">
            <number>
                <xsl:value-of select="."/>
            </number>
            <caption>no.</caption>
        </detail>
    </xsl:template>
    
    <xsl:template match="volno">
        <detail type="volume">
            <number>
                <xsl:value-of select="."/>
            </number>
            <caption>v.</caption>
        </detail>
    </xsl:template>
    
    <xsl:template match="jid">
        <identifier type="vendor">
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template>
    
    <xsl:template match="pubid">
        <titleInfo>
            <title>
                <xsl:value-of select="." />
            </title>
        </titleInfo>
    </xsl:template>
    
    <xsl:template match="abstract">
        <abstract>
        <xsl:value-of select="normalize-space(.)" />
        </abstract>
    </xsl:template>

    <!-- Keywords -->
    <xsl:template match="keywords">
        <xsl:for-each select="tokenize(.,',')">
           <subject>
               <topic>
                   <xsl:value-of select="normalize-space(translate(.,'.',''))" />
               </topic>
           </subject>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Extension -->
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
