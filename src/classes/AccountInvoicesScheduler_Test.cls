@isTest(SeeAllData = false)
public class AccountInvoicesScheduler_Test {
    
    public static testMethod void testAccountInvschedule() {
        Account accnt = new Account();
        accnt.name='test1';
        accnt.type='prospect';
        accnt.Industry='Banking';
        accnt.BillingPostalCode='590009';
        accnt.Invoices_Sent_on_20th__c = true;
        accnt.Invoices_Sent_on_10th__c = true;
        accnt.Hard_Copy_Invoice__c = true;
        accnt.recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Meyers').getRecordTypeId();
        accnt.Payment_Terms__c = 'Net 30';
        accnt.Hold_Past_Due_Emails__c = NULL;
        insert accnt;
              
        Test.StartTest();
        
              
        AccountPastDueInvoices10th20thScheduler testsche = new AccountPastDueInvoices10th20thScheduler();
        String sch = '0 0 23 10 * ?';
        system.schedule('Test Invoice Check', sch, testsche );
        
        AccountPastDueInvoices10th20thScheduler testsche1 = new AccountPastDueInvoices10th20thScheduler();
        String sch1 = '0 0 23 20 * ?';
        system.schedule('Test Invoice Check1', sch1, testsche1 );
        
        AccountInvoicesScheduler9th testsche2 = new AccountInvoicesScheduler9th();
        String sch2 = '0 0 23 25 * ?';
        system.schedule('Test uncheck 10th checkbox', sch2, testsche2 );
        
        AccountInvoicesScheduler19th testsche3 = new AccountInvoicesScheduler19th();
        String sch3 = '0 0 23 15 * ?';
        system.schedule('Test uncheck 20th checkbox', sch3, testsche3 );
        
        AccountPastDueInvoices10thScheduler testsche4 = new AccountPastDueInvoices10thScheduler();
        String sch4 = '0 0 23 10 * ?';
        system.schedule('Test check 10th', sch4, testsche4 );
        
        AccountPastDueInvoices20thScheduler testsche5 = new AccountPastDueInvoices20thScheduler();
        String sch5 = '0 0 23 20 * ?';
        system.schedule('Test check 20th', sch5, testsche5 );
        
        Test.stopTest();
    }
    
    public static testMethod void testAccountInvschedule2() {
        list<blng__Invoice__c> invoice1 =  new list<blng__Invoice__c>();
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User usr = new User(LastName = 'LIVESTON',
                            FirstName='JASON',
                            Alias = 'jliv',
                            Email = 'jason.liveston@asdf.com',
                            Username = 'jason.liveston@asdf.com123',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US');
       // insert usr;

        Account accnt = new Account();
        accnt.name='test1';
        accnt.Ownerid = usr.id;
        accnt.type='prospect';
        accnt.Industry='Banking';
        accnt.BillingPostalCode='590009';
        accnt.Invoices_Sent_on_20th__c = true;
        accnt.Invoices_Sent_on_10th__c = true;
        accnt.Hard_Copy_Invoice__c = true;
        accnt.Payment_Terms__c = 'Net 30';
        accnt.Hold_Past_Due_Emails__c = NULL;
       // insert accnt;
        
        Contact con = new Contact();
        con.Lastname = 'Test';
        con.email = 'abc@abc.com';
        con.AccountId = accnt.Id;
     //   insert con;
        
        blng__Invoice__c inv1 = new blng__Invoice__c();
        inv1.blng__Account__c = accnt.Id;
        inv1.blng__InvoiceStatus__c = 'Posted';
        inv1.Hard_Copy_Invoice_Account__c = accnt.Hard_Copy_Invoice__c;
        inv1.Payment_Term__c = accnt.Payment_Terms__c;
        inv1.RSD_Auto_Set__c = usr.Id;
        inv1.blng__BillToContact__c = con.id;
        inv1.blng__DueDate__c = system.Today()-41;
       // insert inv1;
        
        blng__FinanceBook__c fBook = new blng__FinanceBook__c();
        fBook.Name = 'sdf';
        fBook.blng__Active__c = true;
        fBook.blng__PeriodType__c = 'Revenue';
      //  insert fBook;
        
        blng__FinancePeriod__c fPer = new blng__FinancePeriod__c();
        fPer.Name = 'Test';
        fPer.blng__FinanceBook__c = fBook.Id;
       // fPer.blng__PeriodStartDate__c = system.today();
        fPer.blng__PeriodStartDate__c =  date.newInstance(2018,05,01) ;
       // fPer.blng__PeriodEndDate__c = system.today()+30;
        fPer.blng__PeriodEndDate__c = date.newInstance(2018,05,31);
        fPer.blng__PeriodStatus__c = 'Open';
       // insert fPer;
        
        blng__InvoiceLine__c invline = new blng__InvoiceLine__c();
        invline.Name = 'test invoice line';
        invline.blng__Invoice__c = inv1.Id ; 
        invline.blng__InvoiceLineStatus__c = 'Posted';
        invline.blng__TotalAmount__c = 45;
      //  insert invline;
      
        Test.StartTest();
        AccountPastDueInvoices10th20thScheduler testsche = new AccountPastDueInvoices10th20thScheduler();
        String sch = '0 0 23 10 * ?';
        system.schedule('Test Invoice Check', sch, testsche );
        AccountPastDueInvoices10th20thScheduler testsche1 = new AccountPastDueInvoices10th20thScheduler();
        String sch1 = '0 0 23 20 * ?';
        system.schedule('Test Invoice Check1', sch1, testsche1 );
        Test.StopTest();
    }

            
}