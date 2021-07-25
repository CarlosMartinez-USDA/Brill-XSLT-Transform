<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns="http://www.loc.gov/mods/v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" indent="yes" encoding="UTF-8" />
    <xsl:strip-space elements="*"/> 
    
    <!--    
        File name: 
        pubmed_to_mods-IRSC.xsl
        
        Created by: 
        Carlos Martinez III, NAL Metadata Librarian, 8/16/2016
        revised 20160817
        
        Description: 
        This transformation is a revised version of the pubmed_to_mods.xsl transformation.  Pubmed_to_mods is a transformation used locally unique to NAL for use
        in indexing and UI display in NAL's Fedora-based Digital Repository. 
        
        This xsl transforms metadata received from the Inter-Research Science Center from Pubmed Central's citation format XML file to NAL"s MODS XML record format per a  
        to faciliate acceess to digital content within NAL's Digital Repository. Each resulting file is ingested to its corresponding FOXML and use in NLM's Fedora-based digital 
        repository.  
        
        This tranformation serves to transform metadata that is delievered in PubMed citiation format into serial at the article level. 
               
        Other information: (fill in additional info as needed)
        
        Revision History: 
        Changed Personal name: added primary usage to first author and added displayForm element 2014-07-03 CWS
        Added Language text English and dateIssued elements 2016-02-23 JG
		Commented out of code to test super and subscript spacing (????)
		Updated MODS validation schema to 3.6
		Cleaned up template and added Filename, Created by, Description and Revisioin history.     
    -->
    
    
    <!-- Parameters -->
    <xsl:param name="vendorName"/>
    <xsl:param name="archiveFile"/>
    
    <!-- Root -->
    <xsl:template match="/">
        <mods xmlns:xlink="http://www.w3.org/1999/xlink" version="3.6" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xmlns="http://www.loc.gov/mods/v3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-6.xsd">
            <xsl:apply-templates select="/ArticleSet/Article" />
        </mods>
    </xsl:template>
    
    <!--  MAIN ARTICLE TEMPLATE   
        <displayForm>
        AuthorLastName, AuthorFirstName
        <affiliation>
        Required if Included: Organization or Agency - Optional: Street, City, State or Province, Zip, Country,- email
        </affiliation>
        </displayForm>
     -->
    
    <xsl:template match="Article">    
            <xsl:if test="VernacularTitle">
                <xsl:apply-templates select="VernacularTitle" /> <!-- VernacularTitle is the translated title and article title is the main title -->
            </xsl:if>         
        <xsl:apply-templates select="ArticleTitle" />
        <xsl:apply-templates select="AuthorList/Author" />
        <typeOfResource>text</typeOfResource>
        <genre>article</genre>
        <xsl:call-template name="dateIssued" /> <!-- insert date here <originInfo><dateIssued encoding="w3cdtf" keyDate="yes">YYYY-MM-DD</dateIssued></originInfo>  -->
        <xsl:apply-templates select="Language" />
        <xsl:apply-templates select="Abstract" />
        <xsl:apply-templates select="PublicationType" />
        <xsl:apply-templates select="Journal" />
        <xsl:call-template name="PII" />
        <xsl:call-template name="DOI" />

        <xsl:call-template name="extension" />

    </xsl:template>

    <!--  Vendor name -->
    <xsl:template match="vendor">
        <recordInfo>
            <recordIdentifier type="vendor">
                <xsl:value-of select="." />
            </recordIdentifier>
        </recordInfo>
    </xsl:template>
    
    <!--Article title-->
    
    <xsl:template match="ArticleTitle">
        <titleInfo>
            <title>
                <xsl:value-of select="normalize-space(/ArticleSet/Article/ArticleTitle)"/>
            </title>
        </titleInfo>
    </xsl:template>
    
    <!-- Translated title -->
    <xsl:template match="VernacularTitle"> 
            <titleInfo type="translated">
                <title>
                    <xsl:value-of select="normalize-space(/ArticleSet/Article/VernacularTitle)" />
                </title>
            </titleInfo>
    </xsl:template>
    
  <!-- Removing this code to test super and subscript spacing  
    <xsl:template match="text()">
        <xsl:sequence select="replace(., '^\s+|\s+$', '', '')"/>
    </xsl:template>-->
    
    <!--DOI-->
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
            <xsl:when test="ELocationID">
                <identifier type="doi">
                    <xsl:value-of select="ELocationID" />
                </identifier>
                <location>
                    <url><xsl:text>http://dx.doi.org/</xsl:text><xsl:value-of select="ELocationID" /></url>
                </location>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- PII -->
   
    <xsl:template name="PII">
        <xsl:choose>
            <xsl:when test="ArticleIdList/ArticleId[@IdType='pii']">
                <identifier type="pii">
                    <xsl:value-of select="ArticleIdList/ArticleId[@IdType='pii']" />
                </identifier>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- Author Template -->
    
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
    <!-- Abstract --> <!-- Remove "Abstract" or "Summary" if they appear in the transformed MODS, cleanup program should automate removal  -->

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

    <!-- Date Issued -->
    
    <xsl:template name="dateIssued">
        <originInfo>
            <dateIssued encoding="w3cdtf" keyDate="yes">
                <xsl:value-of select="Journal/PubDate/Year"/>
                <xsl:choose>
                    <xsl:when test="string-length(Journal/PubDate/Month)= 1 and Journal/PubDate/Month != ' ' ">
                        <xsl:text>-0</xsl:text>
                        <xsl:value-of select="Journal/PubDate/Month"/>
                    </xsl:when>
                    <xsl:when test="string-length(Journal/PubDate/Month)= 2 and Journal/PubDate/Month != '  ' ">
                        <xsl:text>-</xsl:text>
                        <xsl:value-of select="Journal/PubDate/Month"/>
                    </xsl:when>
                    <xsl:when test="string-length(Journal/PubDate/Month)>2">
                        <xsl:text>-</xsl:text>
                        <xsl:if test="Journal/PubDate/Month='January' or Journal/PubDate/Month='JANUARY' or Journal/PubDate/Month='Jan.' or Journal/PubDate/Month='Jan'">01</xsl:if>
                        <xsl:if test="Journal/PubDate/Month='February' or Journal/PubDate/Month='FEBRUARY'or Journal/PubDate/Month='Feb.' or Journal/PubDate/Month='Feb'">02</xsl:if>
                        <xsl:if test="Journal/PubDate/Month='March' or Journal/PubDate/Month='MARCH' or Journal/PubDate/Month='Mar.' or Journal/PubDate/Month='Mar'">03</xsl:if>
                        <xsl:if test="Journal/PubDate/Month='April' or Journal/PubDate/Month='APRIL' or Journal/PubDate/Month='Apr.' or Journal/PubDate/Month='Apr'">04</xsl:if>
                        <xsl:if test="Journal/PubDate/Month='May' or Journal/PubDate/Month='MAY'">05</xsl:if>
                        <xsl:if test="Journal/PubDate/Month='June' or Journal/PubDate/Month='JUNE' or Journal/PubDate/Month='Jun.' or Journal/PubDate/Month='Jun'">06</xsl:if>
                        <xsl:if test="Journal/PubDate/Month='July' or Journal/PubDate/Month='JULY' or Journal/PubDate/Month='Jul.' or Journal/PubDate/Month='Jul'">07</xsl:if>
                        <xsl:if test="Journal/PubDate/Month='August' or Journal/PubDate/Month='AUGUST' or Journal/PubDate/Month='Aug.' or Journal/PubDate/Month='Aug'">08</xsl:if>
                        <xsl:if test="Journal/PubDate/Month='September' or Journal/PubDate/Month='SEPTEMBER' or Journal/PubDate/Month='Sept.' or Journal/PubDate/Month='Sept'">09</xsl:if>
                        <xsl:if test="Journal/PubDate/Month='October' or Journal/PubDate/Month='OCTOBER' or Journal/PubDate/Month='Oct.' or Journal/PubDate/Month='Oct'">10</xsl:if>
                        <xsl:if test="Journal/PubDate/Month='November' or Journal/PubDate/Month='NOVEMBER' or Journal/PubDate/Month='Nov.' or Journal/PubDate/Month='Nov'">11</xsl:if>
                        <xsl:if test="Journal/PubDate/Month='December' or Journal/PubDate/Month='DECEMBER' or Journal/PubDate/Month='Dec.' or Journal/PubDate/Month='Dec'">12</xsl:if>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="string-length(Journal/PubDate/Day)= 1" >
                        <xsl:text>-0</xsl:text>
                        <xsl:value-of select="Journal/PubDate/Day"/>
                    </xsl:when>
                    <xsl:when test="string-length(Journal/PubDate/Day)= 2" >
                        <xsl:text>-</xsl:text>
                        <xsl:value-of select="Journal/PubDate/Day"/>
                    </xsl:when>
                </xsl:choose>
            </dateIssued>
        </originInfo> 
    </xsl:template>
    
    <!-- Journal-->
    
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
                <!-- Issue test-->
                <xsl:if test="Issue">
                <detail type="issue">
                     <number>
                            <xsl:value-of select="Issue" />
                     </number>
                     <caption>no.</caption>
                </detail>    
                </xsl:if>
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
    
    <!-- Publication Date -->
    
    <xsl:template match="PubDate">
        <xsl:apply-templates select="Year" />
        <xsl:apply-templates select="Month" />
        <xsl:apply-templates select="Day" />
        <xsl:apply-templates select="Season" />
    </xsl:template>
    <xsl:template match="Year">
        <text type="year">
            <xsl:value-of select="." />
        </text>
    </xsl:template>
    <xsl:template match="Month">
        <text type="month">
            <xsl:value-of select="." />
        </text>
    </xsl:template>
    <xsl:template match="Day">
        <text type="day">
            <xsl:value-of select="." />
        </text>
    </xsl:template>
    <xsl:template match="Season">
        <text type="season">
            <xsl:value-of select="." />
        </text>
    </xsl:template>
   
    <!-- Language -->
    
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
    
    <!-- PublicationType -->
    
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