<?xml version="1.0" encoding="utf-8"?>
<!-- Added code to call the extension template 8-1-2013 -->
<!-- Added code to Abstract for superscript/subscript 8-1-2013 -->
<!-- Fixed <relatedItem> to include all journal information 8-7-2013 -->
<!-- Added one more identifier for the default ISSN 8-28-2013 -->
<!-- Added code to remove the white space in "given" names 9-3-2013 -->
<!-- Added code to fix superscript problem in the author affiliation 9-13-2013 -->
<!-- Changed Personal name: added primary usage to first author and added displayForm element 2014-07-03 CWS -->
<!-- Fix date handling, abbreviated journal titles 2016-01-14 JG -->
<!--  Added missing host titles and ISSN; added language tests for abstracts 2016-02-08 JG -->

<!-- Header -->
<xsl:stylesheet version="2.0" xmlns="http://www.loc.gov/mods/v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="http://whatever"   exclude-result-prefixes="local">
    <xsl:output method="xml" indent="yes" encoding="UTF-8" />
    <!-- Pulls in source information such as Vendor and source file name -->
    <!-- Parameters -->
    <xsl:param name="vendorName"/>
    <xsl:param name="archiveFile"/>
    <!-- Parameters -->

    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="abstract" />
    
    <!-- Function -->
    <xsl:function name="local:to_month">
        <xsl:param name="inString"/>        
        <xsl:variable name="myMonth3" select="upper-case(substring(normalize-space($inString), 0, 4))"/>
        <xsl:variable name="myMonth" select="number($inString)"/> 
        <xsl:choose>
            <xsl:when test="$myMonth gt 0 and $myMonth lt 13"><xsl:value-of select="$myMonth"/></xsl:when>
            <xsl:when test="$myMonth3 eq 'JAN'">1</xsl:when>
            <xsl:when test="$myMonth3 eq 'FEB'">2</xsl:when>
            <xsl:when test="$myMonth3 eq 'MAR'">3</xsl:when>
            <xsl:when test="$myMonth3 eq 'APR'">4</xsl:when>
            <xsl:when test="$myMonth3 eq 'MAY'">5</xsl:when>
            <xsl:when test="$myMonth3 eq 'JUN'">6</xsl:when>
            <xsl:when test="$myMonth3 eq 'JUL'">7</xsl:when>
            <xsl:when test="$myMonth3 eq 'AUG'">8</xsl:when>
            <xsl:when test="$myMonth3 eq 'SEP'">9</xsl:when>
            <xsl:when test="$myMonth3 eq 'OCT'">10</xsl:when>
            <xsl:when test="$myMonth3 eq 'NOV'">11</xsl:when>
            <xsl:when test="$myMonth3 eq 'DEC'">12</xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <!-- Function -->

    <!-- Root -->
    <xsl:template match="/">
       <mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.5" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
            <xsl:apply-templates select="article/front/article-meta/title-group" />
            <xsl:apply-templates select="article/front/article-meta/contrib-group" />

            <!-- Default -->
            <typeOfResource>text</typeOfResource>
            <genre>article</genre>

           <xsl:apply-templates select="article/front/article-meta/pub-date" />

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
        <xsl:for-each select="contrib[@contrib-type='author']">
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
            <xsl:for-each select="../aff[@id=$affid]">
                <affiliation>
                    <xsl:apply-templates mode="affiliation"/>
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
    <xsl:template match="sup" mode="affiliation"/>

    <!-- Date issued  -->
    
    <xsl:template match="pub-date">
        <xsl:choose>
            <xsl:when test="@pub-type='epub'">
                <xsl:call-template name="My-issue-date"/>
            </xsl:when>
            <xsl:when test="@pub-type='ppub'">
                <xsl:if test="not(/article/front/article-meta/pub-date[@pub-type='epub']/year)" >
                    <xsl:call-template name="My-issue-date"/>
                </xsl:if>
            </xsl:when>
        </xsl:choose>        
    </xsl:template>
    
    <xsl:template name="My-issue-date">
        <xsl:variable name="my_year" select="number(year)" as="xs:double"/>
        <xsl:variable name="my_month" select="local:to_month(month)" as="xs:double"/>
        <xsl:variable name="my_day" select="number(day)" as="xs:double"/>
        
        <xsl:if test="$my_year gt 0">
            <!-- Building w3ctf date -->
            <originInfo>
                <dateIssued encoding="w3cdtf" keyDate="yes">
                    <xsl:value-of select="format-number( $my_year, '0000')"/>
                    <xsl:if test="$my_month gt 0">
                        <xsl:value-of select="format-number($my_month, '-00' )"/>
                        <xsl:if test="$my_day gt 0 and $my_day lt 32">
                            <xsl:value-of select="format-number( $my_day, '-00' )"/>
                        </xsl:if>
                    </xsl:if>
                </dateIssued>
            </originInfo>
        </xsl:if>
        
    </xsl:template>
    <!-- Abstract -->
    <!-- Publisher cleanup program should remove "ABSTRACT:" or "ABSTRACT" from beginning of abstract; also remove (title 'Abstract'), (title 'ABSTRACT'), (title 'Summary'), or (title 'SUMMARY') -->
    <!-- eliminate foreign language abstracts; include records with empty abstract title fields  -->

    <xsl:template match="abstract">
        <xsl:choose>
            <xsl:when test="@xml:lang='en'">
                <xsl:for-each select=".">
                    <abstract xml:lang='en'>
                        <xsl:variable name="abstract" select="."/>
                        <xsl:variable name="this"><xsl:apply-templates/></xsl:variable>
                        <xsl:value-of select="normalize-space($this)"></xsl:value-of>
                    </abstract>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="@xml:lang='fr' or @xml:lang='es' or @xml:lang='de' or @xml:lang='hr'">
                <!-- Do nothing -->
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
    
  <!-- Remove to exclude title from abstract -->
 <!--   <xsl:template match="abstract//text()">
        <xsl:value-of select="." />
    </xsl:template>  -->
    
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

           <xsl:when test="@xml:lang='fr' or @xml:lang='es' or @xml:lang='de' or @xml:lang='hr'">
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
            <xsl:if test="journal-title-group">
            <titleInfo>
                <title>
                    <xsl:value-of select="normalize-space(journal-title-group/journal-title|journal-title-group/abbrev-journal-title)" />
                </title>
                <xsl:if test="journal-subtitle!=''">
                    <subTitle><xsl:value-of select="journal-subtitle" /></subTitle>
                </xsl:if>
            </titleInfo>
            </xsl:if>
            <xsl:if test="not(journal-title-group)">
                <titleInfo>
                    <title>
                        <xsl:value-of select="normalize-space(journal-title|abbrev-journal-title)" />
                    </title>
                    <xsl:if test="journal-subtitle!=''">
                        <subTitle><xsl:value-of select="journal-subtitle" /></subTitle>
                    </xsl:if>
                </titleInfo>
            </xsl:if>
            <originInfo>
                <publisher>
                    <xsl:value-of select="normalize-space(/article/front/journal-meta/publisher/publisher-name)" />
                </publisher>
            </originInfo>
            <xsl:if test="/article/front/journal-meta/issn[@pub-type='ppub'] and not(/article/front/journal-meta/issn[@pub-type='ppub']='')">
            <identifier type="issn-p">
                <xsl:value-of select="/article/front/journal-meta/issn[@pub-type='ppub']" />
            </identifier>
            </xsl:if>
            <xsl:if test="/article/front/journal-meta/issn[@pub-type='epub'] and not(/article/front/journal-meta/issn[@pub-type='epub']='')">
            <identifier type="issn-e">
                <xsl:value-of select="/article/front/journal-meta/issn[@pub-type='epub']" />
            </identifier>
            </xsl:if>
            <identifier type="issn">
                <xsl:choose>
                    <xsl:when test="/article/front/journal-meta/issn[@pub-type='epub'] and not(/article/front/journal-meta/issn[@pub-type='epub']='')" >
                        <xsl:value-of select="/article/front/journal-meta/issn[@pub-type='epub']" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="/article/front/journal-meta/issn[@pub-type='ppub']" />
                    </xsl:otherwise>
                </xsl:choose>
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

       
                <xsl:if test="/article/front/article-meta/pub-date[@pub-type='epub']" >
                    <xsl:if test="/article/front/article-meta/pub-date[@pub-type='epub']/year" >
                        <text type="year">
                            <xsl:for-each-group select="/article/front/article-meta/pub-date[@pub-type='epub']/year"
                                group-by="concat(year,'|',month,'|',day,'|',season)">
                                <xsl:call-template name="normalizeSpace"/>
                            </xsl:for-each-group>
                        </text>
                    </xsl:if>
                </xsl:if>
                <xsl:if test="not(/article/front/article-meta/pub-date[@pub-type='epub'])" >
                    <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']/year" >
                        <text type="year">
                            <xsl:for-each-group select="/article/front/article-meta/pub-date[@pub-type='ppub']/year"
                                group-by="concat(year,'|',month,'|',day,'|',season)">
                                <xsl:call-template name="normalizeSpace"/>
                            </xsl:for-each-group>
                        </text>
                    </xsl:if>
                </xsl:if>
                <xsl:if test="/article/front/article-meta/pub-date[@pub-type='epub']/month" >
                    <text type="month">
                        <xsl:for-each-group select="/article/front/article-meta/pub-date[@pub-type='epub']/month"
                            group-by="concat(year,'|',month,'|',day,'|',season)">
                            <xsl:call-template name="normalizeSpace"/>
                        </xsl:for-each-group>
                    </text>
                </xsl:if>
                <xsl:if test="not(/article/front/article-meta/pub-date[@pub-type='epub'])" >
                    <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']/month" >
                        <text type="month">
                            <xsl:for-each-group select="/article/front/article-meta/pub-date[@pub-type='ppub']/month"
                                group-by="concat(year,'|',month,'|',day,'|',season)">
                                <xsl:call-template name="normalizeSpace"/>
                            </xsl:for-each-group>
                        </text>
                    </xsl:if>
                </xsl:if>
                <xsl:if test="/article/front/article-meta/pub-date[@pub-type='epub']/day" >
                    <text type="day">
                        <xsl:for-each-group select="/article/front/article-meta/pub-date[@pub-type='epub']/day"
                            group-by="concat(year,'|',month,'|',day,'|',season)">
                            <xsl:call-template name="normalizeSpace"/>
                        </xsl:for-each-group>
                    </text>
                </xsl:if>
                <xsl:if test="not(/article/front/article-meta/pub-date[@pub-type='epub'])" >
                    <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']/day" >
                        <text type="day">
                            <xsl:for-each-group select="/article/front/article-meta/pub-date[@pub-type='ppub']/day"
                                group-by="concat(year,'|',month,'|',day,'|',season)">
                                <xsl:call-template name="normalizeSpace"/>
                            </xsl:for-each-group>
                        </text>
                    </xsl:if>
                </xsl:if>
                <xsl:if test="/article/front/article-meta/pub-date[@pub-type='epub']/season" >
                    <text type="day">
                        <xsl:for-each-group select="/article/front/article-meta/pub-date[@pub-type='epub']/season"
                            group-by="concat(year,'|',month,'|',day,'|',season)">
                            <xsl:call-template name="normalizeSpace"/>
                        </xsl:for-each-group>
                    </text>
                </xsl:if>
                <xsl:if test="not(/article/front/article-meta/pub-date[@pub-type='epub'])" >
                    <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']/season" >
                        <text type="day">
                            <xsl:for-each-group select="/article/front/article-meta/pub-date[@pub-type='ppub']/season"
                                group-by="concat(year,'|',month,'|',day,'|',season)">
                                <xsl:call-template name="normalizeSpace"/>
                            </xsl:for-each-group>
                        </text>
                    </xsl:if>
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
            <xsl:for-each select="/article/front/article-meta/self-uri[@content-type='pdf']">
                <fileLocation note="nonpublic" usage="primary">
                    <xsl:text>file://</xsl:text>
                    <xsl:value-of select="@xlink:href"/>
                </fileLocation>
            </xsl:for-each>
        </extension>
    </xsl:template>
    <xsl:template name="normalizeSpace">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>

</xsl:stylesheet>
