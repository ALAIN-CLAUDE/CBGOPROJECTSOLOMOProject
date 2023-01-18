/**
 * Created by Dzianis_Liatkouski on 11.08.22.
 */

public with sharing class lwcBudgetWrapper {

    private Map<Id, Decimal> sumOfApprovedById;
    private Map<Id, Decimal> sumOfInvitedById;

    public lwcBudgetWrapper() {
    }

    public lwcBudgetWrapper(Id portfolioId, Budget_Scenario__c budget, lwcCalculationHelper amounts, List<Budget_Scenario__c> childBudgets, Map<String, Decimal> budgetWithPlanning) {
        this.name = budget.Name;
        this.budget = String.valueOf(budget.Amount__c);
        if (amounts != null) {
            this.paid = (amounts.paid != null ? String.valueOf(amounts.paid) : '0').substringBefore('.');
            this.invited = (amounts.invited != null ? String.valueOf(amounts.invited) : '0').substringBefore('.');
            this.approved = (amounts.approved != null ? String.valueOf(amounts.approved) : '0').substringBefore('.');
        } else {
            this.paid = '0';
            this.invited = '0';
            this.approved = '0';
        }
        this.planning = String.valueOf(budgetWithPlanning.get(budget.Id) != null ? budgetWithPlanning.get(budget.Id).intValue() : 0);


        if (this.paid != null && budget.Amount__c != null ) {
            this.remaining = String.valueOf(budget.Amount__c -  Decimal.valueOf(this.invited) -  Decimal.valueOf(this.approved) -  Decimal.valueOf(this.planning) - Decimal.valueOf(this.paid));
        }
        this.fy = budget.Fiscal_Year__c;
        this.isParent = true;
        this.portfolioId = portfolioId;
        this.parentBudgetId = budget.Id;
        this.currentParentBudgetId = String.isNotBlank(budget.CBGO_Budget__c) ? budget.CBGO_Budget__c : null;
        this.isAdmin = lwcBudgetController.getIsAdminUser();

        if (childBudgets != null && !childBudgets.isEmpty()) {
            this.numberOfChildes = childBudgets.size();

            List<lwcBudgetWrapper> childBudgetsList = new List<lwcBudgetWrapper>();
            for (Budget_Scenario__c childBudget : childBudgets) {
                lwcBudgetWrapper wrappedBudget = new lwcBudgetWrapper(portfolioId, childBudget,
                        lwcCalculationHelper.calculateAmounts(new Map<Id, Set<String>>{childBudget.Portfolio__c => new Set<String> {childBudget.Fiscal_Year__c}}).get(childBudget.Portfolio__c + childBudget.Fiscal_Year__c),
                        new List<Budget_Scenario__c>(), budgetWithPlanning);
                wrappedBudget.isParent = false;
                childBudgetsList.add(wrappedBudget);
            }
            this.children = new List<lwcBudgetWrapper>();
            this.children.addAll(childBudgetsList);
        }
    }

    public List<lwcBudgetWrapper> getWrappedBudget(List<Budget_Scenario__c> selectedBudgets) {

        Map<Id, List<Budget_Scenario__c>> portfolioByBudget =  getPortfolioIds(selectedBudgets);
        Map<Id, List<Budget_Scenario__c>> childByParentBudgetMap = getChildBudgets(selectedBudgets);
        Map<String, Decimal> budgetWithProjected = lwcPlanningBudgetController.calculatePlanningForBudgets(selectedBudgets);
        system.debug('budgetWithProjected = ' + budgetWithProjected);
        Map<String, lwcCalculationHelper> calculatedAmounts = lwcCalculationHelper.calculateAmounts(getPortfolioWithFY(portfolioByBudget));
        return wrapBudget(portfolioByBudget, calculatedAmounts, childByParentBudgetMap, budgetWithProjected);
    }

    private Map<Id, List<Budget_Scenario__c>> getChildBudgets(List<Budget_Scenario__c> selectedBudgets) {
        Map<Id, List<Budget_Scenario__c>> parentBudgetWithChild = new Map<Id, List<Budget_Scenario__c>>();

        for (Budget_Scenario__c budget : selectedBudgets) {
            if (String.isNotBlank(budget.CBGO_Budget__c)) {
                if (parentBudgetWithChild.containsKey(budget.CBGO_Budget__c)) {
                    List<Budget_Scenario__c> currentChildBudgets = parentBudgetWithChild.get(budget.CBGO_Budget__c);
                    currentChildBudgets.add(budget);
                    parentBudgetWithChild.put(budget.CBGO_Budget__c, currentChildBudgets);
                } else {
                    parentBudgetWithChild.put(budget.CBGO_Budget__c, new List<Budget_Scenario__c> {budget});
                }
            }
        }
        return parentBudgetWithChild;
    }

    private  Map<Id, Set<String>> getPortfolioWithFY( Map<Id, List<Budget_Scenario__c>> portfolioByBudget) {
        Map<Id, Set<String>> portfolioWithFY = new Map<Id, Set<String>>();
        for (Id portfolioId : portfolioByBudget.keySet()) {
            for (Budget_Scenario__c budget : portfolioByBudget.get(portfolioId)) {
                if (portfolioWithFY.containsKey(portfolioId)) {
                    Set<String> currentFYs =  portfolioWithFY.get(portfolioId);
                    currentFYs.add(budget.Fiscal_Year__c);
                    portfolioWithFY.put(portfolioId,currentFYs);
                } else {
                    portfolioWithFY.put(portfolioId, new Set<String> {budget.Fiscal_Year__c});
                }
            }
        }

        return portfolioWithFY;

    }

    private List<lwcBudgetWrapper> wrapBudget(Map<Id, List<Budget_Scenario__c>> portfolioByBudget,
            Map<String, lwcCalculationHelper> portfolioWithPaidSum,
            Map<Id, List<Budget_Scenario__c>> childByParentBudgetMap, Map<String, Decimal> budgetWithPlanning) {
        List<lwcBudgetWrapper> wrappedBudgets = new List<lwcBudgetWrapper>();
        Decimal totalBudget = 0;
        Decimal totalPaid = 0;
        Decimal totalPlanning = 0;
        Decimal totalRemaining = 0;
        Decimal totalApproved = 0;
        Decimal totalInvited = 0;
        for (Id portfolioId : portfolioByBudget.keySet()) {
            for (Budget_Scenario__c budget1 : portfolioByBudget.get(portfolioId)) {
                if (String.isBlank(budget1.CBGO_Budget__c)) {
                    System.debug(portfolioId + budget1.Fiscal_Year__c);
                    System.debug( portfolioWithPaidSum.get(portfolioId + budget1.Fiscal_Year__c));
                    lwcBudgetWrapper wrappedBudget =
                            new lwcBudgetWrapper(portfolioId, budget1, portfolioWithPaidSum.get(portfolioId + budget1.Fiscal_Year__c),
                                    childByParentBudgetMap.get(budget1.Id), budgetWithPlanning);
                    //collectTotal(wrappedBudget, totalBudget, totalPaid, totalPlanning, totalRemaining, totalApproved, totalInvited);
                    totalBudget += wrappedBudget.budget != null ? Decimal.valueOf(wrappedBudget.budget) : 0;
                    totalPaid += wrappedBudget.paid != null ? Decimal.valueOf(wrappedBudget.paid) : 0;
                    totalPlanning += wrappedBudget.planning != null ? Decimal.valueOf(wrappedBudget.planning) : 0;
                    totalRemaining += wrappedBudget.remaining != null ? Decimal.valueOf(wrappedBudget.remaining) : 0;
                    totalApproved += wrappedBudget.approved != null ? Decimal.valueOf(wrappedBudget.approved) : 0;
                    totalInvited += wrappedBudget.invited != null ? Decimal.valueOf(wrappedBudget.invited) : 0;

                    if (wrappedBudget.children != null && wrappedBudget.children.size() > 0) {
                        for (lwcBudgetWrapper childWrapper : wrappedBudget.children) {
                            totalBudget += childWrapper.budget != null ? Decimal.valueOf(childWrapper.budget) : 0;
                            totalPaid += childWrapper.paid != null ? Decimal.valueOf(childWrapper.paid) : 0;
                            totalPlanning += childWrapper.planning != null ? Decimal.valueOf(childWrapper.planning) : 0;
                            totalRemaining += childWrapper.remaining != null ? Decimal.valueOf(childWrapper.remaining) : 0;
                            totalApproved += childWrapper.approved != null ? Decimal.valueOf(childWrapper.approved) : 0;
                            totalInvited += childWrapper.invited != null ? Decimal.valueOf(childWrapper.invited) : 0;
                        }
                    }
                    wrappedBudgets.add(wrappedBudget);
                }
            }
        }
        //calculateTotalForChild(wrappedBudgets, totalBudget, totalPaid, totalPlanning, totalRemaining, totalApproved, totalInvited);
        wrappedBudgets.add(setTotal(totalBudget, totalPaid, totalPlanning, totalRemaining, totalApproved, totalInvited));

        return wrappedBudgets;
    }

    /*private void calculateTotalForChild(List<BudgetWrapper> wrappedBudget, Decimal totalBudget, Decimal totalPaid, Decimal totalPlanning,
            Decimal totalRemaining, Decimal totalApproved, Decimal totalInvited) {

        for (BudgetWrapper parentWrapper: wrappedBudget) {
            if (parentWrapper.children != null && parentWrapper.children.size() > 0) {
                 for(BudgetWrapper childWrapper : parentWrapper.children) {
                     System.debug('In the child cLCULATION totalBudget ' + totalBudget);
                     System.debug('In the child cLCULATION totalPaid ' + totalPaid);
                     System.debug('In the child cLCULATION totalPlanning ' + totalPlanning);
                     System.debug('In the child cLCULATION totalRemaining ' + totalRemaining);
                     System.debug('In the child cLCULATION totalInvited ' + totalInvited);
                     collectTotal(childWrapper, totalBudget, totalPaid, totalPlanning, totalRemaining, totalApproved, totalInvited);
                 }
            }
        }

    }

    private void collectTotal(BudgetWrapper wrappedBudget, Decimal totalBudget, Decimal totalPaid, Decimal totalPlanning,
            Decimal totalRemaining, Decimal totalApproved, Decimal totalInvited) {
        totalBudget += wrappedBudget.budget != null ? Decimal.valueOf(wrappedBudget.budget) : 0;
        totalPaid += wrappedBudget.paid != null ? Decimal.valueOf(wrappedBudget.paid) : 0;
        totalPlanning += wrappedBudget.planning != null ? Decimal.valueOf(wrappedBudget.planning) : 0;
        totalRemaining += wrappedBudget.remaining != null ? Decimal.valueOf(wrappedBudget.remaining) : 0;
        totalApproved += wrappedBudget.approved != null ? Decimal.valueOf(wrappedBudget.approved) : 0;
        totalInvited += wrappedBudget.invited != null ? Decimal.valueOf(wrappedBudget.invited) : 0;
    }*/

    private lwcBudgetWrapper setTotal(Decimal totalBudget, Decimal totalPaid, Decimal totalPlanning,
            Decimal totalRemaining, Decimal totalApproved, Decimal totalInvited) {
        lwcBudgetWrapper totalBudgetWrapper = new lwcBudgetWrapper();
        totalBudgetWrapper.name = 'Total';
        totalBudgetWrapper.budget = String.valueOf(totalBudget);
        totalBudgetWrapper.paid =  String.valueOf(totalPaid);
        totalBudgetWrapper.planning =  String.valueOf(totalPlanning);
        totalBudgetWrapper.remaining = String.valueOf(totalRemaining);
        totalBudgetWrapper.invited = String.valueOf(totalInvited);
        totalBudgetWrapper.approved = String.valueOf(totalApproved);


        return totalBudgetWrapper;
    }

    private Map<Id, List<Budget_Scenario__c>> getPortfolioIds(List<Budget_Scenario__c> selectedBudgets) {
        Map<Id, List<Budget_Scenario__c>> filteredBudgetsByPortfolio = new Map<Id, List<Budget_Scenario__c>>();
        for (Budget_Scenario__c budgetByPortfolio: selectedBudgets) {
            if (filteredBudgetsByPortfolio.containsKey(budgetByPortfolio.Portfolio__c)) {
                List<Budget_Scenario__c> currentBudget = filteredBudgetsByPortfolio.get(budgetByPortfolio.Portfolio__c);
                currentBudget.add(budgetByPortfolio);
                filteredBudgetsByPortfolio.put(budgetByPortfolio.Portfolio__c, currentBudget);
            } else {
                filteredBudgetsByPortfolio.put(budgetByPortfolio.Portfolio__c, new List<Budget_Scenario__c> {budgetByPortfolio});
            }
        }
        return filteredBudgetsByPortfolio;
    }

    // private Map<Id, Decimal> getFundingRequestsByPortfolio(Map<Id, Set<String>> portfolioWithFY) {
    //     List<Funding_Request__c> requests = [
    //             SELECT Id, Approved_Amount__c, Grant_Amount__c, Portfolio__c, Fiscal_Year__c, Stage__c, (SELECT Id, Amount__c FROM Payments__r)
    //             FROM Funding_Request__c
    //             WHERE Portfolio__c IN: portfolioWithFY.keySet()
    //     ];

    //     sumOfApprovedById = new Map<Id, Decimal>();
    //     sumOfInvitedById = new Map<Id, Decimal>();
    //     List<String> portfolioStatuses = new List<String>{'Invited', 'In Process', 'Submitted', 'Decision', 'Pending'};
    //     Map<Id, Decimal> portfolioWithPaid = new Map<Id, Decimal>();
    //     for (Funding_Request__c request: requests) {
    //         if (portfolioWithFY.get(request.Portfolio__c).contains(request.Fiscal_Year__c)) {
    //             if (request.Stage__c == 'Approved' && request.Payments__r.size() > 0) {
    //                 for (Payment__c payment : request.Payments__r) {
    //                     Decimal currentAmount = payment.Amount__c == null ? 0 : payment.Amount__c;
    //                     if (portfolioWithPaid.containsKey(request.Portfolio__c)) {
    //                         portfolioWithPaid.put(request.Portfolio__c, portfolioWithPaid.get(request.Portfolio__c) + currentAmount);
    //                     } else {
    //                         portfolioWithPaid.put(request.Portfolio__c, currentAmount);
    //                     }
    //                 }
    //             } else if (request.Stage__c == 'Approved') {
    //                 Decimal currentApprovedAmount = request.Approved_Amount__c == null ? 0 : request.Approved_Amount__c;
    //                 if (sumOfApprovedById.containsKey(request.Portfolio__c)) {
    //                     sumOfApprovedById.put(request.Portfolio__c, portfolioWithPaid.get(request.Portfolio__c) + currentApprovedAmount);
    //                 } else {
    //                     sumOfApprovedById.put(request.Portfolio__c, currentApprovedAmount);
    //                 }
    //             } else if (portfolioStatuses.contains(request.Stage__c)) {
    //                 Decimal currentGrandAmount = request.Grant_Amount__c == null ? 0 : request.Grant_Amount__c;
    //                 if (sumOfInvitedById.containsKey(request.Portfolio__c)) {
    //                     sumOfInvitedById.put(request.Portfolio__c, portfolioWithPaid.get(request.Portfolio__c) + currentGrandAmount);
    //                 } else {
    //                     sumOfInvitedById.put(request.Portfolio__c, request.Grant_Amount__c);
    //                 }
    //             } else {
    //                 if (!portfolioWithPaid.containsKey(request.Portfolio__c)) {
    //                     portfolioWithPaid.put(request.Portfolio__c, 0);
    //                 }
    //                 if (!sumOfApprovedById.containsKey(request.Portfolio__c)) {
    //                     sumOfApprovedById.put(request.Portfolio__c, 0);
    //                 }
    //                 if (!sumOfInvitedById.containsKey(request.Portfolio__c)) {
    //                     sumOfInvitedById.put(request.Portfolio__c, 0);
    //                 }
    //             }
    //         }
    //     }
    //     return portfolioWithPaid;
    // }

    @AuraEnabled
    public String name;
    @AuraEnabled
    public String budget;
    @AuraEnabled
    public String planning;
    @AuraEnabled
    public String remaining;
    @AuraEnabled
    public String paid;
    @AuraEnabled
    public String approved;
    @AuraEnabled
    public String invited;
    @AuraEnabled
    public String fy;
    @AuraEnabled
    public String portfolioId;
    @AuraEnabled
    public String parentBudgetId;
    @AuraEnabled
    public String currentParentBudgetId;
    @AuraEnabled
    public Boolean isAdmin;
    @AuraEnabled
    public Integer numberOfChildes;
    @AuraEnabled
    public Boolean isParent;
    @AuraEnabled
    public List<lwcBudgetWrapper> children;
}