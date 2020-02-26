trigger FC_ZuoraCustomerAccountTrigger on Zuora__CustomerAccount__c (before update) {
    fcf.TriggerFactory.createHandler('FC_ZuoraCustomerAccountHandler');
}