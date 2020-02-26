trigger FC_AccountTrigger on Account (before insert, before update) {
    fcf.TriggerFactory.createHandler('FC_AccountHandler');
}