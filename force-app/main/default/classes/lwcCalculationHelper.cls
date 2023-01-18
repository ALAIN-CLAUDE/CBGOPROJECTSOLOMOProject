/**
 * Created by Dzianis_Liatkouski on 10.08.22.
 */

public with sharing class lwcCalculationHelper {
    public String fiscalYear = '';
    public String idWithFY = '';
    public Decimal paid = 0;
    public Decimal approved = 0;
    public Decimal invited = 0;

    public static Map<String, lwcCalculationHelper> calculateAmounts(Map<Id, Set<String>> portfolioWithFY) {

        Map<String, lwcCalculationHelper> finalCalculations = new Map<String, lwcCalculationHelper>();
        List<Funding_Request__c> requests = [
                SELECT Id, Approved_Amount__c, Grant_Request_Amount__c, Portfolio__c, Fiscal_Year__c, Stage__c, (SELECT Id, Amount__c FROM Payments__r)
                FROM Funding_Request__c
                WHERE Portfolio__c IN: portfolioWithFY.keySet()
        ];
        List<String> portfolioStatuses = new List<String>{'Invited', 'In Process', 'Submitted', 'Decision', 'Pending'};
        for (Funding_Request__c request: requests) {
            String currentIdWithFY = request.Portfolio__c + request.Fiscal_Year__c;
            lwcCalculationHelper currentRecord;
            if (finalCalculations.containsKey(currentIdWithFY)) {
                currentRecord = new lwcCalculationHelper();
                currentRecord = finalCalculations.get(currentIdWithFY);
            } else {
                currentRecord = new lwcCalculationHelper();
                currentRecord.fiscalYear = request.Fiscal_Year__c;
                currentRecord.idWithFY = request.Portfolio__c + request.Fiscal_Year__c;
            }
            if (request.Stage__c == 'Approved' && request.Payments__r.size() > 0) {
                for (Payment__c payment : request.Payments__r) {
                    currentRecord.paid = payment.Amount__c == null ? currentRecord.paid : currentRecord.paid + payment.Amount__c;
                }
            }
            if (request.Stage__c == 'Approved' && request.Payments__r.size() == 0) {
                currentRecord.approved = request.Approved_Amount__c == null ? currentRecord.approved : currentRecord.approved + request.Approved_Amount__c;
            }
            if (portfolioStatuses.contains(request.Stage__c)) {
                currentRecord.invited = request.Grant_Request_Amount__c == null ? currentRecord.invited : currentRecord.invited + request.Grant_Request_Amount__c;
            }

            finalCalculations.put(currentIdWithFY, currentRecord);
        }

        return finalCalculations;
    }

    // public static List<lwcBudgetDetailController.BudgetCalculationsDetail> getBudgetCalculationDetails(String portfolioId, String fiscalYear) {
    //     List<Funding_Request__c> requestsByPortfolioAndFY = [
    //             SELECT Id, Approved_Amount__c, Approved_Date__c, Complete_Notes__c, Grant_Request_Amount__c, Portfolio__c, Fiscal_Year__c, Stage__c, (SELECT Id, Amount__c FROM Payments__r)
    //             FROM Funding_Request__c
    //             WHERE Portfolio__c =: portfolioId AND Fiscal_Year__c =: fiscalYear
    //     ];

    //     return null;
    // }
}