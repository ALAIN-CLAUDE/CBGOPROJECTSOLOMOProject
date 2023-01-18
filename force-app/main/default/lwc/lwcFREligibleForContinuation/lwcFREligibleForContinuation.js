import { LightningElement, api } from 'lwc';
import cloneFundingReq_APX from '@salesforce/apex/lwcFREligibleForContinuation_APX.cloneFundingReq_APX';
import {NavigationMixin} from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class LwcFREligibleForContinuation extends NavigationMixin(LightningElement) {
    @api recordId;
    selectedFundingOppId;
    loaded = true;

    handleFundingOppSelected(event){
        if(event){
            let fundingOppId = event.target.value;
            console.log('fundingOppId -- ' + typeof  fundingOppId);
            this.selectedFundingOppId = fundingOppId.toString();
            this.cloneFundingReq().then(result=>{
                this.navigateToRecordPage();
            }).catch(errorInCloneFundingReq=>{
                console.log('errorInCloneFundingReq = ' + JSON.stringify(errorInCloneFundingReq));
            });
        }
    }

    cloneFundingReq(){
        console.log('recordId -- ' + this.recordId);
        this.loaded = false;
        return cloneFundingReq_APX({selectedFundingOppId:this.selectedFundingOppId,fundingReqId:this.recordId}).then(result=>{

        }).catch(errorInCloneFundingReq_APX=>{
            console.log('errorInCloneFundingReq_APX = ' + JSON.stringify(errorInCloneFundingReq_APX));
            let errorBody = '';
            
            if('body' in errorInCloneFundingReq_APX){
                let messageParam = errorInCloneFundingReq_APX['body'];
                if('message' in  messageParam){
                    errorBody = messageParam['message']
                }
            }
            if(errorBody.length>200){
                errorBody = 'Error occured while performing the request. Check console for more information';
            }
            this.displayErrorMessage('Error!!', errorBody, 'error', 'dismissible');
        });
    }

    navigateToRecordPage(){
        this.loaded = true;
        this[NavigationMixin.Navigate]({
            type:'standard__recordPage',
            attributes:{
                recordId:this.recordId,
                objectApiName:'Funding_Request__c',
                actionName:'view'
            }
        });
    }

    displayErrorMessage(titleParam,messageParam,variantParam,modeParam){
        const toastEvent = new ShowToastEvent({
            title:titleParam,
            message:messageParam,
            variant:variantParam,
            mode:modeParam
        });
        this.dispatchEvent(toastEvent);
    }
}