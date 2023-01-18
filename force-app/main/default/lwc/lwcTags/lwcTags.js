import { LightningElement, api } from 'lwc';
import getParentTagsAPX from '@salesforce/apex/lwcTagsAPX.getParentTagsAPX';
import getChildTagsAPX from '@salesforce/apex/lwcTagsAPX.getChildTagsAPX';
import createRelatedCodeAndTagRecsAPX from '@salesforce/apex/lwcTagsAPX.createRelatedCodeAndTagRecsAPX';



export default class LwcTags extends LightningElement {
    listTagsColumns;
    listTagsRecs;
    

    @api recordId;

    connectedCallback(){
        this.handleInitialLoad();
    }

    async handleInitialLoad(){
        this.listTagsColumns = [];
        this.listTagsRecs = [];
        await this.setTagsColumns();
        await this.getParentTags();
    }

    async setTagsColumns(){
        this.listTagsColumns = [
            {label:'Tag',fieldName:'tagName',type:'text', wrapText:true}
        ];
    }

    async getParentTags(){
        await getParentTagsAPX().then(listParentTags=>{
            if(listParentTags && Array.isArray(listParentTags) && listParentTags.length>0){
                listParentTags.forEach(async parentTagRec=>{
                    if('hasChildTagRecs' in parentTagRec && parentTagRec['hasChildTagRecs']){
                        parentTagRec['_children'] = [];
                    }
                    this.listTagsRecs = [...this.listTagsRecs, parentTagRec];
                });
            }
        });
    }

    handleRowToggle(event){
        if(event){
            const toggledTagId = event.detail.name;
            console.log(`toggledTagId = ${toggledTagId}`);
            const hasChildContent = event.detail.hasChildrenContent;
            console.log(`hasChildContent = ${hasChildContent}`);
            if(!hasChildContent){
                this.handleGetChildTagRecs(toggledTagId);
            }
        }
    }

    async handleGetChildTagRecs(toggledTagId){
        let listChildTagRecs = await this.getChildTags(toggledTagId);
        console.log(`listChildTagRecs = ${JSON.stringify(listChildTagRecs)}`);
        console.log(`child tag records retrieved`);
        this.listTagsRecs = await this.resetParentTagWithChildTags(toggledTagId, this.listTagsRecs, listChildTagRecs);
    }

    async getChildTags(toggledTagId){
        let listChildTagRecs = [];
        await getChildTagsAPX({parentTagId:toggledTagId}).then(async listChildTags=>{
            console.log(`listChildTags = ${JSON.stringify(listChildTags)}`);
            if(listChildTags && Array.isArray(listChildTags) && listChildTags.length>0){
                listChildTags.forEach(childTagRec=>{
                    if('hasChildTagRecs' in childTagRec && childTagRec['hasChildTagRecs']){
                        childTagRec['_children'] = [];
                    }
                });
            }
            listChildTagRecs =  listChildTags;
        });
        return listChildTagRecs;
    }

    async resetParentTagWithChildTags(toggledTagId, listTagsRecs, listChildTagRecs){
        console.log(`resetting parent Tag with child Tags`);
        return listTagsRecs.map(row=>{
            let hasChildren = false;
            if('_children' in row && row['_children'] && Array.isArray(row['_children']) && row['_children'].length>0){
                hasChildren = true;
            }
            console.log(`row.tagId = ${row.tagId}`);
            if(row.tagId === toggledTagId){
                console.log(`found a match with the id`);
                row['_children'] = listChildTagRecs;
            }
            else if(hasChildren){
                this.resetParentTagWithChildTags(toggledTagId, row['_children'], listChildTagRecs);
            }
            // console.log(`tag row = ${JSON.stringify(row)}`);
            return row;
        });
    }

    handleSubmitButtonClick(event){
        if(event){
            this.createRelatedCodeAndTagRecs();
        }
    }

    async createRelatedCodeAndTagRecs(){
        let tagTreegridCmp = this.template.querySelector('lightning-tree-grid');
        if(tagTreegridCmp){
            let listSelectedTagRows = tagTreegridCmp.getSelectedRows();
            console.log(`listSelectedTagRows = ${JSON.stringify(listSelectedTagRows)}`);
            console.log(`recordId = ${JSON.stringify(this.recordId)}`);
            if(listSelectedTagRows && Array.isArray(listSelectedTagRows) && listSelectedTagRows.length>0){
                await createRelatedCodeAndTagRecsAPX({listSelectedTagsRecs:listSelectedTagRows,recordId:this.recordId}).then(async listToastParams=>{
                    if(listToastParams && Array.isArray(listToastParams) && listToastParams.length>0){
                        let toastParamsComponent = this.template.querySelector('c-lwc-toast-params');
                        if(toastParamsComponent){
                            toastParamsComponent.handleSavedResults(listToastParams);
                        }
                    }
                    const hideTagsComponent = new CustomEvent('submittags',{detail:null});
                    this.dispatchEvent(hideTagsComponent);
                }).catch(async errorInCreateRelatedCodeAndTagRecsAPX=>{
                    let toastParamsComponent = this.template.querySelector('c-lwc-toast-params');
                    if(toastParamsComponent){
                        toastParamsComponent.handleCustomErrorLogic(errorInCreateRelatedCodeAndTagRecsAPX);
                    }
                });
                
            }
        }
    }



}