<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:f="http://functions"
    xmlns:saxon="http://saxon.sf.net/" xmlns:ali="http://www.niso.org/schemas/ali/1.0/"
    xmlns="http://www.loc.gov/mods/v3" exclude-result-prefixes="xd xs f saxon xlink xsi xml ali">
    <xsl:import href="../jats_to_mods_30.xsl"/>

    <xsl:output method="xml" encoding="UTF-8" name="archive-original" version="1.0"
        doctype-public="-//NLM//DTD JATS (Z39.96) Journal Publishing DTD v1.1 20151215//EN"
        doctype-system="https://jats.nlm.nih.gov/publishing/1.1/JATS-journalpublishing1.dtd"/>


    <xd:doc scope="stylesheet" id="brill">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jul 16, 2021</xd:p>
            <xd:p><xd:b>Authored by:</xd:b> Carlos Martinez</xd:p>
            <xd:p><xd:b>Edited on:</xd:b>Aug 7, 2021</xd:p>
            <xd:p><xd:b>Edited by:</xd:b>Carlos Martinez</xd:p>
            <xd:ul>
                <xd:p><xd:b>Issues:</xd:b>Required to create valid metadata</xd:p>
                <xd:li>
                    <xd:p><xd:b>Issue #1</xd:b>: Brill's metadata uses the <xd:a
                            href="ttps://jats.nlm.nih.gov/publishing/1.1/JATS-journalpublishing1.dtd">
                            <xd:i>NISO JATS DTD version 1.1</xd:i></xd:a>. The jats_to_mods.xsl
                        archive-original result document produces A-file metadata with the incorrect
                        DTD thus causing the archival copy of the source metadata to render
                        invalid</xd:p>
                    <xd:p><xd:b>Solution</xd:b>: Added an output statement containing the system and
                        public ids to the correct version of the JATS publishing DTD to render valid
                        archival metadata</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:b>Issue #2</xd:b>: Brill's metadata rendered two mods
                            <xd:i>originInfo</xd:i> tags. They both contained the attribute
                            <xd:i>keyDate</xd:i>" with the value set to "yes" (e.g.,
                            <xd:i>keyDate</xd:i>="yes")</xd:p>
                    <xd:p><xd:b>Solution</xd:b>: This stylesheet uses the named template <xd:a
                            docid="brill_origin">"brill_origin"</xd:a> to choose only one date based
                        on the conditions contained therein.</xd:p>
                </xd:li>
                <xd:li>
                    <xd:p><xd:b>Issue #3:</xd:b> The text type date tags contained within the
                        mods:part tag need to select and match only one date from the pub-date
                        element. The date should reflect the choice made in the
                            <xd:i>dateIssued</xd:i> element.</xd:p>
                    <xd:p><xd:b>Solution: </xd:b> Applying similar conditional logic this stylesheet
                        accomplishes this using the<xd:a docid="brill_modsPart"
                            >"brill_modsPart"</xd:a> template</xd:p>
                </xd:li>
            </xd:ul>
            <xd:ul><xd:b>Enhancements:</xd:b> Recommended changes for more efficient
                            processing<xd:li><xd:p><xd:b>Enhancement #1</xd:b>: Pairing the
                        affiliation to the correct author is overly complicated in
                        jats_to_mods30.xsl</xd:p>Purpose: This stylesheet uses the named template
                        <xd:a docid="brill-authors-name-info">"brill-authors-name-info"</xd:a> using
                    an XPath expression to match aff[@id] to xref/@rid using the current() function.
                            <xd:p><xd:i>XPath expression</xd:i>: (e.g.,
                        aff[@id=current()/xref/@rid]) </xd:p></xd:li><xd:li>
                    <xd:p><xd:b>Enhancement #2</xd:b>: Conditional added to get corresponding
                        author's email if it exists.</xd:p>
                    <xd:p>Purpose: To provide readers with information needed to correspond with the
                        author. <xd:a docid="brill-authors-name-info"
                            >"brill-authors-name-info"</xd:a> an similar enhancement was added to
                        include the corresponding author's email if it exists. </xd:p>
                    <xd:p><xd:i>XPath Expression:</xd:i> (e.g., fn[@id=current()/xref/@rid]) </xd:p>
                </xd:li></xd:ul>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:result-document method="xml" encoding="UTF-8" indent="yes"
            href="file:///{$workingDir}A-{replace($originalFilename,'(.*/)(.*)(\.xml)', '$2')}_{position()}.xml"
            format="archive-original">
            <xsl:copy-of select="."/>
        </xsl:result-document>
        <!-- uncomment lines 79-80 if no N-file is produce-->
        <xsl:result-document method="xml" encoding="UTF-8" indent="yes"
            href="file:///{$workingDir}N-{replace($originalFilename, '(.*/)(.*)(\.xml)', '$2')}_{position()}.xml">
            <mods version="3.7">
                <xsl:namespace name="xsi">http://www.w3.org/2001/XMLSchema-instance</xsl:namespace>
                <xsl:attribute name="xsi:schemaLocation"
                    select="normalize-space('http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-7.xsd')"/>
                <xsl:apply-templates select="article/front/article-meta/title-group"/>
                <xsl:apply-templates select="article/front/article-meta/contrib-group"/>

                <!-- Check if need to add affiliation note -->
                <xsl:apply-templates select="article/front/article-meta/(. | contrib-group)/aff"
                    mode="note"/>

                <!-- Default -->
                <typeOfResource>text</typeOfResource>
                <genre>article</genre>

                <xsl:call-template name="brill_origin"/>

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
                    <xsl:call-template name="brill_modsPart"/>
                </relatedItem>

                <xsl:apply-templates
                    select="article/front/article-meta/article-id[@pub-id-type] | /article/front[1]/article-meta[1]/doi-group[1]/article-doi[1]"/>
                <xsl:call-template name="extension"/>

            </mods>
            <!--uncomment this line 121 and remove text outside of the tag-->
        </xsl:result-document>
    </xsl:template>

    <xd:doc scope="component" id="contrib">
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
                    <xsl:call-template name="brill-authors-name-info"/>
                </name>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc scope="component" id="brill-authors-name-info">
        <xd:desc>
            <xd:p>Formatting for personal names</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="brill-authors-name-info">
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
        <!--Xpath uses the id aattribute and the current() function to the appropriate author (xref/@rid) -->
        <xsl:for-each
            select="/article/front/article-meta/contrib-group/aff[@id = current()/xref/@rid]">
            <xsl:variable name="this">
                <xsl:apply-templates mode="affiliation"/>
            </xsl:variable>
            <affiliation>
                <xsl:value-of select="normalize-space($this)"/>
            </affiliation>
        </xsl:for-each>
        <!--corresponding author's email-->
        <xsl:choose>
            <xsl:when test="/article/front/article-meta/author-notes/fn[@id]">
                <xsl:for-each
                    select="/article/front/article-meta/author-notes/fn[@id = current()/xref/@rid]">
                    <xsl:variable name="this">
                        <xsl:apply-templates mode="affiliation"/>
                    </xsl:variable>
                    <affiliation>
                        <xsl:value-of select="normalize-space($this)"/>
                    </affiliation>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="/article/back/fn-group/fn[@id]">
                <xsl:for-each select="/article/back/fn-group/fn[@id = current()/xref/@rid]">
                    <xsl:variable name="this">
                        <xsl:value-of select="concat(p, email)"/>
                        <xsl:apply-templates mode="affiliation"/>
                    </xsl:variable>
                    <affiliation>
                        <xsl:value-of select="normalize-space($this)"/>
                    </affiliation>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
        <role>
            <roleTerm type="text">author</roleTerm>
        </role>
    </xsl:template>



    <xd:doc scope="component" id="brill_origin">
        <xd:desc>
            <xd:p><xd:b>Issue:</xd:b>Transforming JATS pub-date to MODS dateIssued elements, thus
                providing two dateIssued tags with different values, while both containing the
                keyDate attribute set to "yes"</xd:p>
            <xd:p><xd:b>Example of issue:</xd:b>The following two dateIssued elements are actual
                results before customization:</xd:p>
            <xd:p>
                <![CDATA[]
                <dateIssued encoding="w3cdtf" keyDate="yes">2020-09-30</dateIssued>
                <dateIssued encoding="w3cdtf" keyDate="yes>2021-07-12</dateIssued>
             ]]>
            </xd:p>
            <xd:p><xd:b>Customization:</xd:b>Thus new conditional criteria had to be implemented to
                match only one pub-date element within the source metadata. </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="brill_origin">
        <originInfo>
            <xsl:for-each select="/article/front/article-meta">
                <!--condition 1-->
                <xsl:choose>
                    <xsl:when
                        test="pub-date[@publication-format = 'online' and @date-type = 'article']">
                        <xsl:apply-templates
                            select="pub-date[@publication-format = 'online' and @date-type = 'article']"
                            mode="brill_origin"/>
                    </xsl:when>
                    <!--condition 2-->
                    <xsl:when
                        test="pub-date[@publication-format = 'online' and not(@date-type = ('issue', 'article'))]">
                        <xsl:apply-templates
                            select="pub-date[@publication-format = 'online' and not(@date-type = ('issue', 'article'))]"
                            mode="brill_origin"/>
                    </xsl:when>
                    <!--condition 3-->
                    <xsl:when
                        test="pub-date[@date-type = 'issue' and @publication-format = 'online']">
                        <xsl:apply-templates
                            select="pub-date[@date-type = 'issue' and @publication-format = 'online']"
                            mode="brill_other"/>
                    </xsl:when>
                    <!--condition 4-->
                    <xsl:when test="not(pub-date)">
                        <xsl:apply-templates select="history/date[@date-type = 'accepted']"
                            mode="brill_origin"/>
                        <!--condition 5-->
                        <xsl:if test="not(//history/date[@date-type = 'accepted'])">
                            <xsl:apply-templates select="permissions/copyright-year"
                                mode="brill_origin"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <dateOther encoding="w3cdtf">
                            <xsl:attribute name="type">
                                <xsl:choose>
                                    <xsl:when test="pub-date[@publication-format = 'print']">
                                        <xsl:value-of
                                            select="pub-date[@publication-format = 'print']"/>
                                    </xsl:when>
                                    <xsl:when test="pub-date[@publication-format = 'online']">
                                        <xsl:value-of
                                            select="pub-date[@publication-format = 'online']"/>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:value-of
                                select="pub-date[string-join((year, f:checkMonthType(month[not(. = '')]), format-number(day[not(. = '')], '00'))[. != 'NaN'], '-')]"
                            />
                        </dateOther>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </originInfo>
    </xsl:template>

    <!--@publication-format = 'online' and @date-type = 'article'-->
    <xd:doc scope="component" id="dateIssued_origin">
        <xd:desc>
            <xd:p>Online publication date added as 'dateIssued.' Brill's print publication date
                contains only the year, as such the online publication is preferred. </xd:p>
            <xd:p>Checks that 'day' is not 'NaN'. Month function checks that 'month' is present
                andnot 'null.'</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="pub-date[@publication-format = 'online' and @date-type = 'article']"
        mode="brill_origin">
        <dateIssued encoding="w3cdtf" keyDate="yes">
            <xsl:value-of
                select="string-join((year, f:checkMonthType(month[not(. = '')]), format-number(day[not(. = '')], '00'))[. != 'NaN'], '-')"
            />
        </dateIssued>
    </xsl:template>

    <!--evaluates true if @publication-format='online'-->
    <xd:doc scope="component" id="dateIssued_e-origin">
        <xd:desc>Electronic publication date as "dateIssued." </xd:desc>
    </xd:doc>
    <xsl:template
        match="pub-date[@publication-format = 'online' and not(@date-type = ('issue', 'article'))] | history/date[@date-type = 'accepted']"
        mode="brill_origin">
        <dateIssued encoding="w3cdtf" keyDate="yes">
            <xsl:value-of
                select="string-join((year, f:checkMonthType(month)[not(. = '')], format-number(day[not(. = '')], '00'))[. != 'NaN'], '-')"
            />
        </dateIssued>
    </xsl:template>


    <!--date-type="issue" and @publication-format='online'-->
    <xd:doc scope="component" id="dateOther">
        <xd:desc>Electronic publication date for dateOther element is matched when
            @publication-format='online' and @date=type='issued' </xd:desc>
    </xd:doc>
    <xsl:template match="pub-date[@date-type = 'issue' and @publication-format = 'online']"
        mode="brill_other">
        <dateOther encoding="w3cdtf" type="electronic">
            <xsl:value-of
                select="string-join((year, f:checkMonthType(month)[not(. = '')], format-number(day[not(. = '')], '00'))[. != 'NaN'], '-')"
            />
        </dateOther>
    </xsl:template>




    <xd:doc>
        <xd:desc> Uses copyright date as the date of publication. </xd:desc>
    </xd:doc>
    <xsl:template match="//copyright-year" mode="brill_origin">
        <dateIssued encoding="w3cdtf" keyDate="yes">
            <xsl:value-of select="."/>
        </dateIssued>
    </xsl:template>


    <!--Brill modsPart-->
    <xd:doc scope="component" id="brill_modsPart">
        <xd:desc>
            <xd:p>Similar to the purpose of the modsPart template in the <xd:a
                    href="../jats_to_mods_30.xsl"> main JATS to MODS stylesheet</xd:a> this template
                uses a series of conditonal statements to select the elements contained in
                mods:Part. Specifically the <![CDATA[<text type="year/month/day">]]> metatags</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:template name="brill_modsPart">
        <part>
            <xsl:apply-templates
                select="/article/front/article-meta/volume[not(@content-type = 'year')]"/>
            <xsl:apply-templates select="/article/front/article-meta/issue"/>
            <xsl:choose>
                <!--conditoins 1-3-->
                <xsl:when
                    test="/article/front/article-meta/pub-date[@publication-format = 'online' or @date-type = ('issue', 'article')]">
                    <xsl:apply-templates
                        select="/article/front/article-meta/pub-date[@publication-format = 'online' or @date-type = ('issue', 'article')][1]"
                        mode="brill_modsPart"/>
                </xsl:when>
                <!--conditoins 4-->                
                <xsl:when test="not(pub-date)">
                    <xsl:apply-templates select="//history/date[@date-type = 'accepted'][1]"
                        mode="brill_modsPart"/>
                    <!--conditon 5-->
                    <xsl:if test="not(pub-date) and not(history/date[@date-type = 'accepted'])">
                        <xsl:apply-templates select="//permissions/copyright-year"
                            mode="brill_modsPart"/>
                    </xsl:if>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="/article/front/article-meta/fpage or /article/front/article-meta/elocation-id or /article/front[1]/article-meta[1]/counts[1]/page-count[1]/@count">
                <xsl:call-template name="modsPages"/>
            </xsl:if>
        </part>
    </xsl:template>


    <xd:doc scope="component" id="brill_modsPart">
        <xd:desc>
            <xd:p>The date contained within pub-date[@date-type='article'] is parsed into three to
                five metatags representing the month day year season or era.</xd:p>
            <xd:p>condition 1-3</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template
        match="//pub-date[@publication-format = 'online' or @date-type = ('issue', 'article')][1]"
        mode="brill_modsPart">
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

    <xd:doc>
        <xd:desc><xd:p>Builds the mods:part type metatags to display the day the article was accepted. If
            no publication date, copyright date or other substantive date of distribution can be
            established</xd:p>
            <xd:p>condition 4</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="//history/date[@date-type = 'accepted'][1]" mode="brill_modsPart">
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

    <xd:doc>
        <xd:desc><xd:p>Uses copyright date as the date of publication</xd:p>
        <xd:p>condition 5</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="//permissions/copyright-year" mode="brill_modsPart">
        <text type="year">
            <xsl:value-of select="."/>
        </text>
    </xsl:template>

    <!-- doi number -->
    <xd:doc>
        <xd:desc>
            <xd:p>The DOI is selected and transformed from the article-id element to the identifier
                and location/url elements in mods</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="article-id[@pub-id-type = 'doi']">
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
        <identifier type="brill">
            <xsl:value-of select="."/>
        </identifier>
    </xsl:template>

</xsl:stylesheet>
