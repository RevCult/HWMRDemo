public without sharing class ProjectStatusBoardController {
	public ProjectStatusBoardController() {
		
	}

	public String getPendingUpdateCount() {
		Integer pendingUpdateCount = [SELECT COUNT() FROM Project_Update_Request__c WHERE Update_Request_Status__c = 'Pending'];
		String pendingUpdateCountText = pendingUpdateCount.format();
		return pendingUpdateCountText;
	}

	public String getInProgressUpdateCount() {
		Integer inProgressUpdateCount = [SELECT COUNT() FROM Project_Update_Request__c WHERE Update_Request_Status__c = 'In Progress'];
		String inProgressUpdateCountText = inProgressUpdateCount.format();
		return inProgressUpdateCountText;
	}

	public String getTotalBuilderCount() {
		Integer totalBuilderCount = [SELECT COUNT() FROM Builder__c WHERE Id IN (SELECT Builder__c FROM Project__c)];
		String totalBuilderCountText = totalBuilderCount.format();
		return totalBuilderCountText;
	}

	public String getTotalProjectCount() {
		Integer totalProjectCount = [SELECT COUNT() FROM Project__c];
		String totalProjectCountText = totalProjectCount.format();
		return totalProjectCountText;
	}
}