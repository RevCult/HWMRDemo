/****************************************************************************************************
*Description:   	Test Class for the CustomCaseCloneExtension class
*
*Required Class(es):N/A
*
*Revision   |Date       |Author             |AdditionalNotes
*====================================================================================================
*   1.0    	9/29/2014   Justin Padilla      WO#1741 Initial Version
*****************************************************************************************************/
@isTest
private class CustomCaseCloneExtension_Test {

    static testMethod void CustomVFPage_Test()
	{
        //Set up Case objects
        Account a = new Account(Name='Test', BillingPostalCode = '12345');
        insert(a);
        Opportunity o = new Opportunity(StageName='Prospect',Name='Test',Probability=50,AccountId=a.Id,CloseDate=Date.today().addDays(30));
        insert(o);
        Case c = new Case(Subject='Test',AccountId=a.Id);
        insert(c);
        Attachment att = new Attachment(Name='Test',ParentId=c.Id,ContentType='text',Body=Blob.valueOf('Test'));
        insert(att);
        EmailMessage em = new EmailMessage(ParentId=c.Id,TextBody='Test',Subject='Test');
        insert(em);
        CaseComment cc = new CaseComment(ParentId=c.Id, CommentBody='Test');
        insert(cc);
        //Now Create and test the Extension
        Apexpages.StandardController controller = new Apexpages.StandardController(c);
        CustomCaseCloneExtension page = new CustomCaseCloneExtension(controller);
        page.CreateClone();
    }
}