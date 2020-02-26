public with sharing class FC_MetroclientAccountProvisionBatchCtrl {

    private final Account ACCOUNT_RECORD;

    public FC_MetroclientAccountProvisionBatchCtrl(ApexPages.StandardController standardController) {
        this.ACCOUNT_RECORD = (Account) standardController.getRecord();
    }

    public PageReference runBatchable() {
        FC_MetroclientAccountProvisionBatchable batchable = new FC_MetroclientAccountProvisionBatchable(new Set<Id>{
                this.ACCOUNT_RECORD.Id
        });
        Database.executeBatch(batchable);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,
                'Your account provision update request has been submitted.'));
        return null;
    }

}