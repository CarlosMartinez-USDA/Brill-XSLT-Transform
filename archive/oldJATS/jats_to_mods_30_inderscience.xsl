<?xml version="1.0" encoding="utf-8"?>
<!--    
        File name: 
        jats_to_mods-Inderscience.xsl
        
        Created by: 
        Carlos Martinez III, NAL Metadata Librarian, 8/28/2016
        revised 20160824
        
        Description: 
        This transformation is a revised version of the jats_to_mods30.xsl transformation.  
        jats_to_mods30 is a transformation was created to meet system specificities at NAL, and thus is intended for local use
        for indexing and UI display in NAL's Fedora-based Digital Repository. 
        
        This XSLT transforms metadata received from the Inderscience using the Journal Archiving and Interchange Tag Set, otherwise known as JATS to NAL's customized MODS XML record format.  
        This faciliates acceess to digital content within NAL's Digital Repository. Each resulting file is ingested to its corresponding FOXML and use in NLM's Fedora-based digital 
        repository.  
        
        This tranformation serves to transform metadata that is delievered in PubMed citiation format into serial at the article level. 
               
        Other information: Using MODS 3.6 as of 20160808
        
        Revision History: 
            Added code to call the extension template 8-1-2013 
            Added code to Abstract for superscript/subscript 8-1-2013
            Fixed <relatedItem> to include all journal information 8-7-2013
            Added one more identifier for the default ISSN 8-28-2013 
            Added code to remove the white space in "given" names 9-3-2013
            Added code to fix superscript problem in the author affiliation 9-13-2013
            Changed Personal name: added primary usage to first author and added displayForm element 2014-07-03 CWS
            Changed file paths and corrected 
            Added code to create DOI identifier from publisher URL; added code for articles with pubtype='pub' 2016-09-12 jgg
            
    -->


<!-- Header -->
<xsl:stylesheet version="2.0" xmlns="http://www.loc.gov/mods/v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" >
    <xsl:output method="xml" indent="yes" encoding="UTF-8" />
    <!-- Pulls in source information such as Vendor and source file name -->
    <!-- Parameters -->
    <xsl:param name="vendorName"/>
    <xsl:param name="archiveFile"/>
    <!-- Parameters -->

    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="x" />

    <!-- Root -->
    <xsl:template match="/">
       <mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.6" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-6.xsd">
            <xsl:apply-templates select="article/front/article-meta/title-group" />
            <xsl:apply-templates select="article/front/article-meta/contrib-group" />

            <!-- Default -->
            <typeOfResource>text</typeOfResource>

            <!-- CD  Need to check to see what they use besides 'Research Articles'  -->
           <!-- <xsl:apply-templates select="article/front/article-meta/article-categories" />  -->
            <xsl:apply-templates select="article" />

            <xsl:apply-templates select="article/front/article-meta/pub-date[@pub-type='ppub']" />
           <xsl:apply-templates select="article/front/article-meta/pub-date[@pub-type='pub']" />

            <!-- Default language -->
            <language>
                <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
                <languageTerm type="text">English</languageTerm>
            </language>

            <xsl:apply-templates select="article/front/article-meta/abstract" />
            <xsl:apply-templates select="article/front/article-meta/kwd-group" />
            <xsl:apply-templates select="article/front/journal-meta/journal-title-group" />
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
            <xsl:value-of select="normalize-space (string-name/given-names)" />
        </namePart>
        <namePart type="family">
            <xsl:value-of select="string-name/surname" />
        </namePart>
        <displayForm>
            <xsl:value-of select="string-name/surname" />
            <xsl:text>, </xsl:text>
            <xsl:value-of select="normalize-space (string-name/given-names)" />
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


    <!-- Genre  -->
    <xsl:template match="article">
        <xsl:if test="@article-type='research-article'">
            <genre>article</genre>
        </xsl:if>
    </xsl:template>

    <!-- Date issued  -->
    <xsl:template match="pub-date[@pub-type='ppub']">
    
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
        <xsl:template match="pub-date[@pub-type='pub']">
   
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
        <xsl:for-each select=".">
            <abstract>
                <xsl:variable name="abstract" select="."/>
                <xsl:variable name="this"><xsl:apply-templates/></xsl:variable>
                <xsl:value-of select="normalize-space($this)"></xsl:value-of>
            </abstract>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="abstract//text()">
        <xsl:value-of select="." /><xsl:text> </xsl:text>
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
                <xsl:value-of select="/article/front/journal-meta/journal-id[@journal-id-type='publisher-id' or @journal-id-type='publisher']" />
            </identifier>
            
            <xsl:if test="/article/front/article-meta/article-id[@pub-id-type='pmid']">
                <identifier type="pmid">
                    <xsl:value-of select="/article/front/article-meta/article-id[@pub-id-type='pmid']"/>
                </identifier>
            </xsl:if>
  
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
                
                <xsl:if test="/article/front/article-meta/pub-date[@pub-type='pub']" >
                    <xsl:if test="/article/front/article-meta/pub-date[@pub-type='pub']/year" >
                        <text type="year">
                            <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='pub']/year" />
                        </text>
                    </xsl:if>
                    <xsl:if test="/article/front/article-meta/pub-date[@pub-type='pub']/month and not(normalize-space(/article/front/article-meta/pub-date[@pub-type='pub']/month)='')" >
                        <text type="month">
                            <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='pub']/month" />
                        </text>
                    </xsl:if>
                    <xsl:if test="/article/front/article-meta/pub-date[@pub-type='pub']/day and not(normalize-space(/article/front/article-meta/pub-date[@pub-type='pub']/day)='')" >
                        <text type="day">
                            <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='pub']/day" />
                        </text>
                    </xsl:if>
                    <xsl:if test="/article/front/article-meta/pub-date[@pub-type='pub']/season" >
                        <text type="season">
                            <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='pub']/season" />
                        </text>
                    </xsl:if>
                </xsl:if>
                <xsl:if test="/article/front/article-meta/pub-date[@pub-type='pub']/string-date" >
                    <text type="display-date">
                        <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='pub']/string-date" />
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

        <!-- URL identifier   -->
        <xsl:if test="@pub-id-type='url'"> 
            <xsl:variable name="s1" select="'http://www.inderscienceonline.com/doi/'"/>
            <xsl:variable name="s2" select="substring-after(., $s1)"/>
            <identifier type="doi">
                <xsl:value-of select="$s2" />
            </identifier>
            <location>
                <url>
                    <xsl:value-of select="."/>
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
        </extension>
    </xsl:template>


</xsl:stylesheet>
