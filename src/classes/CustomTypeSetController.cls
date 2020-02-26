public with sharing class CustomTypeSetController implements CustomTypeSetInterface{

    private integer pageSize;

    private List<Object> objectList;
    
    private integer currentPage;
    
    private Map<Integer, List<Object>> objectMap;
    
    private void regenerateMap(){
        
        System.Debug('Regenerating map with Pagesize: ' + pageSize);
        
        objectMap = new Map<Integer, List<Object>>();
        
        
        Integer key = 0;
        Integer counter = 0;
        Integer pageSize = 25;
        //List<Object> objList = new List<Object>();
        
        for(Object obj : objectList)
        {
            //System.Debug('Object' + obj);
            List<Object> templist;
            if(objectMap.containskey(key))
            {
                
                templist = objectMap.get(key);
            }
            else
            {
                templist = New List<object>();
            }
            tempList.add(obj);
            objectMap.put(key, tempList);
            
            //objList.add(obj);  
            
            counter++;
        //I need to bucket the objects into groups of 25.   
            
        //Put each object in the respective Page.   
            if(counter == pageSize)
            {
                counter = 0;
                key++;
            }
                        
        }
        
        //System.Debug('ObjectMap' + objectMap);
    }
    
    public CustomTypeSetController(List<Object> objectList){
        
        this.pageSize = 25;
        
        this.currentPage = 0;
        
        this.objectList = objectList;
        
        regenerateMap();
    }
    public Integer getCurrentPage(){
        
        return this.currentPage + 1;
    }
    
    public List<Object> getRecords(){
        
    return objectMap.get(currentPage);
    }
    
    public Void setPageSize(Integer pageSize){
        
        this.pageSize = pageSize;
        
        regenerateMap();
    }
    public Boolean getHasNext(){
        
        return objectMap.containsKey(currentPage + 1);
        
    }
    public Boolean getHasPrevious(){
        if(currentPage == 0)
        {
            return false;
        }
        return objectMap.containsKey(currentPage - 1);
    }
    public Void next(){
        if(getHasNext())
        {
            currentPage++;
        }
    }
    public Void previous(){
        if(getHasPrevious())
        {
            currentPage--;
        }
    }
    public Integer getResultSize(){
        
        return objectList.size();
        
    }
    public Integer getPageSize(){
        
        return pageSize;
    }
}