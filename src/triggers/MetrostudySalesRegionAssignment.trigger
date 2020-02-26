trigger MetrostudySalesRegionAssignment  on MetrostudySalesRegionAssignment__c (after update) {
     TriggerFactory.createHandler(MSRATriggerHandler.class);
}