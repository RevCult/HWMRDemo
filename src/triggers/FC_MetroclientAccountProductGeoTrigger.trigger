trigger FC_MetroclientAccountProductGeoTrigger on MetroclientAccountProductGeography__c (before insert, before update) {
    fcf.TriggerFactory.createHandler('FC_MetroclientAccountProductGeoHandler');
}