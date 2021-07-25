<?xml version="1.0" encoding="utf-8"?>

<!-- Added code to call the extension template 8-1-2013 -->
<!-- Added code to Abstract for superscript/subscript 8-1-2013 -->
<!-- Added new code for author affiliation 8-14-2013 -->
<!-- Added code for identifer type issn-p and issn-e 8-14-2013 -->
<!-- Added code for PDF copies of files 9-6-2012 -->
<!-- Added XHTML namespace 9-16-2013 -->
<!-- Added if-else statement to identifier issn and changed coding for PDF file 9-17-2013 -->
<!-- Changed Extension, added URL note 9-17-2013 -->
<!-- Changed Extension, move URL access information from note to usage attribute -->
<!-- Changed Personal name: added primary usage to first author and added displayForm element 2014-07-03 CWS -->
<!-- Fixed affiliation; added copyright year when pubdate is missing 2016-01-21 JG -->
<!-- Removed "ABSTRACT:" or "ABSTRACT" from beginning of abstract; added tests for copyright-year; fixed missing host titles 2016-02-26 jg --> 
<!-- Fixed pub-date 2016-03-04 jg -->
<!-- Added publisher URL when DOI is missing 2016-03-22 jg -->

<!-- Header -->
<xsl:stylesheet version="2.0" xmlns="http://www.loc.gov/mods/v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xhtml="http://www.w3.org/1999/xhtml/" >
    <xsl:output method="xml" indent="yes" encoding="UTF-8" />

    <!-- Pulls in source information such as Vendor and source file name -->
    <!-- Parameters -->
    <xsl:param name="vendorName"/>
    <xsl:param name="archiveFile"/>
    <!-- Parameters -->

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

            <xsl:apply-templates select="article/front/article-meta/pub-date[@pub-type='ppub']" />
            <xsl:apply-templates select="article/front/article-meta/copyright-year" />
            <xsl:apply-templates select="article/front/article-meta/permissions/copyright-year" />

            <!-- Default language -->
            <language>
                <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
                <languageTerm type="text">English</languageTerm>
            </language>

            <xsl:apply-templates select="article/front/article-meta/abstract" />
            <xsl:apply-templates select="article/front/article-meta/kwd-group" />
            <xsl:apply-templates select="article/front/journal-meta" />
            <xsl:apply-templates select="article/front/article-meta/article-id[@pub-id-type]" />
            <xsl:apply-templates select="article/front/article-meta/related-article" />
            <xsl:apply-templates select="article/front/article-meta/self-uri" />
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
              <namePart type="family">
                  <xsl:value-of select="name/surname" />
              </namePart>
              <namePart type="given">
                <xsl:value-of select="name/given-names" />
            </namePart>
         <displayForm>
             <xsl:value-of select="name/surname" />
             <xsl:text>, </xsl:text>
             <xsl:value-of select="name/given-names" />
         </displayForm>
             
         <!-- Use id to get affiliation  -->
         <xsl:variable name="affid" select="xref[@ref-type='aff']/@rid"/>
             <xsl:if test="$affid">
                 <xsl:for-each select="//aff[@id=$affid]">
                     <affiliation>
                         <xsl:apply-templates mode="affiliation"/>
                     </affiliation>
                 </xsl:for-each>
             </xsl:if>  
              <role>
                  <roleTerm type="text">author</roleTerm>
              </role>
    </xsl:template>
    <xsl:template match="sup | label" mode="affiliation">
        <!-- Do nothing, don't want to copy this. -->
    </xsl:template>

    <!-- Genre  -->
    <xsl:template match="article">
        <xsl:if test="@article-type='research-article' or 'Article'">
            <genre>article</genre>
        </xsl:if>
    </xsl:template>

    <!-- Date issued  -->
    <xsl:template match="pub-date[@pub-type='ppub']">
        <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']">
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
        </xsl:if>
   </xsl:template>
    
  <!-- Added copyright year when pub date is missing -->
    <xsl:template match="copyright-year">
        <xsl:if test="not(/article/front/article-meta/pub-date[@pub-type='ppub'])"> 
            <xsl:if test="/article/front/article-meta/copyright-year">
            <originInfo>
                <dateIssued encoding="w3cdtf" keyDate="yes">
                    <xsl:value-of select="/article/front/article-meta/copyright-year"/>
                </dateIssued>
            </originInfo>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="permissions/copyright-year">
        <xsl:if test="not(/article/front/article-meta/pub-date[@pub-type='ppub'])"> 
            <xsl:if test="/article/front/article-meta/permissions/copyright-year">
                <originInfo>
                    <dateIssued encoding="w3cdtf" keyDate="yes">
                        <xsl:value-of select="/article/front/article-meta/permissions/copyright-year"/>
                    </dateIssued>
                </originInfo>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <!-- Abstract -->
    <!-- Publisher cleanup program should remove "ABSTRACT:" or "ABSTRACT" from beginning of abstract; also remove (title 'Abstract'), (title 'ABSTRACT'), (title 'Summary'), or (title 'SUMMARY') -->
    <!-- eliminate foreign language abstracts; include records with empty abstract title fields  -->

    <xsl:template match="abstract">
        <abstract>
            <xsl:apply-templates select="node()|*"/>
        </abstract>
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

        <xsl:when test="contains(title,'Key words') or contains(title,'Keywords') or contains(title,'KEY WORDS') or contains(title,'KEYWORDS')" >
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

           <xsl:when test="@xml:lang='fr' or @xml:lang='es' or @xml:lang='de'">
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
            <xsl:if test="journal-title-group/journal-title">
            <titleInfo>
                <title>
                    <xsl:value-of select="normalize-space(journal-title-group/journal-title)" />
                </title>
            </titleInfo>
            </xsl:if>
            <xsl:if test="journal-title">
                <titleInfo>
                    <title>
                        <xsl:value-of select="normalize-space(journal-title)" />
                    </title>
                </titleInfo>
            </xsl:if>
       <xsl:if test="(normalize-space(publisher/publisher-name)!='')" >
        <originInfo>
            <publisher>
                <xsl:value-of select="normalize-space(publisher/publisher-name)" />
            </publisher>
        </originInfo>
        </xsl:if>
            <xsl:if test="/article/front/journal-meta/issn[@pub-type='ppub']">
                <identifier type="issn-p">
                    <xsl:value-of select="/article/front/journal-meta/issn[@pub-type='ppub']" />
                </identifier>
            </xsl:if>
            <xsl:if test="/article/front/journal-meta/issn[@pub-type='epub']">
                <identifier type="issn-e">
                    <xsl:value-of select="/article/front/journal-meta/issn[@pub-type='epub']" />
                </identifier>
            </xsl:if>
       <identifier type="issn">
           <xsl:choose>
                <xsl:when test="/article/front/journal-meta/issn[@pub-type='epub']" >
               <xsl:value-of select="/article/front/journal-meta/issn[@pub-type='epub']" />
                </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="/article/front/journal-meta/issn[@pub-type='ppub']" />
              </xsl:otherwise>
           </xsl:choose>
            </identifier>

        <identifier type="vendor">
            <xsl:value-of select="journal-id[@journal-id-type='publisher-id']" />
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
                         <xsl:value-of select="/article/front/article-meta/counts/page-count/@count" />
                     </total>
                 </extent>
             </xsl:if>

             <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']" >
                 <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']/year" >
                     <text type="year">
                         <xsl:for-each-group select="/article/front/article-meta/pub-date[@pub-type='ppub']/year"
                             group-by="concat(year,'|',month,'|',day,'|',season)">
                             <xsl:apply-templates select="."/>
                         </xsl:for-each-group>
                     </text>
                 </xsl:if>

                 <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']/month" >
                     <text type="month">
                         <xsl:for-each-group select="/article/front/article-meta/pub-date[@pub-type='ppub']/month"
                             group-by="concat(year,'|',month,'|',day,'|',season)">
                             <xsl:apply-templates select="."/>
                         </xsl:for-each-group>
                     </text>
                 </xsl:if>

                 <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']/day" >
                     <text type="day">
                         <xsl:for-each-group select="/article/front/article-meta/pub-date[@pub-type='ppub']/day"
                             group-by="concat(year,'|',month,'|',day,'|',season)">
                             <xsl:apply-templates select="."/>
                         </xsl:for-each-group>
                     </text>
                 </xsl:if>

                 <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']/season" >
                     <text type="day">
                         <xsl:for-each-group select="/article/front/article-meta/pub-date[@pub-type='ppub']/season"
                             group-by="concat(year,'|',month,'|',day,'|',season)">
                             <xsl:apply-templates select="."/>
                         </xsl:for-each-group>
                     </text>
                 </xsl:if>
             </xsl:if>
             <!-- Added copyright year when pubdate is missing. -->
             <xsl:if test="not(/article/front/article-meta/pub-date[@pub-type='ppub'])" >
                 <xsl:if test="/article/front/article-meta/permissions/copyright-year">
                 <text type="year">
                     <xsl:value-of select="/article/front/article-meta/permissions/copyright-year"/>
                 </text>
             </xsl:if>
                 <xsl:if test="/article/front/article-meta/copyright-year">
                     <text type="year">
                     <xsl:value-of select="/article/front/article-meta/copyright-year"/> 
                     </text>
                 </xsl:if>
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
                <url><xsl:text>http://dx.doi.org/</xsl:text><xsl:value-of select="encode-for-uri(.)" /></url>
            </location>
        </xsl:if>

        <!-- URL identifier   -->
        <xsl:if test="@pub-id-type='url'">
            <identifier type="url">
                <xsl:value-of select="." />
            </identifier>
        </xsl:if>
        <xsl:if test="@pub-id-type='url' and @pub-id-type='publisher-id'">
            <location>
                <url>
                    <xsl:value-of select="@pub-id-type='url'"/>    
                </url>
            </location>
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
            <xsl:for-each select="/article/front/article-meta/related-article[@related-article-type='pdf']">
                <fileLocation note="nonpublic" usage="primary">
                    <xsl:text>file://</xsl:text>
                    <xsl:value-of select="@xlink:href"/>
                </fileLocation>
            </xsl:for-each>

        </extension>
    </xsl:template>

</xsl:stylesheet>
