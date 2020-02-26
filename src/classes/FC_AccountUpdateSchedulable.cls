global class FC_AccountUpdateSchedulable implements Schedulable {
    
    global void execute(SchedulableContext context) {
        FC_AccountUpdateBatchable batchable = new FC_AccountUpdateBatchable();
        Database.executeBatch(batchable);
    }
    
}