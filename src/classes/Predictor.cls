public class Predictor {

    public static void predictAllBlanks(List<String> objList){
        Map<String, List<String>> fields = PriorHelper.getFields(objList);
        for(String obj : fields.keySet()){
            List<sObject> records = PriorHelper.getRecords(fields.get(obj),obj);
            for(sObject rec : records){
                List<Prediction> recPreds = recordPredictor(rec, fields.get(obj));
            }
        }
    }

    public static List<String> predictMyBlanks(Id recordId){
        //get object name for query
        List<String> objList = new List<String>{recordId.getSObjectType().getDescribe().getName()};
        //get available fields
        Map<String, List<String>> fields = PriorHelper.getFields(objList);
        //get the record with the right fields
        sObject record = PriorHelper.getRecord(fields.get(objList[0]), recordId);
        List<Prediction> preds = recordPredictor(record, fields.get(objList[0]));
        makeSuggestion(preds);
        List<String> values = new List<String>();
        return values;
    }

    public static List<String> predictMyValues(Id recordId){
        List<String> objList = new List<String>{recordId.getSObjectType().getDescribe().getName()};
        List<String> fields = PriorHelper.getFields(objList).get(objList[0]);
        sObject record = PriorHelper.getRecord(fields, recordId);
        List<Prediction> preds = recordPredictor(record, fields);
        List<String> values = new List<String>();
        return values;
    }

    //helper methods
    private static List<Prediction> recordPredictor(sObject record, List<String> fields){
        Map<String,Prediction> preds = new Map<String,Prediction>();
        List<String> missVal = new List<String>();
        List<String> hasVal = new List<String>();
        List<String> queryList = new List<String>();
        for(String field : fields){
            if(record.get(field) == null){
                missVal.add(field);
            } else {
                hasVal.add(field);
            }
        }
        for (String has : hasVal){
            for (String miss : missVal){
                String fieldName = has+':'+miss;
                queryList.add(fieldName);
            }
        }
        Map<String,Prior__c> priors = PriorHelper.getPriors(queryList, record.getSObjectType().getDescribe().getName());

        for(String has : hasVal){
            for (String p : priors.keySet()){
                String recVal = String.valueOf(record.get(has));
                if(priors.get(p).Value__c.startsWith(recVal)){
                    String field2 = priors.get(p).Field__c.split(':')[1];
                    Prediction pred = preds.get(field2);
                    if(pred == null){
                        pred = new Prediction();
                        pred.field = field2;
                        pred.record = record.Id;
                        pred.predList.put(priors.get(p).Value__c.split(':')[1], priors.get(p).Probability__c);
                        preds.put(field2,pred);
                    } else {
                        Double addProb = pred.predList.get(priors.get(p).Value__c.split(':')[1]);
                        if(addProb == null){
                            pred.predList.put(
                                priors.get(p).Value__c.split(':')[1],
                                priors.get(p).Probability__c
                            );
                        } else {
                            pred.predList.put(
                                priors.get(p).Value__c.split(':')[1],
                                priors.get(p).Probability__c + addProb
                            );
                        }
                        preds.put(field2, pred);
                    }
                }
            }
        }
        // List<Prediction> predList = new List<Prediction>();
        // for (Prediction pred : preds.values()){
        //     predList.add(pred);
        //     system.debug(pred);
        // }
        return preds.values();
    }

    public static void makeSuggestion(List<Prediction> preds){
        Double total = 0;
        List<Suggestion__c> suggestions = new List<Suggestion__c>();
        for(Prediction p : preds){
            Suggestion__c s = new Suggestion__c();
            s.Record_ID__c = p.record;
            for(String key : p.predList.keySet()){
                total += p.predList.get(key);
            }
            for(String key : p.predList.keySet()){
                p.predList.put(key,p.predList.get(key)/total);
            }
            s.Field__c = p.field;
            s.Suggested_Value__c = Json.serialize(p.predList);
            suggestions.add(s);
        }
        insert suggestions;
    }

    //storage class
    private class Prediction {

        public String field;
        public String record;
        Public Map<String,Double> predList;

        public Prediction(){
            this.record = '';
            this.field = '';
            this.predList = new Map<String,Double>();
        }

        public void resetVote(Integer size){
            for(String key : predList.keySet()){
                predList.put(key, predList.get(key)/size);
            }
        }
    }
}