trigger FC_OpportunityTrigger on Opportunity (before insert, before update, after insert, after update) {
    fcf.TriggerFactory.createHandler('FC_OpportunityHandler');
}