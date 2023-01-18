/**
 * Created by Dzianis_Liatkouski on 11.08.22.
 */

public with sharing class lwcBudgetDetailController {

    @AuraEnabled
    public static BudgetRecordDetail getTableDetail(String budgetId) {
        Map<String, List<lwcBudgetDetailController.BudgetCalculationsDetail>> paymentTypeWithFundingRequests =
                new Map<String, List<lwcBudgetDetailController.BudgetCalculationsDetail>>{
                        'Paid' => new List<lwcBudgetDetailController.BudgetCalculationsDetail>(),
                        'Approved' => new List<lwcBudgetDetailController.BudgetCalculationsDetail>(),
                        'Invited' => new List<lwcBudgetDetailController.BudgetCalculationsDetail>()
                };

        List<String> portfolioStatuses = new List<String>{'Invited', 'In Process', 'Submitted', 'Decision', 'Pending'};

        List<Budget_Scenario__c> selectedBudget = [SELECT Id, Portfolio__c, Fiscal_Year__c, Name, Amount__c FROM Budget_Scenario__c WHERE Id =: budgetId];
        if (selectedBudget.isEmpty()) {
            return null;
        }
        List<Funding_Request__c> relatedFundingRequests = [
                SELECT Id, Approved_Amount__c, Grant_Request_Amount__c, Project_Title__c, Name, Stage__c, (SELECT Id, Amount__c, Name FROM Payments__r)
                FROM Funding_Request__c
                WHERE Portfolio__c =: selectedBudget[0].Portfolio__c
                AND Fiscal_Year__c =: selectedBudget[0].Fiscal_Year__c
                ];
        Decimal paid = 0;
        Decimal invited = 0;
        Decimal approved = 0;
        Decimal planning = 0;

        for (Funding_Request__c request: relatedFundingRequests) {
            if (request.Stage__c == 'Approved' && request.Payments__r.size() == 0) {
                BudgetCalculationsDetail currentBudget = new BudgetCalculationsDetail(request.Name, request.Approved_Amount__c, request.Project_Title__c, request.Id);
                List<BudgetCalculationsDetail> currentFundingsByType =  paymentTypeWithFundingRequests.get('Approved');
                currentFundingsByType.add(currentBudget);
                paymentTypeWithFundingRequests.put('Approved', currentFundingsByType);
                approved += request.Approved_Amount__c == null ? 0 : request.Approved_Amount__c;
            }
            if (request.Stage__c == 'Approved' && request.Payments__r.size() > 0) {
                Decimal totalAmountForCurrentRequest = 0;
                List<BudgetCalculationsDetail> particularPayments = new List<BudgetCalculationsDetail>();
                for (Payment__c payment: request.Payments__r) {
                    totalAmountForCurrentRequest += payment.Amount__c;
                    BudgetCalculationsDetail currentBudget = new BudgetCalculationsDetail(payment.Name, payment.Amount__c, '', payment.Id);
                    particularPayments.add(currentBudget);
                }
                BudgetCalculationsDetail currentBudget = new BudgetCalculationsDetail(request.Name, totalAmountForCurrentRequest, request.Project_Title__c, particularPayments, request.Id);
                List<BudgetCalculationsDetail> currentBudgetDetailsList = paymentTypeWithFundingRequests.get('Paid');
                currentBudgetDetailsList.add(currentBudget);
                paymentTypeWithFundingRequests.put('Paid', currentBudgetDetailsList);
                paid += totalAmountForCurrentRequest == null ? 0 : totalAmountForCurrentRequest;
                //paidRequests.add(request);
            }
            if (portfolioStatuses.contains(request.Stage__c)) {
                BudgetCalculationsDetail currentBudget = new BudgetCalculationsDetail(request.Name, request.Grant_Request_Amount__c, request.Project_Title__c, request.Id);
                System.debug('Approved ' + request.Approved_Amount__c);
                paymentTypeWithFundingRequests.get('Invited').add(currentBudget);
                invited += request.Grant_Request_Amount__c != null ? request.Grant_Request_Amount__c : 0;
                //invitedRequests.add(request);
            }
        }

        List<BudgetCalculationsDetail> fundingsByType = new List<BudgetCalculationsDetail>();
        fundingsByType.add(new BudgetCalculationsDetail('Paid', paid, '', paymentTypeWithFundingRequests.get('Paid'), '/lightning/r/' + selectedBudget[0].Portfolio__c + '/related/Funding_Responses__r/view'));
        fundingsByType.add(new BudgetCalculationsDetail('Approved', approved, '', paymentTypeWithFundingRequests.get('Approved'), '/lightning/r/' + selectedBudget[0].Portfolio__c + '/related/Funding_Responses__r/view'));
        fundingsByType.add(new BudgetCalculationsDetail('Invited', invited, '', paymentTypeWithFundingRequests.get('Invited'), '/lightning/r/' + selectedBudget[0].Portfolio__c + '/related/Funding_Responses__r/view'));
        
        //AD Edited
        // if(selectedBudget!=null && !selectedBudget.isEmpty()){
        //     List<AggregateResult> listAggResRec = [Select sum(Amount__c) planningDollarsAggAmt
        //     FROM Planning_Dollars__c
        //     WHERE Budget_Scenario__c=:selectedBudget[0].Id
        //     ];

        //     if(listAggResRec!=null && !listAggResRec.isEmpty()){
        //         planning = (Decimal)listAggResRec[0].get('planningDollarsAggAmt');
        //     }
        // }
        

        BudgetRecordDetail finalDetailCalculations = new BudgetRecordDetail(selectedBudget[0], (paid + approved + invited), fundingsByType);
        return finalDetailCalculations;
    }

    public class BudgetRecordDetail {

        public BudgetRecordDetail(Budget_Scenario__c budget, Decimal sumOfTypes, List<BudgetCalculationsDetail> calculations) {
            Decimal planning = 0;
            planning = lwcPlanningBudgetController.calculateSumPlanning(budget.Id);
            this.budgetName = budget.Name;
            this.budgetAmount = budget.Amount__c == null ? '0': String.valueOf(budget.Amount__c);
            this.planning = String.valueOf(lwcPlanningBudgetController.calculateSumPlanning(budget.Id));
            this.remaining = String.valueOf(budget.Amount__c - sumOfTypes - planning);
            this.projected = String.valueOf(sumOfTypes);
            this.calculationsDetails = calculations;
        }

        private String divideNumber(String inputNumber) {
            inputNumber = inputNumber.substringAfter('.');
            return inputNumber;
        }

        @AuraEnabled
        public String budgetName;

        @AuraEnabled
        public String budgetAmount;

        @AuraEnabled
        public String remaining;

        @AuraEnabled
        public String planning;

        @AuraEnabled
        public String projected;

        @AuraEnabled
        public List<BudgetCalculationsDetail> calculationsDetails;
    }

    public class BudgetCalculationsDetail {

        public BudgetCalculationsDetail(String name, Decimal amount, String title, String link) {
            this.typePaid = name;
            this.amount = amount == null ? 0 : amount;
            this.projectTitle = title;
            this.link = URL.getSalesforceBaseUrl().toExternalForm() + '/' + link;
        }

        public BudgetCalculationsDetail(String name, Decimal amount, String title, List<BudgetCalculationsDetail> children, String link) {
            this.typePaid = name;
            this.amount = amount == null ? 0 : amount;
            this.projectTitle = title;
            this.childRecords = children;
            this.link = URL.getSalesforceBaseUrl().toExternalForm() + '/' + link;
        }

        @AuraEnabled
        public String typePaid;

        @AuraEnabled
        public Decimal amount;

        @AuraEnabled
        public String projectTitle;

        @AuraEnabled
        public String link;

        @AuraEnabled
        public List<BudgetCalculationsDetail> childRecords;

    }
}