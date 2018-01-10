public class objectQuery {

    public static void fieldQuery(List<String> objList) {

        Id owner = UserInfo.getUserId();
        /*Map<String, List<String>> fields = PriorHelper.getFields(objList);
        for(String obj : fields.keySet()){
            List<sObject> records = PriorHelper.getRecords(fields.get(obj),obj);
            makeMap(records,fields.get(obj), owner, obj);
        }*/
    }

    private static void makeMap(List<sObject> records, List<String> fields, String owner, String obj){
        Integer total = records.size();
        Map<String,PriorData> dists = new Map<String,PriorData>();
        for(sObject rec : records){
            for(String field1 : fields){
                String value1 = (String)rec.get(field1);
                PriorData p = dists.get(field1+':'+value1);
                if(p != null){
                    p.points += 1;
                    dists.put(field1+':'+value1, p);
                    for(String field2 : fields){
                        if(field2 != field1){
                            String value2 = (String)rec.get(field2);
                            PriorData up = p.pointList.get(field2+':'+value2);
                            if(up != null){
                                up.points += 1;
                                p.pointList.put(field2+':'+value2, up);
                            } else {
                                up = new PriorData();
                                up.field = field2;
                                up.value = value2;
                                up.points = 1;
                                p.pointList.put(field2+':'+value2, up);
                            }
                        }
                    }
                } else {
                    p = new PriorData();
                    p.total = total;
                    p.field = field1;
                    p.value = value1;
                    p.points = 1;
                    for(string field2 : fields){
                        if(field2 != field1){
                            String value2 = (String)rec.get(field2);
                            PriorData pd = new PriorData();
                            pd.field = field2;
                            pd.points = 1;
                            pd.value = value2;
                            p.pointList.put(field2 + ':' + value2,pd);
                        }
                    }
                    dists.put(field1 + ':' + value1, p);
                }
            }
        }
        makePriors(dists, owner, obj);
    }

    private static void makePriors(Map<String,PriorData> theList, Id owner, String obj){
        List<Prior__c> records = new List<Prior__c>();
        for(PriorData pd : theList.values()){
            Prior__c p = new Prior__c();
            p.Object__c = obj;
            p.Field__c = pd.field;
            p.OwnerId = owner;
            p.Probability__c = pd.setPerc();
            p.Value__c = pd.value;
            records.add(p);
            for(PriorData pdi : pd.pointList.values()){
                Prior__c pi = new Prior__c();
                pi.Field__c = pd.field + ':' + pdi.field;
                pi.Object__c = obj;
                pi.OwnerId = owner;
                pi.Probability__c = pdi.points/pd.points;
                pi.Value__c = pd.value + ':' + pdi.value;
                if(!pi.Field__c.endsWith(':')){
                	records.add(pi);
                }

            }
        }
        insert records;
    }

    private class PriorData {

        public String field;
        public String value;
        public Double points;
        public Double total;
        Public Map<String,PriorData> pointList;

        public PriorData(){
            this.field = '';
            this.value = '';
            this.points = 0;
            this.pointList = new Map<String,PriorData>();
            this.total = 0;
        }

        public Double setPerc(){
            return points/total;
        }

    }
}