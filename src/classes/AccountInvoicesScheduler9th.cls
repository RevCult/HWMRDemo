global class AccountInvoicesScheduler9th implements Schedulable {
    global void execute(SchedulableContext sc){
        AccountInvoicesUncheck9Batch accInvBatch = new AccountInvoicesUncheck9Batch(); 
        database.executebatch(accInvBatch);
    }
}