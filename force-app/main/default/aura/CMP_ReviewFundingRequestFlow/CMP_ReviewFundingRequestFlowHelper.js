({
	/*loadFlowComponentsV2 : function(component, event, helper) {
		var url = window.location.search;
        var fundingReqId = '';
        if(url!=null && url!=''){
            if(url.includes('fundingReqId')){
                const urlParams = new URLSearchParams(url);
                fundingReqId = urlParams.get('fundingReqId');
            }
        }
        
        if(fundingReqId!=null && fundingReqId!=''){
            var action = component.get('c.getReviewId');
            action.setParams({fundingReqId:fundingReqId});
            action.setCallback(this,function(response){
                if(response.getState()==='SUCCESS'){
                    var returnValue = response.getReturnValue();
                    if(returnValue!=null && returnValue!=''){
                        this.flowsForReviewFundingRequest(component, event, helper, returnValue);
                    }
                }
            });
            $A.enqueueAction(action);
        }
        
	},*/
    
    loadFlowComponents : function(component, event, helper) {
		var url = window.location.search;
        var reviewId = '';
        if(url!=null && url!=''){
            if(url.includes('reviewId')){
                const urlParams = new URLSearchParams(url);
                reviewId = urlParams.get('reviewId');
            }
        }
        
        if(reviewId!=null && reviewId!=''){
            this.flowsForReviewFundingRequest(component, event, helper, reviewId);
        }
        
	},
    
    flowsForReviewFundingRequest : function(component, event, helper, reviewId) {
        var flow = component.find("reviewFundingRequest");
        var inputVars = [
            {
                name:'reviewId',
                type:'String',
                value:reviewId
            }
        ];
        flow.startFlow($A.get('$Label.c.Review_Funding_Request_Flow_Name'),inputVars);
    },
})