import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getResources from '@salesforce/apex/ResourceRemote.getResources';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
import ALL from '@salesforce/label/c.AF_All';
import ARTICLES from '@salesforce/label/c.Resources_Card_Title_Articles';
import ARTICLE from '@salesforce/label/c.Resources_Article';
import VIDEO from '@salesforce/label/c.Resources_Video';
import VIDEOS from '@salesforce/label/c.Resources_Card_Title_Videos';
import FAVORITES from '@salesforce/label/c.Resource_Tab_Favorites';
import All_EMPTY from '@salesforce/label/c.Resources_All_Empty'

export default class PpResourceEngage extends LightningElement {
    //@api vars
    @api isRtl = false;
    @api desktop = false;

    @track resourcesData;
    @track resourcesFilterData;
    selectedOption = ALL;

    //Boolean vars
    isInitialized = false;
    isDisabled=false;

    label={
        All_EMPTY
    };

    connectedCallback() {
        this.selectedOption = 'All';
        this.initializeData();
    }
    initializeData() {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) {
            this.spinner.show();
        }
        //get all Articles/Videos together to avoid extra calls
        getResources({ resourceType: 'Article;Video', resourceMode: 'Default' })
            .then((result) => {
                this.resourcesData = result.wrappers;
                this.resourcesFilterData = this.resourcesData[0] ? this.resourcesData : false;
                this.isDisabled=this.resourcesData[0] ? false : true;
            })
            .catch((error) => {
                this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
            });
        this.isInitialized = true;
        if (this.spinner) {
            this.spinner.hide();
        }
    }
    showErrorToast(titleText, messageText, variantType) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: titleText,
                message: messageText,
                variant: variantType
            })
        );
    }
    //dropdown options
    get options() {
        return [
            { label: ALL, value: ALL },
            { label: FAVORITES, value: FAVORITES },
            { label: ARTICLES, value: ARTICLE },
            { label: VIDEOS, value: VIDEO }
        ];
    }
    //filter cached data on client side based on selected dropdown 
    handleChangeSelection(event) {
        this.selectedOption = event.detail.value;
        this.resourcesFilterData =
            this.selectedOption == ALL
                ? this.resourcesData
                : this.selectedOption == FAVORITES
                ? this.resourcesData.filter((data) => data.isFavorite == true)
                : this.resourcesData.filter(
                      (data) => data.resource.Content_Type__c == this.selectedOption
                  );
        this.resourcesFilterData = this.resourcesFilterData[0] ? this.resourcesFilterData : false;
    }
    //change isfavorite field of clicked resource in cached data 
    handleFavorite(event){
        let index=this.resourcesData.findIndex((data) => data.resource.Id == event.detail.resourceId);
        this.resourcesData[index].isFavorite=event.detail.isFavourite;
    }
}
