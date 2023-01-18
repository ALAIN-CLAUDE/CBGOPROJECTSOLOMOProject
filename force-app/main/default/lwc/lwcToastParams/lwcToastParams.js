import { LightningElement, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class LwcToastParams extends LightningElement {
    title='';
    message='';
    variant='';
    mode='';

    connectedCallback(){
        
    }

    @api handleSavedResults(listsavedresults){
        console.log('SAVED RESULTS IN TOAST PARAM' + JSON.stringify(listsavedresults));
        if(listsavedresults!=null && Array.isArray(listsavedresults) && listsavedresults.length>0){
            console.log('IN HERE');
            listsavedresults.forEach(saveResRec=>{
                console.log('saveResRec-------'+JSON.stringify(saveResRec));
                if('isSuccess' in saveResRec && saveResRec.isSuccess){
                    if('isCreated'  in saveResRec &&  saveResRec.isCreated){
                        this.handleInsertSuccessLogic();
                    }
                    if('isUpdated'  in saveResRec &&  saveResRec.isUpdated){
                        this.handleUpdateSuccessLogic();
                    }
                    if('isDeleted' in saveResRec && saveResRec.isDeleted){
                        this.handleDeleteSuccessLogic();
                    }
                }
                else{
                    this.handleErrorLogic(saveResRec);
                }
            });
        }
    }

    @api handleInsertSuccessLogic(){
        const evt = new ShowToastEvent({
            title:'SUCCESS!!',
            message:'Record created.',
            variant:'success',
            mode:'dismissable'
        });
        this.dispatchEvent(evt);
    }

    handleUpdateSuccessLogic(){
        const evt = new ShowToastEvent({
            title:'SUCCESS!!',
            message:'Record updated.',
            variant:'success',
            mode:'dismissable'
        });
        this.dispatchEvent(evt);
    }

    handleDeleteSuccessLogic(){
        const evt = new ShowToastEvent({
            title:'SUCCESS!!',
            message:'Record deleted.',
            variant:'success',
            mode:'dismissable'
        });
        this.dispatchEvent(evt);
    }

    handleErrorLogic(saveResRec){
        if(saveResRec!=null && 'listErrors' in saveResRec){
            let listErrors = saveResRec['listErrors'];
            if(listErrors!=null && Array.isArray(listErrors) && listErrors.length>0){
                for(var err of listErrors){
                    const evt = new ShowToastEvent({
                        title:'ERROR!!',
                        message:err,
                        variant:'error',
                        mode:'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
            }
        }
        
    }

    @api handleCustomErrorLogic(msg){
        const evt = new ShowToastEvent({
            title:'ERROR!!',
            message:'Error detected . ' + msg,
            variant:'error',
            mode:'dismissable'
        });
        this.dispatchEvent(evt);
    }

    displayToastParams(toastParam){

    }
}