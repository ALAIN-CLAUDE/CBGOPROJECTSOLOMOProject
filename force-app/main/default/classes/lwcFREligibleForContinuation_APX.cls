public with sharing class lwcFREligibleForContinuation_APX {
    
    @AuraEnabled
    public static void cloneFundingReq_APX(string selectedFundingOppId, string fundingReqId){
        try {
            string newFundingRequestId = '';
            system.debug('selectedFundingOppId -- '+  selectedFundingOppId);
            system.debug('fundingReqId -- '+  fundingReqId);

            string fundingRequestQuery = 'SELECT ';

            Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get('Funding_Request__c').getDescribe().fields.getMap();
            for(Schema.SObjectField sfield : fieldMap.Values()){
                schema.describefieldresult fieldAttr = sfield.getDescribe();
                fundingRequestQuery = fundingRequestQuery + fieldAttr.getName() + ', ';
            }

            if(fundingRequestQuery!=null && fundingRequestQuery!='' && fundingRequestQuery.endsWith(', ')){
                fundingRequestQuery = fundingRequestQuery.removeEnd(', ');
            }
            system.debug('fundingRequestQuery = ' + fundingRequestQuery);
            fundingRequestQuery = fundingRequestQuery + ' FROM Funding_Request__c WHERE Id=:fundingReqId LIMIT 1';

            List<Funding_Request__c> listFundingReqRecs = Database.query(fundingRequestQuery);

            //Query all objectives
            string objectivesQuery = 'SELECT ';
            Map <String, Schema.SObjectField> objectivesFieldMap = schemaMap.get('Objective__c').getDescribe().fields.getMap();
            for(Schema.SObjectField sfield : objectivesFieldMap.Values()){
                schema.describefieldresult fieldAttr = sfield.getDescribe();
                objectivesQuery = objectivesQuery + fieldAttr.getName() + ', ';
            }
            if(objectivesQuery!=null && objectivesQuery!='' && objectivesQuery.endsWith(', ')){
                objectivesQuery = objectivesQuery.removeEnd(', ');
            }
            objectivesQuery = objectivesQuery + ' FROM Objective__c WHERE Funding_Request__c=:fundingReqId';
            system.debug('objectivesQuery = ' + objectivesQuery);


            List<Objective__c> listObjectiveRecs = Database.query(objectivesQuery);


            List<RecordType> listRecordTypes = [Select Id,DeveloperName 
            From RecordType
            WHERE SobjectType=:'Funding_Request__c'
            AND DeveloperName=:'Draft_Response'
            LIMIT 1
            ];
            

            //system.debug('listFundingReqRecs -- '+  listFundingReqRecs);
            List<Funding_Request__c> listInsertFundingRequests = new List<Funding_Request__c>();
            if(listFundingReqRecs!=null && !listFundingReqRecs.isEmpty()){
                Funding_Request__c fundingReqRec = new Funding_Request__c();
                fundingReqRec = listFundingReqRecs[0].clone(false,true,false,false);
                fundingReqRec.Stage__c = 'In Process';
                fundingReqRec.Funding_Opportunity__c = selectedFundingOppId;
                fundingReqRec.Continued__c = true;
                fundingReqRec.External_Id__c = '';
                if(listRecordTypes!=null && !listRecordTypes.isEmpty()){
                    fundingReqRec.RecordTypeId = listRecordTypes[0].Id;
                }
                listInsertFundingRequests.add(fundingReqRec);
            }
            

            if(listInsertFundingRequests!=null && !listInsertFundingRequests.isEmpty()){
                //system.debug('listInsertFundingRequests -- '+  listInsertFundingRequests);
                List<Database.SaveResult> listSaveResults = Database.insert(listInsertFundingRequests);
                if(listSaveResults!=null && !listSaveResults.isEmpty()){
                    for(Database.SaveResult srResRec : listSaveResults){
                        if(srResRec.isSuccess()){
                            newFundingRequestId = (string)srResRec.getId();
                        }
                    }
                }
            }
            if(listFundingReqRecs!=null && !listFundingReqRecs.isEmpty()){
                listFundingReqRecs[0].Stage__c = 'Approved';
                listFundingReqRecs[0].Decision_Stage__c = '';
                //system.debug('listFundingReqRecs -- '+  listFundingReqRecs);
                List<Database.SaveResult> listSaveResults = Database.update(listFundingReqRecs);
            }

            List<Objective__c> listInsertClonedObjectives = new List<Objective__c>();
            if(listObjectiveRecs!=null && !listObjectiveRecs.isEmpty()){
                if(newFundingRequestId!=null && newFundingRequestId!=''){
                    for(Objective__c oldObjectiveRec : listObjectiveRecs){
                        Objective__c newObjectiveRec = new Objective__c();
                        newObjectiveRec = oldObjectiveRec.clone(false,true,false,false);
                        newObjectiveRec.Funding_Request__c = newFundingRequestId;
                        listInsertClonedObjectives.add(newObjectiveRec);
                    }
                }
            }
            if(listInsertClonedObjectives!=null && !listInsertClonedObjectives.isEmpty()){
                List<Database.SaveResult> listSaveResults = Database.insert(listInsertClonedObjectives);
            }
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}