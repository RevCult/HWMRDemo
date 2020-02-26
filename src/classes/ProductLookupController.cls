public class ProductLookupController extends zqu.LookupComponentController{

  //these are the options that get passed to the LookupComponent
  public zqu.LookupComponentOptions optionsForProductLookup { get;set; } 

  public ProductLookupController() {
    optionsForProductLookup = makeProductOptions();
  }

  private zqu.LookupComponentOptions makeProductOptions() {
      optionsForProductLookup = new zqu.LookupComponentOptions();
      optionsForProductLookup.objectName = 'zqu__zProduct__c';
      optionsForProductLookup.Id = 'ProductLookupComponent';
      optionsForProductLookup.isEditMode = true;
      optionsForProductLookup.lookupComponentControllerName = 'ProductLookupController';
      optionsForProductLookup.recordTypeId = zqu__zProduct__c.SObjectType.getDescribe().getRecordTypeInfosByName().get('Master').getRecordTypeId();
      optionsForProductLookup.popupWindowTitle = 'Product Lookup';
      optionsForProductLookup.isRequired = false;
      return optionsForProductLookup;
  }
}