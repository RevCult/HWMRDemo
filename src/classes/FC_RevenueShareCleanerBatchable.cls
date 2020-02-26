public without sharing class FC_RevenueShareCleanerBatchable implements Database.Batchable<sObject> {

    public DateTime latestBatchableProcessedOn;

    public FC_RevenueShareCleanerBatchable(DateTime latestBatchableProcessedOn) {
        this.latestBatchableProcessedOn = latestBatchableProcessedOn;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        String soql = 'select Id from FC_Revenue_Share__c where Opportunity__r.FC_Bypass_Revenue_Share_Calculation__c = false ';
        DateTime latestBatchableProcessedOn = this.latestBatchableProcessedOn;
        if (latestBatchableProcessedOn != null) {
            soql += 'and Obsolete__c = true and Processed_By_Batchable_On__c < :latestBatchableProcessedOn';
        }
        return Database.getQueryLocator(soql);
    }

    public void execute(Database.BatchableContext context, List<FC_Revenue_Share__c> scope) {
        if (scope != null && !scope.isEmpty()) {
            delete scope;
        }
    }

    public void finish(Database.BatchableContext context) {
        if (this.latestBatchableProcessedOn == null) {
            FC_Revenue_Share_Settings__c config = FC_Revenue_Share_Settings__c.getOrgDefaults();
            config.Last_Run_On__c = null;
            upsert config;
        }
    }

}