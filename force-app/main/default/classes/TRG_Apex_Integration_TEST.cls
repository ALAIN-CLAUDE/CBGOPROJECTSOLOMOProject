@IsTEST
public class TRG_Apex_Integration_TEST {
    private static void init(){
        List<ApexClass> listApexClass = [SELECT Id, Name, body 
                                         FROM ApexClass 
                                         Where Name=: 'Batch_ReviewAssignment'
                                         AND NameSpacePrefix = ''
                                         order by LastModifiedDate DESC
                                         LIMIT 1
                                   ];
        
        APEX_Integration_Trigger__c apexIntJob = new APEX_Integration_Trigger__c();
        apexIntJob.Name = listApexClass[0].Name;
        apexIntJob.Run_Batch__c = TRUE;
        insert apexIntJob;
        
        APEX_Integration_Trigger__c apexIntJob2 = new APEX_Integration_Trigger__c();
        apexIntJob2.Name = listApexClass[0].Name;
        apexIntJob2.Batch_Size__c = 50;
        apexIntJob2.Run_Batch__c = TRUE;
        insert apexIntJob2;
        
    }
    
    private static testmethod void testmethod1(){
        init();
        TEST.startTest();
        TEST.stopTest();
    }
}