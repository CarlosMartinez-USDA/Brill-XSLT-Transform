<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE transform [
         <!ENTITY % htmlmathml-f PUBLIC
         "-//W3C//ENTITIES HTML MathML Set//EN//XML"
         "http://www.w3.org/2003/entities/2007/htmlmathml-f.ent"
       >
       %htmlmathml-f;
]>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:f="http://functions"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:ali="http://www.niso.org/schemas/ali/1.0/" 
    xmlns="http://www.loc.gov/mods/v3"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    exclude-result-prefixes="xd xs f saxon xlink xsi xml ali mml">
    <xsl:output method="xml" indent="yes" encoding="UTF-8" saxon:next-in-chain="fix_characters.xsl"/>
    <xsl:output method="xml" indent="yes" encoding="UTF-8" name="archive-original" doctype-public="-//NLM//DTD Journal Archiving and Interchange DTD v3.0 20080202//EN" doctype-system="http://dtd.nlm.nih.gov/archiving/3.0/archivearticle3.dtd"/>

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Last modified on:</xd:b> May 15, 2019</xd:p>
            <xd:p><xd:b>Original author:</xd:b> Jennifer Gilbert</xd:p>
            <xd:p><xd:b>Modified by:</xd:b>Emily Somach, Amanda Xu, and Rachel Donahue</xd:p>
            <xd:p>This stylesheet was refactored in June/July 2017.</xd:p>
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
    <xsl:include href="commons/concat-children.xsl"/>
    
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Ignore whitespace-only (i.e. empty) elements except for <xs:b>x</xs:b>, which JATS uses to define a contcatenation character.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="x p"/>

    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Root template - calls and applies specific templates</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        
        <xsl:result-document method="xml" encoding="UTF-8" indent="yes" href="file:///{$workingDir}A-{$archiveFile}_{position()}.xml" format="archive-original">            
            <xsl:copy-of select="."/>          
        </xsl:result-document>
        
        <mods version="3.7">
            <xsl:namespace name="xsi">http://www.w3.org/2001/XMLSchema-instance</xsl:namespace>
            <xsl:attribute name="xsi:schemaLocation">http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-7.xsd</xsl:attribute>
            <xsl:apply-templates select="article/front/article-meta/title-group"/>
            <xsl:apply-templates select="article/front/article-meta/contrib-group"/>
            
            <!-- Check if need to add affiliation note -->
            <xsl:apply-templates select="article/front/article-meta/(.|contrib-group)/aff" mode="note"/>

            <!-- Default -->
            <typeOfResource>text</typeOfResource>
            <genre>article</genre>
            
            <xsl:call-template name="originInfo"/>

            <!-- Default language -->
            <language>
                <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
                <languageTerm type="text">English</languageTerm>
            </language>

            <xsl:choose>
                <xsl:when test="article/front/article-meta/abstract and article/front/article-meta/trans-abstract[@xml:lang='en']">
                    <xsl:apply-templates select="article/front/article-meta/trans-abstract[@xml:lang='en']"/>
                </xsl:when>
                <xsl:when test="not(article/front/article-meta/abstract) and article/body">
                    <xsl:apply-templates select="article/body/p[1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="article/front/article-meta/abstract"/>
                    <xsl:apply-templates select="article/front/article-meta/trans-abstract"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="article/front/article-meta/kwd-group"/>
         
            <relatedItem type="host">
                <xsl:apply-templates select="article/front/journal-meta"/>
                <xsl:call-template name="modsPart"/>
            </relatedItem>
            
            <xsl:apply-templates select="article/front/article-meta/article-id[@pub-id-type]"/>
            <xsl:call-template name="extension"/>
            
        </mods>
        
    </xsl:template>



    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Article title</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="title-group">
        <titleInfo>
            <title>
                <xsl:variable name="this"><xsl:apply-templates select="article-title"/></xsl:variable>
                <xsl:value-of select="normalize-space($this)"/>
            </title>
            <xsl:apply-templates select="subtitle"/>
        </titleInfo>
        <xsl:apply-templates select="trans-title-group"/>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Remove superscript/footnotes from title - found in APSociety metadata</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="article-title/xref"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Remove alt-title that duplicates article title from title group - found in Brill</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="title-group/alt-title[@alt-title-type='toc']"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Remove fn-group from title group - found in Taylor and Francis</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="title-group/fn-group"/>
    
  <!--<xsl:template match="article-title">
        <xsl:apply-templates/>
    </xsl:template> -->

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Tanslated article title</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="trans-title-group">
        <titleInfo type="translated">
            <title>
                <xsl:value-of select="normalize-space(trans-title)"/>
            </title>
            <xsl:apply-templates select="subtitle"/>
        </titleInfo>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Authors templates.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="contrib-group">
        <xsl:apply-templates select="contrib[@contrib-type = 'author']"/>
        <xsl:if test="/article/front/journal-meta/journal-title-group/journal-title = 'Laboratory Animals' and not(contrib[@contrib-type = 'author'])">
            <xsl:apply-templates select="contrib"/>
        </xsl:if>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Template to account for alternative format of author information.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="contrib-group[@content-type = 'authors']">
        <xsl:apply-templates select="contrib"/>
    </xsl:template>
   
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Template to capture contrib-group without attribute info for authors.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="contrib-group[not(@*)]">
        <xsl:apply-templates select="contrib"/>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>If the contributor is a collaborator rather than an individual, format output accordingly. If processing the first author in the group, assign an attribute of <xs:b>usage</xs:b> with a value of "primary."</xd:desc>
    </xd:doc>
    <xsl:template match="contrib">
        <xsl:choose>
            <xsl:when test="collab">
                <name type="corporate">
                    <namePart>
                        <xsl:value-of select="collab/text()"/>
                    </namePart>
                </name>
            </xsl:when>
            <xsl:otherwise>
                <name type="personal">
                    <xsl:if test="position() = 1 and count(../preceding-sibling::contrib-group) = 0">
                        <xsl:attribute name="usage">primary</xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="name-info"/>
                </name>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Template for authors in the collab tag</xd:p>
        </xd:desc>
    </xd:doc>    

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Formatting for personal names</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="name-info">
        <namePart type="given">
            <xsl:value-of select="normalize-space((string-name|name)/given-names)"/>
        </namePart>
        <namePart type="family">
            <xsl:value-of select="(string-name|name)/surname"/>
        </namePart>
        <displayForm>
            <xsl:value-of select="(string-name|name)/surname"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="normalize-space((string-name|name)/given-names)"/>
        </displayForm>
        
        <!-- Get author's ORCID -->
        <xsl:apply-templates select="contrib-id[@contrib-id-type = 'orcid']"/>     
        
        <!-- Create variables for matching author(s) to affiliation(s) -->
        <!-- Check if author has an affiliation ID for matching -->
        <xsl:variable name="affid" select="xref[@ref-type = 'aff']/@rid"/>
        <!-- Count number of affiliations available for matching -->
        <xsl:variable name="affnum" select="count(../aff)"/>
        <!-- Count number of affiliations available for matching, using alternate path in Indian Journals -->
        <xsl:variable name="affnumIJ" select="count(../../aff)"/>
        <!-- Save author's last name -->
        <xsl:variable name="lastName" select="(string-name|name)/surname"/>
        <!-- Find and save author's initials -->
        <xsl:variable name="initials">
            <xsl:for-each select="tokenize((string-name|name)/given-names, ' ')">
                <xsl:value-of select="substring(., 1, 1)"/>
            </xsl:for-each>
            <xsl:for-each select="tokenize((string-name|name)/surname, ' ')">
                <xsl:value-of select="substring(., 1, 1)"/>
            </xsl:for-each>
        </xsl:variable>
        
        <!-- If aff tag(s) in contrib tag, use as aff (SAGE) -->
        <!-- If no affids for authors and only one aff, use it for all (SAGE) -->
        <!-- If there are affs outside contrib-group tag but no affids for authors, use all affs for all authors (IJ) -->
        <!-- If no affid, match using author's last name or initials and remove parentheses (SAGE) -->
        <xsl:choose>
            <xsl:when test="$affid">
                <xsl:for-each select="../aff[@id = $affid] | ../../aff[@id = $affid]">                    
                    <affiliation>
                        <xsl:variable name="this">
                            <xsl:apply-templates select="x[@xml:space='preserve'][text()='; ']" mode="affiliation"/>
                            <xsl:call-template name="clean-concat-with-comma"/>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="label">
                                <xsl:variable name="this" select="substring-after($this, ',')"/>
                                <xsl:value-of select="normalize-space($this)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$this"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </affiliation>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="aff">                
                <xsl:for-each select="aff">
                    <affiliation>
                        <xsl:variable name="this">
                            <xsl:call-template name="clean-concat-with-comma"/>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="label">
                                <xsl:variable name="this" select="substring-after($this, ',')"/>
                                <xsl:value-of select="normalize-space($this)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$this"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </affiliation>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="not($affid) and $affnum = 1">                
                <xsl:apply-templates mode="affiliation" select="../aff"/>           
            </xsl:when>
            <xsl:when test="not($affid) and $affnumIJ >= 1">
                <xsl:apply-templates mode="affiliation" select="../../aff"/>
            </xsl:when>
            <xsl:when test="$vendorName = 'Sage Publications'">
                <xsl:for-each select="../aff">
                    <xsl:if test="contains(., $lastName) or contains(., $initials)">
                        <affiliation>
                            <xsl:variable name="this">
                                <xsl:call-template name="clean-concat-with-comma"/>
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="label">
                                    <xsl:variable name="this" select="substring-after($this, ',')"/>
                                    <xsl:value-of select="normalize-space($this)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$this"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </affiliation>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>

        <role>
            <roleTerm type="text">author</roleTerm>
        </role>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Adds authors' ORCID if provided.</xd:p>
            <xd:p>Turns ORCID into a URI if only the 16-digit number is given.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="contrib-id[@contrib-id-type = 'orcid']">
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
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Processes affiliation information that doesn't contain footnote superscript.</xd:p>
            <xd:p>Only selects 'aff' elements with no 'label' elements as children. </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="affiliation">        
        <xsl:for-each select="*[not(self::label)]">
            <affiliation>
                <xsl:variable name="this">
                    <xsl:call-template name="clean-concat-with-comma"/>
                </xsl:variable>
                <xsl:value-of select="$this"/>
            </affiliation>
        </xsl:for-each>        
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Prevents a newline from being added before the value.</xd:p>
            <xd:p>Matches all text nodes without normalized space.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="*/text()[not(normalize-space())]" mode="affiliation"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Puts affiliation information in a note element when not formatted like a typical affiliation.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="aff" mode="note">
        <xsl:if test="$vendorName = 'American Phytopathological Society' and (contains(., 'First') and contains(., 'second'))">
            <note type="creation/production credits">
                <xsl:value-of select="concat('Affiliations: ', .)"/>
            </note>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="aff" mode="affiliation">
        <xsl:variable name="lastName" select="contrib/(string-name|name)/surname"/>
        <xsl:variable name="initials">
            <xsl:for-each select="tokenize(constrib/(string-name|name)/given-names, ' ')">
                <xsl:value-of select="substring(., 1, 1)"/>
            </xsl:for-each>
            <xsl:for-each select="tokenize(contrib/(string-name|name)/surname, ' ')">
                <xsl:value-of select="substring(., 1, 1)"/>
            </xsl:for-each>
        </xsl:variable>
        <affiliation>
            <xsl:choose>
                <xsl:when test="contains(., 'First') and contains(., 'second')">
                    <!-- do nothing -->
                </xsl:when>
                <xsl:when test="not($vendorName = 'BioOne') and contains(., '(') and contains(., ')') and (contains(., $lastName) or contains(., $initials))">
                    <xsl:value-of select="replace(., '\(.*\)', '')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="affiliation"/>
                </xsl:otherwise>
            </xsl:choose>
        </affiliation>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>An empty template to prevent the footnote superscript from displaying in the affiliation text string.</xd:p>
            <xd:p>Matches the 'sup' element to remove footnote superscript from the value.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="sup" mode="affiliation"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>An empty template to prevent the footnote superscript from displaying in the affiliation text string. Matches 'label', a parent element of 'sup'. </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="label" mode="affiliation"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>An empty template to prevent a trailing semi colon and space in the affiliation text string.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="x[@xml:space='preserve'][text()='; ']" mode="affiliation"/>    
   
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Removes periods and the sub-string '; and ' from end of affiliation text string.</xd:p>
        </xd:desc>
    </xd:doc>
<!--    <xsl:template match="text()" mode="affiliation">
        <line>440</line>
        <xsl:choose>
            <xsl:when test="ends-with(., '.')">
                <line>443</line>
                <xsl:value-of select="substring(., 1, string-length(.) - 1)"/>
            </xsl:when>
            <xsl:when test="ends-with(., '; and ')">
                <line>447</line>
                <xsl:value-of select="substring(., 1, string-length(.) - 6)"/>
            </xsl:when>
            <xsl:otherwise>
                <line>451</line>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->

    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Builds originInfo date from ppub and epub dates.</xd:p>
            <xd:p>American Chemical Society uses issue-pub and pub.</xd:p>
            <xd:p>Mary Ann Liebert uses copyright date.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="originInfo">
        <originInfo>
            <xsl:for-each select="article/front/article-meta">
                <xsl:apply-templates
                    select="pub-date[(@pub-type = ('ppub', 'epub-ppub') or @date-type = 'pub' or @publication-format = ('print', 'electronic'))]"
                    mode="origin"/>
                <xsl:choose>
                    <xsl:when test="not(pub-date)">
                        <xsl:apply-templates
                            select="history/date[@date-type = 'accepted']"
                            mode="origin"/>
                        <xsl:if
                            test="not(history/date[@date-type = 'accepted'])">
                            <xsl:apply-templates
                                select="permissions/copyright-year"
                                mode="origin"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when
                        test="not(pub-date[(@pub-type = ('ppub', 'epub-ppub') or @date-type = 'pub' or @publication-format = ('print', 'electronic'))][year[text() != '']])">
                        <xsl:apply-templates
                            select="pub-date[(@pub-type = 'epub'or @date-type = 'issue-pub' or @publication-format = 'online')]"
                            mode="origin"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates
                            select="pub-date[(@pub-type = 'epub'or @date-type = 'issue-pub' or @publication-format = 'online')]"
                            mode="other"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </originInfo>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Print publication date added as 'dateIssued.' If no print, then online used.</xd:p>
            <xd:p>Checks that 'day' is not 'NaN'. Month function checks that 'month' is present and not 'null.'</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="pub-date[(@pub-type = ('ppub', 'epub-ppub') or @date-type = 'pub' or @publication-format = ('print', 'electronic'))][1][year[text() != '']] | date[@date-type = 'accepted'][year[text() != '']]" mode="origin">
        <dateIssued encoding="w3cdtf" keyDate="yes">
            <xsl:value-of select="string-join((year, f:checkMonthType(month[not(. = '')]), format-number(day[not(. = '')], '00'))[. != 'NaN'], '-')"/>
        </dateIssued>
    </xsl:template>
    
    <xsl:template match="pub-date[(@pub-type = 'epub' or @date-type = 'issue-pub' or @publication-format = 'online')][1][year[text() != '']]" mode="origin">
        <dateIssued encoding="w3cdtf" keyDate="yes">
            <xsl:value-of select="string-join((year, f:checkMonthType(month)[not(. = '')], format-number(day[not(. = '')], '00'))[. != 'NaN'], '-')"/>
        </dateIssued>
    </xsl:template>
    
    <xsl:template match="copyright-year" mode="origin">
        <dateIssued encoding="w3cdtf" keyDate="yes">
            <xsl:value-of select="."/>
        </dateIssued>    
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Electronic publication date added as 'dateOther' if print date exists.</xd:p>
            <xd:p>Only adds day information if it is present, so as not to produce a NaN in the date.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="pub-date[(@pub-type = 'epub' or @date-type = 'issue-pub' or @publication-format = 'online')][1][year[text() != '']]" mode="other">
        <dateOther encoding="w3cdtf" type="electronic">
            <xsl:value-of select="string-join((year, f:checkMonthType(month[not(. = '')]), format-number(day[not(. = '')], '00'))[. != 'NaN'], '-')"/>
        </dateOther>
    </xsl:template>
    

    
    
    <!-- Abstract -->


    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Only matches abstracts that do not specify a language or that specify the language as English.</xd:p>
            <xd:p>Also matches foreign abstracts translated into English.</xd:p>
            <xd:p>'copy-of' is needed because abstract can have 'title' child elements, which makes normalize-space throw an error.</xd:p>
            <xd:p>The 'apply-templates' variable is necessary to fix super/subscript tags.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="abstract|trans-abstract">
        <xsl:if test="@xml:lang = ('en', 'EN') or not(@xml:lang)">
            <xsl:choose>
                <xsl:when test="$vendorName = 'American Phytopathological Society' and matches(./p[last()], '(Accepted)|(Posted)|(Published)')">
                    <xsl:variable name="this"><xsl:apply-templates select="./p[1]"/></xsl:variable>
                    <abstract>
                        <xsl:value-of select="normalize-space($this)"/>
                    </abstract>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="abstractText"><xsl:copy-of select="*[not(self::title)]"/></xsl:variable>
                    <xsl:variable name="this"><xsl:apply-templates/></xsl:variable>
                    <abstract>
                        <xsl:value-of select="normalize-space($this)"/>
                    </abstract>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Remove teaser abstract - found in Oxford</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="abstract[@abstract-type='teaser']"/>    
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Matches first body paragraph when no abstract present.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="body/p">
        <xsl:if test="@xml:lang = ('en', 'EN') or not(@xml:lang)">            
            <xsl:variable name="bodyText"><xsl:copy-of select="*[not(self::title)]"/></xsl:variable>
            <xsl:variable name="this"><xsl:apply-templates/></xsl:variable>
            <abstract>
                <xsl:value-of select="normalize-space($this)"/>
            </abstract>
        </xsl:if>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Empty templates to match 'title' children of 'abstract' or 'trans-abstract' element, graphical abstracts, and synopses.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="abstract/title|trans-abstract/title"/>    
    <xsl:template match="abstract/sec/title|trans-abstract/sec/title"/>
    <xsl:template match="abstract[@abstract-type='graphical']|abstract[@abstract-type='synopsis']"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Turn keywords into subjects unless the group title is 'Abbreviations,' the language is not specified, or the language is specified as something other than English.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="kwd-group">
        <xsl:if test="(not(@xml:lang) or lower-case(@xml:lang) = 'en') and (not(title) or title != 'Abbreviations')">
                <xsl:for-each select="kwd">
                    <subject>
                        <topic>
                            <xsl:value-of select="normalize-space(.)"/>
                        </topic>
                    </subject>
                </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>The following section includes templates for building relatedItem from journal-meta</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="journal-meta">
        <xsl:apply-templates select="journal-title-group/journal-title|journal-title[not(parent::journal-title-group)]"/>
        <xsl:apply-templates select="journal-title-group/abbrev-journal-title|abbrev-journal-title[not(parent::journal-title-group)]"/>
        <xsl:apply-templates select="publisher"/>
        <xsl:apply-templates select="issn"/>
        <xsl:apply-templates select="journal-id"/>        
    </xsl:template>
    
    <xsl:template match="journal-title-group/journal-title|journal-title[not(parent::journal-title-group)]">
        <titleInfo>
            <title>
                <xsl:value-of select="normalize-space(.)"/>
            </title>
            <xsl:apply-templates select="../journal-subtitle"/>
        </titleInfo>
    </xsl:template>
    
    <xsl:template match="journal-title-group/abbrev-journal-title|abbrev-journal-title[not(parent::journal-title-group)]">
        <titleInfo type="abbreviated">
            <title>
                <xsl:value-of select="normalize-space(.)"/>
            </title>
            <xsl:apply-templates select="../journal-subtitle"/>
        </titleInfo>
    </xsl:template>
    
    <xsl:template match="journal-subtitle|subtitle">
        <subTitle>
            <xsl:value-of select="normalize-space(.)"/>
        </subTitle>
    </xsl:template>
        
    <xsl:template match="issn">
        <xsl:variable name="eIssn">
            <xsl:if test="@pub-type = 'epub' or @publication-format = 'electronic'">
                <xsl:choose>
                    <xsl:when test=". = 'XXXX-XXXX'">
                        <xsl:value-of select="'1943-4936'"/>
                    </xsl:when>
                    <xsl:when test=". = '1544-4221'">
                        <xsl:value-of select="'1544-2217'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:variable>
        <identifier type="issn-e"><xsl:value-of select="$eIssn"/></identifier>
        <identifier type="issn"><xsl:value-of select="$eIssn"/></identifier>
        <xsl:if test="@pub-type = 'ppub' or @publication-format = 'print'">
            <identifier type="issn-p"><xsl:value-of select="."/></identifier>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="journal-id">
        <xsl:if test="@journal-id-type = 'publisher-id'">
            <identifier type="vendor"><xsl:value-of select="."/></identifier>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="publisher">
        <originInfo>
            <publisher>
                <xsl:choose>
                    <xsl:when test="$vendorName = 'Mary Ann Liebert' and contains(publisher-name, 'publishers')">
                        <xsl:value-of select="normalize-space(substring-before(publisher-name, ', publishers'))"/>
                    </xsl:when>
                    <xsl:when test="$vendorName = 'PAGEPress' and contains(publisher-name, 'Pavia, Italy')">
                        <xsl:value-of select="normalize-space(substring-before(publisher-name, ', Pavia, Italy'))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(publisher-name)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </publisher>
        </originInfo>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>The following section includes templates for adding information from article-meta to relatedItem.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="modsPart">
        <part>
            <xsl:apply-templates select="/article/front/article-meta/volume[not(@content-type = 'year')]"/>
            <xsl:apply-templates select="/article/front/article-meta/issue"/>
            <xsl:apply-templates select="/article/front/article-meta/pub-date[@pub-type = 'ppub'] | /article/front/article-meta/pub-date[@pub-type = 'epub-ppub'] | /article/front/article-meta/pub-date[@date-type = 'pub']" mode="part"/>
            <xsl:if test="not(/article/front/article-meta/pub-date[@pub-type = 'ppub']) and not(/article/front/article-meta/pub-date[@date-type = 'pub']) and not(/article/front/article-meta/pub-date[@pub-type = 'epub-ppub'])">
                <xsl:apply-templates select="/article/front/article-meta/pub-date[@pub-type = 'epub'] | /article/front/article-meta/pub-date[@date-type = 'issue-pub']" mode="part"/>
            </xsl:if>

            <xsl:if test="/article/front/article-meta/fpage or /article/front/article-meta/elocation-id or /article/front[1]/article-meta[1]/counts[1]/page-count[1]/@count">
                <xsl:call-template name="modsPages"/>
            </xsl:if>         
        </part>
    </xsl:template>
    
    <xsl:template match="/article/front/article-meta/volume[not(@content-type = 'year')]">
        <detail type="volume">
            <number><xsl:value-of select="."/></number>
            <caption>v.</caption>
        </detail>
    </xsl:template>

    <xsl:template match="/article/front/article-meta/issue[text()]">
        <detail type="issue">
            <number>
                <xsl:value-of select="."/>
            </number>
            <caption>no.</caption>
        </detail>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Transform page details</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="modsPages">
        <extent unit="pages">
            <xsl:apply-templates select="/article/front/article-meta/fpage"/>
            <xsl:apply-templates select="/article/front/article-meta/lpage"/>
            <xsl:apply-templates select="/article/front/article-meta/elocation-id"/>
            <xsl:sequence select="f:calculateTotalPgs(/article/front/article-meta/fpage, /article/front/article-meta/lpage)"/>            
        </extent>
    </xsl:template>
    
    <xsl:template match="/article/front/article-meta/fpage">
        <start><xsl:value-of select="."/></start>
    </xsl:template>
    
    <xsl:template match="/article/front/article-meta/elocation-id">
        <start><xsl:value-of select="."/></start>
    </xsl:template>
   
    <xsl:template match="/article/front/article-meta/lpage">
        <end><xsl:value-of select="."/></end>
    </xsl:template>
    
    <xsl:template match="/article/front[1]/article-meta[1]/counts[1]/page-count[1]/@count" name="pageCount">        
        <total><xsl:value-of select="/article/front[1]/article-meta[1]/counts[1]/page-count[1]/@count"/></total>        
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Builds date for part element.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:template match="/article/front/article-meta/pub-date[@pub-type = 'ppub'][1] | /article/front/article-meta/pub-date[@pub-type = 'epub-ppub'][1] | /article/front/article-meta/pub-date[@date-type = 'pub']" mode="part">
        <xsl:for-each select="year, month, day, season, string-date">
            <xsl:choose>
                <xsl:when test="name() = 'month'">
                    <text type="month">
                        <xsl:value-of select="f:checkMonthType(.)"/>
                    </text>                    
                </xsl:when>
                <xsl:otherwise>
                    <text type="{name()}">
                        <xsl:value-of select="."/>
                    </text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="/article/front/article-meta/pub-date[@pub-type = 'epub'][1] | /article/front/article-meta/pub-date[@date-type = 'issue-pub']" mode="part">
        <xsl:for-each select="*">
            <xsl:choose>
                <xsl:when test="name() = 'month'">
                    <text type="month">
                        <xsl:value-of select="f:checkMonthType(.)"/>
                    </text>                    
                </xsl:when>
                <xsl:otherwise>
                    <text type="{name()}">
                        <xsl:value-of select="."/>
                    </text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Transform DOI and URL</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="article-id[not(@pub-id-type = 'doi')]">        
        <identifier type="{@pub-id-type}">
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template>
    
    <xsl:template match="article-id[@pub-id-type='doi']">
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
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p><xd:b>vendorName:</xd:b> Name of the vendor supplying the metadata.</xd:p>
            <xd:p><xd:b>archiveFile:</xd:b> Filename of the file (xml or zip) that originally held the source data.</xd:p>
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
            <!-- Funding group information -->            
            <xsl:apply-templates select="/article/front/article-meta/funding-group"/>
            <xsl:apply-templates select="/article/back/(fn-group|fn-group/fn)[@fn-type='financial-disclosure' or @fn-type='supported-by']"/>
        </extension>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Adds funding information from source while preserving source format.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/article/front/article-meta/funding-group">
        <funding-group>
            <xsl:if test="@specific-use">
                <xsl:attribute name="specific-use">FundRef</xsl:attribute>
            </xsl:if>
            <xsl:for-each select="award-group">
                <award-group>
                    <xsl:if test="@id">
                        <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
                    </xsl:if>
                    <funding-source>
                        <xsl:attribute name="id"><xsl:value-of select="funding-source/@id"/></xsl:attribute>
                        <xsl:for-each select="funding-source/named-content">
                            <named-content content-type="{@content-type}">
                                <xsl:value-of select="normalize-space(.)"/>
                            </named-content>
                        </xsl:for-each>
                        <xsl:for-each select="funding-source/institution-wrap">
                            <institution-wrap>
                                <institution>
                                    <xsl:value-of select="institution"/>
                                </institution>
                                <institution-id>
                                    <xsl:attribute name="institution-id-type">FundRef</xsl:attribute>
                                    <xsl:value-of select="institution-id"/>
                                </institution-id>
                            </institution-wrap>
                        </xsl:for-each>
                    </funding-source>
                    <xsl:for-each select="award-id">
                        <award-id>
                            <xsl:if test="@rid">
                                <xsl:attribute name="rid"><xsl:value-of select="@rid"/></xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="."/>
                        </award-id>
                    </xsl:for-each>
                </award-group>
            </xsl:for-each>  
            <funding-statement>
                <xsl:value-of select="funding-statement"/>
            </funding-statement>
            <open-access>
                <xsl:value-of select="open-access"/>
            </open-access>
        </funding-group>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Adds funding types and financial disclosure from source while preserving source format.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/article/back/fn-group">
        <fn-group>
            <xsl:attribute name="fn-type"><xsl:value-of select="@fn-type"/></xsl:attribute>
            <xsl:apply-templates select="fn"/>
        </fn-group>
    </xsl:template>
    
    <xsl:template match="/article/back/fn-group/fn">
        <fn>
            <xsl:attribute name="fn-type"><xsl:value-of select="@fn-type"/></xsl:attribute>
            <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
            <label><xsl:value-of select="label"/></label>
            <p><xsl:value-of select="p"/></p> 
        </fn>
    </xsl:template> 
    
    <xd:doc scope="component">
        <xd:desc><xd:p>Add note to warn that object is not an article.</xd:p></xd:desc>
    </xd:doc>
    <xsl:template match="issue-xml">
        <note type="warning">Object is an issue, not an article.</note>
    </xsl:template>
    
</xsl:stylesheet>
