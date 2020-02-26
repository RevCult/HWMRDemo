/*********************************************************************************************************************
** Module Name   : DSMTOSFDCProductTypeEmailService
** Description   : Parse the email service and update DSM Product object
** Throws        : None
** Calls         : None
** Test Class    : <Name of the test class that is used test this class>
** 
** Organization  : Rainmaker Associates LLC
**
** Revision History:-
** Version  Date        Author      WO#         Description of Action
** 1.0      9/11/2013    RMA-KL    XxXX            Initial Version
*******************************************************************************************************************/
global class DSMTOSFDCProductTypeEmailService implements Messaging.InboundEmailHandler {

 
  global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
 //     if(!Test.isRunningTest()){
           //System.debug(email.textAttachments.size());  
           //System.debug(email.textAttachments); 
            if (email.textAttachments != null && email.textAttachments.size() > 0) {
              for (integer i = 0 ; i < email.textAttachments.size() ; i++) {
                  List<List<String>> rows = parseCSV(email.textAttachments[i].body);
                  Map<String,String> buildProductTypeMap = buildProductTypeMap(rows);
                  rows = null;
                  updateProducts(buildProductTypeMap);
              }
            }
            else{system.debug(' >>>>>>> There is no attachment with the mail >>>>>>>> ');}            
 //     }

        return result;
   }
    
   public static void updateProducts(Map<String,String> buildProductTypeMap) {
     
     List<DSM_Products__c> dsmList = new List<DSM_Products__c>();
     for (String s: buildProductTypeMap.keySet()){
        DSM_Products__c dsm = new DSM_Products__c();
        String[] record = buildProductTypeMap.get(s).split(',');
        dsm.Product_ID__c = s;
        dsm.Product_Type__c = record[0];
        String product_name = EncodingUtil.urlDecode(record[1], 'UTF-8');
        if(product_name.length()>80){
            dsm.name = product_name.substring(0,80);
        }
        else{
            dsm.name = product_name;
        }
        dsm.Product_Name__c = product_name;
        dsmList.add(dsm);
        system.debug('dsmList>>>'+dsmList);
     }
       
   //  upsert dsmList Product_ID__c;
    insert dsmList;
       
   }
    
    
   public static Map<String,String> buildProductTypeMap(List<List<String>> rows) {
       List<DSM_Products__c> dsmProd = new List<DSM_Products__c>();
       set<string> dsmProdSet = new set<string>(); 
       Map<String,String> productIDTypeMap = new Map<String,String>();
       system.debug('rows>>>'+rows);
       for (List<String> row : rows) {
         if (row.size() >= 2) {
           productIDTypeMap.put(row.get(0),row.get(1)+','+ EncodingUtil.urlEncode(row.get(2), 'UTF-8') +','+row.get(3));
           dsmProdSet.add(row.get(0));
         }
       }
       if(dsmProdSet.size()>0)
       {
            dsmProd = [SELECT id, Product_ID__c  from DSM_Products__c where Product_ID__c in : dsmProdSet];
       }
       
       for(DSM_Products__c tempdd  : dsmProd){
        if(NULL != productIDTypeMap.get(tempdd.Product_ID__c)){
            productIDTypeMap.remove(tempdd.Product_ID__c);
        }
       }
       
       system.debug('productIDTypeMap>>>'+productIDTypeMap);
      return productIDTypeMap;
   }
                
    //CSV Parsing Utility
   public static List<List<String>> parseCSV(String contents) {
    List<List<String>> allFields = new List<List<String>>();
    contents = contents.replaceAll('","',',');
    contents = contents.replaceAll('"\n','\n');
    contents = contents.replaceAll('\n"','\n');
    //contents = contents.replaceAll(',\"\"\"',',\"DBLQT').replaceall('\"\"\",','DBLQT\",');
    //contents = contents.replaceAll('\"\"','DBLQT');
    List<String> lines = new List<String>();
    try {
        lines = contents.split('\n');
    } catch (System.ListException e) {
        System.debug('Limits exceeded?' + e.getMessage());
    }
    Integer num = 0;
    boolean found =false;
    boolean skip = true;
    for(integer k=0;k<lines.size();k++) {
        String line  = lines.get(k);
        // check for blank CSV lines (only commas)
        //System.debug('line----> ' + line);
        
        if (!line.contains('Product Type') && !found){
            
        } else  if (line.contains('Product Type') && !found) {
            found = true;
        } else {
        
        List<String> fields = line.split(',');  
        List<String> cleanFields = new List<String>();
        String compositeField;
        Boolean makeCompositeField = false;
        for(String field: fields) {
            if (field.startsWith('"') && field.endsWith('"')) {
                cleanFields.add(field.replaceAll('DBLQT','"'));
            } else if (field.startsWith('"')) {
                makeCompositeField = true;
                compositeField = field;
            } else if (field.endsWith('"')) {
                compositeField += ',' + field;
                cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                makeCompositeField = false;
            } else if (makeCompositeField) {
                compositeField +=  ',' + field;
            } else {
                cleanFields.add(field.replaceAll('DBLQT','"'));
            }
        }
        //System.debug('cleanFields ---> ' + cleanFields);
        allFields.add(cleanFields);
        }
    }
    System.debug('allFields ---> ' + allFields);
    return allFields;       
}
    
    

}