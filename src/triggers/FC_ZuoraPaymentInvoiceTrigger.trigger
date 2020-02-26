trigger FC_ZuoraPaymentInvoiceTrigger on Zuora__PaymentInvoice__c (after insert, after update, after delete, after undelete) {
    fcf.TriggerFactory.createHandler('FC_ZuoraPaymentInvoiceHandler');
}