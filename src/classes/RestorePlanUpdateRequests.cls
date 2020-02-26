/*
* @Description
* 				Batch class for moving Task Records to Big Object
* @History 
* Status      Date         User Story     Author              Comments
* Created     2019-24-01
*
*/
public class RestorePlanUpdateRequests implements Database.Batchable<Plan_Update_Request__c>{
    Date lastDate;
    BackupBatchHandler backupHandler = new BackupBatchHandler();
    
    /*
    * @description 	Constructor of bach class
    * @param 		lastDate Date
    * @return
    * Status        Date         User Story          Author                Comments
    * Created       2019-24-01   
    */
    public RestorePlanUpdateRequests(Date lastDate){
        this.lastDate = lastDate;
    }
    
    /*
    * @description Start method of bach class
    * @param batchableContext Database.BatchableContext
    * @return Iterable<Task> Returns the list of Task records
    * Status        Date         User Story          Author                Comments
    * Created       2019-24-01   
    */
    public Iterable<Plan_Update_Request__c> start(Database.BatchableContext batchableContext){
        return backupHandler.fetchPlanUpdateRequestFromRecycle(lastDate);
    }
    
    /*
    * @description 	Execute method of bach class
    * @param 		batchableContext Database.BatchableContext    
    * @param 		tasks List<Task>
    * @return
    * Status        Date         User Story          Author                Comments
    * Created       2019-24-01   
    */
    public  void execute(Database.BatchableContext batchableContext, List<Plan_Update_Request__c> tasks) {        
        
        if(!tasks.isEmpty()){
            
            Database.undelete(tasks, false);
        }
    }
    
    /*
    * @description 	Finish method of bach class if there is more 
    * 				records it will executes batch again
    * @param 		batchableContext Database.BatchableContext
    * @return
    * Status        Date         User Story          Author                Comments
    * Created       2019-24-01   
    */
    public void finish(Database.BatchableContext batchableContext){        
    	if(!backupHandler.fetchPlanUpdateRequestFromRecycle(lastDate).isEmpty()){
            Database.executeBatch(new RestorePlanUpdateRequests(lastDate));
        }
    }
}