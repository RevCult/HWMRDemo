@isTest(seeAllData = true)
private class Test_DSMToSFDCProductTypeEmailServiceNew {
	static testMethod void testDSMToSFDCProductTypeEmailService(){
		   GoogleIntegrationHelper.disableAsync = true;
		    Account acc = new Account();
		    acc.Name = 'Unique';
            acc.BillingPostalCode = '12345';
		    insert acc;
		    
		   // system.debug('insertedcontact id===>' +testContact.Id);
		   
		   // Create Attachmenat data
		   
		  Attachment attachmnt =new Attachment();
		  attachmnt.name= 'abc';
		  attachmnt.body = blob.valueOf('my text body');
		  attachmnt.ParentId = acc.Id;
		  insert attachmnt ;
		  
		  
		   Test.startTest();
		
		  
		   Messaging.InboundEmail email = new Messaging.InboundEmail() ;
		   Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
		   
		   // setup the data for the email
		   
		  email.subject = 'Test Job Applicant';
		  env.fromAddress = 'iesabhi@yahoo.com';
		  email.fromAddress = env.fromAddress;
		  //env.toAddress = 'abc@abc.com';
		  
		  
		  
		  // add an Text atatchment
		  
		  Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
		  attachmenttext.body = 'my attachment text';
		  attachmenttext.fileName = 'textfiletwo.txt';
		  attachmenttext.mimeTypeSubType = 'text/plain';
		  email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
		 
		 
		  DSMToSFDCProductTypeEmailServiceNew dsm = new DSMToSFDCProductTypeEmailServiceNew();
		  dsm.handleInboundEmail(email, env);
		 
		  
		  // add an Binary attachment
		  Messaging.InboundEmail email1 = new Messaging.InboundEmail() ;
		  Messaging.InboundEnvelope env1 = new Messaging.InboundEnvelope();
		  
		     // setup the data for the email
		   
		  email1.subject = 'Test Job Applicant';
		  env1.fromAddress = 'iesabhi@yahoo.com';
		  email1.fromAddress = env.fromAddress;
		  //env.toAddress = 'abc@abc.com';
		  
		  Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
		  attachment.body = blob.valueOf('my attachment text');
		  attachment.fileName = 'textfileone.txt';
		  attachment.mimeTypeSubType = 'text/plain';
		  email1.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
		 
		  DSMToSFDCProductTypeEmailServiceNew dsm1 = new DSMToSFDCProductTypeEmailServiceNew();
        dsm1.parentAccountId = acc.Id;
		  dsm1.handleInboundEmail(email1, env1);
		    
		   
		   
		   // call the email service class and test it with the data in the testMethod 
		  
		 
		  Test.stopTest();
		  }
		   
		
}