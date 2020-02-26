trigger FC_FcBillingInstructionStepTrigger on FC_Billing_Instruction_Step__c (before insert, before update, after insert, after update) {
    fcf.TriggerFactory.createHandler('FC_FcBillingInstructionStepHandler');
}