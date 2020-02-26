/*
* @Description
* 				Batch class for moving Task Records to Big Object
* @History 
* Status      Date         User Story     Author              Comments
* Created     2019-24-01
*
*/
public class BackupTasksBatch implements Database.Batchable<Task>{
    
    BackupBatchHandler backupHandler = new BackupBatchHandler();
    
    /*
    * @description Start method of bach class
    * @param batchableContext Database.BatchableContext
    * @return Iterable<Task> Returns the list of Task records
    * Status        Date         User Story          Author                Comments
    * Created       2019-24-01   
    */
    public Iterable<Task> start(Database.BatchableContext batchableContext){
        return backupHandler.fetchOlderTasks();
    }
    
    /*
    * @description 	Execute method of bach class
    * @param 		batchableContext Database.BatchableContext    
    * @param 		tasks List<Task>
    * @return
    * Status        Date         User Story          Author                Comments
    * Created       2019-24-01   
    */
    public  void execute(Database.BatchableContext batchableContext, List<Task> tasks) {        
        List<Task__b> backupRecords = backupHandler.createTaskBackup(tasks);
        if(!backupRecords.isEmpty()){
            if(!Test.isRunningTest()){
                Database.insertImmediate(backupRecords);
            }            
            Database.delete(tasks);
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
    	if(!backupHandler.fetchOlderTasks().isEmpty()){
            Database.executeBatch(new BackupTasksBatch());
        }
    }

}