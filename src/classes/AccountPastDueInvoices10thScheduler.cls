global class AccountPastDueInvoices10thScheduler implements Schedulable {
    global void execute(SchedulableContext sc){
        AccountPastDueInvoicesBatch10th accInvBatch = new AccountPastDueInvoicesBatch10th(); 
        database.executebatch(accInvBatch);
    }
}