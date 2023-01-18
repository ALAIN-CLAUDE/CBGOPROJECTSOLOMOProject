public class CMP_ReviewerHomePage_APX {
	
    
    @AuraEnabled
    public static List<User> getUser(){
        List<User> listUsers = [Select Id,Name 
                                FROM User
                                WHERE Id=:UserInfo.getUserId()
                                LIMIT 1
                               ];
        
        return listUsers;
    }
    
    @AuraEnabled
    public static List<ReviewAssignmentCls> getSubmittedReviewAssignments(){
        List<Review_Assignment__c> listCompletedReviewAssignments = new List<Review_Assignment__c>();
		List<ReviewAssignmentCls> listCompltedReviews = new List<ReviewAssignmentCls>();
        List<User> listUsers = [Select Id,Name,ContactId
                                FROM User
                                WHERE Id=:UserInfo.getUserId()
                                LIMIT 1
                               ];
        if(listUsers!=NULL && !listUsers.isEmpty()){
            listCompletedReviewAssignments = [Select Id,Funding_Request__c,Funding_Request__r.Name,Visible_From__c,Visible_To__c,Due_Date__c
                                              ,LastModifiedDate,Funding_Request__r.Funding_Opportunity__r.Name,Stage__c,Funding_Request__r.Grant_Request_Amount__c
                                              FROM Review_Assignment__c 
                                              WHERE Reviewer__c=:listUsers[0].ContactId
                                              AND Stage__c=:'Review Complete'
                                             ];
        }
        
        
        if(listCompletedReviewAssignments!=NULL && !listCompletedReviewAssignments.isEmpty()){
            for(Review_Assignment__c revAssRec : listCompletedReviewAssignments){
                ReviewAssignmentCls revAssignCls = new ReviewAssignmentCls();
                revAssignCls.revAssId = (string)revAssRec.Id;
                revAssignCls.requestName = revAssRec.Funding_Request__r.Name;
                revAssignCls.revAssignmentStageName = revAssRec.Stage__c;
                revAssignCls.fundingOppName = revAssRec.Funding_Request__r.Funding_Opportunity__r.Name;
                revAssignCls.requestId = (string)revAssRec.Funding_Request__c;
                revAssignCls.openDate = revAssRec.Visible_From__c;
                revAssignCls.grantReqAmt = revAssRec.Funding_Request__r.Grant_Request_Amount__c;
                revAssignCls.lastUpdated = revAssRec.LastModifiedDate;
                revAssignCls.lastUpdatedStr = revAssRec.LastModifiedDate.format('MMM dd, YYYY hh:mm aa');
                revAssignCls.dueDate = revAssRec.Due_Date__c;
                revAssignCls.dueDateCSSClass = (revAssRec.Due_Date__c!=null && revAssRec.Due_Date__c<Date.today())?'dueDatePassed':'novalue';
                listCompltedReviews.add(revAssignCls);
            }
        }
        return listCompltedReviews;
    }
    
    @AuraEnabled
    public static List<ReviewAssignmentCls> getPendingReviewAssignments(){
        List<Review_Assignment__c> listPendingReviewAssignments = new List<Review_Assignment__c>();
        List<ReviewAssignmentCls> listPendingReviews = new List<ReviewAssignmentCls>();
        List<User> listUsers = [Select Id,Name,ContactId
                                FROM User
                                WHERE Id=:UserInfo.getUserId()
                                LIMIT 1
                               ];
        if(listUsers!=NULL && !listUsers.isEmpty()){
            listPendingReviewAssignments = [Select Id,Funding_Request__c,Funding_Request__r.Name,Visible_From__c,Visible_To__c,Due_Date__c
                                            ,LastModifiedDate,Funding_Request__r.Funding_Opportunity__r.Name,Stage__c,Funding_Request__r.Grant_Request_Amount__c
                                            FROM Review_Assignment__c 
                                            //WHERE OwnerId=:UserInfo.getUserId()
                                            WHERE Reviewer__c=:listUsers[0].ContactId
                                            AND Stage__c!=:'Review Complete'
                                           ];
        }
        
        system.debug('listPendingReviewAssignments--'+listPendingReviewAssignments);
        if(listPendingReviewAssignments!=NULL && !listPendingReviewAssignments.isEmpty()){
            for(Review_Assignment__c revAssRec : listPendingReviewAssignments){
                ReviewAssignmentCls revAssignCls = new ReviewAssignmentCls();
                revAssignCls.revAssId = (string)revAssRec.Id;
                revAssignCls.requestName = revAssRec.Funding_Request__r.Name;
                revAssignCls.revAssignmentStageName = revAssRec.Stage__c;
                revAssignCls.fundingOppName = revAssRec.Funding_Request__r.Funding_Opportunity__r.Name;
                revAssignCls.requestId = (string)revAssRec.Funding_Request__c;
                revAssignCls.openDate = revAssRec.Visible_From__c;
                revAssignCls.grantReqAmt = revAssRec.Funding_Request__r.Grant_Request_Amount__c;
                revAssignCls.lastUpdated = revAssRec.LastModifiedDate;
                revAssignCls.lastUpdatedStr = revAssRec.LastModifiedDate.format('MMM dd, YYYY hh:mm aa');
                revAssignCls.dueDate = revAssRec.Due_Date__c;
                revAssignCls.dueDateCSSClass = (revAssRec.Due_Date__c!=null && revAssRec.Due_Date__c<Date.today())?'dueDatePassed':'novalue';
                listPendingReviews.add(revAssignCls);
            }
        }
        system.debug('listPendingReviews--'+listPendingReviews);
        return listPendingReviews;
    }
    
    public class ReviewAssignmentCls{
        @AuraEnabled
        public string revAssId{get;set;}
        @AuraEnabled
        public string requestName{get;set;}
        @AuraEnabled
        public string fundingOppName{get;set;}
        @AuraEnabled
        public string requestId{get;set;}
        @AuraEnabled
        public decimal grantReqAmt{get;set;}
        @AuraEnabled
        public string revAssignmentStageName{get;set;}
        @AuraEnabled
        public Date openDate{get;set;}
        @AuraEnabled
        public DateTime lastUpdated{get;set;}
        @AuraEnabled
        public string lastUpdatedStr{get;set;}
        @AuraEnabled
        public Date dueDate{get;set;}
        @AuraEnabled
        public string dueDateCSSClass{get;set;}
        
    }
}