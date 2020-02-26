/****************************************************************************************************
*Description:   	Email Messaging Class for Processing RON CSV Information
*
*Required Class(es):BatchRONForecast_Test
*
*Revision   |Date       |Author             |AdditionalNotes
*====================================================================================================
*   1.0    	10/13/2014	Justin Padilla      WO#1748 Initial Version
*****************************************************************************************************/
global class RONForecastEmailService implements Messaging.InboundEmailHandler
{
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope)
	{
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        system.debug('Email Body: '+email.plainTextBody);
 		List<Attachment> attachObjList = new List<Attachment>();
 		
            if (email.textAttachments != null && email.textAttachments.size() > 0) {
            	
            	for(Messaging.Inboundemail.TextAttachment txtattach : email.textAttachments){
	           		system.debug('<<<<<<<<<<<<<<< We are getting the TEXT attachment');
	           		if (txtattach.fileName.toLowerCase().contains('.xml'))
	           		{
		           		Attachment attachObj = new Attachment();
		           		attachObj.parentId= System.label.AccountIdToSaveRON;
		           		attachObj.name = txtattach.fileName;
		           		attachObj.body= Blob.valueOf(txtattach.body);
		           		attachObjList.add(attachObj);
	           		}
            	}
            }
            else if (email.binaryAttachments  != null && email.binaryAttachments.size() > 0 ){
            	
            	for(Messaging.Inboundemail.Binaryattachment binAttach : email.binaryAttachments){
            		system.debug(' >>>>>>> There is a Binary attachment with the mail >>>>>>>> ');
            		if (binAttach.fileName.toLowerCase().contains('.xml'))
	           		{
	            	Attachment attachObj = new Attachment();
	           		attachObj.parentId= System.label.AccountIdToSaveRON;
	           		attachObj.name = binAttach.fileName;
	           		attachObj.body= binAttach.body;
	           		attachObjList.add(attachObj);
	           		}
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