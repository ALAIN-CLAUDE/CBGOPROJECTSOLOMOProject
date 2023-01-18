({
	fetchReviewAssignments : function(component, event, helper) {
        helper.fetchPendingReviewAssignmentColumns(component, event, helper);
        helper.fetchCompletedReviewAssignmentColumns(component, event, helper);
		helper.fetchUser(component, event, helper);
        helper.fetchSubmittedReviewAssignments(component, event, helper);
        helper.fetchPendingReviewAssignments(component, event, helper);
	},
    
    handleRowAction : function(component, event, helper) {
        helper.handleRowAction(component, event, helper);
    }
})