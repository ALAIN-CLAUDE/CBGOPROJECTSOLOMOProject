@isTest
public class Batch_ReviewAssignment_TEST {
    
    public static void init(){
        User user;
        //UserRole userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'Director' LIMIT 1];
        Profile profile_1 = [SELECT Id FROM Profile WHERE Name =:SYSTEM.LABEL.TestClassReviewerCommunityProfile_1 LIMIT 1];
        User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' and Id=:UserInfo.getUserId() LIMIT 1];
        User user_1;
        User user_2;
        System.runAs(admin) {
            Account account_1 = new Account( Name = 'Community'  );
            insert account_1;
            
            Contact contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek', email = 'test@gmail.com');
            insert contact_1;
            Contact contact_2 = new Contact(AccountId = account_1.Id, LastName = 'xzgeek', email = 'test2@gmail.com');
            insert contact_2;
            
            user_1 = new User( 
                Email = 'yourusername@gmail.com',
                ProfileId = profile_1.Id, 
                UserName = 'yourusername@gmail.com', 
                Alias = 'Test',
                isActive = true,
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US',
                ContactId = contact_1.Id,
                //PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
            );
            insert user_1;
            
            user_2 = new User( 
                Email = 'yourusername1@gmail.com',
                ProfileId = profile_1.Id, 
                UserName = 'yourusername1@gmail.com', 
                Alias = 'Test',
                isActive = true,
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US',
                ContactId = contact_2.Id,
                //PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
            );
            insert user_2;

            Funding_Opportunity__c testFndOpp = new Funding_Opportunity__c();
            testFndOpp.Account__c = account_1.Id;
            testFndOpp.Proposal_Deadline__c = Date.today();
            insert testFndOpp;
            
            Funding_Request__c freq = new Funding_Request__c();
            freq.name = 'New request Funding';
            freq.Stage__c = 'In Process';
            freq.OwnerId = user_1.Id;
            freq.Funding_Opportunity__c = testFndOpp.Id;
            freq.Respondent__c = account_1.Id;
            freq.Declination_Reason__c = 'Limited Resources';
            freq.Project_Title__c = 'New Title';
            insert freq;
            
            //Review assignment share create record
            Review_Assignment__c assign1 = new Review_Assignment__c();
            assign1.Funding_Request__c = freq.Id;
            assign1.Reviewer__c = user_1.ContactId;
            assign1.OwnerId = user_1.Id;
            assign1.Visible_From__c = date.today().addDays(-1);
            assign1.Visible_To__c = date.today()+10;
            assign1.Email_Sent__c = false;
            insert assign1;
            
            //Review assignment share update record
            Review_Assignment__c assign2 = new Review_Assignment__c();
            assign2.Funding_Request__c = freq.Id;
            assign2.Reviewer__c = user_2.ContactId;
            assign2.Visible_From__c = date.today().addDays(-10);
            assign2.Visible_To__c = date.today().addDays(-1);
            assign2.Email_Sent__c = false;
            insert assign2;
            
            Funding_Request__Share fundShare = new Funding_Request__Share();
            fundshare.AccessLevel = 'Edit';	
            fundShare.RowCause = 'Manual';
            fundShare.ParentId = freq.id;
            fundShare.UserOrGroupId = user_2.id; 
            insert fundShare;
            
            Review_Assignment__Share revShare = new Review_Assignment__Share();
            revShare.AccessLevel = 'Edit';
            revShare.RowCause = 'Manual';
            revShare.ParentId = assign2.id;
            revShare.UserOrGroupId = user_2.id;
            insert revShare;
        }
    }
   
    public static testmethod void method1(){
        init();
        Test.startTest();
        Batch_ReviewAssignment_Scheduler sh1 = new Batch_ReviewAssignment_Scheduler();
        String sch = '0 0 23 * * ?'; system.schedule('Batch_ReviewAssignment', sch, sh1); 
        Test.stopTest();
    }
}