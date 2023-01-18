({
    setAdminId : function(component, event, helper) {
        return new Promise(function(resolve,reject){
            var adminId = '';
            var url = window.location.search;
            if(url.includes('adminId')){
                const urlParams = new URLSearchParams(url);
                adminId = urlParams.get('adminId');
                component.set('v.adminId', adminId);
                
        	}
            resolve(adminId);
        });
    },
    returnFundingOppsV2 : function(component, event, helper) {
        var action = component.get('c.getFundingOpportunities');
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                var returnValue = response.getReturnValue();
                if(returnValue!=null && Array.isArray(returnValue) && returnValue.length>0){
                    component.set('v.listFundingOpps',returnValue);
                    returnValue[0]['selected'] = true; // set the first value to be selected
                    component.find('selectedFundOppId').set('v.value',returnValue[0].Id);
                    if('Funding_Responses__r' in returnValue[0]){
                        var listFundingReq = returnValue[0]['Funding_Responses__r'];
                        if(listFundingReq!=null && Array.isArray(listFundingReq) && listFundingReq.length>0){
                            var fundReqStage = listFundingReq[0].Stage__c;
                            console.log('fundReqStage----'+fundReqStage);
                            if(fundReqStage!=null && fundReqStage!=''){
                                //If funding req stage is invited then land on the funding opp tab and then load the flow
                                if(fundReqStage=='Invited'){
                                    component.set('v.selectedNavName', 'fundingOpportunity');
                                    component.set('v.selectedNavItem', 'fundingOpportunity');
                                    this.handleVerticalNavigationSelect(component, event, helper);
                                    this.flowsForFundingOpp(component, event, helper, returnValue[0].Id);
                                }
                                //If funding req stage is anything other than invited then land on the funding req tab and then load the flow
                                else{
                                    component.set('v.selectedNavName', 'fundingRequest');
                                    this.handleVerticalNavigationSelect(component, event, helper);
                                }
                            }
                        }
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    
	returnFundingOpps : function(component, event, helper) {
        var fid = '';
        var url = window.location.search;
        if(url.includes('fid')){
            const urlParams = new URLSearchParams(url);
            fid = urlParams.get('fid')
        }
        
        console.log('fid---'+fid);
		var action = component.get('c.getFundingOpportunities');
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                var returnValue = response.getReturnValue();
                component.set('v.listFundingOpps',returnValue);
                if(returnValue!=null && Array.isArray(returnValue) && returnValue.length>0){
                    console.log('returnVal--' +JSON.stringify(returnValue));
                    for(var fndOpp of returnValue){
                        if(fid!=null && fid!='' && fndOpp.Id == fid){
                            fndOpp['selected'] = true;
                            var fundReqStage = '';
                            if('Funding_Responses__r' in fndOpp){
                                var listFundingReq = fndOpp['Funding_Responses__r'];
                                if(listFundingReq!=null && Array.isArray(listFundingReq) && listFundingReq.length>0){
                                	fundReqStage = listFundingReq[0].Stage__c;
                                }
                            }
                            component.find('selectedFundOppId').set('v.value',fndOpp.Id);
                            console.log('fundReqStage--'+fundReqStage);
                            if(fundReqStage!=null && fundReqStage=='Invited'){
                                component.set('v.selectedNavName', 'fundingOpportunity');
                            	//component.set('v.selectedNavItem', 'fundingOpportunity');
                            	this.flowsForFundingOpp(component, event, helper, fndOpp.Id);
                            }
                            if(fundReqStage!=null && fundReqStage!='' && fundReqStage!='Invited'){
                                component.set('v.selectedNavName', 'fundingRequest');
                                this.handleVerticalNavigationSelect(component, event, helper);
                            }
                            
                            if(url.includes('nav')) {
                                const urlNav = new URLSearchParams(url);
                                var nav = urlNav.get('nav');
                                console.log('NAV----'+nav);
                                if(nav != null && nav != '') {
                                    if(nav=='fr'){
                                        component.set('v.selectedNavName', 'fundingRequest');
                                        this.handleVerticalNavigationSelect(component, event, helper);
                                    }
                                    if(nav=='bu'){
                                        component.set('v.selectedNavName', 'budget');
                                        this.handleVerticalNavigationSelect(component, event, helper);
                                    }
                                    if(nav=='cnt'){
                                        component.set('v.selectedNavName', 'relatedContacts');
                                        this.handleVerticalNavigationSelect(component, event, helper);
                                    } 
                                    if(nav=='dtl'){
                                        component.set('v.selectedNavName', 'details');
                                        this.handleVerticalNavigationSelect(component, event, helper);
                                    }  
                                    if(nav=='org'){
                                        component.set('v.selectedNavName', 'background');
                                        this.handleVerticalNavigationSelect(component, event, helper);
                                    }                                 
                                }
                            }
                        }
                    }
                }
            }
        });
        $A.enqueueAction(action);
	},
        
    returnFundingRequests : function(component, event, helper) {
        var selectedFundOppId = component.find('selectedFundOppId').get('v.value');
        if(selectedFundOppId!=null && selectedFundOppId!=''){
            var action = component.get('c.getFundingRequests');
            action.setParams({selectedFundOppId:selectedFundOppId});
            action.setCallback(this,function(response){
                if(response.getState()==='SUCCESS'){
                    var returnValue = response.getReturnValue();
                    if(returnValue!=null && Array.isArray(returnValue) && returnValue.length>0){
                        component.set('v.listFundingReqs',returnValue);
                        component.set('v.fundingRequestsReturned',true);
                    }
                }
				        
            });
            $A.enqueueAction(action);
        }
    },
    
    handleVerticalNavigationSelect : function(component, event, helper) {
        var selectedNavigationItem = '';
        var selectedFundOppId = component.find('selectedFundOppId').get('v.value');
        
        console.log('selectedFundOppId---'+selectedFundOppId);
        var eventParams = event.getParams();
        
        if('name' in eventParams){
            selectedNavigationItem = eventParams['name'];
        }
        console.log('event Params---'+JSON.stringify(eventParams));
        console.log('selectedNavigationItem---'+selectedNavigationItem);
        if(selectedNavigationItem!=null && selectedNavigationItem!='' && selectedFundOppId!=null && selectedFundOppId!=''){
            component.set('v.selectedNavItem',selectedNavigationItem);
            if(selectedNavigationItem=='fundingOpportunity'){
                this.flowsForFundingOpp(component, event, helper,selectedFundOppId);
            }
            if(selectedNavigationItem=='fundingRequest'){
                this.flowsForFundingRequest(component, event, helper,selectedFundOppId);
            }
            if(selectedNavigationItem=='budget'){
                this.flowsForBudget(component, event, helper,selectedFundOppId);
            }
            if(selectedNavigationItem=='relatedContacts'){
                this.flowsForRelatedContacts(component, event, helper,selectedFundOppId);
            }
            if(selectedNavigationItem=='details'){
                this.flowsForOrgDetails(component, event, helper,selectedFundOppId);
            }
            if(selectedNavigationItem=='background'){
                this.flowsForOrgBackground(component, event, helper,selectedFundOppId);
            }
            if(selectedNavigationItem=='review'){
                this.flowsForReview(component, event, helper,selectedFundOppId);
            } 
            if(selectedNavigationOrgActivities=='orgActivities'){
                this.flowsForOrgActivities(component, event, helper,selectedFundOppId);
            }             
        }
        if(selectedFundOppId==null || selectedFundOppId==''){
            this.showToastParams(component, event, helper);
        }
    },
    
    flowsForFundingOpp : function(component, event, helper, selectedFundOppId) {
        console.log('I AM HERE');
        var flow = component.find("fundingOpportunityId");
        var inputVars = [
            {
                name:'fo_id',
                type:'String',
                value:selectedFundOppId
            }
        ];
        flow.startFlow($A.get('$Label.c.FundingOpportunity_Flow_Name'),inputVars);
    },
    
    flowsForFundingRequest : function(component, event, helper, selectedFundOppId) {
        var flow = component.find("fundingRequestId");
        var inputVars = [
            {
                name:'fo_id',
                type:'String',
                value:selectedFundOppId
            }
        ];
        flow.startFlow($A.get('$Label.c.FundingRequest_Flow_Name'),inputVars);
    },
    
    flowsForBudget : function(component, event, helper, selectedFundOppId) {
        var flow = component.find("budgetId");
        var adminId = component.get('v.adminId');
        var inputVars = [
            {
                name:'fo_id',
                type:'String',
                value:selectedFundOppId
            },
            {
                name:'admin',
                type:'String',
                value:adminId
            }
        ];
        flow.startFlow($A.get('$Label.c.Budget_FlowName1'),inputVars);
    },
    
    flowsForRelatedContacts : function(component, event, helper, selectedFundOppId) {
        var flow = component.find("relatedContactsId");
        var inputVars = [
            {
                name:'fo_id',
                type:'String',
                value:selectedFundOppId
            }
        ];
        flow.startFlow($A.get('$Label.c.RelatedContacts_Flow_Name'),inputVars);
    },
    
    
    flowsForOrgDetails : function(component, event, helper, selectedFundOppId) {
        var flow = component.find("detailsId");
        var inputVars = [
            {
                name:'fo_id',
                type:'String',
                value:selectedFundOppId
            }
        ];
        flow.startFlow($A.get('$Label.c.OrgDetails_Flow_Name'),inputVars);
    },
    flowsForOrgBackground : function(component, event, helper, selectedFundOppId) {
        var flow = component.find("backgroundId");
        var inputVars = [
            {
                name:'fo_id',
                type:'String',
                value:selectedFundOppId
            }
        ];
        flow.startFlow($A.get('$Label.c.OrgBackground_Flow_Name'),inputVars);
    },
    flowsForReview : function(component, event, helper, selectedFundOppId) {
        var flow = component.find("reviewId");
        var inputVars = [
            {
                name:'fo_id',
                type:'String',
                value:selectedFundOppId
            }
        ];
        flow.startFlow($A.get('$Label.c.Submit_Funding_Request_Flow_Name'),inputVars);
    },

    flowsForOrgActivities : function(component, event, helper, selectedFundOppId) {
        var flow = component.find("activitiesId");
        var inputVars = [
            {
                name:'fo_id',
                type:'String',
                value:selectedFundOppId
            }
        ];
        flow.startFlow($A.get('$Label.c.Activities_and_Pops_by_Org'),inputVars);
    },    
    showToastParams : function(component,event,helper){
        var toastPrm = $A.get('e.force:showToast');
        toastPrm.setParams({
            type:'error',
            message:'Please select a funding opportunity',
            mode:'dismissable',
            title:'ERROR'
        });
        toastPrm.fire();
    }
})