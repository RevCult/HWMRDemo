public with sharing class GoogleIntegrationHelper {
    public static Boolean disableAsync = false;
/*Code for Account object - Start*/
    @future(callout=true)
    public static void UpdateAccountFieldsFromGoogleAsync(Id accountId) {
        if(disableAsync){
            // Async helper disabled
            System.debug('GoogleIntegrationHelper Disabled Async Disabled');
            return;
        }
        List<Account> accountsThatNeedUpdates = [SELECT Id, BillingPostalCode FROM Account WHERE Id = :accountId];
        UpdateAccountFieldsFromGoogle(accountsThatNeedUpdates);
    }

    public static void UpdateAccountFieldsFromGoogle(List<Account> AccountIdsThatNeedUpdates) {
        List<Account> AccountThatNeedUpdates = [Select Name, Id, BillingPostalCode From Account WHERE Id IN :AccountIdsThatNeedUpdates];
        for (Account theAccount : AccountThatNeedUpdates) {
         
             if (null != theAccount.BillingPostalCode) {
                GoogleAddressResponse theAddressResponse = getAddressAcc(theAccount);
                system.debug('theAddressResponse: '+theAddressResponse);
                if(theAddressResponse!=null){
               		if (theAddressResponse.status == 'OK') {
                     
                    Result r = theAddressResponse.results[0];
                    String theSublocality = '';
                    for (Address_component ac : r.address_components) {
                        if (ac.types.contains('postal_code')) {
                            //theAccount.BillingPostalCode = ac.long_name;   //Do NOT update ZIP CODE!
                        }  else if (ac.types.contains('country')) {
                            theAccount.BillingCountry = ac.long_name;
                        }  else if (ac.types.contains('locality')) {
                            theAccount.BillingCity = ac.long_name;
                        }  else if (ac.types.contains('administrative_area_level_1')) {
                            //theAccount.BillingState = ac.long_name; 
                            theAccount.BillingState = ac.short_name;
                        } 
                    }
                   
               } system.debug('**Good Request**');
                 }
            }
             else {
              system.debug('**BAD Request**');
            }
        }
        update AccountThatNeedUpdates;
    }
    public static GoogleAddressResponse getAddressAcc(Account theAccount) {
        if (null != theAccount) {
            if (null != GoogleIntegrationHelperSetting__c.getInstance('AddressEndpoint') && null != GoogleIntegrationHelperSetting__c.getInstance('AddressApiKey')) {
                Http h = new Http();
                HttpRequest request = new HttpRequest();
              //  String endPointString = BuildSignedUrl(GoogleIntegrationHelperSetting__c.getInstance('AddressEndpoint').Value__c+'?latlng='+theAccount.Location__latitude__s+','+theAccount.Location__longitude__s+'&client='+GoogleIntegrationHelperSetting__c.getInstance('ClientId').Value__c);
              //  String endPointString = BuildSignedUrl(GoogleIntegrationHelperSetting__c.getInstance('AddressEndpoint').Value__c+'?address='+theAccount.BillingPostalCode+'&client='+GoogleIntegrationHelperSetting__c.getInstance('ClientId').Value__c);
                String endPointString = GoogleIntegrationHelperSetting__c.getInstance('AddressEndpoint').Value__c+'?address=zip'+theAccount.BillingPostalCode+'&key='+GoogleIntegrationHelperSetting__c.getInstance('AddressApiKey').Value__c;
                system.debug('endPointString: '+endPointString);
                request.setEndpoint(endPointString);
                request.setMethod('GET');
                request.setHeader('Content-Type', 'application/json');
                HttpResponse response = h.send(request);
                return (GoogleAddressResponse)System.JSON.deserialize(response.getBody(), GoogleAddressResponse.class);
            } else {
                return null;
            }
        } else {
            return null;
        }
    }
/*Code for Account object - End*/

    
/*Code for Contact object - Start*/  
    @future(callout=true)
    public static void UpdateContactFieldsFromGoogleAsync(Id contactId) {
        List<Contact> contactsThatNeedUpdates = [SELECT Id,MailingPostalCode FROM Contact WHERE Id = :contactId];
        UpdateContactFieldsFromGoogle(contactsThatNeedUpdates);
    }

    public static void UpdateContactFieldsFromGoogle(List<Contact> ContactIdsThatNeedUpdates) {
        List<Contact> ContactThatNeedUpdates = [Select Name, Id,MailingPostalCode From Contact WHERE Id IN :ContactIdsThatNeedUpdates];
        for (Contact theContact : ContactThatNeedUpdates) {
            
               if (null != theContact.MailingPostalCode) {
                GoogleAddressResponse theAddressResponse = getAddressAcc(theContact);
                system.debug('theAddressResponse: '+theAddressResponse);
               if (theAddressResponse != null && theAddressResponse.status == 'OK') {
                    
                    Result r = theAddressResponse.results[0];
                    String theSublocality = '';
                    for (Address_component ac : r.address_components) {
                        if (ac.types.contains('postal_code')) {
                            //theContact.MailingPostalCode = ac.long_name;  // Do NOT update Zip Code
                        }  else if (ac.types.contains('country')) {
                            theContact.MailingCountry = ac.long_name;
                        }  else if (ac.types.contains('locality')) {
                            theContact.MailingCity = ac.long_name;
                        }  else if (ac.types.contains('administrative_area_level_1')) {
                            //theContact.MailingState = ac.long_name;
                            theContact.MailingState = ac.short_name;
                        } 
                    }
                   
               } system.debug('**Good Request**');
            }
             else {
              system.debug('**BAD Request**');
            }
        }
        update ContactThatNeedUpdates;
    }
    public static GoogleAddressResponse getAddressAcc(Contact theContact) {
        if (null != theContact) {
            if (null != GoogleIntegrationHelperSetting__c.getInstance('AddressEndpoint') && null != GoogleIntegrationHelperSetting__c.getInstance('AddressApiKey')) {
                Http h = new Http();
                HttpRequest request = new HttpRequest();
              //  String endPointString = BuildSignedUrl(GoogleIntegrationHelperSetting__c.getInstance('AddressEndpoint').Value__c+'?address='+theContact.MailingPostalCode+'&client='+GoogleIntegrationHelperSetting__c.getInstance('ClientId').Value__c);
                String endPointString = GoogleIntegrationHelperSetting__c.getInstance('AddressEndpoint').Value__c+'?address=zip'+theContact.MailingPostalCode+'&key='+GoogleIntegrationHelperSetting__c.getInstance('AddressApiKey').Value__c;
                system.debug('endPointString: '+endPointString);
                request.setEndpoint(endPointString);
                request.setMethod('GET');
                request.setHeader('Content-Type', 'application/json');
                HttpResponse response = h.send(request);
                return (GoogleAddressResponse)System.JSON.deserialize(response.getBody(), GoogleAddressResponse.class);
            } else {
                return null;
            }
        } else {
            return null;
        }
    }
/*Code for Contact object - End*/

    
/*Code for Project object - Start*/    
    @future(callout=true)
    public static void UpdateProjectFieldsFromGoogleAsync(Id projectId) {
        List<Project__c> projectsThatNeedUpdates = [SELECT Id FROM Project__c WHERE Id = :projectId];
        UpdateProjectFieldsFromGoogle(projectsThatNeedUpdates);
    }

    public static void UpdateProjectFieldsFromGoogle(List<Project__c> projectIdsThatNeedUpdates) {
        List<Project__c> projectsThatNeedUpdates = [SELECT Id, Website__c, Location__Latitude__s, Location__Longitude__s, Short_URL__c, Geocode_Type_calc__c, Address_calc__c, CBSA__c,City_calc__c, County_calc__c, Neighborhood_calc__c, State_calc__c, ZIP_Code_calc__c FROM Project__c WHERE Id IN :projectIdsThatNeedUpdates];
        for (Project__c theProject : projectsThatNeedUpdates) {
            if (null != theProject.Website__c && '' != theProject.Website__c) {
                GoogleUrlResponse theUrlResponse = getShortURLforProject(theProject);
                if (null != theUrlResponse) {
                    theProject.Short_URL__c = theUrlResponse.id;
                }
            } else {
                theProject.Short_URL__c = '';
            }
            if (null != theProject.Location__Latitude__s && null != theProject.Location__Longitude__s) {
                GoogleAddressResponse theAddressResponse = getAddress(theProject);
                system.debug('theAddressResponse: '+theAddressResponse);
                if (theAddressResponse!=null && theAddressResponse.status == 'OK') {
                //if (theAddressResponse.status == 'OK') {
                    theProject.Geocode_Type_calc__c = '';
                    theProject.Address_calc__c = '';
                    theProject.CBSA__c ='';
                    theProject.ZIP_Code_calc__c = '';
                    theProject.County_calc__c = '';
                    theProject.City_calc__c = '';
                    theProject.State_calc__c = '';
                    theProject.Neighborhood_calc__c = '';
                    Result r = theAddressResponse.results[0];
                    theProject.Geocode_Type_calc__c = r.geometry.location_type;
                    theProject.Address_calc__c = r.formatted_address;
                    //theProject.CBSA__c = r.formatted_address;
                    String theSublocality = '';
                    for (Address_component ac : r.address_components) {
                        if (ac.types.contains('postal_code')) {
                            theProject.ZIP_Code_calc__c = ac.long_name;
                        } else if (ac.types.contains('administrative_area_level_2')) {
                            theProject.County_calc__c = ac.long_name;
                        } else if (ac.types.contains('locality')) {
                            theProject.City_calc__c = ac.long_name;
                        } else if (ac.types.contains('administrative_area_level_1')) {
                            theProject.State_calc__c = ac.short_name;
                            if (ac.short_name == 'DC') {
                                theProject.County_calc__c = ac.long_name;
                            }
                        } else if (ac.types.contains('neighborhood')) {
                            theProject.Neighborhood_calc__c = ac.long_name;
                        } else if (ac.types.contains('sublocality')) {
                            theSublocality = ac.long_name;
                        }
                    }
                    if (theProject.City_calc__c == null || theProject.City_calc__c == '') {
                        if (theSublocality != null && theSublocality != '') {
                            theProject.City_calc__c = theSublocality; // handles things like boroughs in NYC, etc...
                        } /*else if (theProject.Neighborhood_calc__c != null && theProject.Neighborhood_calc__c != '') {
                            theProject.City_calc__c = theProject.Neighborhood_calc__c;
                        }*/
                    }
                }
            //////////////////////////////////////////////////////////////////
                system.debug('Project------>County===='+theProject.County_calc__c+' State==='+theProject.State_calc__c);
                String PCounty;
                String County;
                if(theProject.County_calc__c !=null){
                    PCounty = theProject.County_calc__c;
                    if(PCounty!='' && PCounty.containsIgnoreCase(' County')){
                        County = PCounty.removeEndIgnoreCase(' County');
                    }
                    else if(PCounty!='' && PCounty.containsIgnoreCase(' City')){
                        County = PCounty.removeEndIgnoreCase(' City');
                    }
                    else{
                        County = PCounty;
                    }    
                  
                    // Added to get data from Static Resource
                    List<StaticResource> docs = new List<StaticResource>();
                    docs = [select id, name, body from StaticResource  where name = 'CBSALookup']; 
                    string obody = docs[0].body.toString().remove('"').remove('County Name: ').remove('State Name: ').remove('CBSA Title: ').remove('[').remove(']').remove('\\n');
                    list<string> dcs = new list<string>();
                    dcs = obody.split('}');
                    map<string,string> strnMap =  new map<string,string>();   
                    for(integer i=0;i<dcs.size();i++){
                        string str = dcs[i].remove('{').replaceAll('(\\r|\\n)+', '').removeStart(',');
                        string s1 = str.substringBefore(',').remove(' ');
                        string s11 = str.substringAfter(',');
                        string s2 = s11.substringBefore(',').remove(' ');
                        string s22 = s11.substringAfter(',');
                        strnMap.put(s1+','+s2,s22);
                        //system.debug('s1+s2=='+s1+','+s2);
                    }
					system.debug('county===='+County+','+theProject.State_calc__c);  
                    system.debug(strnMap.containsKey(County+','+theProject.State_calc__c));
                    if(strnMap.containsKey(County.remove(' ')+','+theProject.State_calc__c.remove(' ')))
						theProject.CBSA__c = strnMap.get(County.remove(' ')+','+theProject.State_calc__c.remove(' '));                    
                }
            //////////////////////////////////////////////////////////////////
            } else {
                theProject.Geocode_Type_calc__c = '';
                theProject.Address_calc__c = '';
                theProject.CBSA__c ='';
                theProject.ZIP_Code_calc__c = '';
                theProject.County_calc__c = '';
                theProject.City_calc__c = '';
                theProject.State_calc__c = '';
                theProject.Neighborhood_calc__c = '';
            }
        }
        update projectsThatNeedUpdates;
        system.debug('After update projects that need updates');
    }
/*Code for Project object - End*/ 
    
    
/*Code for Land Listing object - Start*/ 
    @future(callout=true)
    public static void UpdateLandListingFieldsFromGoogleAsync(Id listingId) {
        List<Land_Listing__c> listingsThatNeedUpdates = [SELECT Id FROM Land_Listing__c WHERE Id = :listingId];
        UpdateLandListingFieldsFromGoogle(listingsThatNeedUpdates);
    }

    public static void UpdateLandListingFieldsFromGoogle(List<Land_Listing__c> listingIdsThatNeedUpdates) {
        List<Land_Listing__c> listingsThatNeedUpdates = [SELECT Id, Listing_URL__c, Shortened_Listing_URL__c FROM Land_Listing__c WHERE Id IN :listingIdsThatNeedUpdates];
        for (Land_Listing__c theListing : listingsThatNeedUpdates) {
            if (null != theListing.Listing_URL__c && '' != theListing.Listing_URL__c) {
                GoogleUrlResponse theUrlResponse = getShortURLforLandListing(theListing);
                if (null != theUrlResponse) {
                    theListing.Shortened_Listing_URL__c = theUrlResponse.id;
                }
            } else {
                theListing.Shortened_Listing_URL__c = '';
            }
        }
        update listingsThatNeedUpdates;
    }

    public static GoogleUrlResponse getShortURLforProject(Project__c theProject) {
        if (null != theProject) {
            if (null != GoogleIntegrationHelperSetting__c.getInstance('UrlEndpoint')) {
                Http h = new Http();
                HttpRequest request = new HttpRequest();
                String endPointString = GoogleIntegrationHelperSetting__c.getInstance('UrlEndpoint').Value__c+'?key='+GoogleIntegrationHelperSetting__c.getInstance('AddressApiKey').Value__c;
                request.setEndpoint(endPointString);
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json');
                request.setBody('{"longUrl":"'+theProject.Website__c+'"}');
                HttpResponse response = h.send(request);
                if (response.getStatusCode() == 200) {
                    return (GoogleUrlResponse)JSON.deserialize(response.getBody(), GoogleUrlResponse.class);
                } else { // no good response from google
                    system.debug(response);
                    return null;
                }
            } else { // Endpoint isn't configured
                return null;
            }
        } else { // no project received
            return null;
        }
    }

    public static GoogleUrlResponse getShortURLforLandListing(Land_Listing__c theListing) {
        if (null != theListing) {
            if (null != GoogleIntegrationHelperSetting__c.getInstance('UrlEndpoint')) {
                Http h = new Http();
                HttpRequest request = new HttpRequest();
                String endPointString = GoogleIntegrationHelperSetting__c.getInstance('UrlEndpoint').Value__c+'?key='+GoogleIntegrationHelperSetting__c.getInstance('AddressApiKey').Value__c;
                request.setEndpoint(endPointString);
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json');
                request.setBody('{"longUrl":"'+theListing.Listing_URL__c+'"}');
                HttpResponse response = h.send(request);
                if (response.getStatusCode() == 200) {
                    return (GoogleUrlResponse)JSON.deserialize(response.getBody(), GoogleUrlResponse.class);
                } else { // no good response from google
                    system.debug(response);
                    return null;
                }
            } else { // Endpoint isn't configured
                return null;
            }
        } else { // no listing received
            return null;
        }
    }
/*Code for Land Listing object - End*/ 
    
    
/*Code for Communities object - Start*/   
    @future(callout=true)
    public static void UpdateCommunityFieldsFromGoogleAsync(Id CommunityId) {
        List<Community__c> CommunitysThatNeedUpdates = [SELECT Id FROM Community__c WHERE Id = :CommunityId];
        UpdateCommunityFieldsFromGoogle(CommunitysThatNeedUpdates);
    }

    public static void UpdateCommunityFieldsFromGoogle(List<Community__c> CommunityIdsThatNeedUpdates) {
        List<Community__c> CommunitysThatNeedUpdates = [SELECT Id, Location__Latitude__s, Location__Longitude__s, Address_calc__c, CBSA__c,City_calc__c, County_calc__c, State_calc__c, ZIP_Code_calc__c FROM Community__c WHERE Id IN :CommunityIdsThatNeedUpdates];
        for (Community__c theCommunity : CommunitysThatNeedUpdates) {
            if (null != theCommunity.Location__Latitude__s && null != theCommunity.Location__Longitude__s) {
                GoogleAddressResponse theAddressResponse = getAddressCommunity(theCommunity);
                system.debug('theAddressResponse: '+theAddressResponse);
                if (theAddressResponse !=null && theAddressResponse.status == 'OK') {
                    theCommunity.Address_calc__c = '';
                    theCommunity.CBSA__c ='';
                    theCommunity.ZIP_Code_calc__c = '';
                    theCommunity.County_calc__c = '';
                    theCommunity.City_calc__c = '';
                    theCommunity.State_calc__c = '';
                    Result r = theAddressResponse.results[0];
                    theCommunity.Address_calc__c = r.formatted_address;
                    String theSublocality = '';
                    for (Address_component ac : r.address_components) {
                        if (ac.types.contains('postal_code')) {
                            theCommunity.ZIP_Code_calc__c = ac.long_name;
                        } else if (ac.types.contains('administrative_area_level_2')) {
                            theCommunity.County_calc__c = ac.long_name;
                        } else if (ac.types.contains('locality')) {
                            theCommunity.City_calc__c = ac.long_name;
                        } else if (ac.types.contains('administrative_area_level_1')) {
                            theCommunity.State_calc__c = ac.short_name;
                            if (ac.short_name == 'DC') {
                                theCommunity.County_calc__c = ac.long_name;
                            }
                        } else if (ac.types.contains('sublocality')) {
                            theSublocality = ac.long_name;
                        }
                    }
                    if (theCommunity.City_calc__c == null || theCommunity.City_calc__c == '') {
                        if (theSublocality != null && theSublocality != '') {
                            theCommunity.City_calc__c = theSublocality; // handles things like boroughs in NYC, etc...
                        }
                    }
                }
//////////////////////////////////////////////////////////////////
                system.debug('Community------>County===='+theCommunity.County_calc__c+' State==='+theCommunity.State_calc__c);
                String PCounty;
                String County;
                if(theCommunity.County_calc__c !=null){
                    PCounty = theCommunity.County_calc__c;
                    if(PCounty!='' && PCounty.containsIgnoreCase(' County')){
                        County = PCounty.removeEndIgnoreCase(' County');
                    }
                    else if(PCounty!='' && PCounty.containsIgnoreCase(' City')){
                        County = PCounty.removeEndIgnoreCase(' City');
                    }
                    else{
                        County = PCounty;
                    }    
                  
                    // Added to get data from Static Resource
                    List<StaticResource> docs = new List<StaticResource>();
                    docs = [select id, name, body from StaticResource  where name = 'CBSALookup']; 
                    string obody = docs[0].body.toString().remove('"').remove('County Name: ').remove('State Name: ').remove('CBSA Title: ').remove('[').remove(']').remove('\\n');
                    list<string> dcs = new list<string>();
                    dcs = obody.split('}');
                    map<string,string> strnMap =  new map<string,string>();   
                    for(integer i=0;i<dcs.size();i++){
                        string str = dcs[i].remove('{').replaceAll('(\\r|\\n)+', '').removeStart(',');
                        string s1 = str.substringBefore(',').remove(' ');
                        string s11 = str.substringAfter(',');
                        string s2 = s11.substringBefore(',').remove(' ');
                        string s22 = s11.substringAfter(',');
                        strnMap.put(s1+','+s2,s22);
                        system.debug('s1+s2=='+s1+','+s2);
                    }
					system.debug('county===='+County+','+theCommunity.State_calc__c);  
                    system.debug(strnMap.containsKey(County+','+theCommunity.State_calc__c));
                    if(strnMap.containsKey(County.remove(' ')+','+theCommunity.State_calc__c.remove(' ')))
						theCommunity.CBSA__c = strnMap.get(County.remove(' ')+','+theCommunity.State_calc__c.remove(' '));                    
                }
//////////////////////////////////////////////////////////////////
            } else {
                theCommunity.Address_calc__c = '';
                theCommunity.CBSA__c ='';
                theCommunity.ZIP_Code_calc__c = '';
                theCommunity.County_calc__c = '';
                theCommunity.City_calc__c = '';
                theCommunity.State_calc__c = '';
            }
        }
        update CommunitysThatNeedUpdates;
    }

    public static GoogleAddressResponse getAddresscommunity(Community__c Community) {
        if (null != Community) {
            if (null != GoogleIntegrationHelperSetting__c.getInstance('AddressEndpoint') && null != GoogleIntegrationHelperSetting__c.getInstance('AddressApiKey')) {
                Http h = new Http();
                HttpRequest request = new HttpRequest();
                String endPointString = BuildSignedUrl(GoogleIntegrationHelperSetting__c.getInstance('AddressEndpoint').Value__c+'?latlng='+Community.Location__latitude__s+','+Community.Location__longitude__s+'&client='+GoogleIntegrationHelperSetting__c.getInstance('ClientId').Value__c);
                system.debug('endPointString: '+endPointString);
                request.setEndpoint(endPointString);
                request.setMethod('GET');
                request.setHeader('Content-Type', 'application/json');
                HttpResponse response = h.send(request);
                return (GoogleAddressResponse)System.JSON.deserialize(response.getBody(), GoogleAddressResponse.class);
            } else {
                return null;
            }
        } else {
            return null;
        }
    }

/*Code for Communities object - End*/

    
    
/**/
    public static GoogleAddressResponse getAddress(Project__c theProject) {
        if (null != theProject) {
            if (null != GoogleIntegrationHelperSetting__c.getInstance('AddressEndpoint') && null != GoogleIntegrationHelperSetting__c.getInstance('AddressApiKey')) {
                Http h = new Http();
                HttpRequest request = new HttpRequest();
              //  String endPointString = GoogleIntegrationHelperSetting__c.getInstance('AddressEndpoint').Value__c+'?key='+GoogleIntegrationHelperSetting__c.getInstance('AddressApiKey').Value__c+'&latlng='+theProject.Location__latitude__s+','+theProject.Location__longitude__s;
              //  String endPointString = BuildSignedUrl(GoogleIntegrationHelperSetting__c.getInstance('AddressEndpoint').Value__c+'?latlng='+theProject.Location__latitude__s+','+theProject.Location__longitude__s+'&client='+GoogleIntegrationHelperSetting__c.getInstance('ClientId').Value__c);
                String endPointString = GoogleIntegrationHelperSetting__c.getInstance('AddressEndpoint').Value__c+'?latlng='+theProject.Location__latitude__s+','+theProject.Location__longitude__s+'&key='+GoogleIntegrationHelperSetting__c.getInstance('AddressApiKey').Value__c;
                system.debug('endPointString: '+endPointString);
                request.setEndpoint(endPointString);
                request.setMethod('GET');
                request.setHeader('Content-Type', 'application/json');
                HttpResponse response = h.send(request);
                return (GoogleAddressResponse)System.JSON.deserialize(response.getBody(), GoogleAddressResponse.class);
            } else {
                return null;
            }
        } else {
            return null;
        }
    }


    /**
    // Google Url Shortener Response Model:
    */
    public class GoogleUrlResponse {
        public String kind {get; set;}
        public String id {get; set;}
        public String longUrl {get; set;}

    }

    /**
    // Google Address Response Model:
    */
    public class GoogleAddressResponse {
        public List<Result> results;
        public String status;
    }

    public class Result {
        public List<Address_component> address_components;
        public String formatted_address;
        public Geometry geometry;
        public Set<String> types;
    }
    
    public class Address_component {
        public String long_name;
        public String short_name;
        public Set<String> types;
    }

    public class Geometry_Z {
        public Viewport bounds;
        public Location location;
        public String location_type;
        public Viewport viewport;
    }

    public class Location {
        public Double lat;
        public Double lng;
    }

    public class Geometry {
        public Location location;
        public String location_type;
        public Viewport viewport;
    }

    public class Viewport {
        public Location northeast;
        public Location southwest;
    }

    public static String BuildSignedUrl(String urlToBeSigned) {
        if (null == GoogleIntegrationHelperSetting__c.getInstance('CryptoKey')) {
            return null;
        }

        String urlPartForSignature = urlToBeSigned.substringAfter('googleapis.com');
        system.debug('urlPartForSignature: '+urlPartForSignature);

        String privateKey = GoogleIntegrationHelperSetting__c.getInstance('CryptoKey').Value__c;
        privateKey = privateKey.replace('-', '+');
        privateKey = privateKey.replace('_', '/');
        
        Blob privateKeyBlob = EncodingUtil.base64Decode(privateKey);
        Blob urlBlob = Blob.valueOf(urlPartForSignature);
        Blob signatureBlob = Crypto.generateMac('HMacSHA1', urlBlob, privateKeyBlob);

        String signature =EncodingUtil.base64Encode(signatureBlob);
        signature = signature.replace('+', '-');
        signature = signature.replace('/', '_');

        return urlToBeSigned += '&signature=' + signature;
    }

}