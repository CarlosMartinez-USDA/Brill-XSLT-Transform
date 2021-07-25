<?xml version="1.0" encoding="utf-8"?>

<!-- Header -->
<xsl:stylesheet version="2.0" xmlns="http://www.loc.gov/mods/v3" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" >
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

            <xsl:apply-templates select="article" />

            <xsl:apply-templates select="article/front/article-meta/pub-date[@pub-type='ppub']" />

            <!-- Default language -->
            <language>
                <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
                <languageTerm type="text">English</languageTerm>
            </language>

            <xsl:apply-templates select="article/front/article-meta/abstract" />
            <xsl:apply-templates select="article/front/article-meta/kwd-group" />
            <xsl:apply-templates select="article/front/journal-meta" />
            <xsl:apply-templates select="article/front/article-meta/article-id[@pub-id-type='doi']" />
            <xsl:apply-templates select="article/front/article-meta" />

    </mods>
</xsl:template>

<!--Article title-->
    <xsl:template match="title-group">
        <titleInfo>
            <title><xsl:apply-templates select="@*|node()[normalize-space()]" /></title>
             <xsl:if test="subtitle!=''">
                 <subTitle><xsl:value-of select="subtitle" /></subTitle>
             </xsl:if>
        </titleInfo>
    </xsl:template>
    <xsl:template match="xref/sup">
        <!-- Do nothing, don't want to copy this. -->
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
        <!-- affiliation matched by the reference super script character -->   
        <xsl:variable name="affid" select="xref[@ref-type='aff']/@rid" />
        <xsl:variable name="sups" select="xref[@ref-type='aff']//text()[matches(.,'^[0-9]+$') eq true()]" />  
        <!--affiliation in author element. both affid and superscript/label -->
        <xsl:choose>
            <xsl:when test="$affid and $sups">
                <xsl:for-each select="/article/front/article-meta/aff[@id=$affid]">
                    <!-- affiliation element -->
                    <xsl:variable name="affilSups" select=".//text()"/>
                    <affiliation>
                        <!--<xsl:call-template name="affiliation-work"/>-->
                        <xsl:for-each select="$sups">
                            <xsl:variable name="sup" select="."/>
                            <xsl:for-each select="$affilSups">
                                <xsl:variable name="thatAffilSup" select="."/>                  
                                <xsl:if test="$sup eq $thatAffilSup">
                                    <!-- for each affid match, for each author sup/label go through affiliation sup/label, if match ...-->
                                    <xsl:variable name="thatAffilSupSeq" select="index-of($affilSups,$thatAffilSup)"/>
                                    <!-- consider affiliation element as a sequence of components, find position of label --> 
                                    <xsl:variable name="thatAffilSupSeqWords" select="$thatAffilSupSeq + 1"/>
                                    <!-- get position of next item, the affiliation's words --> 
                                    <xsl:value-of select="$affilSups[$thatAffilSupSeqWords]"/>
                                </xsl:if>    
                            </xsl:for-each>
                        </xsl:for-each>                          
                    </affiliation>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$affid">
                <xsl:for-each select="/article/front/article-meta/aff[@id=$affid]">
                    <affiliation>
                        <xsl:for-each select="text()"> 
                            <xsl:call-template name="affiliation-work"/>
                        </xsl:for-each>
                    </affiliation>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="/article/front/article-meta/aff">
                    <xsl:choose>
                     <xsl:when test="(.//sup or .//label)">  
                            <xsl:variable name="affilArray" select=".//text()"></xsl:variable>
                            <xsl:choose>
                                <xsl:when test ="(matches($affilArray[1],'^[0-9]+$') eq true())">                                    
                                </xsl:when>    
                                <xsl:otherwise>
                                    <affiliation>
                                        <xsl:value-of select="$affilArray[1]"/>
                                    </affiliation>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                         <xsl:otherwise>
                            <affiliation>
                                <xsl:for-each select="text()">
                                    <xsl:value-of select="normalize-space(.)"/>
                                </xsl:for-each>
                            </affiliation>
                        </xsl:otherwise>
                    </xsl:choose>
                 </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>     
       <role>
            <roleTerm type="text">author</roleTerm>
        </role>
    </xsl:template>
    
    <!-- This template pulls out the label and normalize the affiliations -->
    <xsl:template name="affiliation-work"> <!-- The source is so ugly, that why this is. -->
        <xsl:value-of
            select="concat(normalize-space(), ' ', substring-after(label, ./following-sibling::text()[normalize-space()]))"
        />
    </xsl:template>    
     
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
                     <xsl:when test="string-length(month)= 1" >
                        <xsl:text>-0</xsl:text>
                        <xsl:value-of select="month"/>
                     </xsl:when>
                     <xsl:when test="string-length(month)= 2" >
                         <xsl:text>-</xsl:text>
                        <xsl:value-of select="month"/>
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

    <!-- Abstract - Publisher cleanup program should remove "Abstract" or "Summary" from beginning of abstract -->

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
    
    <!-- Keywords -->
    <xsl:template match="kwd-group">
        <xsl:for-each select="kwd">
           <subject>
               <topic>
                   <xsl:value-of select="normalize-space(.)" />
               </topic>
           </subject>
        </xsl:for-each>
    </xsl:template>

    <!-- Journal info -->
    <xsl:template match="journal-meta">
        <relatedItem type="host">
            <titleInfo>
                <title>
                    <xsl:value-of select="journal-title" />
                </title>
            </titleInfo>

        <originInfo>
            <publisher>
                <xsl:value-of select="normalize-space(publisher/publisher-name)" />
            </publisher>
        </originInfo>

        <identifier type="issn">
            <xsl:value-of select="issn" />
        </identifier>

        <identifier type="vendor">
            <xsl:value-of select="journal-id[@journal-id-type='publisher']" />
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

             <xsl:if test="/article/front/article-meta/issue" >
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

             <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']" >
                 <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']/year" >
                   <text type="year">
                       <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='ppub']/year" />
                   </text>
                </xsl:if>
                 <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']/month" >
                     <text type="month">
                         <xsl:value-of select="/article/front/article-meta/pub-date[@pub-type='ppub']/month" />
                     </text>
                 </xsl:if>
                 <xsl:if test="/article/front/article-meta/pub-date[@pub-type='ppub']/day" >
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

           </part>
        </relatedItem>
    </xsl:template>

  <!-- DOI   -->
    <xsl:template match="article-id[@pub-id-type='doi']">
           <identifier type="doi">
              <xsl:value-of select="." />
           </identifier>
        <location>
           <url>
               <xsl:text>http://dx.doi.org/</xsl:text><xsl:value-of select="." /></url>
       </location>
    </xsl:template>

    <xsl:template match="article-meta">
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
