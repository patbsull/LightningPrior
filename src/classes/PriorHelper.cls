public class PriorHelper {
    
	public static List<SObject> getRecords(List<String> fields, String sObjectName){
        return Database.query('SELECT ' + String.join(fields, ',') + ' FROM '+sObjectName+' LIMIT 50');
    }
    
    public static sObject getRecord(List<String> fields, Id recordId){
        String sObjectName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        return Database.query('SELECT ' + String.join(fields, ',') + ' FROM '+sObjectName+' Where Id = \''+recordId+'\'');
    }
    
    public static Map<String,Prior__c> getPriors(List<String> couples, String obj){
        Map<String,Prior__c> priors = new Map<String,Prior__c>([SELECT Field__c, Value__c, Probability__c, Id 
                                 FROM Prior__c 
                                 WHERE Object__c = :obj and Field__c in :couples]);
        return priors;
    }
    
    public static Set<cleanObject> getFields(List<String> obj){
        Set<cleanObject> objFields = new Set<cleanObject>();
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(obj);
        for (Schema.DescribeSobjectResult res : results ) {
            Map<String, Schema.SObjectField> fieldsMap = res.fields.getMap();
            cleanObject co = new cleanObject();
            co.objectName = res.getLabel();
            for ( String fieldKey: fieldsMap.keySet() ) {
                DescribeFieldResult dfr = fieldsMap.get( fieldKey ).getDescribe();
                co.fieldTypes.put(fieldKey, String.valueOf(dfr.getType()));
            }
            objFields.add(co);
        }
        return objFields;
        //pass back picklist values to make sure that deactivated values aren't factored in
    }
    
    public class cleanObject {
    	public String objectName;
    	public Map<String, String> fieldTypes;
    	
    	public cleanObject(){
    		objectName = '';
    		fieldTypes = new Map<String,String>();
    	}
    }
    
}