import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRelatedCodesAndTags from '@salesforce/apex/lwcCodesAndTagsPercentAPX.getRelatedCodesAndTags';
import delSelectedCodeTags from '@salesforce/apex/lwcCodesAndTagsPercentAPX.delSelectedCodeTags';
import {refreshApex} from '@salesforce/apex';

export default class LwcCodesAndTagsDisplayPercent extends LightningElement {
    @api recordId;

    recordData;
    codeMap;
    tags;
    codes;
    refreshTable; // used to refresh datatable
    @track isLoading = false;

    @wire(getRelatedCodesAndTags, { recordId: '$recordId' })
    wiredRecordData(refreshTable) {
      //  debugger;
      this.refreshTable = refreshTable;
      const { data, error } = refreshTable;
        if (data) {
            let tags = [];
            let codes = [];
            let codeMap = {};
            let recMap = [];
            let result = JSON.parse(JSON.stringify(data));
            console.log('all codes and tags data===================> '+JSON.stringify(data));

            for(let rec of result){
                if(rec.Code_and_Tag__r.Code_and_Tag__c == null){
                  rec['RecCodeTag__c']=rec.Id;
                  rec['RecCodeTag__rCodeTag__rName'] = '';
                    recMap.push(rec);
                }
                if(rec.Code_and_Tag__r.Code_and_Tag__c != null){
                    rec['RecCodeTag__c']=rec.Code_and_Tag__r.Code_and_Tag__c;
                    rec['RecCodeTag__rCodeTag__rName'] = rec.Code_and_Tag__r.Code_and_Tag__r.Name;
                    recMap.push(rec);
                  }
            }

            console.log('recMap===================> '+JSON.stringify(recMap));   

            let result2 = JSON.parse(JSON.stringify(recMap));

            for (let rec of result2) {
                if (rec.Code_and_Tag__r.RecordType.Name == 'Tag') {
                    tags.push({ label: rec.Code_and_Tag__r.Name, variant: 'circle' });
                }
                else {
                    if (!codeMap[rec.RecCodeTag__c])
                        codeMap[rec.RecCodeTag__c] = [];
                        codeMap[rec.RecCodeTag__c].push(rec);


                }

                
            }

            console.log('codeMap============> '+JSON.stringify(codeMap));


            

            let codePushed = {};
            for (let rec of result) {
                console.log('recoooo  ============> '+JSON.stringify(rec));
                if (rec.Code_and_Tag__r.RecordType.Name == 'Code') {
                    if (!codePushed[rec.RecCodeTag__c]) {
                        codePushed[rec.RecCodeTag__c] = rec.RecCodeTag__c;
                        codes.push({ parentCodeName: rec.RecCodeTag__rCodeTag__rName, childs: codeMap[rec.RecCodeTag__c] });

                    }
                }
            }

            console.log('codes ===========> '+JSON.stringify(codes));
            console.log('tAGS ===========> '+JSON.stringify(tags));
         
            this.tags = tags;
            this.codes = codes;
            this.recordData = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.recordData = undefined;
        }
    }

    handleItemRemove(event) {
      //  const name = event.detail.item.name;

      this.isLoading = true;
    
        const recName = event.detail.item.label;
       // alert(JSON.stringify(recName));
       // alert(recName + ' pill was removed!');
       // const index = event.detail.index;
       //  this.items.splice(index, 1);


       delSelectedCodeTags({recordId: this.recordId,tagName : recName})
       .then(result => {
           window.console.log('result ====> ' + result);
         //  alert(JSON.stringify(result));
           // showing success message
           this.dispatchEvent(new ShowToastEvent({
               title:  'Record was deleted',
               message:'',
               variant: 'success'
           }),);

           this.isLoading = false;
         
           // refreshing table data using refresh apex
          return refreshApex(this.refreshTable);
         
       })
       .catch(error => {
           window.console.log('Error ====> '+JSON.stringify(error));
           this.dispatchEvent(new ShowToastEvent({
               title: 'Error!!', 
               message: error.message, 
               variant: 'error'
           }),);
       });

    }



    seeData(event) {
        alert('clicker');
        alert(JSON.stringify(this.recordData));
    }


}