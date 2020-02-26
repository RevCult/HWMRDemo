global without sharing class FC_AccountHandler extends fcf.TriggerAdapter {

    private Map<ID, Account> accountLookupMap = new Map<ID, Account>();
    private Map<ID, Integer> accountIdToActiveSubscriptionCountMap = new Map<ID, Integer>();

    global override void bulkBefore() {

        if (Trigger.isInsert || Trigger.isUpdate) {

            Set<ID> accountIdsToLookup = new Set<ID>();
            for (SObject so : Trigger.new) {
                Account accountRecord = (Account) so;
                if (accountRecord.ParentId != null) {
                    accountIdsToLookup.add(accountRecord.ParentId);
                }
            }
            accountLookupMap.putAll(FC_AccountCache.findByIds(accountIdsToLookup));
        }

        if (Trigger.isUpdate) {

            for (SObject so : Trigger.new) {
                accountIdToActiveSubscriptionCountMap.put(so.Id, 0);
            }
            for (AggregateResult ar : [
                    select Zuora__Account__c, count(Id) recordCount
                    from Zuora__Subscription__c
                    where Zuora__Account__c in :Trigger.newMap.keySet()
                    and Term_Status__c = 'Active'
                    group by Zuora__Account__c
            ]) {
                accountIdToActiveSubscriptionCountMap.put((ID) ar.get('Zuora__Account__c'),
                        (Integer) ar.get('recordCount'));
            }

        }
    }

    global override void beforeInsert(SObject so) {
        Account newAccountRecord = (Account) so;

        populateFields(newAccountRecord);
    }

    global override void beforeUpdate(SObject oldSo, SObject so) {
        Account newAccountRecord = (Account) so;

        populateFields(newAccountRecord);
    }

    private void populateFields(Account accountRecord) {
        Integer activeSubscriptionCount =
                accountIdToActiveSubscriptionCountMap.get(accountRecord.Id);
        accountRecord.Has_Active_Subscription__c =
                activeSubscriptionCount != null && activeSubscriptionCount > 0;

        ID ultimateParentId = null;
        if (accountRecord.ParentId != null) {
            ultimateParentId = accountRecord.ParentId;
            Account parentAccountRecord = accountLookupMap.get(accountRecord.ParentId);
            if (parentAccountRecord != null) {
                if (parentAccountRecord.ParentId != null) {
                    ultimateParentId = parentAccountRecord.ParentId;
                    if (parentAccountRecord.Parent.ParentId != null) {
                        ultimateParentId = parentAccountRecord.Parent.ParentId;
                        if (parentAccountRecord.Parent.Parent.ParentId != null) {
                            ultimateParentId = parentAccountRecord.Parent.Parent.ParentId;
                            if (parentAccountRecord.Parent.Parent.Parent.ParentId != null) {
                                ultimateParentId = parentAccountRecord.Parent.Parent.Parent.ParentId;
                                if (parentAccountRecord.Parent.Parent.Parent.Parent.ParentId != null) {
                                    ultimateParentId = parentAccountRecord.Parent.Parent.Parent.Parent.ParentId;
                                    if (parentAccountRecord.Parent.Parent.Parent.Parent.Parent.ParentId != null) {
                                        ultimateParentId = parentAccountRecord.Parent.Parent.Parent.Parent.Parent.ParentId;
                                    }
                                }
                            }
                        }

                    }
                }
            }
        }
        accountRecord.FC_Ultimate_Parent_Account__c = ultimateParentId;

    }

}