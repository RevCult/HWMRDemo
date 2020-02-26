public class WorkFrontService {
    public static string login_Url = 'https://hanleywood.attask-ondemand.com/attask/api/login';
    public static string Project_Url = 'https://hanleywood.attask-ondemand.com/attask/api/v4.0/project';
    
    
    static string username = 'rainmakeradmin%2Bhwworkfront@rainmakercloud.com';
    static string password = 'rain2020';
    
    public static string login() {
        string sessionId ;
        string url = login_Url + '?username='+ username +'&password='+ password;
        string jsonstr = getCalloutResponseContents(url, 'GET');
        
        system.debug('#######'+jsonstr);
        WF_Loginresponse loginresponse = WF_Loginresponse.parse(jsonstr);
        
        sessionId = loginresponse.data.sessionID;
        
        system.debug('sessionId' + sessionId);
        return sessionId;
    }
    
    public static String updateProject(string projectId, DSM_Products__c prod) {
        //Product_ID__c, name,Product_Type__c, Product_Category__c, Product_Subcategory__c 
        
        try {
            //projectId = '56f006ec00ac4e12df7549307c334fc6';
            string sessionId = login();
            string url = Project_Url + '?id='+ projectId +'&sessionID='+ sessionId+'&method=PUT';
            
            url += '&DE:Product%20ID='+prod.Product_ID__c;
            String prodName = '';
            if(prod.Product_Name__c != null){
                prodName = prod.Product_Name__c;
            }
            else{
                prodName = prod.Name;
        
            }
            if(prodName != ''){
                url += '&name='+EncodingUtil.urlEncode(prodName,'UTF-8');
                url += '&DE:Product%20Name='+EncodingUtil.urlEncode(prodName,'UTF-8');
            }
            if(prod.Product_Category__c != null){
                url += '&DE:DSM%20Product%20Category='+EncodingUtil.urlEncode(prod.Product_Category__c,'UTF-8');
            }
            if(prod.Product_Subcategory__c != null){
                url += '&DE:DSM%20Product%20Sub%20Category='+EncodingUtil.urlEncode(prod.Product_Subcategory__c,'UTF-8');
            }
            if(prod.Product_Type__c != null){
                url += '&DE:DSM%20Product%20Type='+EncodingUtil.urlEncode(prod.Product_Type__c,'UTF-8');
            }
            url += '&categoryID=57054be50005e22dc7f6fcf7b2826fc8';
            string jsonstr = getCalloutResponseContents(url, 'GET');
            if(jsonstr.indexOf('{"error":') != -1){
                return jsonstr;    
            }
            if(prod.WF_Template_ID__c != null){
                    string urlTemp = Project_Url + '/'+ projectId +'/attachTemplate?sessionID='+ sessionId+'&method=PUT';
                    urlTemp  += '&templateID='+prod.WF_Template_ID__c;
                    string jsonstrTemp = getCalloutResponseContents(urlTemp, 'GET');
            }
            
            return '';
        }
        catch(Exception e) {
            
            return e.getMessage();
        }
    }
    
    public static Boolean updateProject(string projectId, string productId) {
        try {
            //projectId = '56f006ec00ac4e12df7549307c334fc6';
            string sessionId = login();
            string url = Project_Url + '?id='+ projectId +'&sessionID='+ sessionId+'&method=PUT'+'&DE:Product%20ID='+productId;
            //system.assert(false,url);
            //Builder Test Product Line Item (Project)
            string jsonstr = getCalloutResponseContents(url, 'GET');
            return true;
        }
        catch(Exception e) {
            return false;
        }
    }
    //PUT /attask/api/project?id=4c7...&name=New Project Name
    //sessionID

    /*
    
    {"data":{"userID":"56b4d0bc0024d04ea8d5101d1f50925a","sessionID":"460cc40c1fda4ef09734216cd5c9d583","versionInformation":{"currentAPI":"v5.0","buildNumber":"963b2bed623a06c6aa2e3f21f6f451e7c6acb980","apiVersions":{"v1.0":"\/attask\/api\/v1.0\/","v2.0":"\/attask\/api\/v2.0\/","v3.0":"\/attask\/api\/v3.0\/","v4.0":"\/attask\/api\/v4.0\/","v5.0":"\/attask\/api\/v5.0\/"},"lastUpdated":"2016\/06\/06 20:18:35","release":"R16","version":"4.0"},"locale":"en_US","timeZone":"US\/Mountain","timeZoneName":"Mountain Standard Time","iso3Country":"USA","iso3Language":"eng","currency":{"useNegativeSign":false,"fractionDigits":2,"symbol":"$","ID":"USD","groupingSeparator":",","decimalSeparator":"."}}}
    */
    
    // Pass in the endpoint to be used using the string url
    public static String getCalloutResponseContents(String url, string method) {
    
        // Instantiate a new http object
        Http h = new Http();
        
         // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.settimeout(60000);
        /*if (method == 'POST') {
            req.setHeader('Content-Type','multipart/form-data;');
            req.setHeader('Content-Length', url.length() +'');
        }*/
        req.setMethod(method);
        
        // Send the request, and return a response
        HttpResponse res = h.send(req);
        return res.getBody();
    }
}