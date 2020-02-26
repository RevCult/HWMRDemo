public class FC_MCAccountProvisionBatchUpdateCtrl {

    public FC_MCAccountProvisionBatchUpdateCtrl() {
    }
    
    public PageReference invoke() {
        SchedulableContext context = null; 
        MetroclientAccountProvisionBatchUpdate instance = new MetroclientAccountProvisionBatchUpdate(); 
        instance.execute(context);
        return null;
    }
    
}