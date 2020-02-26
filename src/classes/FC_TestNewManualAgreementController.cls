@isTest
private class FC_TestNewManualAgreementController {
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
        
    }

    @isTest 
    static void test_OppAgreement() {

        test.startTest();

        List<Opportunity> oppList = [Select Id from Opportunity where name ='TestOpportunity'];

        System.assertEquals(1, oppList.size(), 'Opportunity Exists');

        PageReference  pageRef = Page.FC_NewManualAgreement;
         pageRef.getparameters().put('opportunityId',oppList[0].id);
        test.setCurrentPageReference(pageRef);

        FC_NewManualAgreementController mAgreement = new FC_NewManualAgreementController();

        mAgreement.clientAgreement.Name = 'Test';
        mAgreement.clientAgreement.echosign_dev1__Status__c = 'Signed';
        mAgreement.clientAgreement.echosign_dev1__Opportunity__c = oppList[0].id;
        mAgreement.clientAgreement.echosign_dev1__SignatureType__c = 'Written Signature';
        mAgreement.clientAgreement.echosign_dev1__DateSigned__c = Date.today();
        mAgreement.clientAgreement.Quote__c = null;

        mAgreement.CreateDocument();
        mAgreement.AgreementDocument.body = Blob.valueOf('Test');
        mAgreement.AgreementDocument.Name = 'TEts';

        PageReference pr = mAgreement.Save();

        System.assertNotEquals(null, pr);

        test.stopTest();


    }

    @isTest 
    static void test_QuoteAgreement() {

        test.startTest();

        List<zqu__Quote__c> quotesList = [Select Id from zqu__Quote__c where name ='TestQuote'];

        System.assertEquals(1, quotesList.size(), 'Quote Exists');

        PageReference  pageRef = Page.FC_NewManualAgreement;
         pageRef.getparameters().put('quoteId',quotesList[0].id);
        test.setCurrentPageReference(pageRef);

        FC_NewManualAgreementController mAgreement = new FC_NewManualAgreementController();

        mAgreement.clientAgreement.Name = 'Test';
        mAgreement.clientAgreement.echosign_dev1__Status__c = 'Signed';
        mAgreement.clientAgreement.echosign_dev1__Opportunity__c =null;
        mAgreement.clientAgreement.echosign_dev1__SignatureType__c = 'Written Signature';
        mAgreement.clientAgreement.echosign_dev1__DateSigned__c = Date.today();
        mAgreement.clientAgreement.Quote__c = quotesList[0].id;

        mAgreement.CreateDocument();
        mAgreement.AgreementDocument.body = Blob.valueOf('Test');
        mAgreement.AgreementDocument.Name = 'TEts';

        PageReference pr = mAgreement.Save();

        System.assertNotEquals(null, pr);

        test.stopTest();

        
    }
    
}