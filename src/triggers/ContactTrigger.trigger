trigger ContactTrigger on Contact (before insert) {
    AdBookIntegration instance = new AdBookIntegration();
    instance.handleContactTrigger(trigger.new);
}