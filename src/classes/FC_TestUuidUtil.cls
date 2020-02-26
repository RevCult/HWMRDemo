@isTest
private class FC_TestUuidUtil {

    @isTest
    private static void testUuidV4() {
        Test.startTest();
        for (Integer i = 0; i < 10; i++) {
            String uuid = FC_UuidUtil.uuidV4();
            System.assertEquals(36, uuid.length());
            for (Integer j = 0; j < uuid.length(); j++) {
                if (j == 8 || j == 13 || j == 18 || j == 23) {
                    System.assertEquals('-', uuid.mid(j, 1));
                } else if (j == 14) {
                    System.assertEquals('4', uuid.mid(j, 1));
                } else if (j == 19) {
                    System.assert(uuid.mid(j, 1).containsOnly('89ab'));
                } else {
                    System.assert(uuid.mid(j, 1).containsOnly('0123456789abcdef'));
                }
            }
        }
        Test.stopTest();
    }

}