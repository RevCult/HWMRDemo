global class BatchCSVParser implements Database.Batchable<sObject>{ 
    
       
   global Database.QueryLocator start(Database.BatchableContext BC){
    
        DateTime nowTime = DateTime.now();
        DateTime sixHoursBackTime = DateTime.now().addHours(-12);
    
        //JGP 05/06/2015
      //String query = 'Select body from Attachment Where ParentID = \''+System.label.AccountIDToSaveAttachments+'\' AND CreatedDate< :nowTime AND CreatedDate> :sixHoursBackTime  ORDER BY CreatedDate Desc limit 1'; 
      String query = 'Select body, Description from Attachment Where ParentID = \''+System.label.AccountIDToSaveAttachments+'\' AND CreatedDate< :nowTime AND CreatedDate> :sixHoursBackTime  ORDER BY CreatedDate Desc limit 1';
      //String query = 'Select body, Description from Attachment Where id = \'00P23000000eOEk\''; //used for testing purposes
      system.debug('batchrun');
      system.debug('query '+ Database.getQueryLocator(query));
      return Database.getQueryLocator(query);
   }
   
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Attachment> attachList = scope;
        //JGP 05/06/2015 Addition to Separately parse DFP sourced report
        /*
        List<List<String>> rows = parseCSV(attachList[0].body.toString());
        */
        List<List<String>> rows;
        
        if (attachList[0].Description != null && attachList[0].Description.contains('DFP'))
        {   
            rows = parseDFPCSV(attachList[0].body.toString());
            
            /*
            for (List<string> s: rows)
            {
                system.debug('DFP row: '+s);
            }
            */
            
            //Map<String,String> buildProductTypeMap = buildDFPProductTypeMap(rows);
            /*
            for (string s: buildProductTypeMap.keySet())
            {
                system.debug('DFP buildProductTypeMap ID: '+s+' value: '+buildProductTypeMap.get(s));
            }
            */
            updateDFPProducts(rows);
        }
      /*  if (attachList[0].Description == null || attachList[0].Description == '')
        {
            rows = parseCSV(attachList[0].body.toString());
              //was commented out from here to
            for (List<string> s: rows)
            {
                system.debug('DFP row: '+s);
            }
            //here       
            Map<String,String> buildProductTypeMap = buildProductTypeMap(rows);
            rows = null;
            updateProducts(buildProductTypeMap);            
        } */
    }   
  
    global void finish(Database.BatchableContext BC){
   }
   
   public static List<List<String>> parseCSV(String contents) {
        List<List<String>> allFields = new List<List<String>>();
        contents = contents.replaceAll('","',',');
        contents = contents.replaceAll('"\n','\n');
        contents = contents.replaceAll('\n"','\n');
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
                
            } 
            else  if (line.contains('Product Type') && !found) {
                found = true;
            } 
            else {
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
        //System.debug('allFields parseCSV---> ' + allFields);
        return allFields;       
    }
    
    public static Map<String,String> buildProductTypeMap(List<List<String>> rows) {
       List<DSM_Products__c> dsmProd = new List<DSM_Products__c>();
       set<string> dsmProdSet = new set<string>(); 
       Map<String,String> productIDTypeMap = new Map<String,String>();
       //system.debug('rows>>>'+rows);
       for (List<String> row : rows) {
         if (row.size() >= 2) {
           productIDTypeMap.put(row.get(0),row.get(1)+','+ EncodingUtil.urlEncode(row.get(2), 'UTF-8') +','+row.get(4)); //
           //ID = 0
           //Product Type = 1
           //Product Name = 2
           //Product Status = 4
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
       
       //system.debug('productIDTypeMap>>>'+productIDTypeMap);
      return productIDTypeMap;
   }
   
  /*  public static void updateProducts(Map<String,String> buildProductTypeMap) {
         List<DSM_Products__c> dsmList = new List<DSM_Products__c>();
         for (String s: buildProductTypeMap.keySet()){
            DSM_Products__c dsm = new DSM_Products__c();
            String[] record = buildProductTypeMap.get(s).split(',');
            dsm.Product_ID__c = s;
            dsm.Product_Type__c = record[0];
            String product_name = EncodingUtil.urlDecode(record[1], 'UTF-8');
            if(product_name.length()>80){dsm.name = product_name.substring(0,80);}
            else{dsm.name = product_name;}
            dsm.Product_Name__c = product_name;
            dsmList.add(dsm);
            system.debug('dsmList>>>'+dsmList);
         }
     //  upsert dsmList Product_ID__c;
     system.debug('dsmList updateProducts>>>'+dsmList);
     insert dsmList;
   } */
   public static void test(){
   integer i=0;
   for(i=0; i<1000; i++){
   i++;
   i++;
   i++;
   i++;
   i++;
   i++;
   i++;
   i++;
   i++;
   
   }
   }

    public static List<List<String>> parseDFPCSV(String contents)
    {
        List<List<String>> allFields = new List<List<String>>();
        contents = contents.replaceAll('","',',');
        contents = contents.replaceAll('"\n','\n');
        contents = contents.replaceAll('\n"','\n');
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
                
            } 
            else  if (line.contains('Product Type') && !found) {
                found = true;
            } 
            else {
                //system.debug('Line: '+line);
                if (line.contains('"')) //modify to remove quotes
                {
                    string sub = line.subString(0,line.lastIndexOf('"')+1);
                    //system.debug('sub: '+sub);
                    string modified = sub.replace(',','|');
                    string[] splits = modified.split(',');
                    string newMod = '';
                    for (string s: splits)
                    {
                        newMod += s;
                    }
                    //if (newMod.contains(',')) system.debug(' **WTF!');
                    modified = newMod.replace('"','');
                    //system.debug('modified: '+modified);
                    line = line.replace(sub,modified);              
                }
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
        //system.debug('allFields parseDFPCSV---> ' + allFields);
        return allFields;       
    }

    public static Map<String,String> buildDFPProductTypeMap(List<List<String>> rows) {
       List<DSM_Products__c> dsmProd = new List<DSM_Products__c>();
       set<string> dsmProdSet = new set<string>(); 
       Map<String,String> productIDTypeMap = new Map<String,String>();
       system.debug('rows buildDFPProductTypeMap>>>'+rows);
       //system.debug('row size >> '+rows.size());
       for (List<String> row : rows) {
        //system.debug('Row: '+row);
        //system.debug('Build DFP Product Map: '+row+' Size: '+row.size());
         if (row.size() == 5) {
           productIDTypeMap.put(row.get(1),row.get(4)+','+ EncodingUtil.urlEncode(row.get(0), 'UTF-8') +','+row.get(2));
           system.debug('productIDTypeMap::: '+productIDTypeMap);
           //Product Name = 0
           //ID = 1
           //Product Status = 2
           //GL Code =3
           //Product Type = 4
           //WF Template ID = 5
           system.debug('Id: '+row.get(1)+' -- Row Added - row: '+row);
           dsmProdSet.add(row.get(1));
           
         }
         if (row.size() > 5) system.debug('ERROR: '+row);
       }
       //system.debug('dsmProdSet size: '+dsmProdSet.size() + ' :: '+dsmProdSet);
       if(dsmProdSet.size()>0)
       {
            dsmProd = [SELECT id, Product_ID__c  from DSM_Products__c where Product_ID__c in : dsmProdSet];
       }
       
       for(DSM_Products__c tempdd  : dsmProd){
        //system.debug('productIDTypeMap::: '+productIDTypeMap);
        if(NULL != productIDTypeMap.get(tempdd.Product_ID__c)){
            productIDTypeMap.remove(tempdd.Product_ID__c);
        }
       }
       
       //system.debug('productIDTypeMap>>>'+productIDTypeMap);
      return productIDTypeMap;
   }
    public static void updateDFPProducts(List<List<String>> rows) {
         system.debug(Logginglevel.ERROR,'updateDFPProducts rows '+rows);
        system.debug(rows.size());
         List<DSM_Products__c> dsmList = new List<DSM_Products__c>();
         for (List<String> row : rows) {
            DSM_Products__c dsm = new DSM_Products__c();
            //Product Name = 0
            //ID = 1
            //Product Status = 2
            //GL Code =3
            //Product Type = 4
            
            system.debug('rows size>>>' +row.size() +'  ' +row);
            
            dsm.Product_ID__c = row[1];
            dsm.Product_Status__c =row[2];
            dsm.GL_CODE__c = row[3];
            dsm.Product_Type__c = row[4];
            dsm.isDFP__c = true;
             
            String product_name = EncodingUtil.urlDecode(row[0], 'UTF-8');
            if(product_name.length()>80){
                dsm.name = product_name.substring(0,80);
            }
            else{
                dsm.name = product_name;
            }
            dsm.Product_Name__c = row[0];
             if (row[1] != '-' && row[0] != '' && row[2] == 'Active'){
                 dsmList.add(dsm);
             } 
         }
       system.debug('dsmList updateDFPProducts>>> '+dsmList.size()+ '  '+dsmList);
       try{
         upsert dsmList Product_ID__c ;
       }catch(DMLException e){
           system.debug(e);
       }
   }
}