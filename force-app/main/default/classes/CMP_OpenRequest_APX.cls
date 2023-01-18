public class CMP_OpenRequest_APX {
    
    @AuraEnabled
    public static string fetchUserId(){
       List<User> listUsers = [Select Id,ContactId
                     FROM User 
                     WHERE
                     Id=:UserInfo.getUserId()
                     LIMIT 1
                    ];
        string usrId = (string)listUsers[0].ContactId;
        return usrId;
    }
    
    @AuraEnabled
    public static List<FundReqObj> getFundingRequests(){
        List<Funding_Request__c> listFundingRequests = new List<Funding_Request__c>();
        List<FundReqObj> listFundReqs = new List<FundReqObj>();
        List<User> listUsers = new List<User>();
        Map<Id,User> mapUserRecords = new Map<Id,User>();
        
        listUsers = [Select Id,ContactId
                     FROM User 
                     WHERE
                     Id=:UserInfo.getUserId()
                     LIMIT 1
                    ];
        if(listUsers!=NULL && !listUsers.isEmpty()){
            //re-add following to query Objectives__c, Community_Involvement__c,
            listFundingRequests = [Select Id,Name,Project_Title__c,Project_Goal__c
                                   ,Target_Communities__c,Grant_Request_Amount__c,Project_Start_Date__c,Project_End_Date__c
                                   FROM Funding_Request__c
                                   WHERE 
                                   //OwnerId=:UserInfo.getUserId()
                                   ID IN (Select Funding_Request__c 
                                          FROM 
                                          Review_Assignment__c 
                                          WHERE Reviewer__c=:listUsers[0].ContactId
                                         )
                                   
                                   AND 
                                   Stage__c=:'In Process'
                                  ];
            
        }

        if(listFundingRequests!=NULL && !listFundingRequests.isEmpty()){
            for(Funding_Request__c fndReqRec : listFundingRequests){
                string title = '';
                string goal = '';
                //string objectives = '';
                string targetComm = '';
                string commInvolvement = ''; 
                string grantReqAmount = '$0';
                string startDate = '';
                string endDate = '';
                FundReqObj fndObj = new FundReqObj(); 
                
                if(fndReqRec.Project_Title__c!=NULL && fndReqRec.Project_Title__c!=''){
                    title = fndReqRec.Project_Title__c;
                    fndObj.titleChecked = TRUE;
                }
                if(fndReqRec.Project_Goal__c!=NULL && fndReqRec.Project_Goal__c!=''){
                    goal = fndReqRec.Project_Goal__c;
                    fndObj.goalChecked = TRUE;
                }
                /*if(fndReqRec.Objectives__c!=NULL && fndReqRec.Objectives__c!=''){
                    objectives = fndReqRec.Objectives__c;
                    objectives = objectives.stripHtmlTags();
                    fndObj.objectivesChecked = TRUE;
                }*/
                if(fndReqRec.Target_Communities__c!=NULL && fndReqRec.Target_Communities__c!=''){
                    targetComm = fndReqRec.Target_Communities__c;
                    fndObj.targetCommChecked = TRUE;
                }
                /*if(fndReqRec.Community_Involvement__c!=NULL && fndReqRec.Community_Involvement__c!=''){
                    commInvolvement = fndReqRec.Project_Title__c;
                    fndObj.commInvolvementChecked = TRUE;
                }*/
                if(fndReqRec.Grant_Request_Amount__c!=NULL && fndReqRec.Grant_Request_Amount__c>0){
                    grantReqAmount = '$' + string.valueOf(fndReqRec.Grant_Request_Amount__c);
                    fndObj.grantReqAmountChecked = TRUE;
                }
                if(fndReqRec.Project_Start_Date__c!=NULL){
                    startDate = fndReqRec.Project_Start_Date__c.format();
                    fndObj.startDateChecked = TRUE;
                }
                if(fndReqRec.Project_End_Date__c!=NULL){
                    endDate = fndReqRec.Project_End_Date__c.format();
                    fndObj.endDateChecked = TRUE;
                }
                
                
                fndObj.recId = fndReqRec.Id;
                fndObj.link = '/'+fndReqRec.Id;
                fndObj.Name = fndReqRec.Name;
                fndObj.title = title;
                fndObj.goal = goal;
                //fndObj.objectives = objectives;
                fndObj.targetComm = targetComm;
                fndObj.commInvolvement = commInvolvement;
                fndObj.grantReqAmount = grantReqAmount;
                fndObj.startDate = startDate;
                fndObj.endDate = endDate;
                fndObj.disabled = TRUE;
                listFundReqs.add(fndObj);
            }
        }
        return listFundReqs;
    }
    
    public class FundReqObj{
        @AuraEnabled
        public string recId{get;set;}
        @AuraEnabled
        public string link{get;set;}
        @AuraEnabled
        public string name{get;set;}
        @AuraEnabled
        public string title{get;set;}
        @AuraEnabled
        public string goal{get;set;}
        /*@AuraEnabled
        public string objectives{get;set;}
        */
        @AuraEnabled
        public string targetComm{get;set;}
        @AuraEnabled
        public string commInvolvement{get;set;}
        @AuraEnabled
        public string grantReqAmount{get;set;}
        @AuraEnabled
        public string startDate{get;set;}
        @AuraEnabled
        public string endDate{get;set;}
        @AuraEnabled
        public boolean titleChecked{get;set;}
        @AuraEnabled
        public boolean goalChecked{get;set;}
        /*@AuraEnabled
        public boolean objectivesChecked{get;set;}*/
        @AuraEnabled
        public boolean targetCommChecked{get;set;}
        @AuraEnabled
        public boolean commInvolvementChecked{get;set;}
        @AuraEnabled
        public boolean grantReqAmountChecked{get;set;}
        @AuraEnabled
        public boolean startDateChecked{get;set;}
        @AuraEnabled
        public boolean endDateChecked{get;set;}
        @AuraEnabled
        public boolean disabled{get;set;}
        
    }
}