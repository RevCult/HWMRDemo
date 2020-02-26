/*
* @Description
* 				Batch class for moving Plan_Update_Request__c Records to Big Object
* @History 
* Status      Date         User Story     Author              Comments
* Created     2019-24-01
*
*/
public class BackupPlanUpdateRequestsBatch implements Database.Batchable<Plan_Update_Request__c>{
    BackupBatchHandler backupHandler = new BackupBatchHandler();
    
    Date lastDate;
    
    /*
    * @description 	Constructor of bach class
    * @param 		lastDate Date
    * @return
    * Status        Date         User Story          Author                Comments
    * Created       2019-24-01   
    */
    public BackupPlanUpdateRequestsBatch(Date lastDate){
        this.lastDate = lastDate;
    }
    
    /*
    * @description 	Start method of bach class
    * @param 		batchableContext Database.BatchableContext
    * @return 		Iterable<Plan_Update_Request__c> Returns the list of Plan_Update_Request__c records
    * Status        Date         User Story          Author                Comments
    * Created       2019-24-01   
    */
    public Iterable<Plan_Update_Request__c> start(Database.BatchableContext batchableContext){
        return backupHandler.fetchPlanUpdateRequests(lastDate);
    }
    
    /*
    * @description 	Execute method of bach class
    * @param 		batchableContext Database.BatchableContext    
    * @param 		planUpdateRequests List<Plan_Update_Request__c>
    * @return
    * Status        Date         User Story          Author                Comments
    * Created       2019-24-01   
    */
    public  void execute(Database.BatchableContext batchableContext, List<Plan_Update_Request__c> planUpdateRequests) {        
        List<Plan_Update_Request_B__b> backupRecords = backupHandler.createPlanUpdateRequestBackup(planUpdateRequests);
        if(!backupRecords.isEmpty()){
            if(!Test.isRunningTest()){
                Database.insertImmediate(backupRecords);
            }            
            Database.delete(planUpdateRequests);
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
        if(!backupHandler.fetchPlanUpdateRequests(lastDate).isEmpty()){
            Database.executeBatch(new BackupPlanUpdateRequestsBatch(lastDate));
        }
    }
}