@isTest
private class FC_TestEditManualAgreementController {
	private static final String QUOTE_TEMPLATE_NAME = 'Test Quote Template';
	@testSetup
	static void setup(){

		 Account testAccount = new Account(Name = 'TestAccount', BillingPostalCode = '12345');
        insert testAccount;
        
        Opportunity[] testOpportunities = new Opportunity[] {
            	new Opportunity(Name = 'TestOpportunity', AccountId = testAccount.Id, 
                                StageName = 'New', CloseDate = Date.today())};
        insert testOpportunities;
        
        zqu__Quote_Template__c[] testQuoteTemplates = new zqu__Quote_Template__c[] {
            	new zqu__Quote_Template__c(Name = QUOTE_TEMPLATE_NAME, zqu__IsDefault__c = true, 
                                           zqu__Quote_Type__c = 'New Subscription', zqu__Template_Id__c = '12345') };
        upsert testQuoteTemplates;

        zqu__Quote__c[] testQuotes = new zqu__Quote__c[] { 
            	new zqu__Quote__c(Name = 'TestQuote', RecordTypeId = fcf.RecordTypeUtil.findByName('zqu__Quote__c.Default').Id, Approval_Status__c = '', 
                                  zqu__QuoteTemplate__c = testQuoteTemplates[0].Id, zqu__QuoteTemplate__r = testQuoteTemplates[0], zqu__Status__c = 'New',
                                  zqu__Opportunity__c = testOpportunities[0].Id)};
        insert testQuotes;

		echosign_dev1__SIGN_Agreement__c es = new echosign_dev1__SIGN_Agreement__c();

		es.FC_Manual_EchoSign__c = true;
		es.echosign_dev1__Account__c = testAccount.id;
		es.Name = 'agreement1';
		es.echosign_dev1__Status__c = 'Signed';
		es.echosign_dev1__Recipient2__c = null;
		es.echosign_dev1__Opportunity__c = testOpportunities[0].id;
		es.Quote__c = null;
		es.echosign_dev1__SignatureType__c = 'Written Signature';
		es.echosign_dev1__DateSigned__c = Date.today();

		insert es;



		echosign_dev1__SIGN_Agreement__c es2 = new echosign_dev1__SIGN_Agreement__c();

		es2.FC_Manual_EchoSign__c = true;
		es2.echosign_dev1__Account__c = testAccount.id;
		es2.Name = 'agreement2';
		es2.echosign_dev1__Status__c = 'Signed';
		es2.echosign_dev1__Recipient2__c = null;
		es2.echosign_dev1__Opportunity__c = null;
		es2.Quote__c = testQuotes[0].id;
		es2.echosign_dev1__SignatureType__c = 'Written Signature';
		es2.echosign_dev1__DateSigned__c = Date.today();

		insert es2;


	}

	@isTest 
	static void testEditAgreement() {
		
		test.startTest();
		List<echosign_dev1__SIGN_Agreement__c> eslist = [Select Id,echosign_dev1__Opportunity__c  from echosign_dev1__SIGN_Agreement__c where Name='agreement1'];
		System.assertEquals(1,eslist.size());
		ApexPages.StandardController sc = new ApexPages.StandardController(eslist[0]);


		PageReference pgRef = Page.FC_EditManualAgreement;
		pgRef.getParameters().put('id',eslist[0].id);
		String oppId = eslist[0].echosign_dev1__Opportunity__c;
		pgRef.getParameters().put('retURL', oppId);
		
		test.SetCurrentPage(pgRef);
		FC_EditManualAgreementController fce = new FC_EditManualAgreementController(sc);

		PageReference pr = fce.SelectPage();
		System.assertEquals(null,pr);
		PageReference pr1 = fce.Save();
		System.assertNotEquals(null,pr1);
		PageReference pr2 = fce.Cancel();
		System.assertNotEquals(null,pr2);



		test.stopTest();


	}
	
}