public without sharing class FC_ChargeMonthlyRevenueCleanerBatchable implements Database.Batchable<sObject> {

    public FC_ChargeMonthlyRevenueCleanerBatchable() {
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        FC_Charge_Monthly_Revenue_Settings__c config = FC_Charge_Monthly_Revenue_Settings__c.getOrgDefaults();
        return Database.getQueryLocator([
                select Id
                from FC_Charge_Monthly_Revenue__c
                where Import_Process_ID__c != :config.Active_Import_Process_ID__c
        ]);
    }

    public void execute(Database.BatchableContext context, List<FC_Charge_Monthly_Revenue__c> scope) {
        if (scope != null && !scope.isEmpty()) {
            delete scope;
        }
    }

    public void finish(Database.BatchableContext context) {
    }

}