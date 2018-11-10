<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:example="examples:function"
  
  xmlns:examples-product="examples:product"
  xpath-default-namespace="examples:product"
  exclude-result-prefixes="examples-product"
>
  <xsl:param name="output.directory" static="yes" />
  <xsl:param name="xslt.indent"      static="yes" select="'yes'" />
  
  <!-- see http://www.saxonica.com/html/documentation/xsl-elements/param.html -->
  <xsl:output name="html5-indent"
              method="html"
              doctype-system="about:legacy-compat"
              encoding="utf-8"
              indent="yes"
              cdata-section-elements="script pre style" />
  <xsl:output name="html5-noindent"
              method="html"
              doctype-system="about:legacy-compat"
              encoding="utf-8"
              indent="no"
              cdata-section-elements="script pre style" />              
  <xsl:variable name="docformat" select="if ($xslt.indent eq 'yes') then 'html5-indent' else 'html5-noindent'" />

  <!--
    <xsl:decimal-format name="price-decimal-format" decimal-separator="," grouping-separator=" " />
    <xsl:variable name="DATE_FORMAT" select="'[D01]/[M01]/[Y0001]'" />
  -->
  
  <xsl:function name="example:fun" as="xs:string">
    <xsl:param name="arg0" as="xs:string" />
    <xsl:value-of select="$arg0" />
  </xsl:function>
  
  <xsl:template match="/database">                                                   
    <xsl:variable name="page-href" select="@name || '.html'" />
    <xsl:variable name="db" select="." />
    <xsl:message>result-document: <xsl:value-of select="$page-href" /></xsl:message>
    <xsl:result-document href="{$output.directory}/{$page-href}" format="{$docformat}">
    <html lang="fr-FR" xml:lang="fr-FR">     
      <head>
        <meta charset="utf-8" />
        <meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8" />
        <meta name="viewport" content="width=device-width" />    
        <title>Database</title>
      </head>
      <body>
        <header>
          <h1>Database</h1>
          <nav>
            <xsl:for-each select="
              for $cat in distinct-values(
                            for $i in $db/products/product/categories/@ref 
                              return tokenize($i)
                       ) return $db/categories/category[@id = $cat]">
              <a href="#cat{@id}"><xsl:value-of select="./@title" /></a>
            </xsl:for-each>
          </nav>
        </header>
      </body>
    </html>
    </xsl:result-document>
  </xsl:template>
</xsl:stylesheet>