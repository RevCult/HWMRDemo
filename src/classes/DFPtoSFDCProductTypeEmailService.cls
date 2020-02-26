/****************************************************************************************************
*Description:           This email service class handles the Product Type Import Reporting for the 
*                       new DFP System
*
*Required Class(es):    DFPtoSFDCProductTypeEmailService_TEST
*
*Organization: Rainmaker-LLC
*
*Revision   |Date       |Author             |AdditionalNotes
*====================================================================================================
*   1.0     05/06/2015   Justin Padilla     Initial Implementation
*****************************************************************************************************/
global class DFPtoSFDCProductTypeEmailService implements Messaging.InboundEmailHandler {
 global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope) {
        system.debug('DFP Email Service');
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        List<Attachment> attachObjList = new List<Attachment>();
        
        integer numAttachments = email.textAttachments == null ? 0 : email.textAttachments.size();
        integer numBinaryAttachments = email.binaryAttachments == null ?  0  : email.binaryAttachments.size();

        insert new Integration_Log__c ( Log_Level__c = 'Info', Integration_Type__c = 'DFPEmailService', Message__c = 'DSMTOSFDCProductTypeEmailServiceNew starting, ' + numAttachments  + ' text attachments, ' + numBinaryAttachments + ' binary attachments');
        
        
            if (numAttachments > 0) {
                
                for(Messaging.Inboundemail.TextAttachment txtattach : email.textAttachments){
                    system.debug('<<<<<<<<<<<<<<< We are getting the TEXT attachment');
                    Attachment attachObj = new Attachment();
                    attachObj.parentId= System.label.AccountIDToSaveAttachments;
                    attachObj.name = txtattach.fileName;
                    attachObj.body= Blob.valueOf(txtattach.body);
                    attachObj.Description = 'DFP';
                    attachObjList.add(attachObj);
                }
            }
            else if (numBinaryAttachments  > 0 ){
                
                for(Messaging.Inboundemail.Binaryattachment binAttach : email.binaryAttachments){
                    system.debug(' >>>>>>> There is a Binary attachment with the mail >>>>>>>> ');
                    Attachment attachObj = new Attachment();
                    attachObj.parentId= System.label.AccountIDToSaveAttachments;
                    attachObj.name = binAttach.fileName;
                    attachObj.body= binAttach.body;
                    attachObj.Description = 'DFP';
                    attachObjList.add(attachObj);
                }
            }
            else {
                system.debug(' >>>>>>> There is no attachment with the mail >>>>>>>> ');
            }   
        
        try{
            insert attachObjList;
            insert new Integration_Log__c ( Log_Level__c = 'Info', Integration_Type__c = 'DFPEmailService', Message__c = 'DSMTOSFDCProductTypeEmailServiceNew complete, ' + attachObjList.size() + ' attachments created ');

        }
        catch(Exception e){
            System.debug('>>>>>>'+e.getMessage());
            insert new Integration_Log__c ( Log_Level__c = 'Error', Integration_Type__c = 'DFPEmailService', Message__c = 'DSMTOSFDCProductTypeEmailServiceNew failed to create integration attachments,  ' + attachObjList.size() + ' attachments, error: ' + e.getMessage());
        }
        return result;
   }
}