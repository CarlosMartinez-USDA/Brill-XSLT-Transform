<?xml version="1.0" encoding="utf-8"?>

<!-- Changed Personal name: added primary usage to first author and added displayForm element 2014-07-03 CWS -->

<!--
     Header and root
-->
<xsl:stylesheet version="2.0" xmlns="http://www.loc.gov/mods/v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" indent="yes" encoding="UTF-8" />
    
<!-- Parameters -->
    <xsl:param name="vendorName"/>
    <xsl:param name="archiveFile"/>
<!-- Parameters -->
    
    <!-- Root -->
    <xsl:template match="/">
        <mods xmlns:xlink="http://www.w3.org/1999/xlink" version="3.5" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/mods/v3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
            <xsl:apply-templates select="/ArticleSet/Article" />
        </mods>
    </xsl:template>
    <!--    <displayForm>Mufula, Alain I.<affiliation>Department of Chemistry, University of the Witwatersrand, Wits, 2050, Republic of South Africa, ilungamufula@yahoo.fr</affiliation></displayForm>

    MAIN ARTICLE TEMPLATE
-->
    <xsl:template match="Article">    
            <xsl:if test="VernacularTitle">
                <xsl:apply-templates select="VernacularTitle" />
                <!-- VernacularTitle is the translated title and article title is the main title -->
            </xsl:if>         
        <xsl:apply-templates select="ArticleTitle" />
        <xsl:apply-templates select="AuthorList/Author" />
        <typeOfResource>text</typeOfResource>
        <genre>article</genre>
<!-- insert date here <originInfo><dateIssued encoding="w3cdtf" keyDate="yes">YYYY-MM-DD</dateIssued></originInfo>  -->
        <xsl:apply-templates select="Language" />
        <xsl:apply-templates select="Abstract" />
        <xsl:apply-templates select="PublicationType" />
        <xsl:apply-templates select="Journal" />
        <xsl:call-template name="PII" />
        <xsl:call-template name="DOI" />

        <xsl:call-template name="extension" />

    </xsl:template>
    <!--
    Vendor name
-->
    <xsl:template match="vendor">
        <recordInfo>
            <recordIdentifier type="vendor">
                <xsl:value-of select="." />
            </recordIdentifier>
        </recordInfo>
    </xsl:template>
    <!--
    Article title
-->
    <xsl:template match="ArticleTitle">
        <titleInfo>
            <title>
                <xsl:value-of select="normalize-space(/ArticleSet/Article/ArticleTitle)"/>
            </title>
        </titleInfo>
    </xsl:template>
    <!--
    Translated title
-->
    <xsl:template match="VernacularTitle"> 
            <titleInfo type="translated">
                <title>
                    <xsl:value-of select="normalize-space(/ArticleSet/Article/VernacularTitle)" />
                </title>
            </titleInfo>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:sequence select="replace(., '^\s+|\s+$', '', '')"/>
    </xsl:template>
    
    <!--
    DOI
-->
    <xsl:template name="DOI">
        <xsl:choose>
            <xsl:when test="ArticleIdList/ArticleId[@IdType='doi']">
                <identifier type="doi">
                    <xsl:value-of select="ArticleIdList/ArticleId[@IdType='doi']" />
                </identifier>
                <location>
                    <url><xsl:text>http://dx.doi.org/</xsl:text><xsl:value-of select="ArticleIdList/ArticleId[@IdType='doi']" /></url>
                </location>
            </xsl:when>
            <xsl:when test="ArticleIdList/ELocationID">    
                <location>
                    <url>
                        <xsl:value-of select="ArticleIdList/ELocationID" />
                    </url>
                </location>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
    PII
-->
    <xsl:template name="PII">
        <xsl:choose>
            <xsl:when test="ArticleIdList/ArticleId[@IdType='pii']">
                <identifier type="pii">
                    <xsl:value-of select="ArticleIdList/ArticleId[@IdType='pii']" />
                </identifier>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!--
    Author Template
-->
    
    <xsl:template match="Author[position()=1]">
        <xsl:if test="LastName">
            <name type="personal" usage="primary">
                <xsl:apply-templates select="FirstName" />
                <xsl:apply-templates select="MiddleName" />
                <xsl:apply-templates select="LastName" />
                <xsl:apply-templates select="Suffix" />
                <displayForm>
                    <xsl:value-of select="LastName" />
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="FirstName" />
                    <xsl:if test="./MiddleName">
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="MiddleName" />
                    </xsl:if>
                    <xsl:if test="Suffix">
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="Suffix" />
                    </xsl:if>
                </displayForm>
                <xsl:apply-templates select="Affiliation" />                    
                <role>
                    <roleTerm type="text">author</roleTerm>
                </role>
            </name>
        </xsl:if>
        <xsl:apply-templates select="CollectiveName" />
    </xsl:template>
    
    <xsl:template match="Author[position()>1]">
        <xsl:if test="LastName">
            <name type="personal">
                <xsl:apply-templates select="FirstName" />
                <xsl:apply-templates select="MiddleName" />
                <xsl:apply-templates select="LastName" />
                <xsl:apply-templates select="Suffix" />
                <displayForm>
                    <xsl:value-of select="LastName" />
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="FirstName" />
                    <xsl:if test="./MiddleName">
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="MiddleName" />
                    </xsl:if>
                    <xsl:if test="Suffix">
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="Suffix" />
                    </xsl:if>                    
                </displayForm>
                <xsl:apply-templates select="Affiliation" />
                <role>
                    <roleTerm type="text">author</roleTerm>
                </role>
            </name>
        </xsl:if>
        <xsl:apply-templates select="CollectiveName" />
    </xsl:template>    
    
    <!--
        Author Name parts
-->
    <xsl:template match="FirstName">
        <namePart type="given">
            <xsl:value-of select="." />
        </namePart>
    </xsl:template>
    <xsl:template match="MiddleName">
        <namePart type="given">  <!-- No middle name in MODS -->
            <xsl:value-of select="." />
        </namePart>
    </xsl:template>
    <xsl:template match="LastName">
        <namePart type="family">
            <xsl:value-of select="." />
        </namePart>
    </xsl:template>
    <xsl:template match="Suffix">
        <namePart type="termsOfAddress">
            <xsl:value-of select="." />
        </namePart>
    </xsl:template>
    <xsl:template match="Affiliation">
        <affiliation>
            <xsl:value-of select="normalize-space(.)" />
        </affiliation>
    </xsl:template>
    
    <xsl:template match="CollectiveName">
        <name type="corporate">
            <namePart>
                <xsl:value-of select="." />
            </namePart>
        </name>
    </xsl:template>
    <!--
    Abstract
-->

    <!-- Abstract - Publisher cleanup program should remove "Abstract" or "Summary" from beginning of abstract -->

   <xsl:template match="Abstract">
        <abstract>
              <xsl:apply-templates select="node()|*"/>
        </abstract>
    </xsl:template>

    <xsl:template match="sub|subscript|inf">
        <xsl:value-of select="translate(.,
            '0123456789+-−=()aehijklmnoprstuvxəβγρφχ',
            '₀₁₂₃₄₅₆₇₈₉₊₋₋₌₍₎ₐₑₕᵢⱼₖₗₘₙₒₚᵣₛₜᵤᵥₓₔᵦᵧᵨᵩᵪ')" />
    </xsl:template>

    <xsl:template match="sup|superscript">
        <xsl:value-of select="translate(.,
            '0123456789+-−=()abcdefghijklmnoprstuvwxyzABDEGHIJKLMNOPRTUVWαβγδεθɩφχ',
            '⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻⁻⁼⁽⁾ᵃᵇᶜᵈᵉᶠᵍʰⁱʲᵏˡᵐⁿᵒᵖʳˢᵗᵘᵛʷˣʸᶻᴬᴮᴰᴱᴳᴴᴵᴶᴷᴸᴹᴺᴼᴾᴿᵀᵁⱽᵂᵅᵝᵞᵟᵋᶿᶥᵠᵡ')" />
    </xsl:template>


    <!--
        Journal
-->
    <xsl:template match="Journal">
        <relatedItem type="host">
            <titleInfo>
                <title>
                    <xsl:value-of select="JournalTitle" />
                </title>
            </titleInfo>

            <originInfo>
                <publisher>
                    <xsl:value-of select="PublisherName" />
                </publisher>
            </originInfo>

            <identifier type="issn">
                <xsl:value-of select="Issn" />
            </identifier>
            <part>
                <detail type="volume">
                    <number>
                        <xsl:value-of select="Volume" />
                    </number>
                    <caption>v.</caption>
                </detail>
                <detail type="issue">
                    <number>
                        <xsl:value-of select="Issue" />
                    </number>
                    <caption>no.</caption>
                </detail>
                <extent unit="pages">
                    <start>
                        <xsl:value-of select="/ArticleSet/Article/FirstPage" />
                    </start>
                    <end>
                        <xsl:value-of select="/ArticleSet/Article/LastPage" />
                    </end>
                </extent>
                <xsl:apply-templates select="PubDate" />
            </part>
        </relatedItem>
    </xsl:template>
    <!--
    Publication Date
-->
    <xsl:template match="PubDate">
    <xsl:if test="Year">
        <text type="year">
            <xsl:value-of select="Year" />
        </text>
    </xsl:if>
    <xsl:if test="Month">
        <text type="month">
            <xsl:value-of select="Month" />
        </text>
    </xsl:if>
    <xsl:if test="Day">
        <text type="day">
            <xsl:value-of select="Day" />
        </text>
    </xsl:if>
    <xsl:if test="Season">
        <text type="season">
            <xsl:value-of select="Season" />
        </text>
    </xsl:if>
    <xsl:if test="@PubStatus">
        <text type="display-date">
            <xsl:value-of select="@PubStatus" />
        </text>
    </xsl:if>
    </xsl:template>
    <!--
        Language
-->
    <xsl:template match="Language">
        <language>        
            <xsl:choose>
                <xsl:when test=".='EN'">
                    <languageTerm authority="iso639-2b" type="code">
                        <xsl:text>eng</xsl:text>
                    </languageTerm>            
                </xsl:when>
                <xsl:when test=".='en'">
                    <languageTerm authority="iso639-2b" type="code">
                        <xsl:text>eng</xsl:text>
                    </languageTerm>            
                </xsl:when>
                <xsl:otherwise>
                   <languageTerm authority="iso639" type="code">
                        <xsl:value-of select="." />
                   </languageTerm>
                </xsl:otherwise>
            </xsl:choose>
        </language>
    </xsl:template>
    <!--
        PublicationType

-->
    <xsl:template match="PublicationType">
        <xsl:if test="not(normalize-space(.)='')">
            <note type="publicationType">
                <xsl:value-of select="." />
            </note>
        </xsl:if>
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
        </extension>
    </xsl:template>
        
</xsl:stylesheet>
