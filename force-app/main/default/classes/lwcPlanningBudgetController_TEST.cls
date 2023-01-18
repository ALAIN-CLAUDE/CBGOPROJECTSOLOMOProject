@isTest
public with sharing class lwcPlanningBudgetController_TEST {
    
    private static List<Id> listTestPortfolioIds;
    private static List<Id> listTestBudgetScenarioIds;
    private static List<Id> listInsertedChildPlanningDollarIds;
    
    private static void setup1(){
        List<Account> listTestAccounts = TestDataFactory.returnAccounts(1,null);
        List<Id> listInsertedAccountIds = TestDataFactory.executeDML(listTestAccounts, 'Insert');

        List<Contact> listTestContacts = TestDataFactory.returnContacts(1,listInsertedAccountIds);
        List<Id> listInsertedContactIds = TestDataFactory.executeDML(listTestContacts, 'Insert');


        List<Funding_Opportunity__c> listTestFundingOpps = TestDataFactory.returnFundingOpportunities(1,listInsertedAccountIds);
        List<Id> listInsertedFundingOppIds = TestDataFactory.executeDML(listTestFundingOpps, 'Insert');
        string fundingOppQuery = TestDataFactory.getTestSOQLQuery('Funding_Opportunity__c');
        fundingOppQuery = fundingOppQuery+' WHERE Id IN:listInsertedFundingOppIds';
        listTestFundingOpps = Database.query(fundingOppQuery);


        List<Portfolio__c> listTestPortfolios = TestDataFactory.returnPortfolios(1);
        listTestPortfolioIds = TestDataFactory.executeDML(listTestPortfolios, 'Insert');


        List<Funding_Request__c> listTestFundingRequests = TestDataFactory.returnFundingRequests(3,listTestFundingOpps);
        listTestFundingRequests[0].Portfolio__c = listTestPortfolioIds[0];
        listTestFundingRequests[0].Stage__c = 'Invited';
        listTestFundingRequests[1].Portfolio__c = listTestPortfolioIds[0];
        listTestFundingRequests[1].Stage__c = 'Approved';
        listTestFundingRequests[2].Portfolio__c = listTestPortfolioIds[0];
        listTestFundingRequests[2].Stage__c = 'Approved';
        List<Id> listInsertedFundingReqIds = TestDataFactory.executeDML(listTestFundingRequests, 'Insert');
        TestDataFactory.additionalFields = 'Funding_Opportunity__r.Account__c';
        string fundingReqQuery = TestDataFactory.getTestSOQLQuery('Funding_Request__c');
        fundingReqQuery = fundingReqQuery+' WHERE Id IN:listInsertedFundingReqIds';
        listTestFundingRequests = Database.query(fundingReqQuery);
        List<Funding_Request__c> listTestFundingReqsForPayment = new List<Funding_Request__c>();
        listTestFundingReqsForPayment.add(listTestFundingRequests[0]);
        listTestFundingReqsForPayment.add(listTestFundingRequests[1]);
        List<Payment__c> listTestPayments = TestDataFactory.returnPayments(1,listTestFundingReqsForPayment);
        List<Id> listInsertedPaymentIds = TestDataFactory.executeDML(listTestPayments, 'Insert');


        List<Budget_Scenario__c> listTestBudgetScenarios= TestDataFactory.returnBudgetScenarios(1,listTestPortfolioIds);
        listTestBudgetScenarioIds = TestDataFactory.executeDML(listTestBudgetScenarios, 'Insert');

        List<Planning_Dollars__c> listTestParentPlanningDollars = TestDataFactory.returnParentPlanningDollars(3,listTestBudgetScenarioIds);
        List<Id> listInsertedParentPlanningDollarIds = TestDataFactory.executeDML(listTestParentPlanningDollars, 'Insert');
        TestDataFactory.additionalFields = '';
        string parentPlanningDollarsQuery = TestDataFactory.getTestSOQLQuery('Planning_Dollars__c');
        parentPlanningDollarsQuery = parentPlanningDollarsQuery+' WHERE Id IN:listInsertedParentPlanningDollarIds';
        listTestParentPlanningDollars = Database.query(parentPlanningDollarsQuery);

        List<Planning_Dollars__c> listTestParentPlanningDollarsWChildren = new List<Planning_Dollars__c>();
        listTestParentPlanningDollarsWChildren.add(listTestParentPlanningDollars[0]);
        listTestParentPlanningDollarsWChildren.add(listTestParentPlanningDollars[1]);

        List<Planning_Dollars__c> listTestChildPlanningDollars = TestDataFactory.returnChildPlanningDollars(3,listTestParentPlanningDollarsWChildren);
        listInsertedChildPlanningDollarIds = TestDataFactory.executeDML(listTestChildPlanningDollars, 'Insert');



    }

    @isTest
    private static void testmethod1(){
        Test.startTest();
        setup1();
        lwcPlanningBudgetController.getPlanningData(listTestBudgetScenarioIds[0]);
        lwcPlanningBudgetController.deletePlanningDollarsAPX(listInsertedChildPlanningDollarIds[0]);
        Test.stopTest();
    }
}