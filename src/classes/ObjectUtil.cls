public with sharing class ObjectUtil {

	public static Map<String,String> getFields(Set<String> types, SObjectType sType){
		Schema.DescribeSobjectResult res = sType.getDescribe();
		Map<String, Schema.SObjectField> fieldsMap = res.fields.getMap();
		Map<String, String> fields = new Map<String, String>();
		for ( String fieldKey: fieldsMap.keySet() ) {
			DescribeFieldResult dfr = fieldsMap.get( fieldKey ).getDescribe();
			String type = String.valueOf(dfr.getType());
			if(types.contains(type) || types.contains(type.toUpperCase())){
                fields.put(fieldKey,type);
            }
        }
        return fields;
    }
    
    public static Double standardDeviation(List<Prediction__c> predictions) {
        
        Double sum = 0;
        for(Prediction__c p : predictions) {
            sum += p.Probability__c *100;
        }
        
        Double mean = sum / predictions.size();
        Double squaredDifferencesSum = 0;
        Double exponent = 2;
        
        for(Prediction__c d : predictions) {
            Double doubleValue = (d.Probability__c*100) - mean;
            squaredDifferencesSum += Math.pow(doubleValue, exponent);
        }
        
        Double squaredDifferencesMean = squaredDifferencesSum / predictions.size();
        Double standardDeviation = Math.sqrt(squaredDifferencesMean)/100;
        return standardDeviation;
    }
}