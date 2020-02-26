@isTest
public class ProjectRollUpHandlerTest {
    @testSetup static void setup() {
        
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
        
        Schema.DescribeSObjectResult R = Community__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
        
        Community__c mcomm = new Community__c();
        mcomm.RecordTypeId = RT[0].getRecordTypeId();
        mcomm.name = 'mTestCommu1';
        mcomm.Open_Date__c = system.today();
        insert mcomm;
        
        Project__c masp = new Project__c();
        masp.Name = 'mTestProject';
        masp.Builder__c = b.id;
        masp.Status__c = 'Active';
        masp.open_Date__c = system.today()-1;
        masp.Total_Units_Planned__c = 10;
        masp.Total_Units_Sold__c = 5;
        masp.Website__c = 'http://www.test.com/';
        masp.Location__Latitude__s = 40.731;
        masp.Location__Longitude__s = -73.997;
        masp.Master_Plan_Community__c = mcomm.id;
        insert masp;  
        
        Community__c ncomm = new Community__c();
        ncomm.RecordTypeId = RT[1].getRecordTypeId();
        ncomm.name = 'nTestCommu1';
        ncomm.Open_Date__c = system.today();
        insert ncomm;
        
        Project__c neigp = new Project__c();
        neigp.Name = 'nTestProject';
        neigp.Builder__c = b.id;
        neigp.Status__c = 'Active';
        neigp.open_Date__c = system.today()-1;
        neigp.Total_Units_Planned__c = 10;
        neigp.Total_Units_Sold__c = 5;
        neigp.Website__c = 'http://www.test.com/';
        neigp.Location__Latitude__s = 40.731;
        neigp.Location__Longitude__s = -73.997;
        neigp.Neighborhood_Community__c = ncomm.id;
        insert neigp;
        
        Community__c vcomm = new Community__c();
        vcomm.RecordTypeId = RT[2].getRecordTypeId();
        vcomm.name = 'vTestCommu1';
        vcomm.Open_Date__c = system.today();
        insert vcomm;
        
        Project__c villp = new Project__c();
        villp.Name = 'vTestProject';
        villp.Builder__c = b.id;
        villp.Status__c = 'Active';
        villp.open_Date__c = system.today()-1;
        villp.Total_Units_Planned__c = 10;
        villp.Total_Units_Sold__c = 5;
        villp.Website__c = 'http://www.test.com/';
        villp.Location__Latitude__s = 40.731;
        villp.Location__Longitude__s = -73.997;
        villp.Village_Community__c = vcomm.id;
        insert villp;
        
        Project__c mvillp = new Project__c();
        mvillp.Name = 'mvTestProject';
        mvillp.Builder__c = b.id;
        mvillp.Status__c = 'Active';
        mvillp.open_Date__c = system.today()-1;
        mvillp.Total_Units_Planned__c = 10;
        mvillp.Total_Units_Sold__c = 5;
        mvillp.Website__c = 'http://www.test.com/';
        mvillp.Location__Latitude__s = 40.731;
        mvillp.Location__Longitude__s = -73.997;
        mvillp.Village_Community__c = vcomm.id;
        mvillp.Master_Plan_Community__c = mcomm.id;
        insert mvillp ;
    }
    
    // Testing Project Inserting Scenarios
    Public static testmethod void updateCommunityFieldsonInsertTest_MasterPlan(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
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
        
        Schema.DescribeSObjectResult R = Community__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
        
        Community__c comm = new Community__c();
        comm.RecordTypeId = RT[0].getRecordTypeId();
        comm.name = 'TestCommu1';
        comm.Open_Date__c = NULL; //system.today();
        insert comm;
        test.stopTest();
        Project__c p = new Project__c();
        p.Name = 'TestProject';
        P.Builder__c = b.id;
        p.Status__c = 'Active';
        p.open_Date__c = system.today()-1;
        p.Total_Units_Planned__c = 10;
        p.Total_Units_Sold__c = 5;
        p.Website__c = 'http://www.test.com/';
        p.Location__Latitude__s = 40.731;
        p.Location__Longitude__s = -73.997;
        p.Master_Plan_Community__c = comm.id;
        insert p;
        
        
    }
    
    
     Public static testmethod void updateCommunityFieldsonInsertTest_Neighborhood(){
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
        
        Schema.DescribeSObjectResult R = Community__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
        
        Community__c comm = new Community__c();
        comm.RecordTypeId = RT[1].getRecordTypeId();
        comm.name = 'TestCommu1';
        comm.Open_Date__c = system.today();
        insert comm;
        test.stopTest();
        Project__c p = new Project__c();
        p.Name = 'TestProject';
        P.Builder__c = b.id;
        p.Status__c = 'Active';
        p.open_Date__c = system.today()-1;
        p.Total_Units_Planned__c = 10;
        p.Total_Units_Sold__c = 5;
        p.Website__c = 'http://www.test.com/';
        p.Location__Latitude__s = 40.731;
        p.Location__Longitude__s = -73.997;
        p.Neighborhood_Community__c = comm.id;
        insert p;
        
        
    }
    Public static testmethod void updateCommunityFieldsonInsertTest_Village(){
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
        
        Schema.DescribeSObjectResult R = Community__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
        
        Community__c comm = new Community__c();
        comm.RecordTypeId = RT[2].getRecordTypeId();
        comm.name = 'TestCommu1';
        comm.Open_Date__c = system.today();
        insert comm;
        test.stopTest();
        Project__c p = new Project__c();
        p.Name = 'TestProject';
        P.Builder__c = b.id;
        p.Status__c = 'Active';
        p.open_Date__c = system.today()-1;
        p.Total_Units_Planned__c = 10;
        p.Total_Units_Sold__c = 5;
        p.Website__c = 'http://www.test.com/';
        p.Location__Latitude__s = 40.731;
        p.Location__Longitude__s = -73.997;
        p.Village_Community__c = comm.id;
        insert p;
        
        
    } 
    Public static testmethod void updateCommunityFieldsonInsertTest_MasterPlan1(){
        ProjectRollUpHandler.updateOnInsert(new List<Project__c>(),new Set<Id>(),'master');
    }
    Public static testmethod void updateCommunityFieldsonInsertTest_MasterPlan2(){
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
        
        Schema.DescribeSObjectResult R = Community__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
        
        Community__c comm = new Community__c();
        comm.RecordTypeId = RT[0].getRecordTypeId();
        comm.name = 'TestCommu1';
        insert comm;
        test.stopTest();
        Project__c p = new Project__c();
        p.Name = 'TestProject';
        P.Builder__c = b.id;
        p.Status__c = 'Active';
        p.open_Date__c = system.today()-1;
        p.Total_Units_Planned__c = 10;
        p.Total_Units_Sold__c = 5;
        p.Website__c = 'http://www.test.com/';
        p.Location__Latitude__s = 40.731;
        p.Location__Longitude__s = -73.997;
        p.Master_Plan_Community__c = comm.id;
        insert p;
        
        
    }
    Public static testmethod void updateCommunityFieldsonInsertTest_Neighborhood1(){
        ProjectRollUpHandler.updateOnInsert(new List<Project__c>(),new Set<Id>(),'neighbor');
    }
    Public static testmethod void updateCommunityFieldsonInsertTest_Neighborhood2(){
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
        
        Schema.DescribeSObjectResult R = Community__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
        
        Community__c comm = new Community__c();
        comm.RecordTypeId = RT[1].getRecordTypeId();
        comm.name = 'TestCommu1';
        insert comm;
        test.stopTest();
        Project__c p = new Project__c();
        p.Name = 'TestProject';
        P.Builder__c = b.id;
        p.Status__c = 'Active';
        p.open_Date__c = system.today()-1;
        p.Total_Units_Planned__c = 10;
        p.Total_Units_Sold__c = 5;
        p.Website__c = 'http://www.test.com/';
        p.Location__Latitude__s = 40.731;
        p.Location__Longitude__s = -73.997;
        p.Neighborhood_Community__c = comm.id;
        insert p;
        
        
    }
    Public static testmethod void updateCommunityFieldsonInsertTest_village1(){
        ProjectRollUpHandler.updateOnInsert(new List<Project__c>(),new Set<Id>(),'village');
    }
        Public static testmethod void updateCommunityFieldsonInsertTest_Village2(){
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
        
        Schema.DescribeSObjectResult R = Community__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
        
        Community__c comm = new Community__c();
        comm.RecordTypeId = RT[2].getRecordTypeId();
        comm.name = 'TestCommu1';
        insert comm;
        test.stopTest();
        Project__c p = new Project__c();
        p.Name = 'TestProject';
        P.Builder__c = b.id;
        p.Status__c = 'Active';
        p.open_Date__c = system.today()-1;
        p.Total_Units_Planned__c = 10;
        p.Total_Units_Sold__c = 5;
        p.Website__c = 'http://www.test.com/';
        p.Location__Latitude__s = 40.731;
        p.Location__Longitude__s = -73.997;
        p.Village_Community__c = comm.id;
        insert p;
        
        
    }
    
    // Testing Project Updating Scenarios
    Public static testmethod void updateCommunityFieldsonUpdateTest_MasterPlan1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Community__c comm = [select id,Open_date__c,Project_TUP_calc__c,Project_TUS_calc__c from Community__c where name='mTestCommu1'];
        comm.Open_date__c = null; //system.today(); 
        comm.Project_TUP_calc__c = null;
        comm.Project_TUS_calc__c  = null;
        update comm;
        project__c pr = [select id,Master_Plan_Community__c,Open_date__c from Project__c where name = 'mTestProject'];
        pr.Open_Date__c = system.today()-1;
        pr.Master_Plan_Community__c = comm.id;
        Update pr;
        comm.Open_date__c = null;
                
        Project__c masp = new Project__c();
        masp.Name = 'mTestProject2';
        masp.Status__c = 'Active';
        masp.open_Date__c = system.today()-1;
        masp.Total_Units_Planned__c = 10;
        masp.Total_Units_Sold__c = 5;
        masp.Website__c = 'http://www.test.com/';
        masp.Location__Latitude__s = 40.731;
        masp.Location__Longitude__s = -73.997;
        masp.Master_Plan_Community__c = comm.id;
        insert masp; 
        masp.open_Date__c = system.today()-2;
        update masp;
        update comm;
        Update pr;
    }
     Public static testmethod void updateCommunityFieldsonUpdateTest_Village1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Community__c comm = [select id,Open_date__c,Project_TUP_calc__c,Project_TUS_calc__c from Community__c where name='vTestCommu1'];
        comm.Open_date__c = system.today();
        comm.Project_TUP_calc__c = null;
        comm.Project_TUS_calc__c  = null;
        update comm;
        project__c pr = [select id,Village_Community__c,Open_date__c from Project__c where name = 'vTestProject'];
        pr.Open_Date__c = system.today()-1;
        pr.Village_Community__c = comm.id;
        Update pr;
        comm.Open_date__c = null;
        
        Project__c villp = new Project__c();
        villp.Name = 'vTestProject2';
        villp.Status__c = 'Active';
        villp.open_Date__c = system.today()-1;
        villp.Total_Units_Planned__c = 10;
        villp.Total_Units_Sold__c = 5;
        villp.Website__c = 'http://www.test.com/';
        villp.Location__Latitude__s = 40.731;
        villp.Location__Longitude__s = -73.997;
        villp.Village_Community__c = comm.id;
        insert villp; 
        villp.open_Date__c = system.today()-2;
        update villp;
        update comm;
        Update pr;
    }
         Public static testmethod void updateCommunityFieldsonUpdateTest_Neigh1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Community__c comm = [select id,Open_date__c,Project_TUP_calc__c,Project_TUS_calc__c from Community__c where name='nTestCommu1'];
        comm.Open_date__c = system.today();
        comm.Project_TUP_calc__c = null;
        comm.Project_TUS_calc__c  = null;
        update comm;
        project__c pr = [select id,Neighborhood_Community__c,Open_date__c from Project__c where name = 'nTestProject'];
        pr.Open_Date__c = system.today()-1;
        pr.Neighborhood_Community__c = comm.id;
        Update pr;
        comm.Open_date__c = null;
        
        Project__c neigp = new Project__c();
        neigp.Name = 'vTestProject2';
        neigp.Status__c = 'Active';
        neigp.open_Date__c = system.today()-1;
        neigp.Total_Units_Planned__c = 10;
        neigp.Total_Units_Sold__c = 5;
        neigp.Website__c = 'http://www.test.com/';
        neigp.Location__Latitude__s = 40.731;
        neigp.Location__Longitude__s = -73.997;
        neigp.Neighborhood_Community__c = comm.id;
        insert neigp; 
        neigp.open_Date__c = system.today()-2;
        update neigp;
        update comm;
        Update pr;
    }
    
    Public static testmethod void updateCommunityFieldsonUpdateTest_MasterPlan(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        project__c pr = [select id,Master_Plan_Community__c from Project__c where name = 'mTestProject'];
        pr.Master_Plan_Community__c = null;
        Update pr;
    }
    Public static testmethod void updateCommunityFieldsonUpdateTest_Neighborhood(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        project__c pr = [select id,Neighborhood_Community__c from Project__c where name = 'nTestProject'];
        pr.Neighborhood_Community__c = null;
        update pr;
    }
    Public static testmethod void updateCommunityFieldsonUpdateTest_Village(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        project__c pr = [select id,Village_Community__c from Project__c where name='vTestProject'];
        pr.Village_Community__c = null;
        update pr; 
    }
    Public static testmethod void updateCommunityFieldsonUpdateTest_masvill1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        project__c pr = [select id,Village_Community__c,Master_Plan_Community__c from Project__c where name='vTestProject'];
        Community__c comm = [select id from Community__c where name='mTestCommu1'];
        pr.Master_Plan_Community__c = comm.id;
        update pr; 
    }
    Public static testmethod void updateCommunityFieldsonUpdateTest_masvill2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        community__c comm = [Select Id,Open_Date__c,Project_TUP_calc__c,Project_TUS_calc__c from community__c where Name='mTestCommu1'];
        comm.Open_Date__c = null;
        project__c pr = [select id,Village_Community__c,Master_Plan_Community__c,Total_Units_Sold__c,Total_Units_Planned__c from Project__c where name='vTestProject'];
        pr.Master_Plan_Community__c = comm.id;
        pr.Open_Date__c = system.today()-3;
        pr.Total_Units_Sold__c = 11;
        pr.Total_Units_Planned__c = 12;
        update comm;
        update pr;         
        Project__c masp = new Project__c();
        masp.Name = 'vTestProject2';
        masp.Status__c = 'Active';
        masp.open_Date__c = system.today()-1;
        masp.Total_Units_Planned__c = 10;
        masp.Total_Units_Sold__c = 5;
        masp.Website__c = 'http://www.test.com/';
        masp.Location__Latitude__s = 40.731;
        masp.Location__Longitude__s = -73.997;
        masp.Master_Plan_Community__c = comm.id;
        insert masp; 
        masp.open_Date__c = system.today()-2;
        update masp;
        comm.Open_Date__c = system.today();
        update comm;
        ProjectRollUpHandler.updateOnUpdate(new List<Project__c>{pr},new Set<Id>{comm.id},'masvillage2');
        ProjectRollUpHandler.updateOnUpdate(new List<Project__c>{pr},new Set<Id>{comm.id},'masvillage1');
    }
    
    //Delete Test
    Public static testmethod void updateCommunityFieldsonDeleteTest_MasterPlan1(){
        ProjectRollUpHandler.updateOnDelete(new List<Project__c>{null},new Set<Id>{null},'master');
    }
    Public static testmethod void updateCommunityFieldsonDeleteTest_neigh1(){
        ProjectRollUpHandler.updateOnDelete(new List<Project__c>{null},new Set<Id>{null},'neighbor');
    }
    Public static testmethod void updateCommunityFieldsonDeleteTest_village1(){
        ProjectRollUpHandler.updateOnDelete(new List<Project__c>{null},new Set<Id>{null},'village');
    }
    Public static testmethod void updateCommunityFieldsonDeleteTest_Mvill1(){
        ProjectRollUpHandler.updateOnDelete(new List<Project__c>{null},new Set<Id>{null},'masvillage2');
    }
    Public static testmethod void updateCommunityFieldsonDeleteTest_Mvill2(){
        ProjectRollUpHandler.updateOnDelete(new List<Project__c>{null},new Set<Id>{null},'masvillage1');
    }
    
    Public static testmethod void updateCommunityFieldsonDeleteTest_MasterPlan(){
        project__c pr = [select id,Master_Plan_Community__c from Project__c where name = 'mTestProject'];
        Delete pr;
    }
     Public static testmethod void updateCommunityFieldsonDeleteTest_Neighborhood(){
        project__c pr = [select id,Neighborhood_Community__c from Project__c where name = 'nTestProject'];
        Delete pr;
    }
    Public static testmethod void updateCommunityFieldsonDeleteTest_Village(){
        project__c pr = [select id,Village_Community__c from Project__c where name='vTestProject'];
        Delete pr; 
    }
    Public static testmethod void updateCommunityFieldsonDeleteTest_mVillage(){
        project__c pr = [select id,Village_Community__c from Project__c where name='mvTestProject'];
        Delete pr; 
    }
    
}