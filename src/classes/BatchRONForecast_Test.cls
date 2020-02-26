/****************************************************************************************************
*Description:   	This is the test class for the BatchRONForecast XML Class
*
*Required Class(es):N/A
*
*Revision   |Date       |Author             |AdditionalNotes
*====================================================================================================
*   1.0    	10/23/2014	Justin Padilla      WO#1748 Initial Version
*****************************************************************************************************/
@isTest
private class BatchRONForecast_Test {
    
    @testSetup
    static void testSetup(){
        Account a = new Account(Name='Test123', BillingPostalCode = '12345');
        Insert a;
    }

    static testMethod void RONForecastCurrent_Test()
	{
        Account a = [Select Id from Account where Name = 'Test123'];
		string XMLData = '<?xml version=\'1.0\'?><Report reportTimeStamp=\'2014-10-22T07:08:52.654-04:00\'><HeaderData><Header name=\'Report job ID\' localizedName=\'Report job ID\'><Val>1774373413</Val></Header><Header name=\'Date/Time generated\' localizedName=\'Date/Time generated\'><Val>October 22, 2014 7:08:24 AM EDT</Val></Header><Header name=\'Publisher network name\' localizedName=\'Publisher network name\'><Val>Hanley Wood - DFP</Val></Header><Header name=\'User\' localizedName=\'User\'><Val>mluchsinger@hanleywood.com</Val></Header><Header name=\'Date range\' localizedName=\'Date range\'><Val>Oct 23, 2014 - Nov 30, 2014</Val></Header><Header name=\'PQL query statement\' localizedName=\'PQL query statement\'><Val> where line_item_name like \'Run of Network\'</Val></Header></HeaderData><ReportData><ColumnHeaders><ColumnHeader name=\'advertiserName\' localizedName=\'Advertiser\'/><ColumnHeader name=\'orderName\' localizedName=\'Order\'/><ColumnHeader name=\'lineItemName\' localizedName=\'Line item\'/><ColumnHeader name=\'adSlotName\' localizedName=\'Ad unit\'/><ColumnHeader name=\'monthYear\' localizedName=\'Month and year\'/><ColumnHeader name=\'lineitemCostPerUnit\' localizedName=\'Rate ($)\'/><ColumnHeader name=\'imfForecastedImpressions\' localizedName=\'Forecasted impressions\'/></ColumnHeaders><DataSet><Row rowNum=\'1\'><Column name=\'advertiserName\'><Val>ABX ArchitectureBoston Expo</Val></Column><Column name=\'orderName\'><Val>4885247 - 2014 ABX Architecture Boston Expo Architect, Residenitial Architect Print, Run of Site, Email Blast Barter (Aug-Oct)</Val></Column><Column name=\'lineItemName\'><Val>74556339 - Run of Network | Medium Rectangle | 300x250 | Standard CPM</Val></Column><Column name=\'adSlotName\'><Val>Architect</Val></Column><Column name=\'monthYear\'><Val>October 2014</Val></Column><Column name=\'lineitemCostPerUnit\'><Val>0.00</Val></Column><Column name=\'imfForecastedImpressions\'><Val>4,191</Val></Column></Row><Total rowNum="721"><Column name="advertiserName"><Val>19</Val></Column><Column name="orderName"><Val>22</Val></Column><Column name="lineItemName"><Val>52</Val></Column><Column name="adSlotName"><Val>26</Val></Column><Column name="monthYear"><Val/></Column><Column name="lineitemCostPerUnit"><Val/></Column><Column name="imfForecastedImpressions"><Val>26,910,589</Val></Column></Total></DataSet></ReportData></Report>';
        // Create an attachment
        Attachment attachObj = new Attachment();
        attachObj.parentId= a.Id;
        attachObj.name = 'RON Forecast Current.xml';
		attachObj.body= Blob.valueOf(XMLData);
		Insert(attachObj);
		
		BatchRONForecast b = new BatchRONForecast();
        b.monitoredAccountIds.add(a.Id);
		b.runReport = BatchRONForecast.ReportType.Current;
		database.executeBatch(b);
    }
    
    
    static testMethod void RONForecastNext12months_Test()
	{
        Account a = [Select Id from Account where Name = 'Test123'];
		string XMLData = '<?xml version=\'1.0\'?><Report reportTimeStamp=\'2014-10-22T07:08:52.654-04:00\'><HeaderData><Header name=\'Report job ID\' localizedName=\'Report job ID\'><Val>1774373413</Val></Header><Header name=\'Date/Time generated\' localizedName=\'Date/Time generated\'><Val>October 22, 2014 7:08:24 AM EDT</Val></Header><Header name=\'Publisher network name\' localizedName=\'Publisher network name\'><Val>Hanley Wood - DFP</Val></Header><Header name=\'User\' localizedName=\'User\'><Val>mluchsinger@hanleywood.com</Val></Header><Header name=\'Date range\' localizedName=\'Date range\'><Val>Oct 23, 2014 - Nov 30, 2014</Val></Header><Header name=\'PQL query statement\' localizedName=\'PQL query statement\'><Val> where line_item_name like \'Run of Network\'</Val></Header></HeaderData><ReportData><ColumnHeaders><ColumnHeader name=\'advertiserName\' localizedName=\'Advertiser\'/><ColumnHeader name=\'orderName\' localizedName=\'Order\'/><ColumnHeader name=\'lineItemName\' localizedName=\'Line item\'/><ColumnHeader name=\'adSlotName\' localizedName=\'Ad unit\'/><ColumnHeader name=\'monthYear\' localizedName=\'Month and year\'/><ColumnHeader name=\'lineitemCostPerUnit\' localizedName=\'Rate ($)\'/><ColumnHeader name=\'imfForecastedImpressions\' localizedName=\'Forecasted impressions\'/></ColumnHeaders><DataSet><Row rowNum=\'1\'><Column name=\'advertiserName\'><Val>ABX ArchitectureBoston Expo</Val></Column><Column name=\'orderName\'><Val>4885247 - 2014 ABX Architecture Boston Expo Architect, Residenitial Architect Print, Run of Site, Email Blast Barter (Aug-Oct)</Val></Column><Column name=\'lineItemName\'><Val>74556339 - Run of Network | Medium Rectangle | 300x250 | Standard CPM</Val></Column><Column name=\'adSlotName\'><Val>Architect</Val></Column><Column name=\'monthYear\'><Val>October 2014</Val></Column><Column name=\'lineitemCostPerUnit\'><Val>0.00</Val></Column><Column name=\'imfForecastedImpressions\'><Val>4,191</Val></Column></Row><Total rowNum="721"><Column name="advertiserName"><Val>19</Val></Column><Column name="orderName"><Val>22</Val></Column><Column name="lineItemName"><Val>52</Val></Column><Column name="adSlotName"><Val>26</Val></Column><Column name="monthYear"><Val/></Column><Column name="lineitemCostPerUnit"><Val/></Column><Column name="imfForecastedImpressions"><Val>26,910,589</Val></Column></Total></DataSet></ReportData></Report>';
        // Create an attachment
        Attachment attachObj = new Attachment();
        attachObj.parentId= a.Id;
        attachObj.name = 'RON Forecast Next 12 months.xml';
		attachObj.body= Blob.valueOf(XMLData);
		Insert(attachObj);
		
		BatchRONForecast b = new BatchRONForecast();
        b.monitoredAccountIds.add(a.Id);
		b.runReport = BatchRONForecast.ReportType.Future;
		database.executeBatch(b);
    }
    
    static testMethod void RONForecastDelivered_Test()
	{
        Account a = [Select Id from Account where Name = 'Test123'];
		string XMLData = '<?xml version=\'1.0\'?><Report reportTimeStamp=\'2014-10-22T07:08:52.654-04:00\'><HeaderData><Header name=\'Report job ID\' localizedName=\'Report job ID\'><Val>1774373413</Val></Header><Header name=\'Date/Time generated\' localizedName=\'Date/Time generated\'><Val>October 22, 2014 7:08:24 AM EDT</Val></Header><Header name=\'Publisher network name\' localizedName=\'Publisher network name\'><Val>Hanley Wood - DFP</Val></Header><Header name=\'User\' localizedName=\'User\'><Val>mluchsinger@hanleywood.com</Val></Header><Header name=\'Date range\' localizedName=\'Date range\'><Val>Oct 23, 2014 - Nov 30, 2014</Val></Header><Header name=\'PQL query statement\' localizedName=\'PQL query statement\'><Val> where line_item_name like \'Run of Network\'</Val></Header></HeaderData><ReportData><ColumnHeaders><ColumnHeader name=\'advertiserName\' localizedName=\'Advertiser\'/><ColumnHeader name=\'orderName\' localizedName=\'Order\'/><ColumnHeader name=\'lineItemName\' localizedName=\'Line item\'/><ColumnHeader name=\'adSlotName\' localizedName=\'Ad unit\'/><ColumnHeader name=\'monthYear\' localizedName=\'Month and year\'/><ColumnHeader name=\'lineitemCostPerUnit\' localizedName=\'Rate ($)\'/><ColumnHeader name=\'imfForecastedImpressions\' localizedName=\'Forecasted impressions\'/></ColumnHeaders><DataSet><Row rowNum=\'1\'><Column name=\'advertiserName\'><Val>ABX ArchitectureBoston Expo</Val></Column><Column name=\'orderName\'><Val>4885247 - 2014 ABX Architecture Boston Expo Architect, Residenitial Architect Print, Run of Site, Email Blast Barter (Aug-Oct)</Val></Column><Column name=\'lineItemName\'><Val>74556339 - Run of Network | Medium Rectangle | 300x250 | Standard CPM</Val></Column><Column name=\'adSlotName\'><Val>Architect</Val></Column><Column name=\'monthYear\'><Val>October 2014</Val></Column><Column name=\'lineitemCostPerUnit\'><Val>0.00</Val></Column><Column name=\'imfForecastedImpressions\'><Val>4,191</Val></Column></Row><Total rowNum="721"><Column name="advertiserName"><Val>19</Val></Column><Column name="orderName"><Val>22</Val></Column><Column name="lineItemName"><Val>52</Val></Column><Column name="adSlotName"><Val>26</Val></Column><Column name="monthYear"><Val/></Column><Column name="lineitemCostPerUnit"><Val/></Column><Column name="imfForecastedImpressions"><Val>26,910,589</Val></Column></Total></DataSet></ReportData></Report>';
        // Create an attachment
        Attachment attachObj = new Attachment();
        attachObj.parentId= a.Id;
        attachObj.name = 'RON Delivered.xml';
		attachObj.body= Blob.valueOf(XMLData);
		Insert(attachObj);
		
		BatchRONForecast b = new BatchRONForecast();
        b.monitoredAccountIds.add(a.Id);
		b.runReport = BatchRONForecast.ReportType.Delivered;
		database.executeBatch(b);
    }
    
    static testMethod void RONForecastEmailService_txtAttachment_Test()
    {
    	string XMLData = '<?xml version=\'1.0\'?><Report reportTimeStamp=\'2014-10-22T07:08:52.654-04:00\'><HeaderData><Header name=\'Report job ID\' localizedName=\'Report job ID\'><Val>1774373413</Val></Header><Header name=\'Date/Time generated\' localizedName=\'Date/Time generated\'><Val>October 22, 2014 7:08:24 AM EDT</Val></Header><Header name=\'Publisher network name\' localizedName=\'Publisher network name\'><Val>Hanley Wood - DFP</Val></Header><Header name=\'User\' localizedName=\'User\'><Val>mluchsinger@hanleywood.com</Val></Header><Header name=\'Date range\' localizedName=\'Date range\'><Val>Oct 23, 2014 - Nov 30, 2014</Val></Header><Header name=\'PQL query statement\' localizedName=\'PQL query statement\'><Val> where line_item_name like \'Run of Network\'</Val></Header></HeaderData><ReportData><ColumnHeaders><ColumnHeader name=\'advertiserName\' localizedName=\'Advertiser\'/><ColumnHeader name=\'orderName\' localizedName=\'Order\'/><ColumnHeader name=\'lineItemName\' localizedName=\'Line item\'/><ColumnHeader name=\'adSlotName\' localizedName=\'Ad unit\'/><ColumnHeader name=\'monthYear\' localizedName=\'Month and year\'/><ColumnHeader name=\'lineitemCostPerUnit\' localizedName=\'Rate ($)\'/><ColumnHeader name=\'imfForecastedImpressions\' localizedName=\'Forecasted impressions\'/></ColumnHeaders><DataSet><Row rowNum=\'1\'><Column name=\'advertiserName\'><Val>ABX ArchitectureBoston Expo</Val></Column><Column name=\'orderName\'><Val>4885247 - 2014 ABX Architecture Boston Expo Architect, Residenitial Architect Print, Run of Site, Email Blast Barter (Aug-Oct)</Val></Column><Column name=\'lineItemName\'><Val>74556339 - Run of Network | Medium Rectangle | 300x250 | Standard CPM</Val></Column><Column name=\'adSlotName\'><Val>Architect</Val></Column><Column name=\'monthYear\'><Val>October 2014</Val></Column><Column name=\'lineitemCostPerUnit\'><Val>0.00</Val></Column><Column name=\'imfForecastedImpressions\'><Val>4,191</Val></Column></Row><Total rowNum="721"><Column name="advertiserName"><Val>19</Val></Column><Column name="orderName"><Val>22</Val></Column><Column name="lineItemName"><Val>52</Val></Column><Column name="adSlotName"><Val>26</Val></Column><Column name="monthYear"><Val/></Column><Column name="lineitemCostPerUnit"><Val/></Column><Column name="imfForecastedImpressions"><Val>26,910,589</Val></Column></Total></DataSet></ReportData></Report>';
    	
    	// Create a new email, envelope object and Attachment
		Messaging.InboundEmail email = new Messaging.InboundEmail();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		Messaging.InboundEmail.Textattachment inAtt = new Messaging.InboundEmail.Textattachment();
		
		email.subject = 'test';
		env.fromAddress = 'user@acme.com';
	
		// set the body of the attachment
		inAtt.body = XMLData;
		inAtt.fileName = 'test.xml';
		inAtt.mimeTypeSubType = 'plain/txt';
	
		email.Textattachments = new Messaging.inboundEmail.Textattachment[] {inAtt }; 
	
		// call the class and test it with the data in the testMethod
		RONForecastEmailService emailServiceObj = new RONForecastEmailService();
		emailServiceObj.handleInboundEmail(email, env );
    }
    
    static testMethod void RONForecastEmailService_binAttachment_Test()
    {
    	string XMLData = '<?xml version=\'1.0\'?><Report reportTimeStamp=\'2014-10-22T07:08:52.654-04:00\'><HeaderData><Header name=\'Report job ID\' localizedName=\'Report job ID\'><Val>1774373413</Val></Header><Header name=\'Date/Time generated\' localizedName=\'Date/Time generated\'><Val>October 22, 2014 7:08:24 AM EDT</Val></Header><Header name=\'Publisher network name\' localizedName=\'Publisher network name\'><Val>Hanley Wood - DFP</Val></Header><Header name=\'User\' localizedName=\'User\'><Val>mluchsinger@hanleywood.com</Val></Header><Header name=\'Date range\' localizedName=\'Date range\'><Val>Oct 23, 2014 - Nov 30, 2014</Val></Header><Header name=\'PQL query statement\' localizedName=\'PQL query statement\'><Val> where line_item_name like \'Run of Network\'</Val></Header></HeaderData><ReportData><ColumnHeaders><ColumnHeader name=\'advertiserName\' localizedName=\'Advertiser\'/><ColumnHeader name=\'orderName\' localizedName=\'Order\'/><ColumnHeader name=\'lineItemName\' localizedName=\'Line item\'/><ColumnHeader name=\'adSlotName\' localizedName=\'Ad unit\'/><ColumnHeader name=\'monthYear\' localizedName=\'Month and year\'/><ColumnHeader name=\'lineitemCostPerUnit\' localizedName=\'Rate ($)\'/><ColumnHeader name=\'imfForecastedImpressions\' localizedName=\'Forecasted impressions\'/></ColumnHeaders><DataSet><Row rowNum=\'1\'><Column name=\'advertiserName\'><Val>ABX ArchitectureBoston Expo</Val></Column><Column name=\'orderName\'><Val>4885247 - 2014 ABX Architecture Boston Expo Architect, Residenitial Architect Print, Run of Site, Email Blast Barter (Aug-Oct)</Val></Column><Column name=\'lineItemName\'><Val>74556339 - Run of Network | Medium Rectangle | 300x250 | Standard CPM</Val></Column><Column name=\'adSlotName\'><Val>Architect</Val></Column><Column name=\'monthYear\'><Val>October 2014</Val></Column><Column name=\'lineitemCostPerUnit\'><Val>0.00</Val></Column><Column name=\'imfForecastedImpressions\'><Val>4,191</Val></Column></Row><Total rowNum="721"><Column name="advertiserName"><Val>19</Val></Column><Column name="orderName"><Val>22</Val></Column><Column name="lineItemName"><Val>52</Val></Column><Column name="adSlotName"><Val>26</Val></Column><Column name="monthYear"><Val/></Column><Column name="lineitemCostPerUnit"><Val/></Column><Column name="imfForecastedImpressions"><Val>26,910,589</Val></Column></Total></DataSet></ReportData></Report>';
    	
    	// Create a new email, envelope object and Attachment
		Messaging.InboundEmail email = new Messaging.InboundEmail();
		Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		Messaging.InboundEmail.Binaryattachment inAtt = new Messaging.InboundEmail.Binaryattachment();
		
		email.subject = 'test';
		env.fromAddress = 'user@acme.com';
	
		// set the body of the attachment
		inAtt.body = blob.valueOf(XMLData);
		inAtt.fileName = 'test.xml';
		inAtt.mimeTypeSubType = 'plain/txt';
	
		email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {inAtt }; 
	
		// call the class and test it with the data in the testMethod
		RONForecastEmailService emailServiceObj = new RONForecastEmailService();
		emailServiceObj.handleInboundEmail(email, env );
    }
    
    static testMethod void EmailFromAttachment_Test()
    {
        Account a = [Select Id from Account where Name = 'Test123'];
    	//Create an Attachment and send directly to CreateEmail method
    	string XMLData = '<?xml version=\'1.0\'?><Report reportTimeStamp=\'2014-10-22T07:08:52.654-04:00\'><HeaderData><Header name=\'Report job ID\' localizedName=\'Report job ID\'><Val>1774373413</Val></Header><Header name=\'Date/Time generated\' localizedName=\'Date/Time generated\'><Val>October 22, 2014 7:08:24 AM EDT</Val></Header><Header name=\'Publisher network name\' localizedName=\'Publisher network name\'><Val>Hanley Wood - DFP</Val></Header><Header name=\'User\' localizedName=\'User\'><Val>mluchsinger@hanleywood.com</Val></Header><Header name=\'Date range\' localizedName=\'Date range\'><Val>Oct 23, 2014 - Nov 30, 2014</Val></Header><Header name=\'PQL query statement\' localizedName=\'PQL query statement\'><Val> where line_item_name like \'Run of Network\'</Val></Header></HeaderData><ReportData><ColumnHeaders><ColumnHeader name=\'advertiserName\' localizedName=\'Advertiser\'/><ColumnHeader name=\'orderName\' localizedName=\'Order\'/><ColumnHeader name=\'lineItemName\' localizedName=\'Line item\'/><ColumnHeader name=\'adSlotName\' localizedName=\'Ad unit\'/><ColumnHeader name=\'monthYear\' localizedName=\'Month and year\'/><ColumnHeader name=\'lineitemCostPerUnit\' localizedName=\'Rate ($)\'/><ColumnHeader name=\'imfForecastedImpressions\' localizedName=\'Forecasted impressions\'/></ColumnHeaders><DataSet><Row rowNum=\'1\'><Column name=\'advertiserName\'><Val>ABX ArchitectureBoston Expo</Val></Column><Column name=\'orderName\'><Val>4885247 - 2014 ABX Architecture Boston Expo Architect, Residenitial Architect Print, Run of Site, Email Blast Barter (Aug-Oct)</Val></Column><Column name=\'lineItemName\'><Val>74556339 - Run of Network | Medium Rectangle | 300x250 | Standard CPM</Val></Column><Column name=\'adSlotName\'><Val>Architect</Val></Column><Column name=\'monthYear\'><Val>October 2014</Val></Column><Column name=\'lineitemCostPerUnit\'><Val>0.00</Val></Column><Column name=\'imfForecastedImpressions\'><Val>4,191</Val></Column></Row><Total rowNum="721"><Column name="advertiserName"><Val>19</Val></Column><Column name="orderName"><Val>22</Val></Column><Column name="lineItemName"><Val>52</Val></Column><Column name="adSlotName"><Val>26</Val></Column><Column name="monthYear"><Val/></Column><Column name="lineitemCostPerUnit"><Val/></Column><Column name="imfForecastedImpressions"><Val>26,910,589</Val></Column></Total></DataSet></ReportData></Report>';
        // Create an attachment
        Attachment attachObj = new Attachment();
        attachObj.parentId= a.Id;
        attachObj.name = 'RON Delivered.xml';
		attachObj.body= Blob.valueOf(XMLData);
		Insert(attachObj);
		
		BatchRONForecast b = new BatchRONForecast();
        b.monitoredAccountIds.add(a.Id);
		b.runReport = BatchRONForecast.ReportType.Delivered;
		b.CreateEmail(attachObj);		
    }
    
    static testMethod void EmailDirectly_Test()
    {
    	BatchRONForecast b = new BatchRONForecast();
		b.runReport = BatchRONForecast.ReportType.Delivered;
		b.CreateRONEmail('This is a test');	
    }
    
    static testMethod void ScheduledBatchRONCurrentForcast_Test()
    {
    	String CRON_EXP = '0 0 0 15 3 ? 2022';
		test.startTest();
		String jobId = System.schedule('RONCurrentForcastTest',
                        CRON_EXP, 
                        new ScheduledBatchRONCurrentForcast());
		test.stopTest();
    }
    static testMethod void ScheduledBatchRONFutureForecast_Test()
    {
    	String CRON_EXP = '0 0 0 15 3 ? 2022';
    	test.startTest();
		String jobId = System.schedule('RONFutureForecast',
                        CRON_EXP, 
                        new ScheduledBatchRONFutureForecast());
		test.stopTest();
    }
    static testMethod void ScheduledBatchRONDeliveredForecast_Test()
    {
    	String CRON_EXP = '0 0 0 15 3 ? 2022';
    	test.startTest();
		String jobId = System.schedule('RONDeliveredForecast',
                        CRON_EXP, 
                        new ScheduledBatchRONDeliveredForecast());
		test.stopTest();
    }
}