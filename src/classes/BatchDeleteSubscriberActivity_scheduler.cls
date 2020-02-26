global class BatchDeleteSubscriberActivity_scheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		BatchDeleteSubscriberActivity b = new BatchDeleteSubscriberActivity();
		database.executebatch(b);
	}
}