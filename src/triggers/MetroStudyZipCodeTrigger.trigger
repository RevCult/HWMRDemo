trigger MetroStudyZipCodeTrigger on Metrostudy_ZIP_Code__c (after insert,after update) {
    TriggerFactory.createHandler(MetroStudyZipCodeTriggerHandler.class);
}