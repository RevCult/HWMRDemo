global class AccountPastDueInvoices10th20thScheduler implements Schedulable {
    global void execute(SchedulableContext sc){
        AccountPastDueInvoicesBatch10th20th accInvBatch = new AccountPastDueInvoicesBatch10th20th(); 
        database.executebatch(accInvBatch);
    }
}