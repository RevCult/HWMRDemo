global class DSMTOSFDCProductTypeEmailServiceNew implements Messaging.InboundEmailHandler {
    public String parentAccountId = System.label.AccountIDToSaveAttachments;
 global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
 		List<Attachment> attachObjList = new List<Attachment>();
 		
            if (email.textAttachments != null && email.textAttachments.size() > 0) {
            	
            	for(Messaging.Inboundemail.TextAttachment txtattach : email.textAttachments){
	           		system.debug('<<<<<<<<<<<<<<< We are getting the TEXT attachment');
	           		Attachment attachObj = new Attachment();
	           		attachObj.parentId= parentAccountId;
	           		attachObj.name = txtattach.fileName;
	           		attachObj.body= Blob.valueOf(txtattach.body);
	           		attachObjList.add(attachObj);
            	}
            }
            else if (email.binaryAttachments  != null && email.binaryAttachments.size() > 0 ){
            	
            	for(Messaging.Inboundemail.Binaryattachment binAttach : email.binaryAttachments){
            		system.debug(' >>>>>>> There is a Binary attachment with the mail >>>>>>>> ');
	            	Attachment attachObj = new Attachment();
	           		attachObj.parentId= parentAccountId;
	           		attachObj.name = binAttach.fileName;
	           		attachObj.body= binAttach.body;
	           		attachObjList.add(attachObj);
            	}
            }
            else {
            	system.debug(' >>>>>>> There is no attachment with the mail >>>>>>>> ');
            }   
		
		try{
   			insert attachObjList;
   		}
   		catch(Exception e){
   			System.debug('>>>>>>'+e.getMessage());
   		}
        return result;
   }
   }