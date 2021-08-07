
# Brill XSLT
###  JATS Journal Publishing DTD to MODS 3.7 transformation

Brill's metadata had four critical issues that rendered invalid XML result documents and invalid archival copies of the source document. There were also two cosmetic issues with author names and affiliation included within this stylesheet, and explained below. 

A custom stylesheet was created to render valid archival copies of the source documents using the JATS Publishing DTD, then capturing and transforming it into MODS version 3.7.

  
## Summary of Customizations
#### New output statement
1. Added a new output statement directly within the *[brill.xsl](https://github.com/CarlosMtz3/Brill-XSLT-Transform/blob/master/customs/brill.xsl)* in order to correct the both the public and system doctypes. Prior to this correction the metadata provided by Brill was invalid because it was unable to locate MathML. 

> **a. Corrected output statement**
>     <xsl:output version="1.0" encoding="UTF-8" name="archive-original"
>     method="xml" indent="yes" doctype-public="-//NLM//DTD JATS (Z39.96)
>     Journal Publishing DTD with MathML3 v1.1 20151215//EN" 
>     doctype-system="http://jats.nlm.nih.gov/publishing/1.1/JATS-journalpublishing1-mathml3.dtd"/>
>     
> **b. Corresponding result-document**
>     <xsl:result-document method="xml" encoding="UTF-8" indent="yes"
>                 href="file:///{`$`workingDir}A-{replace(`$`originalFilename, 
> '(.`*`/)(.`*`)(\.xml)', '$2')}_{position()}.xml"
>                 format="archive-original">


#### dateIssued tag issues
2. Originally the `<mods:originInfo/mods:dateIsssued>` template was complex and used apply-templates and modes to achieve a desired result.  From the example files provided this template may be simplified by not capturing metadata from a pub-date element containing an attribute set to "issued".  
The processing-instruction is set to copy any pub-date element that does not have a date-type attribute set to "issued", (see the example below)   

##### This [source document](https://github.com/CarlosMtz3/Brill-XSLT-Transform/blob/master/temp/brill-xml-samples/1876312X_052_04_s001_text.xml) contains the following: 
	

>     <pub-date publication-format="online" date-type="article">
>     <day>06</day>
>     <month>08</month>
>     <year>2020</year>
>     </pub-date>
>     
>     <pub-date publication-format="online" date-type="issue">
>     <day>12</day>
>     <month>07</month>
>     <year>2021</year>
>     </pub-date>

##### The current "originInfo" template provides the following undesried result.
>     <originInfo>
>     		<dateIssued keyDate="yes" encoding="w3cdtf">2020-08-06</dateIssued>
>     </originInfo>
>     <originInfo>
>     		<dateIssued keyDate="yes" encoding="w3cdtf">2021-12-07</dateIssued>
>     </originInfo>

##### Solution:  

    <xsl:for-each select="/article/front/article-meta/pub-date[@date-type!='issue']">
##### Desired result:
    <originInfo>
    	<dateIssued keyDate="yes" encoding="w3cdtf">2020-08-06</dateIssued>
    </originInfo>

##### What caused the issue with dateIssued Tags?
The original template matched pub-date more than once and renders invalid MODS XML due to the inclusion of the @keydate attribute and thus was simplified to match any attribute that did not contain issue as the @date-type attribute (see example below) 


		e.g., pub-date[@date-type != 'issue']

Unfortunately, the results files did not all contain dateIssued MODS tags, therefore three templates and named template (i.e., "brill_originInfo")  use apply-templates to render dateIssued tags where @publication-format='online' and/or @date-type = article. 

A few Brill files contained only one date having the publication-format='online' and the @date-type='issue' . These files render a dateOther MODS tag.

####	Transforming pub-date to modsPart

4. Thus, allowing any other pub-date elements to be copied and in this case parsed into one of the following **5** metadata tags: **month, day, year, season, and string-date**. 

#### An Example of the `<mods:part>` tag:
>      <part>
>              <detail type="volume">
>                 <number>52</number>
>                 <caption>v.</caption>
>              </detail>
>              <detail type="issue">
>                 <number>4</number>
>                 <caption>no.</caption>
>              </detail>
>              <text type="year">2020</text>
>              <text type="month">08</text>
>              <text type="day">25</text>*
>              <extent unit="pages">
>                 <start>428</start>
>                 <end>443</end>
>                 <total>16</total>
>              </extent>
>           </part>


### Matching Author to Affiliation
5. This has been a longstanding issue with any JATS to MODS transformation, because each author is given an "aff[@id]" containing a value to match an affiliation's "ref[@rid]  listed below. 
 
	 The JATS_to_MODS_30.xsl handles this using many variables and conditions. It can be simplified by using the following XPath expression. 

	**//aff[@id = current()/xref/@rid]**
> **XPath Explained:** The **affiliation id** (i.e., "*aff[@id]*") is set to correspond and/or match the to affiliation reference listed below (i.e."*xref[@rid]*"). This can be achieved by adding the current( ) function after bracketing the @id attribute as seen here:
> ** aff[@id=current( )]  **
5. Similarly if we want to get the corresponding author's email included within  the affiliation, we can employ similar methodology. 

	**//fn[@id = current()/xref/@rid]**
> **XPath Explained:** In this case “_fn[@id]_” corresponds to “_xref[@rid]_”.
