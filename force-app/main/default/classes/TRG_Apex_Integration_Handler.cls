public class TRG_Apex_Integration_Handler {
	public static void runApxJob(List<APEX_Integration_Trigger__c> listApxIntTrg){
        Set<String> setApxClassNames = new Set<String>();
        Map<String,Integer> mapApexClassBatchSize = new Map<String,Integer>();
        if(listApxIntTrg!=NULL && !listApxIntTrg.isEmpty()){
            for(APEX_Integration_Trigger__c apxIntTrgRec : listApxIntTrg){
                if(apxIntTrgRec.Run_Batch__c){
                    setApxClassNames.add(apxIntTrgRec.Name);
                    integer batchSize = 200;
                    if(apxIntTrgRec.Batch_Size__c!=NULL && apxIntTrgRec.Batch_Size__c!=0){
                        batchSize = Integer.valueOf(apxIntTrgRec.Batch_Size__c);
                    }
                    mapApexClassBatchSize.put(apxIntTrgRec.Name,batchSize);
                }
            }
        }
        if(setApxClassNames!=NULL && !setApxClassNames.isEmpty()){
            Map<Id,ApexClass> mapAPXClass = new Map<Id,ApexClass>([Select Id,Name 
                                                                   From ApexClass 
                                                                   Where 
                                                                   Name IN:setApxClassNames
                                                                  ]);
            if(mapAPXClass!=NULL && !mapAPXClass.isEmpty()){
                for(Id idKey : mapAPXClass.keyset()){
                    Type apexClassType = Type.forName(mapAPXClass.get(idKey).Name);
                    Database.batchable<sObject> batchAPXInstance = (Database.batchable<sObject>)apexClassType.newInstance(); 
                    Database.executeBatch(batchAPXInstance,mapApexClassBatchSize.get(mapAPXClass.get(idKey).Name));
                }
            }
        }
    }
}