public without sharing class FC_InvoiceItemRevenueShareProcessorSched implements Schedulable {

    public void execute(SchedulableContext context) {
        FC_InvoiceItemRevenueShareProcessorBatch batchable = new FC_InvoiceItemRevenueShareProcessorBatch(false);
        Database.executeBatch(batchable);
    }

}