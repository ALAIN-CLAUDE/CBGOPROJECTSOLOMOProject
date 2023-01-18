@isTest
public class ReviewAssignmentController_TEST {

    @testSetup public static void Setup(){
        Funding_Request__c freq = new Funding_Request__c();
            freq.name = 'New request Funding';
            freq.Stage__c = 'In Process';
            freq.Declination_Reason__c = 'Limited Resources';
            freq.Project_Title__c = 'New Title';
            freq.Project_Goal__c = 'new Goal';
            //freq.Objectives__c = 'new Objectives';
            freq.Target_Communities__c = 'new community';
            //freq.Community_Involvement__c = 'involvement';
            freq.Grant_Request_Amount__c = 45;
            freq.Project_Start_Date__c = date.today();
            freq.Project_End_Date__c = date.today() + 1 ;
            insert freq;
            
            Review_Assignment__c assign = new Review_Assignment__c();
            assign.Funding_Request__c = freq.id;
            insert assign;
    }
    @isTest
    public static void method1(){
        
        Funding_Request__c freq = [Select id,name from Funding_Request__c limit 1];
        List<Funding_Request__c> listFreq = new List<Funding_Request__c>();
        listFreq.add(freq);
        ApexPages.StandardSetController  con = new ApexPages.StandardSetController (listFreq);
        ReviewAssignmentController rc = new ReviewAssignmentController(con);
        
                PageReference pageRef = Page.ReviewAssignment;
    }
}