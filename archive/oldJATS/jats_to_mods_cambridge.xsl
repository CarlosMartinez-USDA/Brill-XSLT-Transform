<?xml version="1.0" encoding="utf-8"?>
<!-- 02-25-16 jg -->
<!-- Remove title from abstract; exclude local namespace from output; add PDF file reference 03-07-16 jg -->
<!-- Added article-type attribute 03-22-16 jg  -->

<!-- Header -->
<xsl:stylesheet version="2.0" xmlns="http://www.loc.gov/mods/v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" >
    <xsl:output method="xml" indent="yes" encoding="UTF-8" />
    <!-- Pulls in source information such as Vendor and source file name -->
    <!-- Parameters -->
    <xsl:param name="vendorName"/>
    <xsl:param name="archiveFile"/>
    <!-- Parameters -->
    <xsl:strip-space elements="*"/>
    <!-- Root -->
    <xsl:template match="/">
       <mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.5" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
            <xsl:apply-templates select="article/front/article-meta/title-group" />
            <xsl:apply-templates select="article/front/article-meta/contrib-group" />
           

            <!-- Default -->
            <typeOfResource>text</typeOfResource>

            <!-- CD  Need to check to see what they use besides 'Research Articles'  -->
           <!-- <xsl:apply-templates select="article/front/article-meta/article-categories" />  -->
            <xsl:apply-templates select="article" />

            <xsl:apply-templates select="article/front/article-meta/pub-date[@pub-type='ppub'][1]" />

            <!-- Default language -->
            <language>
                <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
                <languageTerm type="text">English</languageTerm>
            </language>

            <xsl:apply-templates select="article/front/article-meta/abstract" />
            <xsl:apply-templates select="article/front/article-meta/kwd-group" />
            <xsl:apply-templates select="article/front/journal-meta" />
         
            <xsl:apply-templates select="article/front/article-meta/article-id[@pub-id-type]" />
            <xsl:call-template name="extension" />


    </mods>
</xsl:template>

<!--Article title-->
       <xsl:template match="title-group">
            <titleInfo>
                <title>
                    <xsl:value-of select="normalize-space(article-title)"/>
                </title>
<xsl:if test="subtitle!=''">
<subTitle><xsl:value-of select="subtitle" /></subTitle>
                </xsl:if>
            </titleInfo>
       </xsl:template>

    <!-- Authors  -->
    <xsl:template match="contrib-group">
        <xsl:for-each select="contrib">
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
        <namePart type="given">
            <xsl:value-of select="normalize-space (name/given-names)" />
        </namePart>
        <namePart type="family">
            <xsl:value-of select="name/surname" />
        </namePart>
        <displayForm>
            <xsl:value-of select="name/surname" />
            <xsl:text>, </xsl:text>
            <xsl:value-of select="normalize-space (name/given-names)" />
        </displayForm>

        <!-- Use id to get affiliation  -->
        <xsl:variable name="affid" select="xref[@ref-type='aff']/@rid"/>
        <xsl:if test="$affid">
            <xsl:for-each select="/article/front/article-meta/aff[@id=$affid]">
                <affiliation>
                    <xsl:value-of select="string-join((addr-line|institution|country), ', ')"/>
                </affiliation>
            </xsl:for-each>
        </xsl:if>
        <role>
            <roleTerm type="text">author</roleTerm>
        </role>
    </xsl:template>



    <!-- An empty template to exclude the superscript from displaying in the affiliation text string -->
    <xsl:template match="affiliation">
        <xsl:value-of select="text()"/>
    </xsl:template>


    <!-- Genre  -->
    <xsl:template match="article">
        <xsl:if test="@article-type='research-article' or 'rapid-communication'">
            <genre>article</genre>
        </xsl:if>
    </xsl:template>

    <!-- Date issued  -->
    <xsl:template match="pub-date[@pub-type='ppub'][1]">
       <originInfo>
           <dateIssued encoding="w3cdtf" keyDate="yes">
              <xsl:value-of select="year"/>
                 <xsl:choose>
                     <xsl:when test="string-length(month)= 1 and month != ' ' ">
                        <xsl:text>-0</xsl:text>
                        <xsl:value-of select="month"/>
                     </xsl:when>
                     <xsl:when test="string-length(month)= 2 and month != '  ' ">
                         <xsl:text>-</xsl:text>
                        <xsl:value-of select="month"/>
                      </xsl:when>
                     <xsl:when test="string-length(month)>2">
                         <xsl:text>-</xsl:text>
                         <xsl:if test="month='January' or month='JANUARY' or month='Jan.' or month='Jan'">01</xsl:if>
                         <xsl:if test="month='February' or month='FEBRUARY'or month='Feb.' or month='Feb'">02</xsl:if>
                         <xsl:if test="month='March' or month='MARCH' or month='Mar.' or month='Mar'">03</xsl:if>
                         <xsl:if test="month='April' or month='APRIL' or month='Apr.' or month='Apr'">04</xsl:if>
                         <xsl:if test="month='May' or month='MAY'">05</xsl:if>
                         <xsl:if test="month='June' or month='JUNE' or month='Jun.' or month='Jun'">06</xsl:if>
                         <xsl:if test="month='July' or month='JULY' or month='Jul.' or month='Jul'">07</xsl:if>
                         <xsl:if test="month='August' or month='AUGUST' or month='Aug.' or month='Aug'">08</xsl:if>
                         <xsl:if test="month='September' or month='SEPTEMBER' or month='Sept.' or month='Sept'">09</xsl:if>
                         <xsl:if test="month='October' or month='OCTOBER' or month='Oct.' or month='Oct'">10</xsl:if>
                         <xsl:if test="month='November' or month='NOVEMBER' or month='Nov.' or month='Nov'">11</xsl:if>
                         <xsl:if test="month='December' or month='DECEMBER' or month='Dec.' or month='Dec'">12</xsl:if>
                     </xsl:when>
                  </xsl:choose>
               <xsl:choose>
                   <xsl:when test="string-length(day)= 1" >
                       <xsl:text>-0</xsl:text>
                       <xsl:value-of select="day"/>
                   </xsl:when>
                   <xsl:when test="string-length(day)= 2" >
                       <xsl:text>-</xsl:text>
                       <xsl:value-of select="day"/>
                   </xsl:when>
               </xsl:choose>
             </dateIssued>
        </originInfo>
   </xsl:template>

    <!-- Abstract -->
    <!-- Publisher cleanup program should remove "ABSTRACT:" or "ABSTRACT" from beginning of abstract; also remove (title 'Abstract'), (title 'ABSTRACT'), (title 'Summary'), or (title 'SUMMARY') -->
    <!-- eliminate foreign language abstracts; include records with empty abstract title fields  -->

    <xsl:template match="abstract">
        <xsl:choose>
        <xsl:when test="@abstract-type='translated'">
            <!--Do nothing -->
        </xsl:when>
            <xsl:otherwise>
        <xsl:for-each select=".">
            <abstract>
                <xsl:variable name="abstract" select="."/>
                <xsl:variable name="this"><xsl:apply-templates/></xsl:variable>
                <xsl:value-of select="normalize-space($this)"></xsl:value-of>
            </abstract>
        </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="abstract/title"/>

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
    <xsl:template match="kwd-group">
       <xsl:choose>

           <xsl:when test="contains(title,'Key words') or contains(title,'Keywords') or contains(title,'KEY WORDS') or contains(title,'KEYWORDS')or contains(title,'Key Words') " >
         <xsl:for-each select="kwd">
           <subject>
               <topic>
                   <xsl:value-of select="normalize-space(.)" />
               </topic>
           </subject>
          </xsl:for-each>
        </xsl:when>

        <xsl:when test="contains(title,'Abbreviations')" >
            <!-- Do nothing -->
        </xsl:when>

           <xsl:when test="@xml:lang='fr' or @xml:lang='es' or @xml:lang='de' or @xml:lang='FR' or @xml:lang='ES'">
            <!-- Do nothing if keywords are in french, spanish, or german-->
        </xsl:when>

        <xsl:otherwise>
            <!-- when no title element exists -->
               <xsl:for-each select="kwd">
                   <subject>
                       <topic>
                           <xsl:value-of select="normalize-space(.)" />
                       </topic>
                   </subject>
               </xsl:for-each>
           </xsl:otherwise>
       </xsl:choose>
    </xsl:template>

    <!-- Journal info -->
    <xsl:template match="journal-meta">
        <relatedItem type="host">
            <titleInfo>
                <title>
                    <xsl:value-of select="normalize-space(.//journal-title)" />
                </title>
                <xsl:if test="journal-subtitle!=''">
                    <subTitle><xsl:value-of select="journal-subtitle" /></subTitle>
                </xsl:if>
            </titleInfo>
            <originInfo>
                <publisher>
                    <xsl:value-of select="normalize-space(/article/front/journal-meta/publisher/publisher-name)" />
                </publisher>
            </originInfo>
            <identifier type="issn-p">
                <xsl:value-of select="/article/front/journal-meta/issn[@pub-type='ppub']" />
            </identifier>
            <identifier type="issn-e">
                <xsl:value-of select="/article/front/journal-meta/issn[@pub-type='epub']" />
            </identifier>
            <identifier type="issn">
                <xsl:value-of select="/article/front/journal-meta/issn[@pub-type='epub']" />
            </identifier>
            <identifier type="vendor">
                <xsl:value-of select="/article/front/journal-meta/journal-id[@journal-id-type='publisher-id']" />
            </identifier>
            <part>
                <xsl:if test="/article/front/article-meta/volume" >
                    <detail type="volume">
                        <number>
                            <xsl:value-of select="/article/front/article-meta/volume" />
                        </number>
                        <caption>v.</caption>
                    </detail>
                </xsl:if>

                <!-- make sure issue exists and isn't empty  -->

                <xsl:if test="/article/front/article-meta/issue and not(normalize-space(/article/front/article-meta/issue)='')">
                    <detail type="issue">
                        <number>
                            <xsl:value-of select="/article/front/article-meta/issue" />
                        </number>
                        <caption>no.</caption>
                    </detail>
                </xsl:if>

                <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub'][1]"/>
                <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']" >
                    <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']/year" >
                        <text type="year">
                            <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='ppub']/year" />
                        </text>
                    </xsl:if>
                    <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']/month and not(normalize-space(/article/front/article-meta/pub-date[@pub-type='ppub']/month)='')" >
                        <text type="month">
                            <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='ppub']/month" />
                        </text>
                    </xsl:if>
                    <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']/day and not(normalize-space(/article/front/article-meta/pub-date[@pub-type='ppub']/day)='')" >
                        <text type="day">
                            <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='ppub']/day" />
                        </text>
                    </xsl:if>
                    <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']/season" >
                        <text type="season">
                            <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='ppub']/season" />
                        </text>
                    </xsl:if>
                </xsl:if>


                <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']/string-date" >
                    <text type="display-date">
                        <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='ppub']/string-date" />
                    </text>
                </xsl:if>

                <xsl:if test="/article/front/article-meta/fpage" >
                    <extent unit="pages">
                        <start>
                            <xsl:value-of select="/article/front/article-meta/fpage" />
                        </start>

                        <xsl:if test="/article/front/article-meta/lpage" >
                            <end>
                                <xsl:value-of select="/article/front/article-meta/lpage" />
                            </end>
                        </xsl:if>
                    </extent>
                </xsl:if>
                <xsl:if test="/article/front/article-meta/counts/page-count/@count" >
                    <extent unit="pages">
                    <total>
                        <xsl:value-of select="normalize-space(/article/front/article-meta/counts/page-count/@count)" />
                    </total>   
                    </extent>
                </xsl:if>
            </part>
        </relatedItem>
        </xsl:template>

    <xsl:template match="article-meta">
        <part>
            <xsl:if test="/article/front/article-meta/volume" >
                <detail type="volume">
                    <number>
                        <xsl:value-of select="/article/front/article-meta/volume" />
                    </number>
                    <caption>v.</caption>
                </detail>
            </xsl:if>


            <!-- make sure issue exists and isn't empty  -->

            <xsl:if test="/article/front/article-meta/issue and not(normalize-space(/article/front/article-meta/issue)='')">
                <detail type="issue">
                    <number>
                        <xsl:value-of select="/article/front/article-meta/issue" />
                    </number>
                    <caption>no.</caption>
                </detail>
            </xsl:if>

            <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub'][1]"/>
            <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']" >
                <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']/year" >
                    <text type="year">
                        <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='ppub']/year" />
                    </text>
                </xsl:if>
                <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']/month and not(normalize-space(/article/front/article-meta/pub-date[@pub-type='ppub']/month)='')" >
                    <text type="month">
                        <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='ppub']/month" />
                    </text>
                </xsl:if>
                <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']/day and not(normalize-space(/article/front/article-meta/pub-date[@pub-type='ppub']/day)='')" >
                    <text type="day">
                        <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='ppub']/day" />
                    </text>
                </xsl:if>
                <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']/season" >
                    <text type="season">
                        <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='ppub']/season" />
                    </text>
                </xsl:if>
            </xsl:if>


            <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']/string-date" >
                <text type="display-date">
                    <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='ppub']/string-date" />
                </text>
            </xsl:if>

            <xsl:if test="/article/front/article-meta/fpage" >
                <extent unit="pages">
                    <start>
                        <xsl:value-of select="/article/front/article-meta/fpage" />
                    </start>

                    <xsl:if test="/article/front/article-meta/lpage" >
                        <end>
                            <xsl:value-of select="/article/front/article-meta/lpage" />
                        </end>
                    </xsl:if>
                </extent>
            </xsl:if>
        </part>
    </xsl:template>

    <!-- DOI   -->

    <xsl:template match="article-id[@pub-id-type]">

        <xsl:if test="@pub-id-type='doi'">
            <identifier type="doi">
                <xsl:value-of select="." />
            </identifier>
            <location>
                <url><xsl:text>http://dx.doi.org/</xsl:text><xsl:value-of select="." /></url>
            </location>
        </xsl:if>
        
        <xsl:if test="@pub-id-type='pii'">
            <identifier type="pii">
                <xsl:value-of select="." />
            </identifier>
        </xsl:if>
        
        <xsl:if test="@pub-id-type='publisher-id'">
            <identifier type="publisher-id">
                <xsl:value-of select="." />
            </identifier>
        </xsl:if>

        <!-- URL identifier   -->
        <xsl:if test="@pub-id-type='url'">
            <identifier type="url">
                <xsl:value-of select="." />
            </identifier>
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
            <!-- PDF copies of the files. -->
            <xsl:for-each select="/article/front/article-meta/custom-meta-group/custom-meta/meta-value">
                <fileLocation note="nonpublic" usage="primary">
                    <xsl:text>file://</xsl:text>
                    <xsl:value-of select="."/>
                </fileLocation>
            </xsl:for-each>
        </extension>
    </xsl:template>


</xsl:stylesheet>
