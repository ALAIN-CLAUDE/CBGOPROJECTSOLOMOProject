/**
 * Created by Dzianis_Liatkouski on 14.09.22.
 */
public with sharing class lwcPlanningBudgetController {

    public static Decimal calculateSumPlanning(String budgetId) {
        //Update planning parents with sum values of children
        calculateParentPlanningRecordValues(budgetId);
        Decimal sumPlanning = 0;
        List<AggregateResult> planningsAmount = [
                SELECT SUM(Amount__c) sm FROM Planning_Dollars__c
                WHERE Budget_Scenario__c =: budgetId
                and Planning_Detail__c=null
                and Amount__c!=null
        ];
        if (!planningsAmount.isEmpty()) {
            sumPlanning = (Decimal)planningsAmount[0].get('sm');
            sumPlanning = sumPlanning != null ? sumPlanning.intValue() : 0;
        }
        return sumPlanning;
    }

    @AuraEnabled
    public static void calculateParentPlanningRecordValues(string budgetId){
        Map<Id,Planning_Dollars__c> mapParentPlanningDollarRecs = new Map<Id,Planning_Dollars__c>();
        List<AggregateResult> listAggResRecsChildPlanningAmounts = [ SELECT SUM(Amount__c) childPlanningAmounts, Planning_Detail__c parentPlanningId  
        FROM Planning_Dollars__c
        WHERE Budget_Scenario__c =: budgetId
        AND Planning_Detail__c!=null
        AND Amount__c!=null
        GROUP By Planning_Detail__c
        LIMIT 2000
        ];
        if(listAggResRecsChildPlanningAmounts!=null && !listAggResRecsChildPlanningAmounts.isEmpty()){
            for(AggregateResult aggResRec : listAggResRecsChildPlanningAmounts){
                if(aggResRec.get('parentPlanningId')!=null && aggResRec.get('childPlanningAmounts')!=null){
                    Planning_Dollars__c parentPlanningDollarRec = new Planning_Dollars__c();
                    parentPlanningDollarRec.Id = (Id)aggResRec.get('parentPlanningId');
                    parentPlanningDollarRec.Amount__c = (Decimal)aggResRec.get('childPlanningAmounts');
                    mapParentPlanningDollarRecs.put((Id)aggResRec.get('parentPlanningId'), parentPlanningDollarRec);
                }
            }
        }

        if(mapParentPlanningDollarRecs!=null && !mapParentPlanningDollarRecs.isEmpty()){
            List<Database.SaveResult> listSaveResults = Database.update(mapParentPlanningDollarRecs.values());
        }
    }

    public static Map<String, Decimal> calculatePlanningForBudgets(List<Budget_Scenario__c> budgets) {
        Map<String, Decimal> resultPlanningMap = new Map<String, Decimal>();
        List<String> budgetIds = new List<String>();
        for (Budget_Scenario__c budget: budgets) {
            budgetIds.add(budget.Id);
        }

        List<Planning_Dollars__c> plannings = [
                SELECT Id, Amount__c, Budget_Scenario__c
                FROM Planning_Dollars__c
                WHERE Budget_Scenario__c IN: budgetIds
                AND Planning_Detail__c=:null
                AND Amount__c!=null
        ];
        for (Planning_Dollars__c planningRecord : plannings) {
            if (resultPlanningMap.containsKey(planningRecord.Budget_Scenario__c)) {
                Decimal currentAmount = resultPlanningMap.get(planningRecord.Budget_Scenario__c) + planningRecord.Amount__c;
                resultPlanningMap.put(planningRecord.Budget_Scenario__c, currentAmount);
            } else {
                resultPlanningMap.put(planningRecord.Budget_Scenario__c, planningRecord.Amount__c);
            }
        }

        for (String budgetId : budgetIds) {
            if (!resultPlanningMap.containsKey(budgetId)) {
                resultPlanningMap.put(budgetId, 0);
            }
        }

        return resultPlanningMap;
    }


    @AuraEnabled
    public static List<lwcPlanningBudgetController.PlanningWrapper> getPlanningData(String budgetId) {

        //Update planning parents with sum values of children
        calculateParentPlanningRecordValues(budgetId);

        List<lwcPlanningBudgetController.PlanningWrapper> finalPlannings = new List<lwcPlanningBudgetController.PlanningWrapper>();
        List<Planning_Dollars__c> plannedByBudget = [
                SELECT Id, Amount__c, Planning_Detail__c, Notes__c, Budget_Scenario__c, Name
                FROM Planning_Dollars__c
                WHERE Budget_Scenario__c =: budgetId
                AND Amount__c!=null
        ];

        Map<String, List<PlanningWrapper>> parentPlanningWithChild = new Map<String, List<PlanningWrapper>>();
        List<Planning_Dollars__c> parentPlannings = new List<Planning_Dollars__c>();

        for (Planning_Dollars__c planning : plannedByBudget) {
            System.debug('1111111' + planning.Planning_Detail__c);
            System.debug('1111111 ' + (planning.Planning_Detail__c != null && String.isNotBlank(planning.Planning_Detail__c)));
            if (planning.Planning_Detail__c != null && String.isNotBlank(planning.Planning_Detail__c)) {

                if (parentPlanningWithChild.containsKey(planning.Planning_Detail__c)) {
                    List<PlanningWrapper> currentChild = parentPlanningWithChild.get(planning.Planning_Detail__c);
                    System.debug(currentChild.size());
                    currentChild.add(new lwcPlanningBudgetController.PlanningWrapper(planning));
                    parentPlanningWithChild.put(planning.Planning_Detail__c, currentChild);
                } else {
                    parentPlanningWithChild.put(planning.Planning_Detail__c,
                            new List<lwcPlanningBudgetController.PlanningWrapper> {new lwcPlanningBudgetController.PlanningWrapper(planning)});
                }

            } else {
                parentPlannings.add(planning);
            }
        }

        for (Planning_Dollars__c parentPlanning: parentPlannings) {
            PlanningWrapper wrappedParent;
            if (parentPlanningWithChild.containsKey(parentPlanning.Id)) {
                wrappedParent = new PlanningWrapper(parentPlanning, parentPlanningWithChild.get(parentPlanning.Id));
            } else {
                wrappedParent = new PlanningWrapper(parentPlanning);
            }
            finalPlannings.add(wrappedParent);
        }

        return finalPlannings;
    }


    // AD Created
    @AuraEnabled
    public static string deletePlanningDollarsAPX(string planningDollarsRecId){
        string deleteResults = '';
        if(planningDollarsRecId!=null && planningDollarsRecId!=''){
            List<Planning_Dollars__c> listDeletePlanningDollars = [Select Id
            FROM Planning_Dollars__c
            WHERE Id=:planningDollarsRecId
            ];
            if(listDeletePlanningDollars!=null && !listDeletePlanningDollars.isEmpty()){
                List<Database.DeleteResult> listDeleteResults = Database.delete(listDeletePlanningDollars);
                return deleteResults = JSON.serialize(listDeleteResults);
            }
        }
        return deleteResults;
    }

    public class PlanningWrapper {

        public PlanningWrapper(Planning_Dollars__c planning) {
            projectName = planning.Name;
            projectAmount = planning.Amount__c.intValue();
            projectNotes = planning.Notes__c;
            projectLink = '/lightning/r/Planning_Dollars__c/'  + planning.Id + '/view';
            isAdmin = lwcBudgetController.getIsAdminUser();
            isParent = planning.Planning_Detail__c == null || String.isBlank(planning.Planning_Detail__c);
            planningDollarRecId = planning.Id;
        }

        public PlanningWrapper(Planning_Dollars__c planning, List<PlanningWrapper> childRecords) {
            projectName = planning.Name;
            projectAmount = planning.Amount__c.intValue();
            projectNotes = planning.Notes__c;
            projectLink = '/lightning/r/Planning_Dollars__c/'  + planning.Id + '/view';
            isAdmin = lwcBudgetController.getIsAdminUser();
            isParent = true;
            this.child = childRecords;
            planningDollarRecId = planning.Id;
        }

        @AuraEnabled
        public String planningDollarRecId;

        @AuraEnabled
        public String projectName;

        @AuraEnabled
        public Decimal projectAmount;

        @AuraEnabled
        public String projectNotes;

        @AuraEnabled
        public String projectLink;

        @AuraEnabled
        public List<PlanningWrapper> child;

        @AuraEnabled
        public Boolean isAdmin;

        @AuraEnabled
        public Boolean isParent;
    }
}