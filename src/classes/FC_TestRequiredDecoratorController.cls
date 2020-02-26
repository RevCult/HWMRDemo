@isTest
private class FC_TestRequiredDecoratorController {

    @isTest
    private static void testGetMessageForComponent() {
        Test.startTest();
        FC_RequiredDecoratorController controller = new FC_RequiredDecoratorController();
        controller.forComponentId = 'test';
        Component.Apex.OutputPanel messagePanel = controller.getMessageForComponent();
        System.assertEquals(1, messagePanel.childComponents.size());
        Test.stopTest();
    }

}