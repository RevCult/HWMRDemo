global class SchedularBatchCSVParser implements Schedulable {
   global void execute(SchedulableContext sc) {
      BatchCSVParser b = new BatchCSVParser(); 
      database.executebatch(b);
   }
}