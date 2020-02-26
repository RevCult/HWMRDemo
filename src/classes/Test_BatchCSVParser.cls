@isTest(seeAlldata=true)
private class Test_BatchCSVParser {
	static testMethod void testBatchCSVParser(){
		
		DateTime sixhoursBackTime = DateTime.now().addHours(-6);
		String query = 'Select body from Attachment Where ParentID = \''+System.label.AccountIDToSaveAttachments+'\' AND CreatedDate< :DateTime.now() AND CreatedDate> :sixHoursBackTime  ORDER BY CreatedDate Desc limit 1';
		List <Attachment> attachList  = new List<Attachment>();
		for(integer i=0; i<10; i++){
		Attachment att = new Attachment();
		att.parentId = System.label.AccountIdToSaveAttachments;
		att.body= blob.valueOf('my attachment text Product Type \n Product Type');
		att.name= 'Att';
		attachList.add(att);
		}
		
		List<DSM_Products__c> dsmList = new List<DSM_Products__c>();
		for(integer i=0; i<10; i++){
		DSM_Products__c dsm = new DSM_Products__c();
		dsm.Name = 'test';
		dsm.Product_ID__c ='test';
		dsmList.add(dsm);
		}
	
		try{
			insert attachList;
			insert dsmList;
		}
		catch(DmlException excep){
			System.debug('Error Inserting Attachment ::'+ excep.getMessage());
		}
		
		Test.startTest();
			List<List<String>> strng = new List<List<String>>{new List<String>{'abc'}};
			
			BatchCSVParser batch = new BatchCSVParser();
			Database.executeBatch(batch);
			BatchCSVParser.parseCSV('Product Type');
			BatchCSVParser.parseCSV('Test');
			BatchCSVParser.buildProductTypeMap(strng);
			Map<String,String> buildProd = new Map<String,String>();
			//BatchCSVParser.updateProducts(buildProd);
			BatchCSVParser.test();

		Test.stopTest();
	}
}