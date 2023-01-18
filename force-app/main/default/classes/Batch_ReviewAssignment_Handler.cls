public class Batch_ReviewAssignment_Handler {

    public static void changeOwnerForRevAssignAndFundingReq(Id jobId, List<Review_Assignment__c> listReviewAssignments){
        Set<Id> fundingRequestIdSet = new Set<Id>();
        if(listReviewAssignments!=NULL && !listReviewAssignments.isEmpty()){
            for(Review_Assignment__c revAssignment : listReviewAssignments){
                if(revAssignment.Funding_Request__c!=NULL){
                    fundingRequestIdSet.add(revAssignment.Funding_Request__c);
                }
            }
        }

        Map<Id,Funding_Request__c> mapFundingRequests = new Map<Id,Funding_Request__c>();
        Map<Id,Review_Assignment__c> mapUpdateReviewAssignments = new Map<Id,Review_Assignment__c>();
        if(fundingRequestIdSet!=null && !fundingRequestIdSet.isEmpty()){
            mapFundingRequests = new Map<Id,Funding_Request__c>([Select Id,OwnerId
                                                                FROM Funding_Request__c
                                                                WHERE ID IN:fundingRequestIdSet
                                                                AND OwnerId!=:UserInfo.getUserId()
                                                                ]);
        }

        if(listReviewAssignments!=null && !listReviewAssignments.isEmpty()){
            for(Review_Assignment__c revAssignRec : listReviewAssignments){
                if(revAssignRec.OwnerId!=null && revAssignRec.OwnerId!=UserInfo.getUserId()){
                    revAssignRec.OwnerId = UserInfo.getUserId();
                    mapUpdateReviewAssignments.put(revAssignRec.Id, revAssignRec);
                }
            }
        }

        if(mapFundingRequests!=null && !mapFundingRequests.isEmpty()){
            for(Id fundReqId : mapFundingRequests.keySet()){
                mapFundingRequests.get(fundReqId).OwnerId = UserInfo.getUserId();
            }
        }

        if(mapFundingRequests!=null && !mapFundingRequests.isEmpty()){
            List<Database.SaveResult> listSaveResults = Database.update(mapFundingRequests.values());
        }

        if(mapUpdateReviewAssignments!=null && !mapUpdateReviewAssignments.isEmpty()){
            List<Database.SaveResult> listSaveResults = Database.update(mapUpdateReviewAssignments.values());
        }
    }

    public static void createFundingRequestShareRecords(Id jobId, List<Review_Assignment__c> listReviewAssignments){
        Date currentDate = Date.today();
        Set<Id> fundingRequestIdSet = new Set<Id>();
        Map<Id,User> mapUserRecord = new Map<Id,User>();
        Map<Id,User> mapUsers = new Map<Id,User>();
        Map<Id,Funding_Request__c> mapFundingRequest = new Map<Id,Funding_Request__c>();
        List<Funding_Request__Share> listFundingRequestShares = new List<Funding_Request__Share>();
        Map<Id,Funding_Request__Share> mapDeleteFundingRequestShares = new Map<Id,Funding_Request__Share>();
        Map<Id,Funding_Request__Share> mapUpdateFundingRequestShares = new Map<Id,Funding_Request__Share>();
        List<Funding_Request__Share> listInsertFundingRequestShares = new List<Funding_Request__Share>();
        
        
        mapUsers = new Map<Id,User>( [Select Id,ContactId
                                      FROM User 
                                      WHERE isActive=:TRUE
                                      AND Profile.Name =:SYSTEM.LABEL.TestClassReviewerCommunityProfile_1
                                     ]);
        
        if(mapUsers!=NULL && !mapUsers.isEmpty()){
            for(Id userRecId : mapUsers.keySet()){
                if(mapUsers.get(userRecId).ContactId!=NULL){
                    mapUserRecord.put(mapUsers.get(userRecId).ContactId,mapUsers.get(userRecId));
                }
            }
        }
        
        if(listReviewAssignments!=NULL && !listReviewAssignments.isEmpty()){
            for(Review_Assignment__c revAssignment : listReviewAssignments){
                if(revAssignment.Funding_Request__c!=NULL){
                    fundingRequestIdSet.add(revAssignment.Funding_Request__c);
                }
            }
        }
        
        if(fundingRequestIdSet!=NULL && !fundingRequestIdSet.isEmpty()){
            mapFundingRequest = new Map<Id,Funding_Request__c>([Select Id 
                                                                FROM Funding_Request__c
                                                                WHERE ID IN:fundingRequestIdSet
                                                               ]
                                                              );
            listFundingRequestShares = [SELECT Id,AccessLevel,IsDeleted,ParentId,RowCause,UserOrGroupId
                                        FROM Funding_Request__Share
                                        WHERE ParentId IN:fundingRequestIdSet
                                        AND IsDeleted=:FALSE
                                       ];
        }
        system.debug('mapFundingRequest--'+mapFundingRequest);
        if(listReviewAssignments!=NULL && !listReviewAssignments.isEmpty()){
            for(Review_Assignment__c revAssignment : listReviewAssignments){
                if(revAssignment.Reviewer__c!=NULL && revAssignment.Funding_Request__c!=NULL){
                    boolean reviewerExists = FALSE;
                    if(listFundingRequestShares!=NULL && !listFundingRequestShares.isEmpty()){
                        for(Funding_Request__Share fundReqShareRec : listFundingRequestShares){
                            //Check if the funding response record is the same
                            if(revAssignment.Funding_Request__c == fundReqShareRec.ParentId){
                                if(mapUsers!=NULL && !mapUsers.isEmpty() && mapUsers.containsKey(fundReqShareRec.UserOrGroupId)){
                                    
                                    if(revAssignment.Reviewer__c == mapUsers.get(fundReqShareRec.UserOrGroupId).ContactId){
                                        reviewerExists = TRUE;
                                        //Commented on 8th Nov 2021 after discussion with Dan
                                        /*if(revAssignment.Visible_From__c!=NULL && currentDate < revAssignment.Visible_From__c){
                                            mapDeleteFundingRequestShares.put(fundReqShareRec.Id, fundReqShareRec);
                                        } 
                                        if(revAssignment.Visible_To__c!=NULL && currentDate > revAssignment.Visible_To__c){
                                            mapDeleteFundingRequestShares.put(fundReqShareRec.Id, fundReqShareRec);
                                        }*/
                                        mapUpdateFundingRequestShares.put(fundReqShareRec.Id, fundReqShareRec);
                                    }
                                }
                            }
                        }
                    }
                    system.debug('reviewerExists--'+reviewerExists);
                    if(reviewerExists==FALSE){
                        system.debug('revAssignment.Visible_From__c--'+revAssignment.Visible_From__c);
                        system.debug('revAssignment.Visible_From__c--'+revAssignment.Visible_To__c);
                        system.debug('revAssignment.Visible_From__c--'+currentDate);
                        if(currentDate >= revAssignment.Visible_From__c && currentDate <= revAssignment.Visible_To__c){
                            system.debug('reviewerExists--'+reviewerExists);
                            if(mapUserRecord!=NULL && !mapUserRecord.isEmpty() && mapUserRecord.containsKey(revAssignment.Reviewer__c)){
                                /*Funding_Request__Share newFundReqShareRec = new Funding_Request__Share();
                                newFundReqShareRec.AccessLevel = 'Read';
                                newFundReqShareRec.UserOrGroupId = mapUserRecord.get(revAssignment.Reviewer__c).Id;
                                newFundReqShareRec.ParentId = revAssignment.Funding_Request__c;
                                newFundReqShareRec.RowCause = 'Manual';
                                */
                                Funding_Request__Share newFundReqShareRec = createFundingRequestReadRecs(revAssignment.Funding_Request__c, mapUserRecord.get(revAssignment.Reviewer__c).Id , 'Manual', 'Read');
                                if(newFundReqShareRec!=null){
                                    listInsertFundingRequestShares.add(newFundReqShareRec);
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if(mapDeleteFundingRequestShares!=NULL && !mapDeleteFundingRequestShares.isEmpty()){
            List<Database.DeleteResult> listDeleteResults = Database.delete(mapDeleteFundingRequestShares.values());
        }
        if(mapUpdateFundingRequestShares!=NULL && !mapUpdateFundingRequestShares.isEmpty()){
            List<Database.SaveResult> listUpdateResults = Database.update(mapUpdateFundingRequestShares.values());
        }
        if(listInsertFundingRequestShares!=NULL && !listInsertFundingRequestShares.isEmpty()){
            List<Database.SaveResult> listInsertResults = Database.insert(listInsertFundingRequestShares);
        }
    }

    public static Funding_Request__Share createFundingRequestReadRecs(Id parentId, Id userOrGroupId, string rowCause, string accessLevel){
        Funding_Request__Share newFundReqShareRec = new Funding_Request__Share();
        newFundReqShareRec.ParentId = parentId;
        newFundReqShareRec.UserOrGroupId = userOrGroupId;
        newFundReqShareRec.AccessLevel = accessLevel;
        newFundReqShareRec.RowCause = rowCause;
        return newFundReqShareRec;
    }
    
    public static void createReviewAssignmentShareRecords(Id jobId, List<Review_Assignment__c> listReviewAssignments){
        Date currentDate = Date.today();
        Map<Id,User> mapUserRecord = new Map<Id,User>();
        Map<Id,User> mapUsers = new Map<Id,User>();
        Set<Id> revAssignmenIdSet = new Set<Id>();
        List<Review_Assignment__Share> listRevAssignShares = new List<Review_Assignment__Share>();
        Map<Id,Review_Assignment__Share> mapDeleteRevAssignShares = new Map<Id,Review_Assignment__Share>();
        List<Review_Assignment__Share> listInsertRevAssignShares = new List<Review_Assignment__Share>();
        
        mapUsers = new Map<Id,User>( [Select Id,ContactId,Name 
                                      FROM User 
                                      WHERE isActive=:TRUE
                                      AND Profile.Name=: SYSTEM.LABEL.TestClassReviewerCommunityProfile_1
                                     ]);
        
        system.debug('mapUsers '+mapUsers);
        if(mapUsers!=NULL && !mapUsers.isEmpty()){
            for(Id userRecId : mapUsers.keySet()){
                if(mapUsers.get(userRecId).ContactId!=NULL){
                    mapUserRecord.put(mapUsers.get(userRecId).ContactId,mapUsers.get(userRecId));
                }
            }
        }
        system.debug('mapUserRecord--'+mapUserRecord);
        
        if(listReviewAssignments!=NULL && !listReviewAssignments.isEmpty()){
            for(Review_Assignment__c revAssignment : listReviewAssignments){ 
                if(revAssignment.Funding_Request__c!=NULL){
                    revAssignmenIdSet.add(revAssignment.Id);
                }
            }
        }
        
        if(revAssignmenIdSet!=NULL && !revAssignmenIdSet.isEmpty()){
            listRevAssignShares = [SELECT Id,AccessLevel,IsDeleted,ParentId,RowCause,UserOrGroupId
                                   FROM Review_Assignment__Share
                                   WHERE ParentId IN:revAssignmenIdSet
                                   AND IsDeleted=:FALSE
                                  ];
        }
        
        if(listReviewAssignments!=NULL && !listReviewAssignments.isEmpty()){
            for(Review_Assignment__c revAssignment : listReviewAssignments){
                boolean reviewerShareRecExists = FALSE;
                if(revAssignment.Reviewer__c!=NULL){
                    if(listRevAssignShares!=NULL && !listRevAssignShares.isEmpty()){
                        for(Review_Assignment__Share revAssignShare : listRevAssignShares){
                            if(revAssignShare.ParentId == revAssignment.Id){
                                if(mapUsers!=NULL && !mapUsers.isEmpty() && mapUsers.containsKey(revAssignShare.UserOrGroupId)){
                                    if(revAssignment.Reviewer__c == mapUsers.get(revAssignShare.UserOrGroupId).ContactId){
                                        reviewerShareRecExists = TRUE;
                                        if(revAssignment.Visible_From__c!=NULL && currentDate < revAssignment.Visible_From__c ){
                                            mapDeleteRevAssignShares.put(revAssignShare.Id,revAssignShare);
                                            //Added after discussion with Dan on 8th Nov 2021
                                            Review_Assignment__Share revAssignShareRead = createReviewAssignmentReadRecs(revAssignment.Id, revAssignShare.UserOrGroupId,'Manual','Read');
                                            if(revAssignShareRead!=null){
                                                listInsertRevAssignShares.add(revAssignShareRead);
                                            }
                                        }
                                        if(revAssignment.Visible_To__c!=NULL && currentDate > revAssignment.Visible_To__c){
                                            mapDeleteRevAssignShares.put(revAssignShare.Id,revAssignShare);
                                            //Added after discussion with Dan on 8th Nov 2021
                                            Review_Assignment__Share revAssignShareRead = createReviewAssignmentReadRecs(revAssignment.Id, revAssignShare.UserOrGroupId,'Manual','Read');
                                            if(revAssignShareRead!=null){
                                                listInsertRevAssignShares.add(revAssignShareRead);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if(reviewerShareRecExists==FALSE){
                        if(currentDate >= revAssignment.Visible_From__c && currentDate <= revAssignment.Visible_To__c && revAssignment.Stage__c!='Review Complete'){
                            /*Review_Assignment__Share revAssignShare = new Review_Assignment__Share();
                            revAssignShare.AccessLevel = 'Edit';
                            system.debug('mapUserRecord  '+mapUserRecord);
                            system.debug('reviewAssign  '+revAssignment);
                            revAssignShare.UserOrGroupId = mapUserRecord.get(revAssignment.Reviewer__c).Id;
                            revAssignShare.ParentId = revAssignment.Id;
                            revAssignShare.RowCause = 'Manual';
                            listInsertRevAssignShares.add(revAssignShare);
                            */
                            //Commented after discussion with Dan
                            Review_Assignment__Share revAssignShareEdit = createReviewAssignmentReadRecs(revAssignment.Id, mapUserRecord.get(revAssignment.Reviewer__c).Id,'Manual','Edit');
                            if(revAssignShareEdit!=null){
                                listInsertRevAssignShares.add(revAssignShareEdit);
                            }
                        }
                    }
                }
            }
        }
        
        if(mapDeleteRevAssignShares!=NULL && !mapDeleteRevAssignShares.isEmpty()){
            List<Database.DeleteResult> listDeleteResults = Database.delete(mapDeleteRevAssignShares.values());
        }
        
        if(listInsertRevAssignShares!=NULL && !listInsertRevAssignShares.isEmpty()){
            List<Database.SaveResult> listInsertResults = Database.insert(listInsertRevAssignShares);
        }
    }

    public static Review_Assignment__Share createReviewAssignmentReadRecs(Id parentId, Id userOrGroupId, string rowCause, string accessLevel){
        Review_Assignment__Share revAssignShare = new Review_Assignment__Share();
        revAssignShare.ParentId = parentId;
        revAssignShare.UserOrGroupId = userOrGroupId;
        revAssignShare.RowCause = rowCause;
        revAssignShare.AccessLevel = accessLevel;
        return revAssignShare;
    }

    /*public static Funding_Request__Share createReviewAssignmentEditRecs(Id parentId, Id userOrGroupId, string rowCause, string accessLevel){
        Review_Assignment__Share revAssignShare = new Review_Assignment__Share();
        revAssignShare.ParentId = revAssignment.Id;
        revAssignShare.UserOrGroupId = userOrGroupId;
        revAssignShare.RowCause = rowCause;
        revAssignShare.AccessLevel = accessLevel;
        return revAssignShare;
    }*/

    /*public static void updateOwner(Id asyncApexJobId, List<Review_Assignment__c> listReviewAssignments){
        
        if(listReviewAssignments!=NULL && !listReviewAssignments.isEmpty()){
            Set<Id> contactIdSet = new Set<Id>();
            for(Review_Assignment__c revAssignRec : listReviewAssignments){
                if(revAssignRec.Reviewer__c!=NULL){
                    contactIdSet.add(revAssignRec.Reviewer__c);
                }
            }
            if(contactIdSet!=NULL && !contactIdSet.isEmpty()){
                List<User> listUsers = [Select Id,ContactId From User 
                                        WHERE ContactId!=NULL 
                                        AND ContactId IN:contactIdSet
                                       ];
                if(listUsers!=NULL && !listUsers.isEmpty()){
                    for(Review_Assignment__c revAssignRec : listReviewAssignments){
                        if(revAssignRec.Reviewer__c!=NULL){
                            for(User userRec : listUsers){
                                if(userRec.ContactId == revAssignRec.Reviewer__c){
                                    revAssignRec.OwnerId = userRec.Id;
                                }
                            }
                        }
                    }
                }
            }
            List<Database.SaveResult> listSaveResults = Database.update(listReviewAssignments);
        }
    }
    */
    //Jennifer submitted a change request to remove automation that sends email.
    /*
    public static void sendEmails(Id jobId, List<Review_Assignment__c> listReviewAssignments){
      
        Date todaysDate = Date.today();
        if(listReviewAssignments != null && !listReviewAssignments.isEmpty()){
            for(Review_Assignment__c revAssList : listReviewAssignments){
                if(revAssList.Visible_From__c != null && revAssList.Visible_To__c != null){
                    if(todaysDate >= revAssList.Visible_From__c && todaysDate <= revAssList.Visible_To__c){
                        if(revAssList.Email_Sent__c == false){
                            revAssList.Email_Sent__c = true;
                        }
                    }
                }
            }
            Database.update(listReviewAssignments); 
        }
    }
    */
}