/*
* @Description
* 				Batch class for moving Project Update Request Records to Big Object
* @History 
* Status      Date         User Story     Author              Comments
* Created     2019-24-01
*
*/
public class BackupProjectUpdateRequests implements Database.Batchable<Project_Update_Request__c>{
    Date lastDate;
    BackupBatchHandler backupHandler = new BackupBatchHandler();
    
    /*
    * @description 	Constructor of bach class
    * @param 		lastDate Date
    * @return
    * Status        Date         User Story          Author                Comments
    * Created       2019-24-01   
    */
    public BackupProjectUpdateRequests(Date lastDate){
        this.lastDate = lastDate;
    }
    
    /*
    * @description 	Start method of bach class
    * @param 		batchableContext Database.BatchableContext
    * @return 		Iterable<Project_Update_Request__c> Returns the list of Project_Update_Request__c records
    * Status        Date         User Story          Author                Comments
    * Created       2019-24-01   
    */
    public Iterable<Project_Update_Request__c> start(Database.BatchableContext batchableContext){
        return backupHandler.fetchProjectUpdateRequests(lastDate);
    }
    
    /*
    * @description 	Execute method of bach class
    * @param 		batchableContext Database.BatchableContext    
    * @param 		projectUpdateRequests List<Project_Update_Request__c>
    * @return
    * Status        Date         User Story          Author                Comments
    * Created       2019-24-01   
    */
    public  void execute(Database.BatchableContext batchableContext, List<Project_Update_Request__c> projectUpdateRequests) {        
        List<Project_Update_Request_Backup__b> backupRecords = backupHandler.createProjectUpdateRequestBackup(projectUpdateRequests);
        if(!backupRecords.isEmpty()){
            if(!Test.isRunningTest()){
                Database.insertImmediate(backupRecords);
            }            
            Database.delete(projectUpdateRequests);
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
    public void finish(Database.BatchableContext bc){  
        if(!backupHandler.fetchProjectUpdateRequests(lastDate).isEmpty() && !Test.isRunningTest()){
            Database.executeBatch(new BackupProjectUpdateRequests(lastDate));
        }
    }
}