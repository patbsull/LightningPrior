global class ObjectCrawlerBatch implements Database.Batchable<sObject>, Database.StateFul {
	SObjectType sType;
	Map<String, String> fields;

	Map<String, Map<String, Decimal>> pointMap = new Map<String, Map<String, Decimal>>();
	Map<String, Map<String, Decimal>> totalPointsMap = new Map<String, Map<String, Decimal>>();

	public static void run(SObjectType objType){
		// reduce batch size if needed to
		Database.executeBatch(new ObjectCrawlerBatch(objType), 200);
	}


	global ObjectCrawlerBatch(SObjectType sType) {
		this.sType = sType;
		fields = ObjectUtil.getFields(new Set<String>{'PICKLIST','BOOLEAN'}, sType);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator('SELECT ' + String.join(new List<String>(fields.keySet()), ',') + ' FROM ' + sType);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		// number of known records will be number of fields (assuming not null)
		for(SObject sobj : scope){
			for(String f : fields.keySet()){
                for (String f2 : fields.keySet()){
                    if(f <> f2){
                        //add processing for field values that are text and number, booleans are fine as they are
                        String k = f + ':' + getValue(f, fields.get(f), sobj);
                        String k2 = f2 + ':' + getValue(f2, fields.get(f2), sobj);

                        if(pointMap.get(k) == NULL){
                            pointMap.put(k, new Map<String, Decimal>());
                            totalPointsMap.put(k, new Map<String, Decimal>());
                        }

                        if(pointMap.get(k).get(k2) == NULL ){
                            pointMap.get(k).put(k2, 0);
                        }

						if(totalPointsMap.get(k).get(f2) == NULL){
							totalPointsMap.get(k).put(f2, 0);
						}

                        pointMap.get(k).put(k2, pointMap.get(k).get(k2) + 1);
                        totalPointsMap.get(k).put(f2, totalPointsMap.get(k).get(f2) + 1);
                    }
                }
			}
		}
	}
    
    private static Object getValue(String field, String fieldType, SObject sobj){
        if(
            fieldType.containsIgnoreCase('TEXT') || 
            fieldType.containsIgnoreCase('URL') ||
            fieldType.containsIgnoreCase('STRING')||
            fieldType.containsIgnoreCase('CURRENCY')
        ) {
            String value = sobj.get(field) != null ? 'Has Value' : 'Missing Value';
            return value;
        } else if (
            fieldType.containsIgnoreCase('NUMBER') || 
            fieldType.containsIgnoreCase('CURRENCY') || 
            fieldType.containsIgnoreCase('PERCENT')
        ) {
            String value = sobj.get(field) != null ? 'Has Value' : 'Missing Value';
            return value;
        } else {
            return sobj.get(field);
        } 
    }
    

	global void finish(Database.BatchableContext BC) {
		// UUID__c is only for estabilishing parent child relationship
		// using upsert in one go


		Object__c obj = new Object__c(
			Name = String.valueOf(sType),
			UUID__c = sType +':'+ System.now().getTime()
		);

		List<Known__c> knowns = new List<Known__c>();
		List<Prediction__c> predictions = new List<Prediction__c>();

		for(String pair : pointMap.keySet()){
			List<String> fieldPair = pair.split(':');
			knowns.add(new Known__c(
				Object__r = new Object__c(
					UUID__c = obj.UUID__c
				),
				Field__c = fieldPair[0],
				Value__c = fieldPair[1],
				UUID__c = obj.UUID__c + ':' + pair
			));


			Map<String, Decimal> knownMap = pointMap.get(pair);

			for(String pair2 : knownMap.keySet()){
				fieldPair = pair2.split(':');
				predictions.add(new Prediction__c(
					Known__r = new Known__c(
						UUID__c = obj.UUID__c + ':' + pair
					),
					Field__c = fieldPair[0],
					Value__c = fieldPair[1],
					Probability__c = getProbability(knownMap.get(pair2), totalPointsMap.get(pair).get(fieldPair[0]))
				));
			}
		}

		upsert obj UUID__c;
		upsert knowns UUID__c;
		upsert predictions;
	}

	private static Decimal getProbability(Decimal p, Decimal total){
		return p <> NULL && total <> NULL && total <> 0 ? p / total : null;
	}

}