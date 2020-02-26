global class FC_AccountUpdateBatchable implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('select Id from Account');
    }

    global void execute(Database.BatchableContext context, List<SObject> scope) {
        if (scope != null && !scope.isEmpty()) {

//            // Initialize maps
//            Map<ID, Integer> accountIdToTotalMapgCountMap = new Map<ID, Integer>();
//            Map<ID, Integer> accountIdToActiveMapgCountMap = new Map<ID, Integer>();
//            Map<ID, Integer> accountIdToExpiredMapgCountMap = new Map<ID, Integer>();
//            for (SObject record : scope) {
//                accountIdToTotalMapgCountMap.put(record.Id, 0);
//                accountIdToActiveMapgCountMap.put(record.Id, 0);
//                accountIdToExpiredMapgCountMap.put(record.Id, 0);
//            }
//
//            // Calculate totals
//            for (AggregateResult result : [select Account__c, count(Id) totalMapgCount
//                    from MetroclientAccountProductGeography__c where Account__c in :scope
//                    group by Account__c]) {
//                accountIdToTotalMapgCountMap.put((ID) result.get('Account__c'), (Integer) result.get('totalMapgCount'));
//            }
//            for (AggregateResult result : [select Account__c, count(Id) activeMapgCount
//                    from MetroclientAccountProductGeography__c where Account__c in :scope and Status__c = 'Active'
//                    group by Account__c]) {
//                accountIdToActiveMapgCountMap.put((ID) result.get('Account__c'), (Integer) result.get('activeMapgCount'));
//            }
//            for (AggregateResult result : [select Account__c, count(Id) expiredMapgCount
//                    from MetroclientAccountProductGeography__c where Account__c in :scope and Status__c = 'Expired'
//                    group by Account__c]) {
//                accountIdToExpiredMapgCountMap.put((ID) result.get('Account__c'), (Integer) result.get('expiredMapgCount'));
//            }
//
//            // Update accounts
//            Account[] accountsToUpdate = new List<Account>();
//            for (SObject record : scope) {
//                String mapgStatus = null;
//                Integer totalMapgCount = accountIdToTotalMapgCountMap.get(record.Id);
//                Integer activeMapgCount = accountIdToActiveMapgCountMap.get(record.Id);
//                Integer expiredMapgCount = accountIdToExpiredMapgCountMap.get(record.Id);
//                if (totalMapgCount > 0) {
//                    if (activeMapgCount > 0) {
//                        mapgStatus = 'Current';
//                    } else if (expiredMapgCount == totalMapgCount) {
//                        mapgStatus = 'Past';
//                    }
//                }
//                accountsToUpdate.add(new Account(Id = record.Id, FC_MAPG_Status__c = mapgStatus));
//            }
//
//            update accountsToUpdate;

            update scope;
        }
    }

    global void finish(Database.BatchableContext context) {
    }

}