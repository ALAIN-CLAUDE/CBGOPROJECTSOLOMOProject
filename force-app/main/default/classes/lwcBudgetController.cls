/**
 * Created by denisletkovski on 2022-06-22.
 */

public with sharing class lwcBudgetController {

    private static Boolean isAdminUser;

    public static Boolean getIsAdminUser() {
        if (isAdminUser == null) {
            isAdminUser = ([SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()][0].Name == 'System Administrator');
        }
        return isAdminUser;
    }

    @AuraEnabled
    public static void deleteBudget(String recordId) {
        List<Budget_Scenario__c> budgetForDelete = [SELECT Id FROM Budget_Scenario__c WHERE Id =: recordId];
        if (!budgetForDelete.isEmpty()) {
            delete  budgetForDelete;
        }
    }

    @AuraEnabled
    public static String getPortfolioNameById(String portfolioRecId) {
        System.debug('!!!!! ' + portfolioRecId);
        List<Portfolio__c> listSelectedPortfolios = [
                SELECT Name
                FROM Portfolio__c
                WHERE Id =: portfolioRecId
                LIMIT 1
        ];
        
        return listSelectedPortfolios!=null && !listSelectedPortfolios.isEmpty() ?  listSelectedPortfolios[0].Name : '';
    }

   

    @AuraEnabled
    public static List<lwcBudgetWrapper> getBudgetListsByFilter(List<String> selectedYears, List<String> selectedPortfolioIds) {

        String budgetQuery = 'SELECT Id, Name, Portfolio__r.Name, Fiscal_Year__c, Amount__c, CBGO_Budget__c  FROM Budget_Scenario__c';

        if (selectedYears != null && !selectedYears.isEmpty()) {
            budgetQuery += ' WHERE Fiscal_Year__c IN : selectedYears';
        }
        if (selectedPortfolioIds != null && !selectedPortfolioIds.isEmpty()) {
            if (budgetQuery.containsIgnoreCase('WHERE')) {
                budgetQuery += ' AND Portfolio__c IN : selectedPortfolioIds';
            } else {
                budgetQuery += ' WHERE Portfolio__c IN : selectedPortfolioIds';
            }
        }
        lwcBudgetWrapper wrapper = new lwcBudgetWrapper();

        return wrapper.getWrappedBudget((List<Budget_Scenario__c>)Database.query(budgetQuery));

    }

    // @AuraEnabled
    // public static List<Portfolio__c> getPortfoliosByFilter(List<String> selectedYears) {
    //     String portfolioQuery = 'SELECT Id, Name FROM Portfolio__c WHERE (SELECT Id, Fiscal_Year__c FROM Budget_Scenario__c IN : selectedYears)';

    //     return null;
    // }

    // @AuraEnabled
    // public static void createBudget(String fiscalYear, String amount, String portfolioId, String parentId, String name, String recordId) {
    //     System.debug('----- ' + parentId);
    //     List<Portfolio__c> linkedPortfolio = [
    //             SELECT Id, Name
    //             FROM Portfolio__c
    //             WHERE Id =: portfolioId
    //     ];
    //     try {
    //         if (recordId != null && String.isNotBlank(recordId)) {
    //             List<Budget_Scenario__c> budgetForUpdate = [
    //                     SELECT Id, Amount__c, Fiscal_Year__c, Portfolio__c, CBGO_Budget__c, Name  FROM Budget_Scenario__c
    //                     WHERE Id =: recordId
    //             ];
    //             if (!budgetForUpdate.isEmpty()) {


    //                 budgetForUpdate[0].Name = name;
    //                 budgetForUpdate[0].Amount__c = amount != null ? Decimal.valueOf(amount) : 0;
    //                 budgetForUpdate[0].Fiscal_Year__c = fiscalYear;
    //                 budgetForUpdate[0].Portfolio__c = portfolioId;
    //             }

    //             update budgetForUpdate;
    //         } else {
    //             Budget_Scenario__c newBudget = new Budget_Scenario__c();
    //             newBudget.Amount__c = Decimal.valueOf(amount);
    //             newBudget.Fiscal_Year__c = fiscalYear;
    //             newBudget.Portfolio__c = portfolioId;
    //             if (String.isNotBlank(parentId)) {
    //                 List<Budget_Scenario__c> otherChildByParent = [
    //                         SELECT Id
    //                         FROM Budget_Scenario__c
    //                         WHERE CBGO_Budget__c =: parentId
    //                 ];
    //                 newBudget.Name = String.isNotBlank(name) ?
    //                         name : fiscalYear + ' ' + linkedPortfolio[0].Name + ' V' +  String.valueOf((otherChildByParent.size() + 1));
    //                 newBudget.CBGO_Budget__c = parentId;
    //             } else {
    //                 newBudget.Name = String.isNotBlank(name) ? name : fiscalYear + ' ' + linkedPortfolio[0].Name;
    //                 newBudget.CBGO_Budget__c = parentId;
    //             }
    //             insert newBudget;
    //         }
    //     } catch (Exception exc) {
    //         System.debug(exc.getMessage());
    //     }
    // }
}