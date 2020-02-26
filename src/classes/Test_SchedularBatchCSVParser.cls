@isTest
public with sharing class Test_SchedularBatchCSVParser {
	static testMethod void testSchedularBatchCSVParser(){
		Test.startTest();
		SchedularBatchCSVParser sch = new SchedularBatchCSVParser();
		 String str = '0 0 0 1 1 ? 2025';  
         String jobId = System.schedule('testScheduledApex', str,sch);
         Test.stopTest();
	}
}