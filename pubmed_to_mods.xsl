<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE transform [
         <!ENTITY % htmlmathml-f PUBLIC
         "-//W3C//ENTITIES HTML MathML Set//EN//XML"
         "http://www.w3.org/2003/entities/2007/htmlmathml-f.ent"
       >
       %htmlmathml-f;
]>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.loc.gov/mods/v3" 
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:f="http://functions"
    xmlns:saxon="http://saxon.sf.net/" exclude-result-prefixes="xd xs f saxon xlink xsi">
    <xsl:output method="xml" indent="yes" encoding="UTF-8" saxon:next-in-chain="commons/split_modsCollection.xsl"/>
    <xsl:output method="xml" indent="yes" encoding="UTF-8" name="archive-original" doctype-public="-//NLM//DTD PubMe 2.7//EN" doctype-system="https://dtd.nlm.nih.gov/ncbi/pubmed/in/PubMed.dtd"/>
    <xsl:output method="xml" indent="yes" encoding="UTF-8" name="n-file"/>


    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Last modified on:</xd:b> September 08, 2017</xd:p>
            <xd:p><xd:b>Original author:</xd:b> Jennifer Gilbert</xd:p>
            <xd:p><xd:b>Modified by:</xd:b> Rachel Donahue</xd:p>
            <xd:p>This stylesheet was refactored in September 08.</xd:p>
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
            <xd:p>Ignore whitespace-only (i.e. empty) elements except for <xs:b>p</xs:b>.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="p"/>

    <!-- Root -->
    <xsl:template match="/">
        <modsCollection>
            <xsl:for-each select="ArticleSet/Article">
                <xsl:result-document method="xml" encoding="UTF-8" indent="yes" href="{$workingDir}A-{replace($originalFilename, '(.*/)(.*)(\.xml)', '$2')}_{position()}.xml" format="archive-original">            
                    <ArticleSet xmlns="">
                            <xsl:copy-of select="." copy-namespaces="no"/>                
                    </ArticleSet>
                </xsl:result-document>
                <xsl:result-document method="xml" encoding="UTF-8" indent="yes" href="{$workingDir}N-{replace($originalFilename, '(.*/)(.*)(\.xml)', '$2')}_{position()}.xml" format="n-file"> 
                <mods version="3.7">
                    <xsl:namespace name="xsi"
                        >http://www.w3.org/2001/XMLSchema-instance</xsl:namespace>
                    <xsl:attribute name="xsi:schemaLocation">http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-7.xsd</xsl:attribute>
                    <xsl:if test="VernacularTitle">
                        <xsl:apply-templates select="VernacularTitle"/>
                        <!-- VernacularTitle is the translated title and article title is the main title -->
                    </xsl:if>
                    <xsl:apply-templates select="ArticleTitle"/>
                    <xsl:apply-templates select="AuthorList/Author"/>
                    <!-- Note fix for Wolters Kluwer affiliation issue -->
                    <xsl:if test="$vendorName = 'Wolters Kluwer'">
                        <xsl:apply-templates select="AuthorList/Author[1]/Affiliation" mode="note"/>
                    </xsl:if>
                    <typeOfResource>text</typeOfResource>
                    <genre>article</genre>
                    <xsl:apply-templates select="Journal/PubDate" mode="originInfo"/>
                    <xsl:if test="not(Journal/PubDate)">
                        <xsl:apply-templates select="History/PubDate" mode="originInfo"/>
                    </xsl:if>
                    <xsl:apply-templates select="Language"/>
                    <xsl:apply-templates select="Abstract"/>
                    <xsl:apply-templates select="PublicationType"/>
                    <xsl:apply-templates select="Journal"/>
                    <xsl:apply-templates select="ArticleIdList/ArticleId[not(@IdType = 'doi')] | ELocationID[not(@EIdType = 'doi' or @EIdType = 'url')]"/>
                    <xsl:apply-templates select="ArticleIdList/ArticleId[@IdType = 'doi']"/>
                    <xsl:if test="not(ArticleIdList/ArticleId[@IdType = 'doi'])">
                        <xsl:apply-templates select="ELocationID[@EIdType = 'doi']"/>
                    </xsl:if>
                    <xsl:apply-templates select="ELocationID[@EIdType = 'url']"/>

                    <xsl:call-template name="extension"/>
                </mods>
                </xsl:result-document>
            </xsl:for-each>
        </modsCollection>
    </xsl:template>

    <xsl:template match="vendor">
        <recordInfo>
            <recordIdentifier type="vendor">
                <xsl:value-of select="."/>
            </recordIdentifier>
        </recordInfo>
    </xsl:template>
    <!-- Article title -->
    <xsl:template match="ArticleTitle">
        <titleInfo>
            <title>
                <xsl:value-of select="normalize-space(.)"/>
            </title>
        </titleInfo>
    </xsl:template>
    
    <!-- Translated title -->
    <xsl:template match="VernacularTitle">
        <titleInfo type="translated">
            <title>
                <xsl:value-of select="normalize-space(.)"/>
            </title>
        </titleInfo>
    </xsl:template>


    <!-- Identifiers -->
    <xsl:template match="ArticleIdList/ArticleId[not(@IdType = 'doi')] | ELocationID[not(@EIdType = 'doi' or @EIdType = 'url')]">
        <identifier>
            <xsl:choose>
                <xsl:when test="local-name() = 'ArticleId'">
                    <xsl:attribute name="type">
                        <xsl:value-of select="@IdType"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="type">
                        <xsl:value-of select="@EIdType"/>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template>

    <xsl:template match="ArticleIdList/ArticleId[@IdType = 'doi'] | ELocationID[@EIdType = 'doi']">
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

    <xsl:template match="ELocationID[@EIdType = 'url']">
        <location>
            <url>
                <xsl:value-of select="."/>
            </url>
        </location>
    </xsl:template>

    <!-- Author Template -->
    <xsl:template match="Author">
        <name>
            <xsl:if test="position() = 1">
                <xsl:attribute name="usage">primary</xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="CollectiveName">
                    <xsl:attribute name="type">corporate</xsl:attribute>
                    <namePart>
                        <xsl:value-of select="."/>
                    </namePart>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="type">personal</xsl:attribute>
                    <xsl:apply-templates select="FirstName"/>
                    <xsl:apply-templates select="LastName"/>
                    <xsl:apply-templates select="Suffix"/>
                    <displayForm>
                        <xsl:value-of select="LastName"/>
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="FirstName"/>
                        <xsl:if test="./MiddleName">
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="MiddleName"/>
                        </xsl:if>
                        <xsl:if test="Suffix">
                            <xsl:text>, </xsl:text>
                            <xsl:value-of select="Suffix"/>
                        </xsl:if>
                    </displayForm>
                    <xsl:apply-templates select="Affiliation | AffiliationInfo/Affiliation" mode="aff"/>
                    <role>
                        <roleTerm type="text">author</roleTerm>
                    </role>
                    <xsl:apply-templates select="Identifier"/>
                </xsl:otherwise>
            </xsl:choose>

        </name>
    </xsl:template>

    <xsl:template match="FirstName">
        <namePart type="given">
            <xsl:value-of select="string-join((., ../MiddleName), ' ')"/>
        </namePart>
    </xsl:template>
    
    <xsl:template match="LastName">
        <namePart type="family">
            <xsl:value-of select="."/>
        </namePart>
    </xsl:template>
    
    <xsl:template match="Suffix">
        <namePart type="termsOfAddress">
            <xsl:value-of select="."/>
        </namePart>
    </xsl:template>
    
    <xsl:template match="Affiliation | AffiliationInfo/Affiliation" mode="aff">
        <xsl:choose>
            <xsl:when test="$vendorName = 'Wolters Kluwer'">
                <!-- Test to check what type of affiliation info is included -->
                <xsl:variable name="lName1" select="../../Author[1]/LastName"/>
                <xsl:variable name="lName2" select="../../Author[2]/LastName"/>
                <xsl:if test="not(matches(substring(., 1, 3), '1\S+'))">
                    <xsl:if test="not(contains(., $lName1) and contains(., $lName2))">
                        <affiliation>
                            <xsl:value-of select="normalize-space(.)"/>
                        </affiliation>
                    </xsl:if>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <affiliation>
                    <xsl:value-of select="normalize-space(.)"/>
                </affiliation>
            </xsl:otherwise>
    </xsl:choose>
    </xsl:template>
    
    <xsl:template match="Identifier[@Source = 'ORCID']">
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

    <!-- Abstract -->
    <!-- Abstract - Publisher cleanup program should remove "Abstract" or "Summary" from beginning of abstract -->

    <xsl:template match="Affiliation" mode="note">
        <xsl:variable name="lName1" select="../../Author[1]/LastName"/>
        <xsl:variable name="lName2" select="../../Author[2]/LastName"/>
        <xsl:if test="matches(substring(., 1, 3), '1\S+') or (contains(., $lName1) and contains(., $lName2))">
            <note type="creation/production credits">
                <xsl:value-of select="concat('Affiliations: ', .)"/>
            </note>
        </xsl:if>
    </xsl:template>

    <xsl:template match="Abstract">
        <abstract>
            <xsl:apply-templates select="node() | *"/>
        </abstract>
    </xsl:template>

    <!-- Journal -->
    <xsl:template match="Journal">
        <relatedItem type="host">
            <xsl:apply-templates select="JournalTitle"/>
            <xsl:apply-templates select="PublisherName"/>
            <xsl:apply-templates select="Issn | ISSN"/>
            <xsl:call-template name="modsPart"/>
        </relatedItem>
    </xsl:template>
    
    <!-- Begin relatedItem -->
    <xsl:template name="modsPart">
        <part>
            <xsl:apply-templates select="Volume"/>
            <xsl:apply-templates select="Issue"/>
            <xsl:if test="../FirstPage">
                <xsl:call-template name="modsPages"/>
            </xsl:if>                           
            <xsl:apply-templates select="PubDate" mode="modsPart"/>
        </part>
    </xsl:template>

    <xsl:template name="modsPages">
        <extent unit="pages">
            <xsl:apply-templates select="../FirstPage"/>
            <xsl:apply-templates select="../LastPage"/>
            <xsl:sequence select="f:calculateTotalPgs(../FirstPage, ../LastPage)"/>
        </extent>
    </xsl:template>

    <xsl:template match="LastPage">
        <end>
            <xsl:value-of select="."/>
        </end>
    </xsl:template>

    <xsl:template match="FirstPage">
        <start>
            <xsl:value-of select="."/>
        </start>
    </xsl:template>

    <xsl:template match="Issue">
        <detail type="issue">
            <number>
                <xsl:value-of select="."/>
            </number>
            <caption>no.</caption>
        </detail>
    </xsl:template>

    <xsl:template match="Volume">
        <detail type="volume">
            <number>
                <xsl:value-of select="."/>
            </number>
            <caption>v.</caption>
        </detail>
    </xsl:template>

    <xsl:template match="Issn | ISSN">
        <identifier type="issn">
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template>


    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Tests below remove copyright information that appears in Wolters Kluwer metadata and only prints publisher name(s)</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="PublisherName">
        <originInfo>
            <publisher>
                <xsl:choose>
                    <xsl:when test="contains(., 'Wolters Kluwer Health | Lippincott Williams &amp; Wilkins')">
                        <xsl:text>Wolters Kluwer Health | Lippincott Williams &amp; Wilkins</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(., 'Lippincott Williams &amp; Wilkins')">
                        <xsl:text>Lippincott Williams &amp; Wilkins</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(., 'Wolters Kluwer')">
                        <xsl:text>Wolters Kluwer Health</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(., 'Williams &amp; Wilkins')">
                        <xsl:text>Williams &amp; Wilkins</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </publisher>
        </originInfo>
    </xsl:template>

    <xsl:template match="JournalTitle">
        <titleInfo>
            <title>
                <xsl:value-of select="."/>
            </title>
        </titleInfo>
    </xsl:template>
    <!-- Publication Date -->
    <xsl:template match="PubDate" mode="modsPart">
        <xsl:for-each select="Year, Month, Day, Season">
            <text type="{lower-case(name())}">
                <xsl:value-of select="."/> 
            </text>
        </xsl:for-each>
    </xsl:template>
    
    <!-- End relatedInfo -->
    
    <xsl:template match="PubDate" mode="originInfo">
        <originInfo>
            <dateIssued encoding="w3cdtf" keyDate="yes">
                <xsl:value-of select="string-join((Year, f:checkMonthType(Month), format-number(Day,'00'))[. != 'NaN'], '-')"/>
            </dateIssued>
        </originInfo>
    </xsl:template>
    
    <!-- Language -->
    <xsl:template match="Language">
        <language>
            <xsl:choose>
                <xsl:when test=". = ('EN', 'en')">
                    <languageTerm authority="iso639-2b" type="code">
                        <xsl:text>eng</xsl:text>
                    </languageTerm>
                    <languageTerm type="text">English</languageTerm>
                </xsl:when>
                <xsl:otherwise>
                    <languageTerm authority="iso639" type="code">
                        <xsl:value-of select="."/>
                    </languageTerm>
                </xsl:otherwise>
            </xsl:choose>
        </language>
    </xsl:template>
    
    <!-- PublicationType (why not use genre? )-->
    <xsl:template match="PublicationType">
        <xsl:if test="not(normalize-space(.) = '')">
            <note type="publicationType">
                <xsl:value-of select="."/>
            </note>
        </xsl:if>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p><xd:b>vendorName:</xd:b> Name of the vendor supplying the metadata.</xd:p>
            <xd:p><xd:b>archiveFile:</xd:b> Filename of the file (xml or zip) that originally held the source data.</xd:p>
            <xd:p><xd:b>originalFilename:</xd:b> Name of the file currently being processed.</xd:p>
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
            <!-- funding group information -->
            <xsl:apply-templates select="ObjectList[Object[@Type='grant']]"/>
        </extension>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Adds funding information from source while preserving source format.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="ObjectList">
        <ObjectList>
            <xsl:for-each select="Object[@Type='grant']">
                <Object Type="grant">
                    <xsl:for-each select="Param">
                        <Param Name="{@Name}">
                            <xsl:value-of select="."/>
                        </Param>
                    </xsl:for-each>
                </Object>
            </xsl:for-each>
        </ObjectList>
    </xsl:template>
    
</xsl:stylesheet>
