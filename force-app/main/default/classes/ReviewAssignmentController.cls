public with sharing class ReviewAssignmentController {

    /**This is the list which will be passed to Visualforce Page and in turn passed to Flow from Visualforce**/
    public string listFunReqsStr{get;set;}
    public List < Funding_Request__c > LstSelectedRequests {
        get;
        set;
    }
    
    public ReviewAssignmentController(ApexPages.StandardSetController listcontroller) {
      
        Set < Id > requestSelectedIds = new set < Id > ();
        LstSelectedRequests = new List < Funding_Request__c >();
            
        for (Funding_Request__c c: (Funding_Request__c[]) listcontroller.getSelected()) {
            requestSelectedIds.add(c.id);
        }
        
        /**Querying on the Selected records and fetching fields which are required in Flow **/
        LstSelectedRequests = [select Id from Funding_Request__c where id in: requestSelectedIds];
        System.Debug(LstSelectedRequests);
        listFunReqsStr = JSON.serialize(requestSelectedIds);
        /*if(listFunReqsStr!=NULL && listFunReqsStr!=''){
            if(listFunReqsStr.contains('[')){
                listFunReqsStr.replace('[', '');
            }
        }*/
        system.debug('listFunReqsStr--'+listFunReqsStr);
    }
}