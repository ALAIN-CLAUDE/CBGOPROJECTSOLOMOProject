({
	fetchSPAs : function(component, event, helper) {
        helper.fetchPortfolios(component,event,helper);
        helper.fetchPortfolioColumns(component,event,helper);
        helper.fetchOrgTypeColumns(component,event,helper);
        helper.fetchOrgTypes(component,event,helper);
        helper.fetchSPAColumns(component,event,helper);
        helper.fetchAccountColumns(component,event,helper);
		helper.fetchSPAs(component,event,helper);
	},
    
    spaSelected : function(component, event, helper) {
        helper.spaSelected(component,event,helper);
    },
    
    portfolioSelected : function(component, event, helper) {
        helper.portfolioSelected(component,event,helper);
    },
    
    orgTypeSelected : function(component, event, helper) {
        helper.orgTypeSelected(component,event,helper);
    },
    
    accountSelected : function(component, event, helper) {
        helper.accountSelected(component,event,helper);
    },
    
    createFundingRequests : function(component, event, helper) {
        helper.createFundingRequests(component,event,helper);
    },
    
    clearValues : function(component, event, helper) {
        helper.fetchSPAs(component,event,helper);
    },
})