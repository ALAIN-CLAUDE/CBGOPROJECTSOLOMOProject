public with sharing class SaveResult_APX {
    @AuraEnabled
    public string successId{get;set;}
    @AuraEnabled
    public boolean isSuccess{get;set;}
    @AuraEnabled
    public boolean isCreated{get;set;}
    @AuraEnabled
    public boolean isUpdated{get;set;}
    @AuraEnabled
    public boolean isDeleted{get;set;}
    @AuraEnabled
    public List<String> listErrors{get;set;}
    

    public static List<SaveResult_APX> saveResultInsert(List<SObject> listInsertSObjects){
        List<Database.SaveResult> listSaveResults = new List<Database.SaveResult>();
        List<SaveResult_APX> listSaveResultsApx = new List<SaveResult_APX>();
        if(listInsertSObjects!=null && !listInsertSObjects.isEmpty()){
            listSaveResults = Database.insert(listInsertSObjects, false);
        }
        if(listSaveResults!=null && !listSaveResults.isEmpty()){
            for(Database.SaveResult saveResRec : listSaveResults){
                SaveResult_APX svResApx = new SaveResult_APX();
                List<String> listErrors = new List<String>();
                List<String> listFields = new List<String>();
                if(saveResRec.isSuccess()){
                    svResApx.isSuccess = true;
                    svResApx.isCreated = true;
                    svResApx.successId = saveResRec.getId();
                }
                else{
                    if(saveResRec.getErrors()!=null && !saveResRec.getErrors().isEmpty()){
                        List<Database.Error> listDBErrors =  saveResRec.getErrors();
                        
                        if(listDBErrors!=null && !listDBErrors.isEmpty()){
                            for(Database.Error dbError : listDBErrors){
                                listErrors.add(dbError.getMessage());
                            }
                        }
                    }
                }
                if(listErrors!=null && !listErrors.isEmpty()){svResApx.listErrors = listErrors;}
                listSaveResultsApx.add(svResApx);
            }
        }
        return listSaveResultsApx;
    }

    public static List<SaveResult_APX> saveResultUpdate(List<SObject> listUpdateSObjects){
        List<Database.SaveResult> listSaveResults = new List<Database.SaveResult>();
        List<SaveResult_APX> listSaveResultsApx = new List<SaveResult_APX>();
        if(listUpdateSObjects!=null && !listUpdateSObjects.isEmpty()){
            listSaveResults = Database.Update(listUpdateSObjects, false);
        }
        if(listSaveResults!=null && !listSaveResults.isEmpty()){
            for(Database.SaveResult saveResRec : listSaveResults){
                SaveResult_APX svResApx = new SaveResult_APX();
                List<String> listErrors = new List<String>();
                List<String> listFields = new List<String>();
                if(saveResRec.isSuccess()){
                    svResApx.isSuccess = true;
                    svResApx.isUpdated = true;
                    svResApx.successId = saveResRec.getId();
                }
                else{
                    if(saveResRec.getErrors()!=null && !saveResRec.getErrors().isEmpty()){
                        List<Database.Error> listDBErrors =  saveResRec.getErrors();
                        
                        if(listDBErrors!=null && !listDBErrors.isEmpty()){
                            for(Database.Error dbError : listDBErrors){
                                listErrors.add(dbError.getMessage());
                            }
                        }
                    }
                }
                if(listErrors!=null && !listErrors.isEmpty()){svResApx.listErrors = listErrors;}
                listSaveResultsApx.add(svResApx);
            }
        }
        return listSaveResultsApx;
    }

    public static List<SaveResult_APX> saveResultDelete(List<SObject> listDeleteObjects){
        List<Database.DeleteResult> listDeleteResults = new List<Database.DeleteResult>();
        List<SaveResult_APX> listSaveResultsApx = new List<SaveResult_APX>();

        if(listDeleteObjects!=null && !listDeleteObjects.isEmpty()){
            listDeleteResults = Database.delete(listDeleteObjects, false);
        }

        if(listDeleteResults!=null && !listDeleteResults.isEmpty()){
            for(Database.DeleteResult delRes : listDeleteResults){
                SaveResult_APX svResApx = new SaveResult_APX();
                List<String> listErrors = new List<String>();
                List<String> listFields = new List<String>();
                if(delRes.isSuccess()){
                    svResApx.isSuccess = true;
                    svResApx.isDeleted = true;
                    svResApx.successId = delRes.getId();
                }
                else{
                    if(delRes.getErrors()!=null && !delRes.getErrors().isEmpty()){
                        List<Database.Error> listDBErrors =  delRes.getErrors();
                        if(listDBErrors!=null && !listDBErrors.isEmpty()){
                            for(Database.Error dbError : listDBErrors){listErrors.add(dbError.getMessage());}
                        }
                    }
                }
                if(listErrors!=null && !listErrors.isEmpty()){svResApx.listErrors = listErrors;}
                listSaveResultsApx.add(svResApx);
            }
        }
        return listSaveResultsApx;
    }

    public static list<SaveResult_APX> saveResultUpsert(List<SObject> listUpsertSObjects, string objectApiName, string externalIdField){
        SObjectType sobjType = Schema.getGlobalDescribe().get(objectApiName);
        Map<String,Schema.SObjectField> mapFields = sobjType.getDescribe().fields.getMap();
        Schema.SObjectField sobjField = null;
        if(mapFields!=null && !mapFields.isEmpty()){
            if(mapFields.containsKey(externalIdField)){
                sobjField = mapFields.get(externalIdField);
            }
        }
        List<Database.UpsertResult> listUpsertResults = new List<Database.UpsertResult>();
        List<SaveResult_APX> listSaveResultsApx = new List<SaveResult_APX>();
        if(listUpsertSObjects!=null && !listUpsertSObjects.isEmpty()){
            system.debug('sobjField----'+sobjField);
            system.debug('listUpsertSObjects----'+listUpsertSObjects);
            listUpsertResults = Database.Upsert(listUpsertSObjects, sobjField, false);
        }
        system.debug('listUpsertResults---'+listUpsertResults);
        if(listUpsertResults!=null && !listUpsertResults.isEmpty()){
            for(Database.UpsertResult upsertRes : listUpsertResults){
                SaveResult_APX svResApx = new SaveResult_APX();
                List<String> listErrors = new List<String>();
                List<String> listFields = new List<String>();
                if(upsertRes.isSuccess()){
                    svResApx.isSuccess = true;
                    svResApx.isCreated = upsertRes.isCreated()?true:false;
                    svResApx.isUpdated = upsertRes.isCreated()?false:true;
                    svResApx.successId = upsertRes.getId();
                }
                else{
                    if(upsertRes.getErrors()!=null && !upsertRes.getErrors().isEmpty()){
                        List<Database.Error> listDBErrors =  upsertRes.getErrors();
                        if(listDBErrors!=null && !listDBErrors.isEmpty()){
                            for(Database.Error dbError : listDBErrors){listErrors.add(dbError.getMessage());}
                        }
                    }
                }
                if(listErrors!=null && !listErrors.isEmpty()){svResApx.listErrors = listErrors;}
                listSaveResultsApx.add(svResApx);
                
            }
        }

        return listSaveResultsApx;
    }
}