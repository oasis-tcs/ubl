<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
        defaultPhase="only-phase">
  <title>Business rules for maximum total value</title>
  <ns prefix="cbc" 
      uri="urn:oasis:names:draft:ubl:schema:xsd:CommonBasicComponents-2"/>
  <ns prefix="cac"
      uri="urn:oasis:names:draft:ubl:schema:xsd:CommonAggregateComponents-2"/>
  <phase id="only-phase">
    <active pattern="code-list-rules"/>
    <active pattern="total-limit"/>
  </phase>
  <include href="total-limit-constraint.sch"/>
  <include href="order-constraints.sch"/>
</schema>
