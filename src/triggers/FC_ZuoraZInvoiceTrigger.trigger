trigger FC_ZuoraZInvoiceTrigger on Zuora__ZInvoice__c (before update) {
    fcf.TriggerFactory.createHandler('FC_ZuoraZInvoiceHandler');
}