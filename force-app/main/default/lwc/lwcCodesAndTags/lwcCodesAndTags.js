import { LightningElement, api } from 'lwc';
import checkForRelatedCodesAndTagsAPX from '@salesforce/apex/lwcCodesAndTagsAPX.checkForRelatedCodesAndTagsAPX';
import checkForUnAllocatedCodesAPX from '@salesforce/apex/lwcCodesAndTagsAPX.checkForUnAllocatedCodesAPX';
import checkForAllocatedCodesAndTagsAPX from '@salesforce/apex/lwcCodesAndTagsAPX.checkForAllocatedCodesAndTagsAPX';

export default class LwcCodesAndTags extends LightningElement {
    @api recordId;
    @api objectApiName;
    displayCodesComponent;
    displayTagsComponent;
    displayTotalsComponent;

    displayFirstComponent;
    displaySecondComponent;
    displayThirdComponent;
    
    

    connectedCallback(){
        this.handleInitialLoad();
    }

    async handleInitialLoad(){

        this.displayFirstComponent = true;
        this.displayCodesComponent = true;
        this.displayTagsComponent = true;

        this.displaySecondComponent = false;
        this.displayThirdComponent = false;

       
        // this.displayTotalsComponent = false;
        await this.handleComponentRenders();
        // if(!this.displayCodesComponent && !this.displayTagsComponent){
        //     this.displayTotalsComponent = true;
        // }
    }

    async handleComponentRenders(){
        await Promise.resolve();
        await this.checkFirstComponentRender();
        console.log(`first component render check complete displayFirstComponent = ${this.displayFirstComponent}`);
        if(this.displayFirstComponent){
            //do something may be in future
        }
        else{
            await this.checkSecondComponentRender();
            console.log(`second component render check complete displaySecondComponent = ${this.displaySecondComponent}`);
        }
        if(this.displaySecondComponent){
            //do something for second component
        }
        else{
            await this.checkThirdComponentRender();
            console.log(`third component render check complete displayThirdComponent = ${this.displayThirdComponent}`);
        }

        
    }

    async checkFirstComponentRender(){
        await checkForRelatedCodesAndTagsAPX({recordId:this.recordId}).then(async listCodesAndTagsAggrResults=>{
            if(listCodesAndTagsAggrResults && Array.isArray(listCodesAndTagsAggrResults) && listCodesAndTagsAggrResults.length>0){
                listCodesAndTagsAggrResults.forEach(async aggrResRec=>{
                    if('recType' in aggrResRec && 'recCount' in aggrResRec){
                        if(aggrResRec['recType'] == 'Code' && aggrResRec['recCount']>0){
                            this.displayCodesComponent = false;
                        }
                        if(aggrResRec['recType'] == 'Tag' && aggrResRec['recCount']>0){
                            this.displayTagsComponent = false;
                        }
                    }

                    if(this.displayCodesComponent && this.displayTagsComponent){
                        this.displayFirstComponent = true;
                    }
                    else{
                        this.displayFirstComponent = false;
                    }
                });
            }
        }).catch(errorInCheckForRelatedCodesAndTags=>{
            let toastParamsComponent = this.template.querySelector('c-lwc-toast-params');
            if(toastParamsComponent){
                toastParamsComponent.handleCustomErrorLogic(errorInCheckForRelatedCodesAndTags);
            }
        });
    }

    async checkSecondComponentRender(){
        await checkForUnAllocatedCodesAPX({recordId:this.recordId}).then(async unAllocatedCodesFound=>{
            this.displaySecondComponent = false;
            if(unAllocatedCodesFound){
                this.displayFirstComponent = true;
            }
        }).catch(errorInCheckForUnAllocatedCodesAPX=>{
            let toastParamsComponent = this.template.querySelector('c-lwc-toast-params');
            if(toastParamsComponent){
                toastParamsComponent.handleCustomErrorLogic(errorInCheckForUnAllocatedCodesAPX);
            }
        });
    }

    async checkThirdComponentRender(){
        await checkForAllocatedCodesAndTagsAPX({recordId:this.recordId}).then(async allocatedCodesFound=>{
            if(allocatedCodesFound){
                this.displayThirdComponent = true;
                this.displayFirstComponent = false;
                this.displaySecondComponent = false;
            }
        }).catch(errorInCheckForAllocatedCodesAPX=>{
            let toastParamsComponent = this.template.querySelector('c-lwc-toast-params');
            if(toastParamsComponent){
                toastParamsComponent.handleCustomErrorLogic(errorInCheckForAllocatedCodesAPX);
            }
        });
    }

    handleOnclickEdit(event){
        if(event){
            // this.displayCodesComponent = true;
            // this.displayTagsComponent = true;
            // this.displayTotalsComponent = false;
            console.log('Edit Button Clicked');
            // this.handleComponentRenders();
            this.displayFirstComponent = true;
            this.displaySecondComponent = false;
            this.displayThirdComponent = false;
        }
    }

    async handleNextFromCodes(event){
        if(event){
            console.log('dispatch event received from next codes');
            console.log(`event detail from codes next button click = ${JSON.stringify(event.detail)}`);
            // this.displayCodesComponent = false;
            // this.displayTagsComponent = false;
            
            // await this.verifyTotalsComponentDisplay();

            
            await this.handleComponentRenders();
            this.displaySecondComponent = true;
            //Wait for component render otherwise it wont send the data to the next component
            await Promise.resolve();
            this.displayFirstComponent = false;
            this.displayThirdComponent = false;
            this.sendDataToSecondComponent(event.detail);

        }
    }    

    sendDataToSecondComponent(data){
        console.log('I am here in send data to second component');
        let lwcCodesAndTagsPercentCmp = this.template.querySelector('c-lwc-codes-and-tags-percent');
        if(lwcCodesAndTagsPercentCmp){
            console.log(`about to release event to codes and tags percent cmp`);
            lwcCodesAndTagsPercentCmp.handleData(data);
        }
    }

    handleSubmitFromCodes(event){
        if(event){
            console.log('dispatch event received from submitted codes');
            // this.displayCodesComponent = false;
            // this.verifyTotalsComponentDisplay();
            this.handleComponentRenders();
        }
    }

    handleSubmitFromTags(event){
        if(event){
            console.log('dispatch event received from submitted tags');
            // this.displayTagsComponent = false;
            // this.verifyTotalsComponentDisplay();
            this.handleComponentRenders();
        }
    }

    handleBackButtonClickFromSecondComponent(event){
        if(event){
            console.log(`in first component. Back button clicked in second component`);
            this.handleOnclickEdit(event);
        }
    }

    // async verifyTotalsComponentDisplay(){
    //     if(!this.displayCodesComponent && !this.displayTagsComponent){
    //         this.displayTotalsComponent = true;
    //     }
    // }
}