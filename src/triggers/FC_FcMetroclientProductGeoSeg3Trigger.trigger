trigger FC_FcMetroclientProductGeoSeg3Trigger on FC_Metroclient_Product_Geography_Seg3__c (before insert, before update) {
    fcf.TriggerFactory.createHandler('FC_FcMetroclientProductGeoSeg3Handler');
}