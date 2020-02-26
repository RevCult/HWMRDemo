public interface CustomTypeSetInterface {

	//CustomTypeSetInterface(List<Object>){
		
		
	//};
	Integer getCurrentPage();
	List<Object> getRecords();
	Boolean getHasNext();
	Boolean getHasPrevious();
	Void setPageSize(Integer pageSize);
	Void next();
	Void previous();
}