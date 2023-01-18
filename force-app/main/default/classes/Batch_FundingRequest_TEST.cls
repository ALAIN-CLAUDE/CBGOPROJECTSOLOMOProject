@isTEST
public class Batch_FundingRequest_TEST {
    public static void init(){
        
        Profile communityProfile_1 = [SELECT Id FROM Profile WHERE Name = 'CBGO Partner Community' LIMIT 1];
        
        User adminUser = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' and Id=:UserInfo.getUserId() LIMIT 1];
        System.runAs(adminUser){
            
            Account acc = new Account();
            acc.Name = 'TEST';
            insert acc;
            
            Contact con = new Contact();
            con.FirstName = 'TEST CON';
            con.LastName = 'LNAME';
            con.AccountId = acc.Id;
            con.Email = 'testUserConLname@gmail.com';
            insert con;
            
            acc.Application_Contact__c = con.Id;
            update acc;
            
            User usr = new User();
            usr.FirstName = 'TEST CON';
            usr.LastName = 'LNAME';
            usr.ContactId = con.Id;
            usr.ProfileId = communityProfile_1.Id;
            //usr.UserRoleId = userRole_1.Id;
            usr.Email = 'testUserConLname@gmail.com';
            usr.UserName = 'yourusername@gmail.com';
            usr.Alias = 'TestCon';
            usr.TimeZoneSidKey = 'America/New_York';
            usr.EmailEncodingKey = 'ISO-8859-1';
            usr.LocaleSidKey = 'en_US';
            usr.LanguageLocaleKey = 'en_US';
            usr.PortalRole = 'Manager';
            insert usr;
            
            Funding_Opportunity__c fndOpp = new Funding_Opportunity__c();
            fndOpp.Name = 'TEST REQ Assignment';
            fndOpp.Stage__c = 'Deployment';
            fndOpp.Proposal_Release__c = Date.today();
            
            insert fndOpp;
            
            Funding_Request__c fndReq = new Funding_Request__c();
            fndReq.Funding_Opportunity__c = fndOpp.Id;
            fndReq.Stage__c = 'Invited';
            fndReq.Respondent__c = acc.Id;
            fndReq.Request_Contact__c = con.id;
            fndReq.Project_Start_Date__c = Date.today();
            fndReq.Project_End_Date__c = Date.today().addDays(1);
            insert fndReq;
        }      
    }
    
    private static testmethod void testmethod1(){
        init();
        TEST.startTest();
        Batch_FundingRequest_SCHEDULER batchFndSch = new Batch_FundingRequest_SCHEDULER();
        string cronExp = '0 0 23 * * ?';
        system.schedule('TESTFNDSCH', cronExp, batchFndSch);
        TEST.stopTest();
    }
}