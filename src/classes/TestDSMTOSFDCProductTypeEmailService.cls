@isTest
public class TestDSMTOSFDCProductTypeEmailService{

     /*static testMethod void testMethod1() {
        Messaging.InboundEmail inEmail = new Messaging.InboundEmail() ;
  		Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
	    DSMTOSFDCProductTypeEmailService es = new DSMTOSFDCProductTypeEmailService();
        es.handleInboundEmail(inEmail, envelope);
    }*/
    
    static testMethod void testUnitTest() {
 
	  // create a new email and envelope object
	  Messaging.InboundEmail email = new Messaging.InboundEmail() ;
	  Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
	 
	  // setup the data for the email
	  email.subject = 'Test Job Applicant';
	  email.fromname = 'FirstName LastName';
	  env.fromAddress = 'someaddress@email.com';
	 
	  // add an attachment
	  Messaging.InboundEmail.TextAttachment attachment = new Messaging.InboundEmail.TextAttachment();
	  attachment.body = 'my attachment text Product Type \n Product Type';
	  attachment.fileName = 'textfile.txt';
	  attachment.mimeTypeSubType = 'texttwo/plain';
	  email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachment };
	  
	  // call the email service class and test it with the data in the testMethod
	  DSMTOSFDCProductTypeEmailService emailProcess = new DSMTOSFDCProductTypeEmailService();
	  emailProcess.handleInboundEmail(email, env);
	}
}