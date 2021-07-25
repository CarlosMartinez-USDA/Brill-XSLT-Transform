<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

  <!-- Parameters -->
  <xsl:param name="bib"/>
  <xsl:param name="status"/>
  <xsl:variable name="pid" select="concat('bib:', $bib  )"/>
  <!-- Parameters -->

  <xsl:template match="/">


    <foxml:digitalObject VERSION="1.1" PID="{$pid}"
      xmlns:foxml="info:fedora/fedora-system:def/foxml#"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="info:fedora/fedora-system:def/foxml# http://www.fedora.info/definitions/1/0/foxml1-1.xsd">
      <foxml:objectProperties>
        <foxml:property NAME="info:fedora/fedora-system:def/model#state" VALUE="Active"/>
        <foxml:property NAME="info:fedora/fedora-system:def/model#label" VALUE="{$bib}"/>
        <foxml:property NAME="info:fedora/fedora-system:def/model#ownerId" VALUE="voyager"/>
      </foxml:objectProperties>
<!--
      <foxml:datastream ID="DC" STATE="A" CONTROL_GROUP="X" VERSIONABLE="false">
        <foxml:datastreamVersion ID="DC1.0" LABEL="Dublin Core Record for this object"
          MIMETYPE="text/xml" FORMAT_URI="http://www.openarchives.org/OAI/2.0/oai_dc/">
          <foxml:xmlContent>
            <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
              xmlns:dc="http://purl.org/dc/elements/1.1/"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
              <dc:title>
                <xsl:value-of select="$bib"/>
              </dc:title>
              <dc:identifier>
                <xsl:value-of select="$pid"/>
              </dc:identifier>
            </oai_dc:dc>
          </foxml:xmlContent>
        </foxml:datastreamVersion>
      </foxml:datastream>
-->
      <foxml:datastream ID="RELS-EXT" STATE="A" CONTROL_GROUP="X" VERSIONABLE="false">
        <foxml:datastreamVersion ID="RELS-EXT.0" LABEL="RDF Statements"
          MIMETYPE="application/rdf+xml" FORMAT_URI="info:fedora/fedora-system:FedoraRELSExt-1.0">
          <foxml:xmlContent>
            <rdf:RDF xmlns:bibo="http://purl.org/ontology/bibo/"
              xmlns:fedora="info:fedora/fedora-system:def/relations-external#"
              xmlns:fedora-model="info:fedora/fedora-system:def/model#"
              xmlns:islandora="http://islandora.ca/ontology/relsext#"
              xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
              <rdf:Description rdf:about="info:fedora/{$pid}">
                <fedora:isMemberOfCollection rdf:resource="info:fedora/islandora:article_repository"/>
                <fedora-model:hasModel rdf:resource="info:fedora/nal-model:Article"/>
                <bibo:status>
                  <xsl:value-of select="$status"/>
                </bibo:status>
              </rdf:Description>
            </rdf:RDF>
          </foxml:xmlContent>
        </foxml:datastreamVersion>
      </foxml:datastream>
      <foxml:datastream ID="MODS" STATE="A" CONTROL_GROUP="M" VERSIONABLE="true">
        <foxml:datastreamVersion ID="MODS.0" LABEL="MODS" MIMETYPE="text/xml"
          FORMAT_URI="http://www.loc.gov/mods/v3/">
          <foxml:contentLocation TYPE="INTERNAL_ID" REF="file:///data/mods/mods.xml"/>
        </foxml:datastreamVersion>
      </foxml:datastream>
    </foxml:digitalObject>

  </xsl:template>
</xsl:stylesheet>
