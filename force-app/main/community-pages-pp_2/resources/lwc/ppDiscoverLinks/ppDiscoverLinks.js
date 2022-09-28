import { LightningElement } from 'lwc';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import communityPPTheme from '@salesforce/resourceUrl/Community_CSS_PP_Theme';

import getInitData from '@salesforce/apex/RelevantLinksRemote.getInitData';

export default class PpDiscoverLinks extends LightningElement {
    isInitialized = false;
    isAvailable = false;
    linksWrappers = [];


    connectedCallback(){

        loadScript(this, RR_COMMUNITY_JS)
        .then(() => {
            Promise.all([loadStyle(this, communityPPTheme)])
                .then(() => {
                    this.spinner = this.template.querySelector('c-web-spinner');
                    this.spinner ? this.spinner.show() : '';
                    this.initializeData();
                })
                .catch((error) => {
                    console.log(error.body.message);
                });
        })
        .catch((error) => {
            communityService.showToast('', 'error', error.message, 100);
        });       
    }

    initializeData(){
        getInitData()
        .then((returnValue) => {
            this.isInitialized = true;
            let initData = JSON.parse(JSON.stringify(returnValue));
            console.log("initData");
            console.log(initData);
            this.spinner.hide();
        })
        .catch((error) => {
            communityService.showToast('', 'error', 'Failed To read the Data...', 100);
            this.spinner.hide();
        });
    }

}