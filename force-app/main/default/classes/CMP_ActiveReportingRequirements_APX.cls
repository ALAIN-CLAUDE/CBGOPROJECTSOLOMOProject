public class CMP_ActiveReportingRequirements_APX {
	
    @AuraEnabled
    public static List<ReportingCls> getActiveReportingRequirements(){
        
        List<User> listLoggedInUsers = [Select Id, ContactId 
                                        FROM User
                                        WHERE Id=:UserInfo.getUserId()
                                        AND Profile.UserLicense.Name=:SYSTEM.LABEL.PartnerCommunityUserLicenseName
                                        LIMIT 1
                                       ];
        
        List<ReportingCls> listActiveReportingCls = new List<ReportingCls>();
        
        
        
        List<Funding_Request__c> listFundingReqs = [Select Id,Name,Respondent__c,
                                                    (Select Id FROM Forms__r WHERE CreatedById=:UserInfo.getUserId() LIMIT 1)
                                                    FROM Funding_Request__c
                                                    Where //OwnerId=:UserInfo.getUserId()
                                                    Respondent__c IN (Select AccountId 
                                                                      FROM Contact 
                                                                      WHERE Id=:listLoggedInUsers[0].ContactId
                                                                     )
                                                   ];
        
        List<disco__Form_Template__c> listFormTemplates = [Select Id,Name 
                                                           FROM disco__Form_Template__c
                                                           WHERE Name=:SYSTEM.LABEL.CMP_ActiveReportingRequirements_YourekaTemplateName
                                                           AND disco__Status__c=:'In Use'
                                                           LIMIT 1
                                                          ];
        
        List<Network> listNetworks = [Select Id,UrlPathPrefix 
                                      FROM Network
                                      WHERE Name=:SYSTEM.LABEL.CMP_ActiveReportingRequirements_NetworkName
                                      LIMIT 1
                                     ];
      
        
        if(listFormTemplates!=NULL && !listFormTemplates.isEmpty() && listFundingReqs!=NULL && !listFundingReqs.isEmpty()){
            string baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
            string finalUrl = baseUrl;
            string finalUrlForCompletedForm = baseUrl;
            if(listNetworks!=NULL && !listNetworks.isEmpty()){
                //finalUrl2 =finalUrl + '/' +listNetworks[0].UrlPathPrefix+'/disco__NewFormWizard?passthroughretURL=https://partial-cedarssinaicbgo1.cs192.force.com/partners/s/&templateID='+(string)listFormTemplates[0].Id+'&Funding_Request__c=fundingRequestId';
                finalUrl = finalUrl  + '/' + listNetworks[0].UrlPathPrefix + '/disco__NewFormWizard?passthroughretURL=' +  finalUrl + '/' + listNetworks[0].UrlPathPrefix + '/s/&templateID=' + (string)listFormTemplates[0].Id + '&Funding_Request__c=fundingRequestId&disco__Form_Account__c='+(string)listFundingReqs[0].Respondent__c;
                finalUrlForCompletedForm = finalUrlForCompletedForm +  '/' + listNetworks[0].UrlPathPrefix + '/disco__CompleteForm?id=formId&returnURL='+  finalUrlForCompletedForm + '/' + listNetworks[0].UrlPathPrefix+'/s/';
            }
            
            for(Funding_Request__c fndReq : listFundingReqs){
                ReportingCls reportingCls = new ReportingCls();
                reportingCls.reqName = fndReq.Name;
                if(finalUrl!=NULL && finalUrl!='' && finalUrl.contains('fundingRequestId')){
                   finalUrl =  finalUrl.replace('fundingRequestId', (string)fndReq.Id);
                }
                reportingCls.fndReqId = fndReq.Id;
                if(fndReq.Forms__r!=NULL && !fndReq.Forms__r.isEmpty()){
                    reportingCls.formId = (string)fndReq.Forms__r[0].Id;
                    if(finalUrlForCompletedForm.contains('formId')){
                        finalUrlForCompletedForm = finalUrlForCompletedForm.replace('formId',(string)fndReq.Forms__r[0].Id);
                    }
                    finalUrl = finalUrlForCompletedForm;
                    system.debug('finalUrl--'+finalUrl);
                }
                
                reportingCls.reportingUrl = finalUrl;
                listActiveReportingCls.add(reportingCls);
            }
        }
        return listActiveReportingCls;
    }
    
    public class ReportingCls{
        @AuraEnabled
        public string fndReqId{get;set;}
        @AuraEnabled
        public string reportingUrl{get;set;}
        @AuraEnabled
        public string formId{get;set;}
        @AuraEnabled
        public string reqName{get;set;}
    }
}