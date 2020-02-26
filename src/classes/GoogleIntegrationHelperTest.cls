@isTest
public class GoogleIntegrationHelperTest {
    
    //Project Tests
    public static testmethod void UpdateProjectFieldsFromGoogleTestnegative1(){
        test.startTest();
        Project__c prj = new Project__c();
        GoogleIntegrationHelper.getAddress(prj);
        GoogleIntegrationHelper.getShortURLforProject(prj);
        test.stopTest();
    }
    public static testmethod void projectTestNegative(){
        test.startTest();
        Project__c prj = new Project__c();
        Builder__c b = new  Builder__c(); 
        b.Name = 'TestBuilder';
        b.Builder_Website__c = 'http://www.test.com/';
        b.State__c = 'CA';
        b.Builder_Logo_URL__c ='https://kennedywilson.box.com/shared/static/d2dvbd8nz72wt7e44jxpuv9qcas0odhy.jpg';    
        insert b;
        Project__c p = new Project__c();
        p.Name = 'TestProject';
        P.Builder__c = b.id;
        p.Status__c = 'Active';
        p.Website__c = 'http://www.test.com/';
        insert p;
        
        test.stopTest();
    }
    public static testmethod void UpdateProjectFieldsFromGoogleTest(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        GoogleIntegrationHelperSetting__c AddressEndpoint = new GoogleIntegrationHelperSetting__c(Name='AddressEndpoint', Value__c = 'https://maps.googleapis.com/maps/api/geocode/json');
        insert AddressEndpoint;
        GoogleIntegrationHelperSetting__c AddressApiKey = new GoogleIntegrationHelperSetting__c(Name='AddressApiKey', Value__c = 'AIzaSyAMCeNu4PTVrFpBNqNRzl7-s6YnXI_vPpM');
        insert AddressApiKey;  
        GoogleIntegrationHelperSetting__c ClientId = new GoogleIntegrationHelperSetting__c(Name='ClientId', Value__c = 'gme-meyersresearch');
        insert ClientId;        
        GoogleIntegrationHelperSetting__c CryptoKey = new GoogleIntegrationHelperSetting__c(Name='CryptoKey', Value__c = 'PAIt9ZFY6hUf6t33fsilLI2TGRM=');
        insert CryptoKey;  
        GoogleIntegrationHelperSetting__c UrlEndpoint = new GoogleIntegrationHelperSetting__c(Name='UrlEndpoint', Value__c = 'https://www.googleapis.com/urlshortener/v1/url');
        insert UrlEndpoint; 
        
        Builder__c b = new  Builder__c(); 
        b.Name = 'TestBuilder';
        b.Builder_Website__c = 'http://www.test.com/';
        b.State__c = 'CA';
        b.Builder_Logo_URL__c ='https://kennedywilson.box.com/shared/static/d2dvbd8nz72wt7e44jxpuv9qcas0odhy.jpg';    
        insert b;
        Project__c p = new Project__c();
        p.Name = 'TestProject';
        P.Builder__c = b.id;
        p.Status__c = 'Active';
        p.Website__c = 'http://www.test.com/';
        p.Location__Latitude__s = 40.731;
        p.Location__Longitude__s = -73.997;
        insert p;
        
        test.stopTest();
    }
    
    //Land Listing tests   
    public static testmethod void UpdateLandListingFieldsFromGoogleAsyncTest(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        GoogleIntegrationHelperSetting__c AddressEndpoint = new GoogleIntegrationHelperSetting__c(Name='AddressEndpoint', Value__c = 'https://maps.googleapis.com/maps/api/geocode/json');
        insert AddressEndpoint;
        GoogleIntegrationHelperSetting__c AddressApiKey = new GoogleIntegrationHelperSetting__c(Name='AddressApiKey', Value__c = 'AIzaSyAMCeNu4PTVrFpBNqNRzl7-s6YnXI_vPpM');
        insert AddressApiKey;  
        GoogleIntegrationHelperSetting__c ClientId = new GoogleIntegrationHelperSetting__c(Name='ClientId', Value__c = 'gme-meyersresearch');
        insert ClientId;        
        GoogleIntegrationHelperSetting__c CryptoKey = new GoogleIntegrationHelperSetting__c(Name='CryptoKey', Value__c = 'PAIt9ZFY6hUf6t33fsilLI2TGRM=');
        insert CryptoKey;  
        GoogleIntegrationHelperSetting__c UrlEndpoint = new GoogleIntegrationHelperSetting__c(Name='UrlEndpoint', Value__c = 'https://www.googleapis.com/urlshortener/v1/url');
        insert UrlEndpoint; 
        
        Land_Listing__c listing1 = new Land_Listing__c(
            Name = 'the listing'
            ,   County__c = 'San Diego'
            ,   Location__Latitude__s = 33
            ,   Location__Longitude__s = -78
            ,   State__c = 'CA'
            ,   Zip__c = '92129'
            ,   Listing_URL__c = 'http://www.google.com'
        );
        insert listing1;
        
        
        GoogleIntegrationHelper.UpdateLandListingFieldsFromGoogleAsync(listing1.id);
        
        test.stopTest(); 
    }
    public static testmethod void getShortURLforLandListingtest1(){
        test.startTest();
        Land_Listing__c listing1 = new Land_Listing__c();
        GoogleIntegrationHelper.getShortURLforLandListing(listing1);
        test.stopTest();
    }
    public static testmethod void getShortURLforLandListingtest2(){
        test.startTest();

        Land_Listing__c listing1 = new Land_Listing__c(
            Name = 'the listing'
            ,   County__c = 'San Diego'
            ,   Location__Latitude__s = 33
            ,   Location__Longitude__s = -78
            ,   State__c = 'CA'
            ,   Zip__c = '92129'
            ,   Listing_URL__c = 'http://www.google.com'
        );
        insert listing1;
        GoogleIntegrationHelper.getShortURLforLandListing(listing1);
        
        test.stopTest();
    }
    
    //Community Tests
    public static testmethod void UpdateCommunityFieldsFromGoogleAsyncTest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
         GoogleIntegrationHelperSetting__c AddressEndpoint = new GoogleIntegrationHelperSetting__c(Name='AddressEndpoint', Value__c = 'https://maps.googleapis.com/maps/api/geocode/json');
        insert AddressEndpoint;
        GoogleIntegrationHelperSetting__c AddressApiKey = new GoogleIntegrationHelperSetting__c(Name='AddressApiKey', Value__c = 'AIzaSyAMCeNu4PTVrFpBNqNRzl7-s6YnXI_vPpM');
        insert AddressApiKey;  
        GoogleIntegrationHelperSetting__c ClientId = new GoogleIntegrationHelperSetting__c(Name='ClientId', Value__c = 'gme-meyersresearch');
        insert ClientId;        
        GoogleIntegrationHelperSetting__c CryptoKey = new GoogleIntegrationHelperSetting__c(Name='CryptoKey', Value__c = 'PAIt9ZFY6hUf6t33fsilLI2TGRM=');
        insert CryptoKey;  
        GoogleIntegrationHelperSetting__c UrlEndpoint = new GoogleIntegrationHelperSetting__c(Name='UrlEndpoint', Value__c = 'https://www.googleapis.com/urlshortener/v1/url');
        insert UrlEndpoint; 
        Community__c comm = new Community__c();
        comm.RecordTypeId = [select id from Recordtype where DeveloperName='Master_Plan'].id;
        comm.name = 'TestCommu';
        comm.Location__Latitude__s = 40.731;
        comm.Location__Longitude__s = -73.997;
        insert comm;
        
    }
    public static testmethod void getAddresscommunityNeg(){
        GoogleIntegrationHelper.getAddresscommunity(null);
    }
     public static testmethod void UpdateCommunityFieldsFromGoogleAsyncTest1(){
        Community__c comm = new Community__c();
        comm.RecordTypeId = [select id from Recordtype where DeveloperName='Master_Plan'].id;
        comm.name = 'TestCommu';
        insert comm;        
    }

    //Account Tests
	public static testmethod void getAddressDetailsforAccountTest1(){
        test.startTest();
        Account acc = new Account();
		acc.BillingPostalCode  = '33802';
		acc.name= 'test account';
		insert acc;
        GoogleIntegrationHelper.UpdateAccountFieldsFromGoogleAsync(acc.Id);
        test.stopTest();
    }
    public static testmethod void UpdateAccountFieldsFromGoogleAsyncTest(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        GoogleIntegrationHelperSetting__c AddressEndpoint = new GoogleIntegrationHelperSetting__c(Name='AddressEndpoint', Value__c = 'https://maps.googleapis.com/maps/api/geocode/json');
        insert AddressEndpoint;
        GoogleIntegrationHelperSetting__c AddressApiKey = new GoogleIntegrationHelperSetting__c(Name='AddressApiKey', Value__c = 'AIzaSyAMCeNu4PTVrFpBNqNRzl7-s6YnXI_vPpM');
        insert AddressApiKey;  
        GoogleIntegrationHelperSetting__c ClientId = new GoogleIntegrationHelperSetting__c(Name='ClientId', Value__c = 'gme-meyersresearch');
        insert ClientId;        
        GoogleIntegrationHelperSetting__c CryptoKey = new GoogleIntegrationHelperSetting__c(Name='CryptoKey', Value__c = 'PAIt9ZFY6hUf6t33fsilLI2TGRM=');
        insert CryptoKey;  
        GoogleIntegrationHelperSetting__c UrlEndpoint = new GoogleIntegrationHelperSetting__c(Name='UrlEndpoint', Value__c = 'https://www.googleapis.com/urlshortener/v1/url');
        insert UrlEndpoint; 
        
        Account ac = new Account(
            Name = 'the listing'
            ,   BillingPostalCode = '33802'
            );
        insert ac;
        
        
        GoogleIntegrationHelper.UpdateAccountFieldsFromGoogleAsync(ac.id);
        
        test.stopTest(); 
    }
    public static testmethod void getAddressDetailsforAccountTestDC(){
        test.startTest();
        Account acc = new Account();
		acc.BillingPostalCode  = '20003'; // District Of Columbia zipcode
		acc.name= 'test account DC';
		insert acc;
        GoogleIntegrationHelper.UpdateAccountFieldsFromGoogleAsync(acc.Id);
        test.stopTest();
    }
    
    //Contact Tests
    public static testmethod void UpdateContactFieldsFromGoogleAsyncTest(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        GoogleIntegrationHelperSetting__c AddressEndpoint = new GoogleIntegrationHelperSetting__c(Name='AddressEndpoint', Value__c = 'https://maps.googleapis.com/maps/api/geocode/json');
        insert AddressEndpoint;
        GoogleIntegrationHelperSetting__c AddressApiKey = new GoogleIntegrationHelperSetting__c(Name='AddressApiKey', Value__c = 'AIzaSyAMCeNu4PTVrFpBNqNRzl7-s6YnXI_vPpM');
        insert AddressApiKey;  
        GoogleIntegrationHelperSetting__c ClientId = new GoogleIntegrationHelperSetting__c(Name='ClientId', Value__c = 'gme-meyersresearch');
        insert ClientId;        
        GoogleIntegrationHelperSetting__c CryptoKey = new GoogleIntegrationHelperSetting__c(Name='CryptoKey', Value__c = 'PAIt9ZFY6hUf6t33fsilLI2TGRM=');
        insert CryptoKey;  
        GoogleIntegrationHelperSetting__c UrlEndpoint = new GoogleIntegrationHelperSetting__c(Name='UrlEndpoint', Value__c = 'https://www.googleapis.com/urlshortener/v1/url');
        insert UrlEndpoint; 
        
        Contact con = new Contact(
		lastName = 'google',
            mailingPostalCode = '92131'
            );
        insert con;
        
        
        GoogleIntegrationHelper.UpdateContactFieldsFromGoogleAsync(con.id);
        
        test.stopTest(); 
    }
        
}