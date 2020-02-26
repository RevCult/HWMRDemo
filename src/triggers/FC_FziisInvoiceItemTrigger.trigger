trigger FC_FziisInvoiceItemTrigger on fziiss__Invoice_Item__c (before insert, before update, after insert, after update,
        after delete, after undelete) {
    fcf.TriggerFactory.createHandler('FC_FziissInvoiceItemHandler');
}