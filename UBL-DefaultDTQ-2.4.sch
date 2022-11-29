<!--
    This Schematron schema incorporates the UBL 2.4 CVA information
    converted to a Schematron pattern and the UBL 2.4 additional
    document constraints pattern into a complete suite of constraints.
-->
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
  <title>UBL 2.4 Default Data Type Qualifications</title>
  <ns prefix="ext"
uri="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"/>
  <ns prefix="cbc" 
uri="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"/>
  <include href="UBL-DocumentConstraints-2.4.patterns.sch"/>
  <include href="UBL-DefaultDTQ-2.4.pattern.sch"/>
</schema>
