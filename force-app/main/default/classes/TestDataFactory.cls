@isTest
public with sharing class TestDataFactory {

    public static string additionalFields;

    @AuraEnabled
    public static string getTestSOQLQuery(string objectApiName){
        List<String> listFields = new List<String>();
        listFields.addAll(Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().keySet());
        string query = '';
        string query1 = 'SELECT';
        string query2 = String.Join(listFields, ',');
        if(additionalFields!=null && additionalFields!=''){
            query2 = query2 + ',' + additionalFields; 
        }
        string query3 = ' FROM ' + objectApiName;

        query = query + query1;
        query = query +' '+ query2;
        query = query +' '+ query3;
        return query;
    }

    @AuraEnabled
    public static List<Id> executeDML(List<SObject> listTestSObjects, string dmlValue){
        List<Database.SaveResult> listTestSaveResults = new List<Database.SaveResult>();
        Set<Id> returnIdSet = new Set<Id>();
        List<Id> listReturnIds = new List<Id>();
        if(listTestSObjects!=null && !listTestSObjects.isEmpty() && dmlValue!=null && dmlValue!=''){
            if(dmlValue == 'Insert'){
                listTestSaveResults = Database.insert(listTestSObjects);
            }
        }

        if(listTestSaveResults!=null && !listTestSaveResults.isEmpty()){
            for(Database.SaveResult testSRResRec : listTestSaveResults){
                if(testSRResRec.isSuccess()){
                    returnIdSet.add(testSRResRec.getId());
                }
            }
        }
        
        if(returnIdSet!=null && !returnIdSet.isEmpty()){
            listReturnIds.addAll(returnIdSet);
        }
        return listReturnIds;
    }

    public static List<Account> returnAccounts(Integer numberOfRecords, String recordTypeDevName){
        List<Account> returnList = new List<Account>();
        if(numberOfRecords!=null && numberOfRecords>0){
            integer count=0;
            for(Integer start = 0; start < numberOfRecords; start++){
                count = count+1;
                Account testAccRec = new Account();
                testAccRec.Name = 'Test  Acc '+ String.valueOf(count);
                if(recordTypeDevName!=null && recordTypeDevName!=''){
                    testAccRec.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordTypeDevName).getRecordTypeId();
                }
                returnList.add(testAccRec);
            }
        }
        return returnList;
    }

    public static List<Contact> returnContacts(Integer numberOfRecords, List<Id> accountIdSet){
        List<Contact> returnList = new List<Contact>();
        if(accountIdSet!=null && !accountIdSet.isEmpty()){
            if(numberOfRecords!=null && numberOfRecords>0){
                integer count=0;
                for(Id testAccId : accountIdSet){
                    for(Integer start = 0; start < numberOfRecords; start++){
                        count = count + 1;
                        Contact testConRec = new Contact();
                        testConRec.FirstName = 'TEST FIRST NAME' + string.valueOf(count);
                        testConRec.LastName = 'TEST LAST NAME';
                        testConRec.Email = 'testRec@Rec.com'+string.valueOf(count);
                        testConRec.AccountId = testAccId;
                        returnList.add(testConRec);
                    }
                }
            }
        }
        return returnList;
    }

    public static List<Funding_Opportunity__c> returnFundingOpportunities(Integer numberOfRecords, List<Id> accountIdSet){
        List<Funding_Opportunity__c> returnList = new List<Funding_Opportunity__c>();
        if(accountIdSet!=null && !accountIdSet.isEmpty()){
            if(numberOfRecords!=null && numberOfRecords>0){
                integer count=0;
                for(Id testAccId : accountIdSet){
                    for(Integer start = 0; start < numberOfRecords; start++){
                        count = count + 1;
                        Funding_Opportunity__c testFndOpp = new Funding_Opportunity__c();
                        testFndOpp.Name = 'Test Funding Opp ' + String.valueOf(count);
                        testFndOpp.Account__c = testAccId;
                        testFndOpp.Proposal_Deadline__c = Date.today();
                        returnList.add(testFndOpp);
                    }
                }
            }
        }
        return returnList;
    }

    public static List<Portfolio__c> returnPortfolios(Integer numberOfRecords){
        List<Portfolio__c> returnList = new List<Portfolio__c>();
        if(numberOfRecords!=null && numberOfRecords>0){
            integer count=0;
            for(Integer start = 0; start < numberOfRecords; start++){
                count = count + 1;
                Portfolio__c testPortfolio = new Portfolio__c();
                testPortfolio.Name = 'Test Portfolio ' + String.valueOf(count);
                returnList.add(testPortfolio);
            }
        }
        return returnList;
    }

    public static List<Budget_Scenario__c> returnBudgetScenarios(Integer numberOfRecords, List<Id> portfolioIdSet){
        List<Budget_Scenario__c> returnList = new List<Budget_Scenario__c>();
        if(portfolioIdSet!=null && !portfolioIdSet.isEmpty()){
            if(numberOfRecords!=null && numberOfRecords>0){
                integer count=0;
                for(Id portolioId : portfolioIdSet){
                    for(Integer start = 0; start < numberOfRecords; start++){
                        Budget_Scenario__c testBudgetScenario = new Budget_Scenario__c();
                        testBudgetScenario.Name = 'Test Budget Scenario' + string.valueOf(count);
                        testBudgetScenario.Portfolio__c = portolioId;
                        testBudgetScenario.Fiscal_Year__c = 'FY23';
                        testBudgetScenario.Amount__c = 100;
                        returnList.add(testBudgetScenario);
                    }
                }
            }
        }
        return returnList;
    }

    public static List<Budget_Scenario__c> returnChildBudgetScenarios(Integer numberOfRecords, List<Budget_Scenario__c> listParentBudgetScenarios){
        List<Budget_Scenario__c> returnList = new List<Budget_Scenario__c>();
        if(listParentBudgetScenarios!=null && !listParentBudgetScenarios.isEmpty()){
            if(numberOfRecords!=null && numberOfRecords>0){
                integer count=0;
                for(Budget_Scenario__c parentBudgScenario : listParentBudgetScenarios){
                    for(Integer start = 0; start < numberOfRecords; start++){
                        Budget_Scenario__c testBudgetScenario = parentBudgScenario.clone(false, true, false, false);
                        testBudgetScenario.Name = 'Child of ' + parentBudgScenario.Name;
                        testBudgetScenario.Amount__c = 80;
                        testBudgetScenario.CBGO_Budget__c = parentBudgScenario.Id;
                        returnList.add(testBudgetScenario);
                    }
                }
            }
        }
        return returnList;
    }

    public static List<Planning_Dollars__c> returnParentPlanningDollars(Integer numberOfRecords, List<Id> budgetScenarioIds){
        List<Planning_Dollars__c> returnList = new List<Planning_Dollars__c>();
        if(budgetScenarioIds!=null && !budgetScenarioIds.isEmpty()){
            if(numberOfRecords!=null && numberOfRecords>0){
                integer count=0;
                for(Id budgetScenarioId : budgetScenarioIds){
                    for(Integer start = 0; start < numberOfRecords; start++){
                        Planning_Dollars__c testPlanningDollars = new Planning_Dollars__c();
                        testPlanningDollars.Name = 'Test Planning Dollars' + string.valueOf(count);
                        testPlanningDollars.Budget_Scenario__c = budgetScenarioId;
                        testPlanningDollars.Notes__c = 'Test planning dollars';
                        testPlanningDollars.Amount__c = 100;
                        returnList.add(testPlanningDollars);
                    }
                }
            }
        }
        return returnList;
    }


    public static List<Planning_Dollars__c> returnChildPlanningDollars(Integer numberOfRecords, List<Planning_Dollars__c> listParentPlanningDollarRecs){
        List<Planning_Dollars__c> returnList = new List<Planning_Dollars__c>();
        if(listParentPlanningDollarRecs!=null && !listParentPlanningDollarRecs.isEmpty()){
            if(numberOfRecords!=null && numberOfRecords>0){
                integer count=0;
                for(Planning_Dollars__c parentPlanningDollarRec : listParentPlanningDollarRecs){
                    for(Integer start = 0; start < numberOfRecords; start++){
                        Planning_Dollars__c testPlanningDollars = parentPlanningDollarRec.clone(false, true, false, false);
                        testPlanningDollars.Name = 'Test Child Of ' + testPlanningDollars.Name;
                        testPlanningDollars.Notes__c = 'Test Child Of ' + testPlanningDollars.Notes__c;
                        testPlanningDollars.Amount__c = 25;
                        testPlanningDollars.Planning_Detail__c = parentPlanningDollarRec.Id;
                        returnList.add(testPlanningDollars);
                    }
                }
            }
        }
        return returnList;
    }

    public static List<Funding_Request__c> returnFundingRequests(Integer numberOfRecords, List<Funding_Opportunity__c> listTestFundingOpps){
        List<Funding_Request__c> returnList = new List<Funding_Request__c>();
        if(listTestFundingOpps!=null && !listTestFundingOpps.isEmpty()){
            if(numberOfRecords!=null && numberOfRecords>0){
                integer count=0;
                for(Funding_Opportunity__c testFundOpp : listTestFundingOpps){
                    for(Integer start = 0; start < numberOfRecords; start++){
                        count = count + 1;
                        Funding_Request__c testFundReq = new Funding_Request__c();
                        testFundReq.Name = 'Test Funding Req ' + String.valueOf(count);
                        testFundReq.Funding_Opportunity__c = testFundOpp.Id;
                        testFundReq.Stage__c = 'Invited';
                        testFundReq.Fiscal_Year__c = 'FY23';
                        testFundReq.Respondent__c = testFundOpp.Account__c;
                        returnList.add(testFundReq);
                    }
                }
            }
        }
        return returnList;
    }

    public static List<Payment__c> returnPayments(Integer numberOfRecords, List<Funding_Request__c> listTestFundingReqs){
        List<Payment__c> returnList = new List<Payment__c>();
        if(listTestFundingReqs!=null && !listTestFundingReqs.isEmpty()){
            if(numberOfRecords!=null && numberOfRecords>0){
                integer count=0;
                for(Funding_Request__c testFundingReq : listTestFundingReqs){
                    for(Integer start = 0; start < numberOfRecords; start++){
                        Payment__c testPaymentRec = new Payment__c();
                        testPaymentRec.Funding_Request__c = testFundingReq.Id;
                        testPaymentRec.Account__c = testFundingReq.Funding_Opportunity__r.Account__c;
                        testPaymentRec.Amount__c = 100;
                        testPaymentRec.Budget_Fiscal_Year__c = 'FY23';
                        returnList.add(testPaymentRec);
                    }
                }
            }
        }
        return returnList;
    }

    
}