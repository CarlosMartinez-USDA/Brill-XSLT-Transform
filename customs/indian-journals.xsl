<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:f="http://functions"
    xmlns:saxon="http://saxon.sf.net/" xmlns:ali="http://www.niso.org/schemas/ali/1.0/"
    xmlns="http://www.loc.gov/mods/v3" exclude-result-prefixes="xd xs f saxon xlink xsi xml ali">
    <xsl:import href="../jats_to_mods_30.xsl"/>

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Last modified on:</xd:b> May 25, 2021</xd:p>
            <xd:p><xd:b>Original author:</xd:b> Rachel Donahue</xd:p>
            <xd:p><xd:b>Edited by: </xd:b>Carlos Martinez</xd:p>
            <xd:p>This stylesheet accounts for IndianJournals' different structure for DOIs and
                articles that do not have a DOI. Because the article-id template is called in root,
                the entire root template had to be copied.</xd:p>
            <xd:p>Corrected errors and warnings:</xd:p>
            <xd:p>Pub-date received ambiguous error when processing mods:originInfo and the
                mods:part elements</xd:p>
            <xd:p>Affiliation for Indian Journals did not consistently copy the correct affiliation
                to its respective author</xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:template match="/">

        <xsl:result-document method="xml" encoding="UTF-8" indent="yes"
            href="file:///{$workingDir}A-{replace($originalFilename, '(.*/)(.*)(\.xml)', '$2')}_{position()}.xml"
            format="archive-original">
            <xsl:copy-of select="."/>
        </xsl:result-document>
        <!-- uncomment if N-file is produced 
           <xsl:result-document method="xml" encoding="UTF-8" indent="yes"
            href="file:///{$workingDir}N-{replace($originalFilename, '(.*/)(.*)(\.xml)', '$2')}_{position()}.xml">-->
        <mods version="3.7">
            <xsl:namespace name="xsi">http://www.w3.org/2001/XMLSchema-instance</xsl:namespace>
            <xsl:attribute name="xsi:schemaLocation"
                select="
                    normalize-space('http://www.loc.gov/mods/v3
                    http://www.loc.gov/standards/mods/v3/mods-3-7.xsd')"/>
            <xsl:apply-templates select="article/front/article-meta/title-group"/>
            <xsl:apply-templates select="article/front/article-meta/contrib-group"/>

            <!-- Check if need to add affiliation note -->
            <xsl:apply-templates select="article/front/article-meta/(. | contrib-group)/aff"
                mode="note"/>

            <!-- Default -->
            <typeOfResource>text</typeOfResource>
            <genre>article</genre>
            <xsl:call-template name="IJ_originInfo"/>

            <!-- Default language -->
            <language>
                <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
                <languageTerm type="text">English</languageTerm>
            </language>

            <xsl:choose>
                <xsl:when
                    test="article/front/article-meta/abstract and article/front/article-meta/trans-abstract[@xml:lang = 'en']">
                    <xsl:apply-templates
                        select="article/front/article-meta/trans-abstract[@xml:lang = 'en']"/>
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
                <xsl:call-template name="IJ_modsPart"/>
            </relatedItem>

            <xsl:apply-templates
                select="article/front/article-meta/article-id[@pub-id-type] | /article/front[1]/article-meta[1]/doi-group[1]/article-doi[1]"/>
            <xsl:call-template name="extension"/>

        </mods>
        <!--uncomment if no N-File is produced
            </xsl:result-document>-->
    </xsl:template>


    <!--authors templates-->
    <xd:doc scope="component">
        <xd:desc>If the contributor is a collaborator rather than an individual, format output
            accordingly. If processing the first author in the group, assign an attribute of
                <xs:b>usage</xs:b> with a value of "primary."</xd:desc>
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
                    <xsl:call-template name="indian-journals-name-info"/>
                </name>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Formatting for personal names</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="indian-journals-name-info">

        <namePart type="given">
            <xsl:value-of select="normalize-space((string-name | name)/given-names)"/>
        </namePart>
        <namePart type="family">
            <xsl:value-of select="(string-name | name)/surname"/>
        </namePart>
        <displayForm>
            <xsl:value-of select="(string-name | name)/surname"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="normalize-space((string-name | name)/given-names)"/>
        </displayForm>
        <!-- Get author's ORCID -->
        <xsl:apply-templates select="contrib-id[@contrib-id-type = 'orcid']"/>
        <!-- Use id AND current() function to match affiliation  -->
        <xsl:for-each select="//aff[@id = current()/xref/@rid]">
            <affiliation>
                <xsl:variable name="this">
                    <xsl:apply-templates mode="affiliation"/>
                </xsl:variable>
                <!--   $this normalizes whitespace gaps appearing in output -->
                <xsl:value-of select="normalize-space($this)"/>
            </affiliation>
        </xsl:for-each>
        <role>
            <roleTerm type="text">author</roleTerm>
        </role>
    </xsl:template>


    <!--IJ_originInfo-->
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Builds originInfo date from ppub and epub dates.</xd:p>
            <xd:p>American Chemical Society uses issue-pub and pub.</xd:p>
            <xd:p>Mary Ann Liebert uses copyright date.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="IJ_originInfo">
        <originInfo>
            <xsl:for-each select="article/front/article-meta">
                <xsl:apply-templates
                    select="pub-date[(@pub-type = ('ppub', 'epub-ppub') or @publication-format = ('print', 'electronic'))]"
                    mode="IJ_origin"/>
                <xsl:choose>
                    <xsl:when test="not(pub-date)">
                        <xsl:apply-templates select="history/date[@date-type = 'accepted']"
                            mode="IJ_origin"/>
                        <xsl:if test="not(history/date[@date-type = 'accepted'])">
                            <xsl:apply-templates select="permissions/copyright-year"
                                mode="IJ_origin"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when
                        test="not(pub-date[(@pub-type = ('ppub', 'epub-ppub') or @date-type = 'pub' or @publication-format = ('print', 'electronic'))][year[text() != ''][month[text() != ''][day[text() != '']]]])">
                        <xsl:apply-templates
                            select="pub-date[(@pub-type = 'epub' or @date-type = 'issue-pub' or @publication-format = 'online')]"
                            mode="IJ_eorigin"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates
                            select="pub-date[(@pub-type = 'epub' or @date-type = 'issue-pub' or @publication-format = 'online')]"
                            mode="IJ_other"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </originInfo>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Print publication date added as 'dateIssued.' If no print, then online
                used.</xd:p>
            <xd:p>Checks that 'day' is not 'NaN'. Month function checks that 'month' is present and
                not 'null.'</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template
        match="pub-date[(@pub-type = ('ppub', 'epub-ppub') or @publication-format = ('print', 'electronic'))][1][year[text() != '']] | date[@date-type = 'accepted'][year[text() != '']]"
        mode="IJ_origin">
        <dateIssued encoding="w3cdtf" keyDate="yes">
            <xsl:value-of
                select="string-join((year, f:IJ_checkMonthType(month[not(. = '')]), format-number(day[not(. = '')], '00'))[. != 'NaN'], '-')"
            />
        </dateIssued>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>The &lt;month&gt; is a child of the &lt;pub-date&gt; element, and sometimes will
                contain two single digits separated by a &#8211;</xd:p>
            <xd:p>According to MODS standard...</xd:p>
            <!--(research whether dateIssued proscribes the first month or last month in range to choose for dateIssued)
            -->
        </xd:desc>
        <xd:param name="lastMonthString"/>
    </xd:doc>
    <xsl:template
        match="pub-date[(@pub-type = 'epub' or @date-type = 'issue-pub' or @publication-format = 'online')][1][year[text() != '']]"
        mode="IJ_eorigin">
        <xsl:choose>
            <xsl:when test="contains(month, '-')">
                <dateIssued encoding="w3cdtf" keyDate="yes">
                    <xsl:value-of
                        select="
                            string-join((year, f:IJ_checkMonthType(month), format-number(day[not(. = '')], '00'))[. != 'NaN'], '-')"
                    />
                </dateIssued>
            </xsl:when>
            <xsl:otherwise>
                <dateIssued encoding="w3cdtf" keyDate="yes">
                    <xsl:value-of
                        select="string-join((year, f:IJ_checkMonthType(month)[not(. = '')], format-number(day[not(. = '')], '00'))[. != 'NaN'], '-')"
                    />
                </dateIssued>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="copyright-year" mode="IJ_origin">
        <dateIssued encoding="w3cdtf" keyDate="yes">
            <xsl:value-of select="."/>
        </dateIssued>
    </xsl:template>

    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Electronic publication date added as 'dateOther' if print date exists.</xd:p>
            <xd:p>Only adds day information if it is present, so as not to produce a NaN in the
                date.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template
        match="pub-date[(@pub-type = 'epub' or @date-type = 'issue-pub' or @publication-format = 'online')][1][year[text() != '']]"
        mode="IJ_other">
        <dateOther encoding="w3cdtf" type="electronic">
            <xsl:value-of
                select="string-join((year, f:IJ_checkMonthType(month[not(. = '')]), format-number(day[not(. = '')], '00'))[. != 'NaN'], '-')"
            />
        </dateOther>
    </xsl:template>



    <!--IJ_modsPart -->
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>The following section includes templates for adding information from article-meta
                to relatedItem.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="IJ_modsPart">
        <part>
            <xsl:apply-templates
                select="/article/front/article-meta/volume[not(@content-type = 'year')]"/>
            <xsl:apply-templates select="/article/front/article-meta/issue"/>
            <xsl:apply-templates
                select="/article/front/article-meta/pub-date[@pub-type = 'ppub'] | /article/front/article-meta/pub-date[@pub-type = 'epub-ppub'] | /article/front/article-meta/pub-date[@date-type = 'pub']"
                mode="IJ_part"/>
            <xsl:if
                test="not(/article/front/article-meta/pub-date[@pub-type = 'ppub']) and not(/article/front/article-meta/pub-date[@date-type = 'pub']) and not(/article/front/article-meta/pub-date[@pub-type = 'epub-ppub'])">
                <xsl:apply-templates
                    select="/article/front/article-meta/pub-date[@pub-type = 'epub'] | /article/front/article-meta/pub-date[@date-type = 'issue-pub']"
                    mode="IJ_epart"/>
            </xsl:if>
            <xsl:if
                test="/article/front/article-meta/fpage or /article/front/article-meta/elocation-id or /article/front[1]/article-meta[1]/counts[1]/page-count[1]/@count">
                <xsl:call-template name="modsPages"/>
            </xsl:if>
        </part>
    </xsl:template>


    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Builds date for part element.</xd:p>
        </xd:desc>
        <xd:param name="stringMonth"/>
    </xd:doc>
    <xsl:template
        match="/article/front/article-meta/pub-date[@pub-type = 'ppub'][1] | /article/front/article-meta/pub-date[@pub-type = 'epub-ppub'][1] | /article/front/article-meta/pub-date[@date-type = 'pub']"
        mode="IJ_part">
        <xsl:for-each select="year, month, day, season, string-date">
            <xsl:choose>
                <xsl:when test="name() = 'month'">
                    <text type="month">
                        <xsl:value-of select="f:IJ_checkMonthType(.)"/>
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
        <xd:desc/>
        <xd:param name="stringMonth"/>
    </xd:doc>
    <xsl:template
        match="/article/front/article-meta/pub-date[@pub-type = 'epub'][1] | /article/front/article-meta/pub-date[@date-type = 'issue-pub']"
        mode="IJ_epart">
        <xsl:param name="stringMonth" select="month" as="xs:string"/>
        <xsl:for-each select="*">
            <xsl:choose>
                <xsl:when test="name() = 'month'">
                    <text type="month">
                        <xsl:value-of select="f:IJ_checkMonthType(.)"/>
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


    <!--article-doi and identifiers-->
    <xd:doc>
        <xd:desc>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:template match="article-doi">
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

    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="article-id[@pub-id-type = 'other']">
        <identifier type="indian-journals">
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template>

    <!-- function to handle Indian Journal dates-->

    <xd:doc scope="component">
        <xd:desc>
            <xd:p><xd:b>Function: </xd:b>f:IJ_checkMonthType</xd:p>
            <xd:p><xd:b>Usage: </xd:b>f:IJ_checkMonthType(XPath)</xd:p>
            <xd:p><xd:b>Purpose: </xd:b>If month provided, check if represented as an integer or
                string. If integer, pad with zeroes to 2 digits; if string, run
                    <xd:i>f:monthNumFromName:</xd:i>Indian Journals contains the month element as a
                span of months (i.e., 1-6)&lt;</xd:p>
        </xd:desc>
        <xd:param name="testValue"/>
    </xd:doc>
    <xsl:function name="f:IJ_checkMonthType">
        <xsl:param name="testValue"/>
        <xsl:choose>
            <xsl:when test="contains($testValue, '-')">
                <xsl:variable name="lastInRange" select="substring-after($testValue, '-')"
                    as="xs:string"/>
                <xsl:value-of select="format-number(number($lastInRange[not(. = '')]), '00')"/>
            </xsl:when>
            <xsl:when test="(string($testValue)) and (not(string-length($testValue) > 2))">
                <xsl:value-of select="format-number($testValue, '00')"/>
            </xsl:when>
            <xsl:when test="contains($testValue, '–')">
                <xsl:variable name="firstInRange" select="number(substring-before($testValue, '–'))"/>
                <xsl:value-of select="format-number($firstInRange, '00')"/>
            </xsl:when>
            <xsl:when test="(string-length($testValue) > 2 and (not(contains($testValue, '–'))))">
                <xsl:value-of select="f:monthNumFromName($testValue)"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>


</xsl:stylesheet>
