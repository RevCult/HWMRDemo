/******************************************************************************
*
* @description	Universal Schedule
* @author		10KView
* @date			6th June 2017
* @usage
*

// Instantiate the batch class
CustomerTypeBatchHandler myBatch = new CustomerTypeBatchHandler();
 
// Instantiate the scheduler
BatchScheduler scheduler = new BatchScheduler();
 
// Assign the batch class to the variable within the scheduler
scheduler.batchClass = myBatch;
 
// Run every day at 1pm
String sch = '0 0 13 * * ?';
 
System.schedule('Update Customer Type  - Everyday at 1pm', sch, scheduler);

*
*****************************************************************************/

global class BatchScheduler implements Schedulable {
  global Database.Batchable<SObject> batchClass{get;set;}
  global Integer batchSize{get;set;} {batchSize = 200;}
 
  global void execute(SchedulableContext sc) {
   database.executebatch(batchClass, batchSize);
  }
}