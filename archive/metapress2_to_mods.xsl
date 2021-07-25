<?xml version="1.0" encoding="utf-8"?>

<!-- Changed Personal name: added primary usage to first author and added displayForm element
    Added concat for combined issue numbers
    Changed DOI url location from default to requiring DOI identifier  2015-02-18 JG
    Changed abstract template to remove entities 2016-01-15 JG -->
<!-- Replace HTML in abstract and title 2016-06-22 JG -->

<!-- Header -->
<xsl:stylesheet version="2.0" xmlns="http://www.loc.gov/mods/v3"  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" >
    <xsl:output method="xml" indent="yes" encoding="UTF-8" />
    
    <!-- Pulls in source information such as Vendor and source file name -->

    <!-- Parameters -->
    <xsl:param name="vendorName"/>
    <xsl:param name="archiveFile"/>
    <!-- Parameters -->
    
    <xsl:template match="*[not(.//@*) and not( normalize-space() )]" priority="3"/>

    <!-- Root -->
    <xsl:template match="/">
        <mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.5" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
            <xsl:apply-templates select="Publisher/Journal/Volume/Issue/Article/ArticleInfo/ArticleTitle" />
         
            <xsl:apply-templates select="Publisher/Journal/Volume/Issue/Article/ArticleHeader/AuthorGroup" />

            <!-- Defaults -->
            <typeOfResource>text</typeOfResource>
            <genre>article</genre>

            <xsl:apply-templates select="Publisher/Journal/Volume/Issue/IssueInfo/IssuePublicationDate/CoverDate" />

            <!-- language - CD - may not be a good enough test-->

            <xsl:if test="(contains(Publisher/Journal/Volume/Issue/Article/ArticleInfo/ArticleTitle/@Language, 'En'))">
              <language>
                <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
                <languageTerm type="text">English</languageTerm>
              </language>
            </xsl:if>

            <xsl:apply-templates select="Publisher/Journal/Volume/Issue/Article/ArticleHeader/Abstract[@Language='En']" />
            <xsl:apply-templates select="Publisher/Journal/Volume/Issue/Article/ArticleHeader/KeywordGroup[@Language='En']" />
            <xsl:apply-templates select="Publisher/Journal/JournalInfo" />
            <xsl:apply-templates select="Publisher/Journal/Volume/Issue/Article/ArticleInfo/ArticlePII" />
            <xsl:apply-templates select="Publisher/Journal/Volume/Issue/Article/ArticleInfo/ArticleDOI" />
   
            <!-- Extension -->
            
            <extension>
                <vendorName>
                    <xsl:value-of select="$vendorName"/>
                </vendorName>
                <archiveFile>
                    <xsl:value-of select="$archiveFile"/>
                </archiveFile>
           </extension>
            
        </mods>
    </xsl:template>

            <!--Article title-->
            <xsl:template match="ArticleTitle">
                <xsl:for-each select="replace(., '&lt;.*?&gt;', '')">
 
                    <xsl:if test="position()=1">
                <titleInfo>
                    <title>
                        <xsl:value-of select="normalize-space(.)"/>
                    </title>
                </titleInfo>
                    </xsl:if>
                        <xsl:if test="position()>1">
                            <titleInfo type="translated">
                                <title>
                                    <xsl:value-of select="normalize-space(.)"/>
                                </title>
                            </titleInfo>
                        </xsl:if>               
                </xsl:for-each>
            </xsl:template> 

            <!-- Authors  -->
            <xsl:template match="AuthorGroup">
                <xsl:for-each select="Author">
                    <xsl:choose>
                        <xsl:when test="position()=1">
                            <name type="personal" usage="primary">
                                <xsl:call-template name="name-info"/>     
                            </name>              
                        </xsl:when>
                        <xsl:otherwise>
                            <name type="personal">
                                <xsl:call-template name="name-info"/>     
                            </name>              
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:template>
    
    <xsl:template name="name-info">      
                        <xsl:if test="GivenName and not(normalize-space(GivenName)='')" >
                        <namePart type="given">
                            <xsl:value-of select="GivenName" />
                        </namePart>
                        </xsl:if>
                        <xsl:if test="Initials and not(normalize-space(Initials)='')" >
                        <namePart type="given">
                            <xsl:value-of select="Initials" />
                        </namePart>
                        </xsl:if>
                        <xsl:if test="FamilyName and not(normalize-space(FamilyName)='')" >
                        <namePart type="family">
                            <xsl:value-of select="FamilyName" />
                        </namePart>
                        </xsl:if>
        <displayForm>
            <xsl:value-of select="FamilyName" />
            <xsl:text>, </xsl:text>
            <xsl:value-of select="GivenName" />
            <xsl:if test="Initials and not(normalize-space(Initials)='')" >
            <xsl:text> </xsl:text>
            <xsl:value-of select="Initials" />
            </xsl:if>
        </displayForm>         

                       <!-- Use id to get affiliation  -->  
        <xsl:if test="../Affiliation[@AFFID=current()/@AffiliationID]/OrgName">
                      <affiliation>
                          <xsl:value-of select="../Affiliation[@AFFID=current()/@AffiliationID]/OrgName"/>
                      </affiliation>  
        </xsl:if>            
                        <role>
                            <roleTerm type="text">author</roleTerm>
                        </role>       
            </xsl:template>

    <!-- Date issued CD - don't include for online preview articles?? -->
    <xsl:template match="CoverDate">
        <originInfo>
            <dateIssued encoding="w3cdtf" keyDate="yes">
                <xsl:value-of select="@Year"/>
                <xsl:choose>
                    <xsl:when test="string-length(@Month)= 1 and @Month != ' ' ">
                        <xsl:text>-0</xsl:text>
                        <xsl:value-of select="@Month"/>
                    </xsl:when>
                    <xsl:when test="string-length(@Month)= 2 and @Month != '  ' ">
                        <xsl:text>-</xsl:text>
                        <xsl:value-of select="@Month"/>
                    </xsl:when>

                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="string-length(@Day)= 1" >
                        <xsl:text>-0</xsl:text>
                        <xsl:value-of select="@Day"/>
                    </xsl:when>
                    <xsl:when test="string-length(@Day)= 2" >
                        <xsl:text>-</xsl:text>
                        <xsl:value-of select="@Day"/>
                    </xsl:when>
                </xsl:choose>
            </dateIssued>
        </originInfo>
    </xsl:template>

    <xsl:template match="Abstract[@Language='En']">
        <xsl:for-each select="replace(., '&lt;.*?&gt;', '')">
            
                <abstract>
                    <xsl:value-of select="normalize-space(.)" />
                </abstract>
        </xsl:for-each>
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
    
    

    <!-- Keywords  -->
    <xsl:template match="KeywordGroup[@Language='En']">
                <xsl:for-each select="Keyword">
                    <subject>
                        <topic>
                            <xsl:value-of select="normalize-space(.)" />
                        </topic>
                    </subject>
                </xsl:for-each>
    </xsl:template>

    <!-- Journal info -->
    <xsl:template match="JournalInfo">
        <relatedItem type="host">
            <titleInfo>
                <title>
                    <xsl:value-of select="normalize-space(JournalTitle)" />
                </title>
            </titleInfo>

                <originInfo>
                    <publisher>
                        <xsl:value-of select="normalize-space(/Publisher/PublisherInfo/PublisherName)" />
                    </publisher>
                </originInfo>
            <identifier type="issn">
                <xsl:value-of select="JournalPrintISSN" />
            </identifier>
            <identifier type="p-issn">
                <xsl:value-of select="JournalPrintISSN" />
            </identifier>
            <xsl:if test="../JournalElectronicISSN">
            <identifier type="e-issn">
                <xsl:value-of select="../JournalElectronicISSN" />
            </identifier>
            </xsl:if>
            <identifier type="vendor">
                <xsl:value-of select="JournalID" />
            </identifier>

            <!-- Don't include temporary 'part' data for online preview articles (contain "-1" in volume and issue)  -->
            <xsl:if test="not(starts-with(/Publisher/Journal/Volume/VolumeInfo/VolumeNumber, '-' )) and not(starts-with(/Publisher/Journal/Volume/Issue/IssueInfo/IssueNumberBegin, '-' ))" >
            <part>
                <!-- Make sure volume exists  -->
                <xsl:if test="/Publisher/Journal/Volume/VolumeInfo/VolumeNumber and not(starts-with(/Publisher/Journal/Volume/VolumeInfo/VolumeNumber, '-' ))" >
                    <detail type="volume">
                        <number>
                            <xsl:value-of select="/Publisher/Journal/Volume/VolumeInfo/VolumeNumber" />
                        </number>
                        <caption>v.</caption>
                    </detail>
                </xsl:if>

                <!-- Make sure issue exists   -->
                <xsl:if test="/Publisher/Journal/Volume/Issue/IssueInfo/IssueNumberBegin = /Publisher/Journal/Volume/Issue/IssueInfo/IssueNumberEnd" >
                    <detail type="issue">
                        <number>
                            <xsl:value-of select="/Publisher/Journal/Volume/Issue/IssueInfo/IssueNumberBegin" />
                        </number>
                        <caption>no.</caption>
                    </detail>
                </xsl:if>
                        <xsl:if test="/Publisher/Journal/Volume/Issue/IssueInfo/IssueNumberEnd != /Publisher/Journal/Volume/Issue/IssueInfo/IssueNumberBegin">
                    <detail type="issue">
                        <number>
                            <xsl:value-of select="concat(/Publisher/Journal/Volume/Issue/IssueInfo/IssueNumberBegin, '-', /Publisher/Journal/Volume/Issue/IssueInfo/IssueNumberEnd)"/>
                        </number>
                        <caption>no.</caption>
                    </detail>
                </xsl:if>
          
                <!-- Make sure pagination exists -->
                <xsl:if test="/Publisher/Journal/Volume/Issue/Article/ArticleInfo/ArticleFirstPage " >
                    <extent unit="pages">
                        <start>
                            <xsl:value-of select="/Publisher/Journal/Volume/Issue/Article/ArticleInfo/ArticleFirstPage" />
                        </start>

                        <xsl:if test="/Publisher/Journal/Volume/Issue/Article/ArticleInfo/ArticleLastPage" >
                            <end>
                                <xsl:value-of select="/Publisher/Journal/Volume/Issue/Article/ArticleInfo/ArticleLastPage" />
                            </end>
                        </xsl:if>
                    </extent>
                </xsl:if>

         <!-- publication date -->

                <xsl:if test="/Publisher/Journal/Volume/Issue/IssueInfo/IssuePublicationDate/CoverDate[@Year]" >
                        <text type="year">
                            <xsl:value-of select="/Publisher/Journal/Volume/Issue/IssueInfo/IssuePublicationDate/CoverDate/@Year"/>
                        </text>
               </xsl:if>
                <xsl:if test="/Publisher/Journal/Volume/Issue/IssueInfo/IssuePublicationDate/CoverDate[@Month] and not(normalize-space /Publisher/Journal/Volume/Issue/IssueInfo/IssuePublicationDate/CoverDate[@Month]='')" >
                        <text type="month">
                            <xsl:value-of select="/Publisher/Journal/Volume/Issue/IssueInfo/IssuePublicationDate/CoverDate/@Month" />
                        </text>
                    </xsl:if>
                <xsl:if test="/Publisher/Journal/Volume/Issue/IssueInfo/IssuePublicationDate/CoverDate[@Day] and not(normalize-space /Publisher/Journal/Volume/Issue/IssueInfo/IssuePublicationDate/CoverDate[@Day]='')" >
                        <text type="day">
                            <xsl:value-of select="/Publisher/Journal/Volume/Issue/IssueInfo/IssuePublicationDate/CoverDate/@Day" />
                        </text>
                    </xsl:if>

            </part>
            </xsl:if>
        </relatedItem>
    </xsl:template>

    <!-- PII -->
    <xsl:template match="ArticlePII">
        <identifier type="pii">
            <xsl:value-of select="../ArticlePII" />
        </identifier>
    </xsl:template>

        <!-- DOI   -->
    <xsl:template match="ArticleDOI">
        <xsl:if test="../ArticleDOI">
         <identifier type="doi">
             <xsl:value-of select="../ArticleDOI" />
        </identifier>
            <location>
                <url><xsl:text>http://dx.doi.org/</xsl:text><xsl:value-of select="encode-for-uri(.)" /></url>
            </location>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
