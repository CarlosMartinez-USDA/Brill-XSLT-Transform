<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:lc="http://www.loc.gov/mods/v3"
    xmlns="http://www.loc.gov/mods/v3"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:f="http://functions"
    xmlns:saxon="http://saxon.sf.net/"
    exclude-result-prefixes="xd xs f saxon xlink xsi xml lc">
    <xsl:output method="xml" indent="yes" encoding="UTF-8" saxon:next-in-chain="fix_characters.xsl"/>
    <xsl:output method="xml" indent="yes" encoding="UTF-8" name="archive-original"/>

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Last modified on:</xd:b> April 17, 2019</xd:p>
            <xd:p><xd:b>Original author:</xd:b> Emily Somach</xd:p>
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
            <xd:p>Identity template.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@*|node()"> 
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Match Root Node</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/*">
        <xsl:call-template name="aFile"/> 
        <xsl:result-document method="xml" encoding="UTF-8" indent="yes" href="file:///{$workingDir}N-{replace($originalFilename, '(.*/)(.*)(\.xml)', '$2')}_{position()}.xml">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="lc:relatedItem">
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:when>
            
                <xsl:otherwise>
                    <xsl:apply-templates select="lc:titleInfo[1], lc:name"/>
                    <typeOfResource>text</typeOfResource>
                    <genre>article</genre>
                    <xsl:call-template name="addOriginInfo"/>
                    <xsl:apply-templates select="lc:abstract"/>
                    <xsl:call-template name="addRelatedItem"/>
                </xsl:otherwise>
            </xsl:choose>
            <!-- add a new element at the end -->
            <xsl:call-template name="extension"/>
        </xsl:copy>
        </xsl:result-document>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Copies source XML and outputs A-file</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="aFile">
        <xsl:result-document method="xml" encoding="UTF-8" indent="yes" href="file:///{$workingDir}A-{replace($originalFilename, '(.*/)(.*)(\.xml)', '$2')}_{position()}.xml" format="archive-original">            
            <xsl:copy-of select="/"/>       
        </xsl:result-document>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Call namePart template and add displayForm element to name element if not present in source</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="lc:name">
        <name type="personal">
            <xsl:if test=". = ../lc:name[1]">
                <xsl:attribute name="usage">primary</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="namePart"/>
            <xsl:if test="not(./lc:displayForm)">
                <displayForm>
                    <xsl:choose>
                        <xsl:when test="contains(../lc:titleInfo[2]/lc:title, 'Food Chemistry')">
                            <xsl:value-of
                                select="concat(lc:namePart[@type = 'given'], ', ', lc:namePart[@type = 'family'])"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="concat(lc:namePart[@type = 'family'], ', ', lc:namePart[@type = 'given'])"
                            />
                        </xsl:otherwise>
                    </xsl:choose>
                </displayForm>
            </xsl:if>
            <xsl:apply-templates select="lc:displayForm"/>
            <xsl:apply-templates select="lc:affiliation, lc:role"/>
        </name>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Print namePart elements, and swap given and family for JFCN</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="namePart">
        <xsl:choose>
            <xsl:when test="contains(../lc:titleInfo[2]/lc:title, 'Food Chemistry')">
                <namePart type="given">
                    <xsl:value-of select="lc:namePart[@type = 'family']"/>
                </namePart>
                <namePart type="family">
                    <xsl:value-of select="lc:namePart[@type = 'given']"/>
                </namePart>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="lc:namePart"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Empty template to remove incorrect publisher info</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="lc:mods/lc:originInfo/lc:publisher"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Move article identifier elements outside of relatedItem element</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="lc:relatedItem">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="lc:titleInfo"/>
            <xsl:if test="not(lc:originInfo)">
                <xsl:element name="originInfo">
                    <publisher>
                        <xsl:value-of select="lc:titleInfo/lc:title"/>
                    </publisher>
                </xsl:element>
            </xsl:if>
            <xsl:apply-templates select="child::node()[not(self::lc:identifier[@type='doi' or @type='uri'] or self::lc:titleInfo)]"/>
        </xsl:copy>
        <xsl:apply-templates select="lc:identifier[not(@type='issn')]"/>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Adds originInfo element if it doesn't exist, and places appropriate tags inside it</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="addOriginInfo">
        <xsl:element name="originInfo">
            <xsl:apply-templates select="lc:dateIssued, lc:copyrightDate"/>
        </xsl:element>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Does not include copyrightDate when value is "YES"</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="lc:copyrightDate">        
        <xsl:if test=".!='YES'">
            <copyrightDate>
                <xsl:value-of select="."/>
            </copyrightDate>
        </xsl:if>   
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Adds relatedItem element if it doesn't exist, and places appropriate tags inside it</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="addRelatedItem">
        <relatedItem type="host">
            <xsl:apply-templates select="lc:titleInfo[2]"/>
            <xsl:apply-templates select="lc:publisher"/>
            <xsl:if test="not(lc:publisher)">
                <originInfo>
                    <publisher>
                        <xsl:value-of select="lc:titleInfo[2]/lc:title"/>
                    </publisher>
                </originInfo>
            </xsl:if>
            <xsl:apply-templates select="lc:identifier[@type='issn']"/>
            <part>
                <xsl:apply-templates select="lc:detail, lc:extent,lc:text"/>
            </part>
        </relatedItem>
        <xsl:apply-templates select="lc:identifier[not(@type='issn')]"/>
    </xsl:template>
    
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Add the doi and doi url elements</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="lc:identifier[@type='doi'][text() != '']">
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
            <xd:p>Include other identifiers</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="lc:identifier">
        <xsl:if test="string(.)">
            <identifier type="{@type}">
                <xsl:value-of select="."/>
            </identifier>
        </xsl:if>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Ensure correct caption is used for JFCN</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="lc:detail[@type='volume']">
        <detail type="volume">
            <number><xsl:value-of select="lc:number"/></number>
            <caption>v.</caption>
        </detail>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Ensure correct caption is used for JFCN</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="lc:detail[@type='issue']">
        <detail type="issue">
            <number><xsl:value-of select="lc:number"/></number>
            <caption>no.</caption>
        </detail>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>When JoVE, use start page as end page and set total to 1</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="lc:extent">
        <extent unit="pages">
            <start><xsl:value-of select="normalize-space(lc:start)"/></start>
            <xsl:choose>
                <xsl:when test="../../lc:titleInfo/lc:title = 'Journal of Visualized Experiments'">
                    <end><xsl:value-of select="normalize-space(lc:start)"/></end>
                    <total>1</total>
                </xsl:when>
                <xsl:otherwise>
                    <end><xsl:value-of select="normalize-space(lc:end)"/></end>
                    <total><xsl:value-of select="f:calculateTotalPgs(lc:start, lc:end)"/></total>
                </xsl:otherwise>
            </xsl:choose>
        </extent>
        
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p><xd:b>vendorName:</xd:b> Name of the vendor supplying the metadata.</xd:p>
            <xd:p><xd:b>archiveFile:</xd:b> Filename of the file (xml or zip) that originally held
                the source data.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="extension">
        <xsl:element name="extension">
            <xsl:element name="vendorName">
                <xsl:value-of select="$vendorName"/>
            </xsl:element>
            <xsl:element name="archiveFile">
                <xsl:value-of select="$archiveFile"/>
            </xsl:element>
            <xsl:element name="originalFile">
                <xsl:value-of select="$originalFilename"/>
            </xsl:element>
            <xsl:element name="workingDirectory">
                <xsl:value-of select="$workingDir"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
