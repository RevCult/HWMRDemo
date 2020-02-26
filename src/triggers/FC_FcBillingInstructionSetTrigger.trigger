trigger FC_FcBillingInstructionSetTrigger on FC_Billing_Instruction_Set__c (before insert, before update, after insert, after update) {
    fcf.TriggerFactory.createHandler('FC_FcBillingInstructionSetHandler');
}