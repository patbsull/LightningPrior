public class RecordLoop {
    Id recordID;
    Schema.DescribeSObjectResult dsr = recordid.getSobjectType().getDescribe();
    String objectName = dsr.getLabel();
    Map<String,Schema.SObjectField> desFieldList = dsr.fields.getMap();
    Map<String, String> fields = new Map<String, String>();
    
    /*for (String fieldKey : desFieldList.keySet()) {
        DescribeFieldResult dfr = desFieldList.get(fieldKey).getDescribe();
        String type = String.valueOf(dfr.getType());
        fields.put(fieldKey,type);
    }*/
    
    
    
}