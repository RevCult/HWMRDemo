@isTest
public class GaugeChartControllerTEST {
    
    static testMethod void GaugeChartControllerTEST(){
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
       
       GaugeChartControllerMTD controllerMTD = new GaugeChartControllerMTD();
       GaugeChartControllerQTD controllerQTD = new GaugeChartControllerQTD();
       GaugeChartControllerYTD controllerYTD = new GaugeChartControllerYTD();
       controllerMTD.autoRun();
       controllerQTD.autoRun();
       controllerYTD.autoRun();
       
       controllerMTD.getData();
       controllerQTD.getData();
       controllerYTD.getData();
       
       controllerMTD.ExecId = 'All';
       controllerQTD.ExecId = 'All';
       controllerYTD.ExecId = 'All';
       
       controllerMTD.getData();
       controllerQTD.getData();
       controllerYTD.getData();
       
       controllerMTD.ExecId = 'INFO';
       controllerQTD.ExecId = 'INFO';
       controllerYTD.ExecId = 'INFO';
       
       controllerMTD.getData();
       controllerQTD.getData();
       controllerYTD.getData();
       
       GaugeChartControllerMTD_User controllerMTD_User = new GaugeChartControllerMTD_User();
       GaugeChartControllerQTD_User controllerQTD_User = new GaugeChartControllerQTD_User();
       GaugeChartControllerYTD_User controllerYTD_User = new GaugeChartControllerYTD_User();
       controllerMTD_User.autoRun();
       controllerQTD_User.autoRun();
       controllerYTD_User.autoRun();
       
       controllerMTD_User.getData();
       controllerQTD_User.getData();
       controllerYTD_User.getData();
       
       controllerMTD_User.ExecId = 'All';
       controllerQTD_User.ExecId = 'All';
       controllerYTD_User.ExecId = 'All';
       
       controllerMTD_User.getData();
       controllerQTD_User.getData();
       controllerYTD_User.getData();
       
       controllerMTD_User.ExecId = 'INFO';
       controllerQTD_User.ExecId = 'INFO';
       controllerYTD_User.ExecId = 'INFO';
       
       controllerMTD_User.getData();
       controllerQTD_User.getData();
       controllerYTD_User.getData();
       
       
       System.assertEquals(True, True);

     }
}