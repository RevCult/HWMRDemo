global class AccountInvoicesScheduler19th implements Schedulable {
    global void execute(SchedulableContext sc){
        AccountInvoicesUncheck19Batch accInvBatch = new AccountInvoicesUncheck19Batch(); 
        database.executebatch(accInvBatch);
    }
}