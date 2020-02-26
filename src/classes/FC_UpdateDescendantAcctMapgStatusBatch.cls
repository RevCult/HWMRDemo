public without sharing class FC_UpdateDescendantAcctMapgStatusBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
                select Id, FC_Ultimate_Parent_Account__r.FC_MAPG_Status__c
                from Account
                where ParentId != null
        ]);
    }

    public void execute(Database.BatchableContext context, List<Account> scope) {
        if (scope != null && !scope.isEmpty()) {
            for (Account record : scope) {
                record.FC_MAPG_Status__c = record.FC_Ultimate_Parent_Account__r.FC_MAPG_Status__c;
            }
            update scope;
        }
    }

    public void finish(Database.BatchableContext context) {
    }

}