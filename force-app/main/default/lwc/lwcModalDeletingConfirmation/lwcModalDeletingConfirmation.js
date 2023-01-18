/**
 * Created by denisletkovski on 2022-07-27.
 */

import {LightningElement, api, track} from 'lwc';
import deleteBudget from '@salesforce/apex/lwcBudgetController.deleteBudget';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class LwcModalDeletingConfirmation extends LightningElement {
    @api isHasChildBudget;
    @api recordId;
    isDeleted;

    closeModal() {
        console.log(this.isHasChildBudget);
        const closeDeleteModal = new CustomEvent('delete', {detail: this.isDeleted});
        this.dispatchEvent(closeDeleteModal);
    }

    deleteBudget() {
        deleteBudget({
            recordId : this.recordId
        }).then((result) => {
            this.showToast();
            this.refreshData();
            this.isDeleted = true;
            this.closeModal();
        }).catch((error) => {
                console.log('LwcModalDeletingConfirmation error ' + JSON.stringify(error));
            });
    }

    showToast() {
        const event = new ShowToastEvent({
            title: 'Success!',
            message: 'Budget Successfully Deleted!',
            variant: 'success'
        });
        this.dispatchEvent(event);
    }

    refreshData() {
        console.log('on event');
        const refreshEvent = new CustomEvent('refresh', {});
        this.dispatchEvent(refreshEvent);
    }
}