public class FC_MetroclientAccountProvisionBatchable implements Database.Batchable<sObject>, Database.AllowsCallouts,
        Database.Stateful {

    public Id parentTransactionId = null;

    private Set<Id> accountIdsToProvision;

    private Date lastSentToZuoraStartDate;
    private Date lastSentToZuoraEndDate;

    @testVisible
    private static Integer insertedRecordCount = 0;

    @testVisible
    private static Integer updatedRecordCount = 0;

    private static final String SOQL_BASE = 'select Id, ' +
            '(select Id, Zuora__External_Id__c from Zuora__Subscriptions__r) ' +
            'from Account ';

    public FC_MetroclientAccountProvisionBatchable() {
        this(null);
    }

    public FC_MetroclientAccountProvisionBatchable(Set<Id> accountIdsToProvision) {
        this.accountIdsToProvision = accountIdsToProvision;
    }

    public FC_MetroclientAccountProvisionBatchable(Date lastSentToZuoraStartDate, Date lastSentToZuoraEndDate) {
        this.lastSentToZuoraStartDate = lastSentToZuoraStartDate;
        this.lastSentToZuoraEndDate = lastSentToZuoraEndDate;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        String soql = SOQL_BASE;
        if (this.lastSentToZuoraStartDate != null) {
            soql += 'where FC_Opportunity_Last_Sent_To_Zuora__c >= :lastSentToZuoraStartDate ';
            if (this.lastSentToZuoraEndDate != null) {
                soql += 'and FC_Opportunity_Last_Sent_To_Zuora__c <= :lastSentToZuoraEndDate';
            }
        } else if (this.accountIdsToProvision != null && !this.accountIdsToProvision.isEmpty()) {
            soql += 'where Id in :accountIdsToProvision';
        } else {
            soql += 'where FC_Opportunity_Last_Sent_To_Zuora__c >= LAST_N_DAYS:2';
        }

        System.debug('******* SOQL: ' + soql);
        return Database.getQueryLocator(soql);
    }

    public void execute(Database.BatchableContext context, List<Account> scope) {
        if (scope != null && !scope.isEmpty()) {

            Map<Id, Account> accountsInScope = new Map<Id, Account>(scope);

            FC_MetroclientAccountProvisioningUtil.buildProvisioningRecords(
                    new List<Id>(accountsInScope.keySet()), parentTransactionId);

            insertedRecordCount += FC_MetroclientAccountProvisioningUtil.getProvisioningRecordsToInsert().size();
            updatedRecordCount += FC_MetroclientAccountProvisioningUtil.getProvisioningRecordsToUpdate().size();
            FC_MetroclientAccountProvisioningUtil.commitProvisioningRecords();

        }
    }

    public void finish(Database.BatchableContext context) {
    }

}