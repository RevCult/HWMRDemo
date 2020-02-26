public class FC_MetroclientAcctProvisionSchedulable implements Schedulable {

    public void execute(SchedulableContext context) {
        FC_MetroclientAccountProvisionBatchable batchable = new FC_MetroclientAccountProvisionBatchable();
        Database.executeBatch(batchable);
    }

}