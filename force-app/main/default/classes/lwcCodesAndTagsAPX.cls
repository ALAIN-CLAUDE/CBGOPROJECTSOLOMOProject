public with sharing class lwcCodesAndTagsAPX {

    @AuraEnabled
    public static string getWhereClauseField(string recordId){
        string whereClauseField = '';
        if(recordId!=null && recordId!=''){
            Schema.SObjectType recordsSobjectType = Id.valueOf(recordId).getSobjectType();
            Map<string,Schema.SObjectField> fieldMaps = Schema.getGlobalDescribe().get('Related_Code_and_Tag__c').getDescribe().fields.getMap();
            if(fieldMaps!=null && !fieldMaps.isEmpty()){
                for(string field : fieldMaps.keySet()){
                    Schema.DescribeFieldResult fieldSchemaDescribe = fieldMaps.get(field).getDescribe();
                    if(fieldSchemaDescribe!=null && fieldSchemaDescribe.getReferenceTo()!=null && !fieldSchemaDescribe.getReferenceTo().isEmpty()){
                        for(Schema.SObjectType sobjectTypeReferencedTo : fieldSchemaDescribe.getReferenceTo()){
                            if(sobjectTypeReferencedTo == recordsSobjectType){
                                whereClauseField = fieldSchemaDescribe.getName();
                                break;
                            }
                        }
                    }
                    if(whereClauseField!=null && whereClauseField!=''){
                        break;
                    }
                }
            }
        }
        return whereClauseField;
    }
    
    @AuraEnabled
    public static List<AggregateResult> checkForRelatedCodesAndTagsAPX(string recordId){
        List<AggregateResult> listAggResults = new List<AggregateResult>();
        
        string whereClauseField = getWhereClauseField(recordId);

        if(whereClauseField!=null && whereClauseField!=''){
            string query = '';
            string query1 = 'Select Code_and_Tag__r.RecordType.DeveloperName recType, Count(Id) recCount';
            string query2 = 'FROM Related_Code_and_Tag__c';
            string query3 = 'WHERE '+whereClauseField+'=:recordId';
            string query4 = 'GROUP By Code_and_Tag__r.RecordType.DeveloperName';
            query = query + ' ' + query1;
            query = query + ' ' + query2;
            query = query + ' ' + query3;
            query = query + ' ' + query4;
            
            listAggResults = Database.query(query);
        }

        return listAggResults;
    }

    @AuraEnabled
    public static boolean checkForUnAllocatedCodesAPX(string recordId){
        List<Related_Code_and_Tag__c> listUnAllocatedCodes = new List<Related_Code_and_Tag__c>();
        boolean unAllocatedCodesFound = false;
        string whereClauseField = getWhereClauseField(recordId);

        if(whereClauseField!=null && whereClauseField!=''){
            string query = '';
            string query1 = 'Select Id, Code_and_Tag__r.RecordType.DeveloperName';
            string query2 = 'FROM Related_Code_and_Tag__c';
            string query3 = 'WHERE '+whereClauseField+'=:recordId';
            string query4 = 'AND Allocation__c=null';
            string query5 = 'AND Code_and_Tag__r.RecordType.DeveloperName=\'Code\'';
            query = query + ' ' + query1;
            query = query + ' ' + query2;
            query = query + ' ' + query3;
            query = query + ' ' + query4;
            query = query + ' ' + query5;
            
            listUnAllocatedCodes = Database.query(query);

            if(listUnAllocatedCodes!=null && !listUnAllocatedCodes.isEmpty()){
                unAllocatedCodesFound = true;
            }
        }

        return unAllocatedCodesFound;
    }

    @AuraEnabled
    public static boolean checkForAllocatedCodesAndTagsAPX(string recordId){
        List<Related_Code_and_Tag__c> listUnAllocatedCodes = new List<Related_Code_and_Tag__c>();
        boolean allocatedCodesAndTags = false;
        string whereClauseField = getWhereClauseField(recordId);

        if(whereClauseField!=null && whereClauseField!=''){
            string query = '';
            string query1 = 'Select Id, Code_and_Tag__r.RecordType.DeveloperName';
            string query2 = 'FROM Related_Code_and_Tag__c';
            string query3 = 'WHERE '+whereClauseField+'=:recordId';
            string query4 = 'AND Allocation__c=null';
            string query5 = 'AND Code_and_Tag__r.RecordType.DeveloperName=\'Code\'';
            query = query + ' ' + query1;
            query = query + ' ' + query2;
            query = query + ' ' + query3;
            query = query + ' ' + query4;
            query = query + ' ' + query5;
            
            listUnAllocatedCodes = Database.query(query);

            if(listUnAllocatedCodes!=null && !listUnAllocatedCodes.isEmpty()){
                allocatedCodesAndTags = false;
            }
            else{
                string queryForRelatedCodesAndTags = '';
                queryForRelatedCodesAndTags = queryForRelatedCodesAndTags + ' ' + query1;
                queryForRelatedCodesAndTags = queryForRelatedCodesAndTags + ' ' + query2;
                queryForRelatedCodesAndTags = queryForRelatedCodesAndTags + ' ' + query3;
                List<Related_Code_and_Tag__c> listRelatedCodesAndTags = new List<Related_Code_and_Tag__c>();
                listRelatedCodesAndTags = Database.query(queryForRelatedCodesAndTags);
                if(listRelatedCodesAndTags!=null && !listRelatedCodesAndTags.isEmpty()){
                    allocatedCodesAndTags = true;
                }
            }
        }

        return allocatedCodesAndTags;
    }

}