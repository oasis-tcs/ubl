<?xml version="1.0" encoding="UTF-8"?>
<pattern xmlns="http://purl.oclc.org/dsdl/schematron" id="total-limit">
  <rule context="cbc:ToBePaidAmount">
    <assert test=". &lt; 10000">Total amount '<value-of select="."/>' cannot be $10,000 or more</assert>
  </rule>
</pattern>
