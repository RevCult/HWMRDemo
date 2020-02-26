@isTest
private class TestProjectNearbyProjectsMapExt{

static testMethod void myUnitTestFoo() {
 
/*Project__c prj = [select Id, Name, Location__Longitude__s, Location__Latitude__s, ' +
                'Status__c, Phone_Number__c, City__c ' +
            'FROM Project__c ' +
            'WHERE DISTANCE(Location__c, GEOLOCATION('+lat+','+lon+'), \'mi\') < 20 ' +
            'ORDER BY DISTANCE(Location__c, GEOLOCATION('+lat+','+lon+'), \'mi\') ' +
            'LIMIT 25']; */
            Builder__c buil = new  Builder__c();
            
            buil.Name = 'CalAtlantic Homes';
            buil.Builder_Website__c = 'http://www.calatlantichomes.com/';
            buil.State__c = 'CA';
            buil.Builder_Logo_URL__c ='https://kennedywilson.box.com/shared/static/d2dvbd8nz72wt7e44jxpuv9qcas0odhy.jpg';
            
            insert buil;
            
            Project__c proj = new Project__c();
            proj.Name = 'Crawford';
            Proj.Builder__c = buil.id;
            proj.Status__c = 'Active';
            proj.Total_Units_Sold__c = 100;
            proj.Sales_Verified__c = true;
            proj.Location__Longitude__s =-104.893061;
            proj.Location__Latitude__s=39.78701;
           // proj.Location__c=Location.newInstance(28.635308,77.22496);
           proj.Override_Location_Information__c=true;
            insert proj;
        
          ApexPages.StandardController sc = new ApexPages.StandardController(proj);
    ProjectNearbyProjectsMapExt ctr = new ProjectNearbyProjectsMapExt (sc);
      
     PageReference pageRef = Page.ProjectNearbyProjectsMap;
     pageRef.getParameters().put('Id', String.valueOf(proj.Id));
     ctr.getFoo();
  
    ctr.getNearbyProjects();
           
            
            }
      }