public without sharing class FC_MapgUltimateParentAccountSyncBatch implements Database.Batchable<sObject> {

    public FC_MapgUltimateParentAccountSyncBatch() {
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
                select Id, FC_Ultimate_Parent_Account__c, Account__r.FC_Ultimate_Parent_Account_ID_Formula__c
                from MetroclientAccountProductGeography__c
                where FC_Ultimate_Parent_Account_Synced__c = false
        ]);
    }

    public void execute(Database.BatchableContext context, List<MetroclientAccountProductGeography__c> scope) {
        if (scope != null && !scope.isEmpty()) {
            for (MetroclientAccountProductGeography__c record : scope) {
                record.FC_Ultimate_Parent_Account__c = record.Account__r.FC_Ultimate_Parent_Account_ID_Formula__c;
            }
            update scope;
        }
    }

    public void finish(Database.BatchableContext context) {
        FC_UpdateUltimateParentMapgStatusBatch batchable = new FC_UpdateUltimateParentMapgStatusBatch();
        Database.executeBatch(batchable);
    }

}