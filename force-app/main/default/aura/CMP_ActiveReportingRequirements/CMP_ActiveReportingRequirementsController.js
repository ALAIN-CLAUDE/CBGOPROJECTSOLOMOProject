({
	fetchActiveReportingReqs : function(component, event, helper) {
        helper.constructActiveReportingReqsColumns(component, event, helper);
		helper.fetchActiveReportingReqs(component, event, helper);
	},
    
    handleRowAction : function(component, event, helper) {
        helper.handleRowAction(component, event, helper);
    }
})