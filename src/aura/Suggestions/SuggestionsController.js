({ 
    doInit : function(component, event, helper) {
        // Retrieve contacts during component initialization
        helper.loadSuggestions(component);
        
        component.set("v.Columns", [ 
            {label:"Predicted Field", fieldName:"Field__c", type:"text"},
            {label:"Predicted Value", fieldName:"Value__c", type:"text"},
            {label:"Prob.", fieldName:"Probability__c", type:"percent"}
        ]);
        
    }
})