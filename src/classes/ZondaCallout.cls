public with sharing class ZondaCallout {
    private static String access_token = '';
    private static String refresh_token = '';
    private static Boolean apiKeyNeedsUpdate = FALSE;

    public static String generateWebhookPayloadFromObjects(List<sObject> triggerNewRecords) {
        // Container for the payload sent to the server. 
        List<Map<String, Object>> payloads = new List<Map<String, Object>>();
        
        // Loop through each changed/inserted record. Pull the object details into the payload. 
        for (Integer i = 0; i < triggerNewRecords.size(); i++) {
            Map<String, Object> payload = new Map<String, Object>();
                   
            payload.put('curr', triggerNewRecords[i]);
            if (trigger.isUpdate) { 
                //payload.put('prev', trigger.oldMap.get(triggerNewRecords[i].Id));
                payload.put('is_update', true);
            } else {
                payload.put('is_update', false);
            }
            //payload.put('base_url', URL.getSalesforceBaseUrl().toExternalForm());
            payloads.add(payload);
        }
        system.debug(JSON.serialize(payloads));
        return JSON.serialize(payloads);
    }
    


    @future (callout=true)
    public static void sendWebhookRequest(String klass, String payload) {
        Context.isFutureContext = true; // this helps control recursive trigger calls since we're going to update the records after we get back an ID
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();

        String endpoint =  'https://zapi.zonda.co/v11/'; //'https://e2e001e2.ngrok.io/v6';    //ZondaApiSetting__c.getInstance('base_url').Value__c;
        //https://demozapi.zonda.co/v11/  
        //https://qazapi.zonda.co/v11/
        //https://zapi.zonda.co/v11/
        if (!endpoint.endsWith('/')) { endpoint += '/'; }
        //system.debug('sendingABC: '+EncodingUtil.urlEncode(payload, 'UTF-8'));

        //String url1 = endpoint + 'webhooks/' + klass + '?' + klass + '=' + payload;        //Added for debuging
        String url = endpoint + 'webhooks/' + klass + '?' + klass + '=' + EncodingUtil.urlEncode(payload, 'UTF-8'); // + '&access_token=' + getAPIKey()
        //system.debug('klass = ' + klass);        //Added for debuging
        system.debug('payload = ' + payload);        //Added for debuging
        //system.debug('url1 = ' + url1);        //Added for debuging
        //system.debug('Test' + !Test.isRunningTest());
        
        system.debug('url = ' + url);

        req.setEndpoint(url);
        req.setMethod('GET');
 
        if (!Test.isRunningTest()) 
        {
            try {
                res = http.send(req);
                //if (res.getStatusCode() != 200) {
                    system.debug(res);
                //}
            } catch(System.CalloutException e) {
                System.debug('Callout error: '+ e + res.toString());

            }
        }
        
    //    // have to perform any DML operations AFTER the Callout has occurred...  Salesforce won't let you make a callout with non-committed DML in progress
    //    if (apiKeyNeedsUpdate) {
    //        updateApiSettingValues();
    //    }
    //    // if klass == customers, and this was an insert, then we should get the customer id out of the response and update the zonda_account__c.customer_id__c
    //    if (klass == 'customers') {
    //        handleCustomerIdUpdate(res.getBody());
    //    }
    //    // if klass == users, and this was an insert, then we should get the user id out of the response and update the zonda_user__c.user_id__c
    //    if (klass == 'users') {
    //        handleUserIdUpdate(res.getBody());
    //    }
    //}

    //private static void handleCustomerIdUpdate(String responseBody) {
    //    system.debug('responseBody: '+responseBody);
    //    // get the returned customer_id and id and update the Zonda_Account__c.Customer_Id__c field with the customer_id from the database -- id should be the salesforce id
    //    Map<Id, Integer> mapZondaAccountIdToDbId = new Map<Id, Integer>();

    //    List<Object> responseList = new List<Object>();
    //    if (String.isNotBlank(responseBody)) {
    //        responseList = (List<Object>)JSON.deserializeUntyped(responseBody);
    //    }
    //    system.debug('responseList: '+responseList);
        
    //    for (Integer i = 0; i < responseList.size(); i++) {
    //        Object theObject = JSON.serialize(responseList[i]);
    //        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(String.valueOf(theObject));
    //        if (null != responseMap.get('Id') && null != responseMap.get('customer_id')) {
    //            mapZondaAccountIdToDbId.put((Id)responseMap.get('Id'), (Integer)responseMap.get('customer_id'));
    //        }
    //        system.debug(responseMap);
    //    }

    //    if (!mapZondaAccountIdToDbId.isEmpty()) {
    //        List<Zonda_Account__c> zondaAccountsToUpdate = [SELECT Id, Customer_Id__c FROM Zonda_Account__c WHERE Id IN :mapZondaAccountIdToDbId.keyset()];
    //        if (null != zondaAccountsToUpdate && !zondaAccountsToUpdate.isEmpty()) {
    //            for (Zonda_Account__c za : zondaAccountsToUpdate) {
    //                za.Customer_Id__c = mapZondaAccountIdToDbId.get(za.Id);
    //            }
    //        }
    //        update zondaAccountsToUpdate;
    //    }
    }



    //private static void handleUserIdUpdate(String responseBody) {
    //    system.debug('responseBody: '+responseBody);
    //    // get the returned user_id and id and update the Zonda_User__c.Zonda_User_Id__c field with the user_id from the database -- id should be the salesforce id
    //    Map<Id, Integer> mapZondaUserIdToDbId = new Map<Id, Integer>();

    //    List<Object> responseList = new List<Object>();
    //    if (String.isNotBlank(responseBody)) {
    //        responseList = (List<Object>)JSON.deserializeUntyped(responseBody);
    //    }
    //    system.debug('responseList: '+responseList);
        
    //    for (Integer i = 0; i < responseList.size(); i++) {
    //        Object theObject = JSON.serialize(responseList[i]);
    //        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(String.valueOf(theObject));
    //        if (null != responseMap.get('Id') && null != responseMap.get('user_id')) {
    //            mapZondaUserIdToDbId.put((Id)responseMap.get('Id'), (Integer)responseMap.get('user_id'));
    //        }
    //        system.debug(responseMap);
    //    }

    //    if (!mapZondaUserIdToDbId.isEmpty()) {
    //        List<Zonda_User__c> zondaUsersToUpdate = [SELECT Id, Zonda_User_Id__c FROM Zonda_User__c WHERE Id IN :mapZondaUserIdToDbId.keyset()];
    //        if (null != zondaUsersToUpdate && !zondaUsersToUpdate.isEmpty()) {
    //            for (Zonda_User__c zu : zondaUsersToUpdate) {
    //                zu.Zonda_User_Id__c = mapZondaUserIdToDbId.get(zu.Id);
    //            }
    //        }
    //        update zondaUsersToUpdate;
    //    }
    //}



    //public static String getAPIKey() {
    //    access_token = ZondaApiSetting__c.getInstance('access_token').Value__c;
    //    refresh_token = ZondaApiSetting__c.getInstance('refresh_token').Value__c;
    //    String api_user = ZondaApiSetting__c.getInstance('api_user').Value__c;
    //    String api_pw = ZondaApiSetting__c.getInstance('api_pw').Value__c;
    //    String token_expiration_timestamp = ZondaApiSetting__c.getInstance('token_expiration_timestamp').Value__c;
    //    String endpoint = ZondaApiSetting__c.getInstance('base_url').Value__c;
    //    if (!endpoint.endsWith('/')) { endpoint += '/'; }

    //    Datetime expiration_timestamp = System.now()-10; // default value - assume we need a new token unless proven otherwise

    //    if (String.isNotBlank(token_expiration_timestamp)) {
    //        try {
    //            expiration_timestamp = Datetime.valueOf(token_expiration_timestamp);
    //        } catch (Exception e) {
    //            system.debug(e.getMessage());
    //        }
    //    }

    //    if (expiration_timestamp < system.now()) {
    //        // the token has expired - get a new one and store things in the ZondaApiSetting__c custom setting
    //        if (String.isNotBlank(refresh_token)) {
    //            try {
    //                // send a refresh call
    //                HttpRequest req = new HttpRequest();
    //                HttpResponse res = new HttpResponse();
    //                Http http = new Http();
                    
    //                req.setEndpoint(endpoint + 'tokens/refresh/' + refresh_token);
    //                req.setMethod('GET');
             
    //                if (!Test.isRunningTest()) {
    //                    try {
    //                        res = http.send(req);
    //                    } catch(System.CalloutException e) {
    //                        system.debug('Callout error: '+ e + res.toString());
    //                    }
    //                }
    //                Map<String, Object> responseValues = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
    //                access_token = String.valueOf(responseValues.get('access_token'));
    //                refresh_token = String.valueOf(responseValues.get('refresh_token'));
    //                apiKeyNeedsUpdate = TRUE;
    //            } catch (Exception ex) {
    //                // the refresh wasn't valid for some reason, so do an authenticate call
    //                HttpRequest req = new HttpRequest();
    //                HttpResponse res = new HttpResponse();
    //                Http http = new Http();
                    
    //                req.setEndpoint(endpoint + 'authenticate/' + api_user + '/' + api_pw);
    //                req.setMethod('GET');
             
    //                if (!Test.isRunningTest()) {
    //                    try {
    //                        res = http.send(req);
    //                    } catch(System.CalloutException e) {
    //                        system.debug('Callout error: '+ e + res.toString());
    //                    }
    //                }
    //                Map<String, Object> responseValues = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
    //                access_token = String.valueOf(responseValues.get('access_token'));
    //                refresh_token = String.valueOf(responseValues.get('refresh_token'));
    //                apiKeyNeedsUpdate = TRUE;
    //            }
    //        } else {
    //            // we have no refresh token - just do an authenticate call and get all new stuff
    //            HttpRequest req = new HttpRequest();
    //            HttpResponse res = new HttpResponse();
    //            Http http = new Http();
                
    //            req.setEndpoint(endpoint + 'authenticate/' + api_user + '/' + api_pw);
    //            req.setMethod('GET');
         
    //            if (!Test.isRunningTest()) {
    //                try {
    //                    res = http.send(req);
    //                } catch(System.CalloutException e) {
    //                    system.debug('Callout error: '+ e + res.toString());
    //                }
    //            }
    //            if (String.isNotBlank(res.getBody())) {
    //                Map<String, Object> responseValues = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
    //                access_token = String.valueOf(responseValues.get('access_token'));
    //                refresh_token = String.valueOf(responseValues.get('refresh_token'));
    //                apiKeyNeedsUpdate = TRUE;
    //            }
    //        }
    //    }
        
    //    return access_token;
    //}

    //private static void updateApiSettingValues() {
    //    List<ZondaApiSetting__c> settingsToUpdate = new List<ZondaApiSetting__c>();
    //    settingsToUpdate.add(ZondaApiSetting__c.getInstance('access_token'));
    //    settingsToUpdate.add(ZondaApiSetting__c.getInstance('refresh_token'));
    //    settingsToUpdate.add(ZondaApiSetting__c.getInstance('token_expiration_timestamp'));

    //    for (ZondaApiSetting__c setting : settingsToUpdate) {
    //        if (setting.Name == 'access_token') {
    //            setting.Value__c = access_token;
    //        } else if (setting.Name == 'refresh_token') {
    //            setting.Value__c = refresh_token;
    //        } else if (setting.Name == 'token_expiration_timestamp') {
    //            setting.Value__c = String.valueOf(System.now().addMinutes(15));
    //        }
    //    }

    //    update settingsToUpdate;
    //
    //}
}