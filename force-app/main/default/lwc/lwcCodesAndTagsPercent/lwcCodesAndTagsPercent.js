import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import createRelatedCodeTags from '@salesforce/apex/lwcCodesAndTagsPercentAPX.createRelatedCodeTags';
export default class LwcCodesAndTagsPercent extends LightningElement {

    @track recordData;
    @track isLoading = false;
    displaypercentDisplayComponent  = true;
    @api recordId;
    @api objectApiName;
    displaySecondComponent = false ;


    @api handleData(data) {
        if (data)
            data = data.map(rec => ({
                ...rec,
                totalPercentage: rec.selectedCodes.length == 1 ? 100 : 0,
                isPercentComplete: rec.selectedCodes.length == 1 ? true :false,
                selectedCodes: rec.selectedCodes && rec.selectedCodes.map(code => ({
                    ...code,
                    percentAmount: rec.selectedCodes.length == 1 ? 100 : 0,
                }))
            }))
        this.recordData = data;
        console.log('this are the looped records inputs==============> ' + JSON.stringify(this.recordData));
    }

    handleBack(event){
        if(event){
        //    alert('button was clicked');
            // console.log('Edit Button Clicked');
         //   displaySecondComponent = false ;
            const backButtonEvent = new CustomEvent('backbuttonclick',{detail:null});
            this.dispatchEvent(backButtonEvent);
        }

    }

    handleSubmit() {
        this.isLoading = true;
        let codeNames = '';
        for (let rec of this.recordData) {

            console.log('this are the different inputs===> ' + JSON.stringify(rec));

            console.log('this are the different inputs this.recordData===> ' + JSON.stringify(this.recordData));
            if (rec.totalPercentage < 100 || rec.totalPercentage > 100) {
                codeNames += ' ' + rec.codeName;
            }
        }
        if (codeNames) {
            const evt = new ShowToastEvent({
                title: 'Error',
                type: 'sticky',
                message: 'Total percentage should be 100% for code "' + codeNames + '"',
                variant: 'error',
                
            });
            this.isLoading = false;
            this.dispatchEvent(evt);
            this.displaypercentDisplayComponent  = true;

        }
        else
            this.createCodeAndTags();

    }

    async createCodeAndTags() {
      //  this.isLoading = true;
        let recordWrapper = [];
        for (let rec of this.recordData) {
            for (let code of rec.selectedCodes) {
                let rec = { allocation: code.percentAmount, codeId: code.codeId }; //{ Allocation__c: code.percentAmount, Code_and_Tag__c: code.codeId };
                recordWrapper.push(rec);
            }
        }
        await createRelatedCodeTags({ recordId: this.recordId,lstCodeTags:recordWrapper })
            .then((result) => {

                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Related code and tag allocation stored sucessfully',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                this.isLoading = false;

                const callParentComponent = new CustomEvent('submitbuttonclick',{detail:null});
                this.dispatchEvent(callParentComponent);
            })
            .catch((error) => {
                consolse.error(error);
            });

    }

    handlePercentChange(event) {
        let total = 0;
        for (let rec of this.recordData) {
            total = 0
            for (let code of rec.selectedCodes) {
                if (code.codeId == event.currentTarget.dataset.id)
                    code.percentAmount = event.detail.value;

                total += Number(code.percentAmount);
            }
            rec.totalPercentage = total;
            rec.isPercentComplete = rec.totalPercentage == 100;
        }
        this.recordData = JSON.parse(JSON.stringify(this.recordData));
    }




}