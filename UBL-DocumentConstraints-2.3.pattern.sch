<?xml version="1.0" encoding="UTF-8"?>
<pattern xmlns="http://purl.oclc.org/dsdl/schematron"
         id="UBL-DocumentConstraints-2.3"><!--
UBL 2.3 Additional Document Constraints
  
20200708-2250(UTC)

A set of Schematron rules against which UBL 2.3 document constraints are
tested where in the scope of a second pass validation after schema validation
has been performed.

Required namespace declarations as indicated in this set of rules:

<ns prefix="ext" uri="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"/>
<ns prefix="cbc" uri="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"/>

The following is a summary of the additional document constraints enumerated
in UBL 2.3:

[IND1] All UBL instance documents SHALL validate to a corresponding schema.

 - this is tested in the first pass by schema validation, not in the second
   pass with Schematron validation

[IND2] All UBL instance documents SHALL identify their character encoding
       within the XML declaration.

 - this cannot be tested using Schematron as the information is not part of
   XDM (the XML Data Model)

[IND3] In conformance with ISO IEC ITU UN/CEFACT eBusiness Memorandum of
       Understanding Management Group (MOUMG) Resolution 01/08 (MOU/MG01n83)
       as agreed to by OASIS, all UBL XML SHOULD be expressed using UTF-8.

 - this cannot be tested using Schematron as the information is not part of
   XDM (the XML Data Model)

[IND4] (This archaic test no longer exists)

[IND5] UBL-conforming instance documents SHALL NOT contain an element devoid of content or containing null values.

 - implemented below
 - per the documentation, this does not apply to the arbitrary content of
   an extension

[IND6] The absence of a construct or data in a UBL instance document SHALL NOT carry meaning.

 - this cannot be tested using Schematron as it is an application constraint
   on the interpretation of the document

[IND7] Where two or more sibling “Text. Type” elements of the same name exist in a document, no two can have the same “languageID” attribute value.

 - implemented below

[IND8] Where two or more sibling “Text. Type” elements of the same name exist in a document, no two can omit the “languageID” attribute.

 - implemented below

[IND9] UBL-conforming instance documents SHALL NOT contain an attribute devoid of content or containing null values.

 - implemented below
 - per the documentation, this does not apply to the arbitrary content of
   an extension
-->
   <rule id="Extensions-IND5-IND9"
         context="ext:ExtensionContent//*[not(*) and not(normalize-space(.))] |                   ext:ExtensionContent//@*[not(normalize-space(.))]"/>
   <rule context="*[not(*) and not(normalize-space(.))]">
      <report id="IND5" test="true()">[IND5] Elements SHALL NOT be empty</report>
   </rule>
   <rule context="@*[not(normalize-space(.))]">
      <report id="IND9" test="true()">[IND9] Attributes SHALL NOT be empty</report>
   </rule>
   <rule context="cbc:AllowanceChargeReason[1] | cbc:Description[1] | cbc:Note[1] | cbc:JustificationDescription[1] | cbc:ProcessDescription[1] | cbc:ConditionsDescription[1] | cbc:ElectronicDeviceDescription[1] | cbc:Purpose[1] | cbc:Weight[1] | cbc:CalculationExpression[1] | cbc:MinimumImprovementBid[1] | cbc:AwardingCriterionDescription[1] | cbc:TechnicalCommitteeDescription[1] | cbc:LowTendersDescription[1] | cbc:PrizeDescription[1] | cbc:PaymentDescription[1] | cbc:WarrantyInformation[1] | cbc:Remarks[1] | cbc:Content[1] | cbc:SummaryDescription[1] | cbc:TariffDescription[1] | cbc:CarrierServiceInstructions[1] | cbc:CustomsClearanceServiceInstructions[1] | cbc:ForwarderServiceInstructions[1] | cbc:SpecialServiceInstructions[1] | cbc:HandlingInstructions[1] | cbc:Information[1] | cbc:SpecialInstructions[1] | cbc:DeliveryInstructions[1] | cbc:HaulageInstructions[1] | cbc:ModificationReasonDescription[1] | cbc:OptionsDescription[1] | cbc:CriterionDescription[1] | cbc:SpecialTerms[1] | cbc:LossRisk[1] | cbc:Instructions[1] | cbc:BackorderReason[1] | cbc:OutstandingReason[1] | cbc:XPath[1] | cbc:DocumentDescription[1] | cbc:RoleDescription[1] | cbc:LimitationDescription[1] | cbc:Expression[1] | cbc:CandidateStatement[1] | cbc:PaymentNote[1] | cbc:Justification[1] | cbc:Frequency[1] | cbc:AdditionalInformation[1] | cbc:Keyword[1] | cbc:TradingRestrictions[1] | cbc:ReplenishmentOwnerDescription[1] | cbc:ValueQualifier[1] | cbc:ListValue[1] | cbc:Title[1] | cbc:JurisdictionLevel[1] | cbc:Article[1] | cbc:Conditions[1] | cbc:GroupingLots[1] | cbc:ShipsRequirements[1] | cbc:MeterReadingComments[1] | cbc:PackingMaterial[1] | cbc:ExemptionReason[1] | cbc:InstructionNote[1] | cbc:PlannedOperationsDescription[1] | cbc:PlannedWorksDescription[1] | cbc:PlannedInspectionsDescription[1] | cbc:CargoAndBallastTankConditionDescription[1] | cbc:ShipRequirementsDescription[1] | cbc:PriceChangeReason[1] | cbc:ProcessReason[1] | cbc:FeeDescription[1] | cbc:ExclusionReason[1] | cbc:Resolution[1] | cbc:PersonalSituation[1] | cbc:RejectReason[1] | cbc:MonetaryScope[1] | cbc:Response[1] | cbc:Extension[1] | cbc:ServiceType[1] | cbc:DemurrageInstructions[1] | cbc:StatusReason[1] | cbc:Text[1] | cbc:Location[1] | cbc:TaxExemptionReason[1] | cbc:WeightingConsiderationDescription[1] | cbc:CertificationLevelDescription[1] | cbc:NegotiationDescription[1] | cbc:AcceptedVariantsDescription[1] | cbc:PriceRevisionFormulaDescription[1] | cbc:FundingProgram[1] | cbc:EstimatedTimingFurtherPublication[1] | cbc:AdditionalConditions[1] | cbc:DamageRemarks[1] | cbc:SpecialTransportRequirements[1] | cbc:TransportUserSpecialTerms[1] | cbc:TransportServiceProviderSpecialTerms[1] | cbc:ChangeConditions[1] | cbc:ShippingMarks[1] | cbc:RegistrationNationality[1] | cbc:TransportationServiceDescription[1] | cbc:WorkPhase[1] | cbc:ExportReason[1] | cbc:OtherInstruction[1] | cbc:BriefDescription[1] | cbc:RegulatoryDomain[1] | cbc:CancellationNote[1] | cbc:RejectionNote[1] | cbc:WeightScoringMethodologyNote[1] | cbc:DocumentStatusReasonDescription[1] | cbc:TransportUserRemarks[1] | cbc:TransportServiceProviderRemarks[1]">
      <report id="IND7"
              test="@languageID and                    following-sibling::*[name(.)=name(current())][@languageID=current()/@languageID]">[IND7] Two or more sibling "Text.Type" cannot both have the same "languageID" attribute value.
     </report>
      <report id="IND8"
              test="not(@languageID) and                    following-sibling::*[name(.)=name(current())][not(@languageID)]">[IND8] Two or more sibling "Text.Type" cannot both omit the "languageID" attribute.
     </report>
   </rule>
</pattern>
