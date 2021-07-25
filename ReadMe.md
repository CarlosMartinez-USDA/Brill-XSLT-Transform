# Brill XSLT
####  JATS Journal Publishing DTD to MODS 3.7 transformation

   Brill's metadata had four critical issues that rendered invalid XML result documents and invalid archival copies of the source document. There were also two cosmetic issues with author names and affiliation included within this stylesheet, and explained below. 
	A custom stylesheet was created to render valid archival copies of the source documents using the JATS Publishing DTD, then capturing and transforming it into MODS version 3.7.

  
## Summary of Customizations
1. Added a new output statement directly within the *brill.xsl* in order to correct the both the public and system doctypes. Prior to this correction the metadata provided by Brill was invalid because it was unable to locate MathML. 

> **a. Corrected output statement**
>     <xsl:output version="1.0" encoding="UTF-8" name="archive-original"
>     method="xml" indent="yes" doctype-public="-//NLM//DTD JATS (Z39.96)
>     Journal Publishing DTD with MathML3 v1.1 20151215//EN" 
>     doctype-system="http://jats.nlm.nih.gov/publishing/1.1/JATS-journalpublishing1-	mathml3.dtd"/>
>     
> **b. Corresponding result-document**
>     <xsl:result-document method="xml" encoding="UTF-8" indent="yes"
>                 href="file:///{`$`workingDir}A-{replace(`$`originalFilename, 
> '(.`*`/)(.`*`)(\.xml)', '$2')}_{position()}.xml"
>                 format="archive-original">

2. From the example files provided a correction to the <mods:originInfo> template was made. The processing-instruction being to copy any **pub-date[@date-type]**  element metadata containg the date-type  attribute which **does not** equal "*issue*". 
	**(e.g., pub-date[@date-type **!=** "issue"])**

3. Similarly, a simplification of the <mods:part> element again instructs to not copy metadata from 
   (e.g., pub-date[@date-type **!=** 'issue'])

	Thus, allowing any other pub-date elements to be copied and in this case parsed into one of the following **5** metadata tags: **month, day, year, season, and string-date**. 

#### An Example of the <mods:part> tag:
>      <part>
>              <detail type="volume">
>                 <number>52</number>
>                 <caption>v.</caption>
>              </detail>
>              <detail type="issue">
>                 <number>4</number>
>                 <caption>no.</caption>
>              </detail>
>              *<text type="year">2020</text>
>              <text type="month">08</text>
>              <text type="day">25</text>*
>              <extent unit="pages">
>                 <start>428</start>
>                 <end>443</end>
>                 <total>16</total>
>              </extent>
>           </part>

> **//aff[@id = current()/xref/@rid]**

> Thus "*aff[@id]*"  corresponds to "*xref[@rid]*".  

6. Similarly if we want to get the corresponding author's email included within  the affiliation, we can employ similar methodology. 

>**//fn[@id = current()/xref/@rid]**

> In this case “_fn[@id]_” corresponds to “_xref[@rid]_”.
