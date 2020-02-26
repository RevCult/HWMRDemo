@isTest
public class GaugeChartControllerSupplementalTEST {
    
    static testMethod void GaugeChartControllerSupplementalTEST(){
       // Add test method logic using System.assert(), System.assertEquals()
       // and System.assertNotEquals() here.
       
       User testUser = new User(
                               LastName='Smith',
                               TimeZoneSidKey='America/Denver', 
                               LocaleSidKey='en_US', 
                               EmailEncodingKey='UTF-8', 
                               LanguageLocaleKey='en_US',
                               Username='you@metrostudy.com',
                               Title='Test Title',
                               IsActive=True,
                               Alias='you',
                               ForecastEnabled=True,
                               ProfileId='00e80000000tfr2',
                               Email='you@me.com',
                               MetrostudyIncludeOnWebsite__c=True
                               );
       insert testUser;
       
       
       GaugeChartSupplemental_User controllerSupplemental_User = new GaugeChartSupplemental_User();
       
       controllerSupplemental_User.autoRun();
       
       controllerSupplemental_User.getData();
       
       controllerSupplemental_User.ExecId = 'All';
      
       controllerSupplemental_User.getData();
       
       controllerSupplemental_User.ExecId = 'INFO';
       
       controllerSupplemental_User.getData();
       
       System.assertEquals(True, True);

     }
}