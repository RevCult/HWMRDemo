trigger FC_OpportunityLineItemTrigger on OpportunityLineItem (before insert, before update, after insert,
        after update, after delete) {
    fcf.TriggerFactory.createHandler('FC_OpportunityLineItemHandler');
}