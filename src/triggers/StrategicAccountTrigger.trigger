trigger StrategicAccountTrigger on Account (before insert, before update) {
    //Enable bulk processing
    if (trigger.isBefore){
        AccountRD_DBDUpdate.executeAccountRD_DBDUpdate(trigger.new);
    }   
        //StategicAccount.PreProcess(accounts);
    /*
    if (trigger.isAfter)
    {
        //Check for child update and run update
        Map<id,Account> updatedAccounts = trigger.newMap;
        Account[] temp = updatedAccounts.values();
        StategicAccount.PostProcess(temp);
    }
    */
}