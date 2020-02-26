global class AccountPastDueInvoices20thScheduler implements Schedulable {
    global void execute(SchedulableContext sc){
        AccountPastDueInvoicesBatch20th accInvBatch = new AccountPastDueInvoicesBatch20th(); 
        database.executebatch(accInvBatch);
    }
}