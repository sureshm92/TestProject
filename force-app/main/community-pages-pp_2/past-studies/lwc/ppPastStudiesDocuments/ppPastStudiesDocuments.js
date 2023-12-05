import { LightningElement, api } from 'lwc';
import No_Documents_Available from '@salesforce/label/c.No_Documents_Available';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import getPastStudyDocuments from '@salesforce/apex/ResourceRemote.getPastStudyDocuments';

export default class PpPastStudiesDocuments extends LightningElement {
    @api lazyLoad;
    @api pe;
    documentList = [];
    documentPresent;
    lazyLoadResults = 7;
    loaded = false;
    noDocsIcon = pp_icons + '/' + 'no-docs.svg';
    chevronDown = pp_icons + '/' + 'chevron-down.svg';
    label={ No_Documents_Available };
    connectedCallback() {
        this.getDocuments();
    }

    getDocuments() {
        getPastStudyDocuments({pe: this.pe})
            .then((result) => {
                this.documentList = result.wrappers;
                if (this.documentList.length > 0) {
                    this.documentPresent = true;
                } else {
                    this.documentPresent = false;
                }
                this.loaded = true;
            })
            .catch((error) => {
                this.loaded = true;
            });
    }
    get showLoadMore(){
        return this.lazyLoad && this.lazyLoadResults<this.documentList.length;
    }
    loadMore(){
        this.lazyLoadResults += 7;
    }
}