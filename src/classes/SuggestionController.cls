global class SuggestionController { 
    @AuraEnabled
    global static List<Prediction__c> getSuggestions(Id recId) {
        String objType = String.valueOf(recId.getSobjectType());
        Set<String> types = new Set<String>{'PICKLIST'};
        List<String> fields = new List<String>(ObjectUtil.getFields(types,recId.getSobjectType()).keySet());
        String query = 'SELECT ' + String.join(fields, ', ') + ' FROM ' + objType + ' LIMIT 1';
        sObject rec = Database.query(query);
        
        List<String> vals = new List<String>();
        for(String f : fields){
            vals.add((String)rec.get(f));
        }
        
        List<Prediction__c> suggestions = 
            [SELECT Known__r.Field__c, Known__r.Value__c, Probability__c, Value__c, Field__c, Id FROM Prediction__c 
             WHERE Known__r.Object__r.Name LIKE :objType AND Known__r.Field__c in :fields AND Known__r.Value__c IN :vals
             ORDER BY Probability__c DESC
            ];
        
        return filterPList(suggestions, fields, rec);
    }
    
    private static List<Prediction__c> filterPList(List<Prediction__c> preds, List<String> fields, sObject rec){
        Map<String, Prediction__c> groups = new Map<String, Prediction__c>();
        for(String f : fields){
            for(Prediction__c p : preds){
                if(p.Value__c != rec.get(f) && groups.get(p.Field__c) == null){
                    groups.put(p.Field__c, p);
                }
            }
        }
        system.debug(groups.values());
        return groups.values();
    }
}