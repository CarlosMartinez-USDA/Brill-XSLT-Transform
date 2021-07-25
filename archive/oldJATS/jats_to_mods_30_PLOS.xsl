<?xml version="1.0" encoding="utf-8"?>
<!-- Added code to call the extension template 8-1-2013 -->
<!-- Added code to Abstract for superscript/subscript 8-1-2013 -->
<!-- Fixed <relatedItem> to include all journal information 8-7-2013 -->
<!-- Added one more identifier for the default ISSN 8-28-2013 -->
<!-- Added code to remove the white space in "given" names 9-3-2013 -->
<!-- Added code to fix superscript problem in the author affiliation 9-13-2013 -->
<!-- Changed ppub to epub, added elocation-id, changed string-name to name 3-19-2014  -->
<!-- Added code for alternative title; changed author affiliation code 4-1-2014  -->
<!-- Changed extension to test for PDF 2-19-2015  -->
<!-- Added extension note, displayForm and primary author usage. Fixed code for alternative title 2-20-2015  -->
<!-- Added Funding note, fixed pub-date, added accessCondition for open access license. 3-24-2015  -->
<!-- Fixed pub-date, for real. 8-12-2015  -->

<!-- Header -->
<xsl:stylesheet version="2.0" xmlns="http://www.loc.gov/mods/v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" >
    <xsl:output method="xml" indent="yes" encoding="UTF-8" />
    <!-- Parameters -->
    <xsl:param name="vendorName"/>
    <xsl:param name="archiveFile"/>
    <!-- Parameters -->


    <!-- Pulls in source information such as Vendor and source file name -->
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="x" />

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

            <xsl:apply-templates select="article/front/article-meta/pub-date[@pub-type='epub'][1]" />

            <!-- Default language -->
            <language>
                <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
                <languageTerm type="text">English</languageTerm>
            </language>

            <xsl:apply-templates select="article/front/article-meta/abstract" />
            <xsl:apply-templates select="article/front/article-meta/funding-group" />
            <xsl:apply-templates select="article/front/article-meta/counts" />
            <xsl:apply-templates select="article/front/article-meta/kwd-group" />
            <xsl:apply-templates select="article/front/journal-meta/journal-title-group" />
            <xsl:apply-templates select="article/front/article-meta/article-id[@pub-id-type]" />
            <xsl:apply-templates select="article/front/article-meta/elocation-id" />
            <xsl:apply-templates select="article/front/article-meta/permissions" />     
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
<subTitle>
    <xsl:value-of select="subtitle" /></subTitle>
                </xsl:if>
            </titleInfo>
                <titleInfo type="alternative">
                <title>
                    <xsl:value-of select="normalize-space(alt-title)"/>
                </title>
            </titleInfo>
       </xsl:template>

    <!-- Authors  -->
    <xsl:template match="contrib-group">
        <xsl:for-each select="contrib[@contrib-type='author']|contrib[@contrib-type='editor']|xlink[@type='simple']">
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

<!-- Use id to get affiliation -->
              <xsl:variable name="affid" select="xref[@ref-type='aff']/@rid" />
              <xsl:if test="$affid">
                  <xsl:for-each select="/article/front/article-meta/aff[@id=$affid]">
                      <affiliation>
                          <!--<xsl:apply-templates select="./affiliation" />-->
                          <xsl:value-of select="text()"/>
                          <xsl:for-each select="addr-line"><xsl:value-of select="text()"/></xsl:for-each>
                          <xsl:for-each select="country"><xsl:value-of select="text()"/></xsl:for-each>
                          <xsl:for-each select="institution"><xsl:value-of select="text()"/></xsl:for-each>
                          <xsl:for-each select="institution-wrap"><xsl:value-of select="text()"/></xsl:for-each>
                      </affiliation>
                  </xsl:for-each>
              </xsl:if>

              <role>
                  <roleTerm type="text">
                      <xsl:choose>
                          <xsl:when test="role">
                       <xsl:value-of select="./role" />
                          </xsl:when>
                      <xsl:otherwise>
                              <xsl:text>author</xsl:text>
                      </xsl:otherwise>
                      </xsl:choose>
                  </roleTerm>
              </role>
    </xsl:template>

    <!-- An empty template to exclude the superscript from displaying in the affiliation text string -->
       <xsl:template match="affiliation">
            <xsl:value-of select="text()"/>
    </xsl:template>
    <xsl:template match="sup" mode="affiliation"/>


    <!-- Genre  -->
    <xsl:template match="article">
        <xsl:if test="@article-type='research-article'">
            <genre>article</genre>
        </xsl:if>
    </xsl:template>

    <!-- Date issued  -->
    <xsl:template match="pub-date[@pub-type='epub'][1]">
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
               <xsl:when test="@abstract-type='toc'">
                   <!-- Do nothing if abstracts are table of contents-->
               </xsl:when>
               <xsl:when test="@abstract-type='summary'">
                   <!-- Do nothing if abstracts are summaries-->
               </xsl:when>
   <xsl:otherwise>
       <abstract>
           <xsl:variable name="abstract">
               <xsl:for-each select="descendant-or-self::*/text()">
                   <xsl:choose>
                       <xsl:when test="ancestor::title"></xsl:when>
                       <xsl:otherwise><xsl:value-of select="."/><xsl:text> </xsl:text></xsl:otherwise>
                   </xsl:choose>
               </xsl:for-each>
           </xsl:variable>
           <xsl:value-of select="normalize-space($abstract)"></xsl:value-of>
         </abstract>
   </xsl:otherwise>
           </xsl:choose>
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

<xsl:template match="funding-group">
    <xsl:if test="funding-statement">
        <note type="funding">
            <xsl:value-of select="funding-statement" />
        </note>
    </xsl:if>
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
    <xsl:template match="journal-title-group">
        <relatedItem type="host">
            <titleInfo>
                <title>
                    <xsl:value-of select="normalize-space(journal-title)" />
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
                            <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='epub']/year" />
                        </text>
                    </xsl:if>
                    <xsl:if test="/article/front/article-meta/pub-date[@pub-type='epub']/month and not(normalize-space(/article/front/article-meta/pub-date[@pub-type='epub']/month)='')" >
                        <text type="month">
                            <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='epub']/month" />
                        </text>
                    </xsl:if>
                  <xsl:if test="/article/front/article-meta/pub-date[@pub-type='epub']/day and not(normalize-space(/article/front/article-meta/pub-date[@pub-type='epub']/day)='')" >
                        <text type="day">
                            <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='epub']/day" />
                        </text>
                    </xsl:if>
                    <xsl:if test="/article/front/article-meta/pub-date[@pub-type='epub']/season" >
                        <text type="season">
                            <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='epub']/season" />
                        </text>
                    </xsl:if>
                </xsl:if>
                <xsl:if test="/article/front/article-meta/pub-date[@pub-type='epub']/string-date" >
                    <text type="display-date">
                        <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='epub']/string-date" />
                    </text>
                </xsl:if> 
                <xsl:if test="/article/front/article-meta/pub-date[@pub-type='collection'] and not(/article/front/article-meta/pub-date[@pub-type='epub']/year)" >
                    <xsl:if test="/article/front/article-meta/pub-date[@pub-type='collection']/year" >
                        <text type="year">
                            <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='collection']/year" />
                        </text>
                    </xsl:if> 
                    <xsl:if test="/article/front/article-meta/pub-date[@pub-type='collection']/month and not(normalize-space(/article/front/article-meta/pub-date[@pub-type='collection']/month)='')" >
                        <text type="month">
                            <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='collection']/month" />
                        </text>
                    </xsl:if>

                <xsl:if test="/article/front/article-meta/counts/page-count/@count" >
                    <extent unit="pages">
                        <total>
                            <xsl:value-of select="/article/front/article-meta/counts/page-count/@count" />
                        </total>
                    </extent>


    <!--            <xsl:if test="/article/front/article-meta/fpage" >
                    <extent unit="pages">
                        <start>
                            <xsl:value-of select="/article/front/article-meta/fpage" />
                        </start>

                        <xsl:if test="/article/front/article-meta/lpage" >
                            <end>
                                <xsl:value-of select="/article/front/article-meta/lpage" />
                            </end>
                        </xsl:if>
                    </extent> -->
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

    <!-- elocation-id     -->
    <xsl:template match="article/front/article-meta/elocation-id">
        <identifier type="elocation-id">
         <xsl:value-of select="/article/front/article-meta/elocation-id" />
        </identifier>
      </xsl:template>
    
    <!-- license info     -->
    <xsl:template match="permissions">
        <xsl:if test="license/license-p">
            <accessCondition type="use and reproduction">
                <xsl:value-of select="license/license-p" />
            </accessCondition>
        </xsl:if>
    </xsl:template>


  <!-- name of related pdf file CD NEED TO ADD CHOOSE one or the other
           changed to test for presence of a PDF JG 2015-02-19 -->

        <xsl:template match="related-article" >
              <xsl:if test="related-article[@related-article-type='pdf']"/>
                   <extension>
                      <file type="pdf">
                        <xsl:value-of select="@xlink:href"/>
                      </file>
                   </extension>
        </xsl:template>

         <xsl:template match="self-uri" >
                <xsl:if test="self-uri[@content-type='pdf']"/>
                <extension>
                    <file type="pdf">
                        <xsl:value-of select="@xlink:href"/>
                    </file>
                </extension>

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
            <note type="note">Includes JATS article full-text content.</note>
        </extension>
    </xsl:template>

</xsl:stylesheet>
