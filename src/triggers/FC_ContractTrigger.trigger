trigger FC_ContractTrigger on Contract (before insert, before update) {
    fcf.TriggerFactory.createHandler('FC_ContractHandler');
}