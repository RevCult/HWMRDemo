@isTest 
public class CommunityProjectsMapExtnTest {
    static testMethod void testMethod1() 
    {
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
        
        Schema.DescribeSObjectResult R = Community__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
        
        Community__c mcomm = new Community__c();
        mcomm.RecordTypeId = RT[0].getRecordTypeId();
        mcomm.name = 'TestCommu1';
        mcomm.Open_Date__c = system.today();
        insert mcomm;
        Community__c ncomm = new Community__c();
        ncomm.RecordTypeId = RT[1].getRecordTypeId();
        ncomm.name = 'TestCommu1';
        ncomm.Open_Date__c = system.today();
        insert ncomm;
        Community__c vcomm = new Community__c();
        vcomm.RecordTypeId = RT[2].getRecordTypeId();
        vcomm.name = 'TestCommu1';
        vcomm.Open_Date__c = system.today();
        insert vcomm;
        
        Project__c p = new Project__c();
        p.Name = 'TestProject';
        p.Status__c = 'Active';
        p.open_Date__c = system.today()-1;
        p.Total_Units_Planned__c = 10;
        p.Total_Units_Sold__c = 5;
        p.Website__c = 'http://www.test.com/';
        p.Location__Latitude__s = 40.731;
        p.Location__Longitude__s = -73.997;
        p.Village_Community__c = vcomm.id;
        insert p;
        
        Project__c p2 = new Project__c();
        p2.Name = 'TestProject';
        p2.Status__c = 'Active';
        p2.open_Date__c = system.today()-1;
        p2.Total_Units_Planned__c = 10;
        p2.Total_Units_Sold__c = 5;
        p2.Website__c = 'http://www.test.com/';
        p2.Location__Latitude__s = 40.731;
        p2.Location__Longitude__s = -73.997;
        p2.Neighborhood_Community__c = ncomm.id;
        insert p2;
        
        Project__c p3 = new Project__c();
        p3.Name = 'TestProject2';
        p3.Status__c = 'Active';
        p3.open_Date__c = system.today()-1;
        p3.Total_Units_Planned__c = 10;
        p3.Total_Units_Sold__c = 5;
        p3.Website__c = 'http://www.test.com/';
        p3.Location__Latitude__s = 40.731;
        p3.Location__Longitude__s = -73.997;
        p3.Master_Plan_Community__c = mcomm.id;
        insert p3;
        
        PageReference pageRef = Page.CommunityProjectsMap;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(mcomm.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(mcomm);
        CommunityProjectsMapExtn testCommuCtl = new CommunityProjectsMapExtn(sc);
        
        pageRef.getParameters().put('Id', String.valueOf(vcomm.Id));
        ApexPages.StandardController sc2 = new ApexPages.StandardController(vcomm);
        CommunityProjectsMapExtn testCommuCt2 = new CommunityProjectsMapExtn(sc);
        
        pageRef.getParameters().put('Id', String.valueOf(ncomm.Id));
        ApexPages.StandardController sc3 = new ApexPages.StandardController(ncomm);
        CommunityProjectsMapExtn testCommuCt3 = new CommunityProjectsMapExtn(sc);
    }
}