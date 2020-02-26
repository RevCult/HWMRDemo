public without sharing class FC_UpdateUltimateParentMapgStatusBatch implements Database.Batchable<AggregateResult> {

    public FC_UpdateUltimateParentMapgStatusBatch() {
    }

    public Iterable<AggregateResult> start(Database.BatchableContext context) {
        return [
                select FC_Ultimate_Parent_Account__c, SUM(FC_One_If_Active__c) activeCount,
                        SUM(FC_One_If_Future__c) futureCount
                from MetroclientAccountProductGeography__c
                where FC_Ultimate_Parent_Account_Synced__c = true and FC_Ultimate_Parent_Account_Synced__c != null
                group by FC_Ultimate_Parent_Account__c
        ];
    }

    public void execute(Database.BatchableContext context, List<AggregateResult> scope) {
        System.debug('**** SCOPE: ' + scope);
        if (scope != null && !scope.isEmpty()) {
            Account[] accountsToUpdate = new List<Account>();
            for (AggregateResult ar : scope) {
                String mapgStatus = 'Past';
                if ((Decimal) ar.get('activeCount') > 0) {
                    mapgStatus = 'Current';
                } else if ((Decimal) ar.get('futureCount') > 0) {
                    mapgStatus = 'Future';
                }
                accountsToUpdate.add(new Account(Id = (ID) ar.get('FC_Ultimate_Parent_Account__c'),
                        FC_MAPG_Status__c = mapgStatus));
            }
            update accountsToUpdate;
        }
    }

    public void finish(Database.BatchableContext context) {
        FC_UpdateDescendantAcctMapgStatusBatch batchable = new FC_UpdateDescendantAcctMapgStatusBatch();
        Database.executeBatch(batchable);
    }

}