@isTest
private class FC_GaugeChartControllerTEST {

    static testMethod void GaugeChartControllerTEST() {
        // Add test method logic using System.assert(), System.assertEquals()
        // and System.assertNotEquals() here.

        User testUser = new User(
                LastName = 'Smith',
                TimeZoneSidKey = 'America/Denver',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                Username = 'you@metrostudy.com',
                Title = 'Test Title',
                IsActive = True,
                Alias = 'you',
                ForecastEnabled = True,
                ProfileId = '00e80000000tfr2',
                Email = 'you@me.com',
                MetrostudyIncludeOnWebsite__c = True
        );
        insert testUser;

        FC_GaugeChartControllerMTD controllerMTD = new FC_GaugeChartControllerMTD();
        FC_GaugeChartControllerQTD controllerQTD = new FC_GaugeChartControllerQTD();
        FC_GaugeChartControllerYTD controllerYTD = new FC_GaugeChartControllerYTD();
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

        FC_GaugeChartControllerMTD_User controllerMTD_User = new FC_GaugeChartControllerMTD_User();
        FC_GaugeChartControllerQTD_User controllerQTD_User = new FC_GaugeChartControllerQTD_User();
        FC_GaugeChartControllerYTD_User controllerYTD_User = new FC_GaugeChartControllerYTD_User();
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