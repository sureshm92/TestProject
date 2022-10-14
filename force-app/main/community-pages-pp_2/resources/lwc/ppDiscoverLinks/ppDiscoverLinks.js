import { LightningElement } from 'lwc';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import communityPPTheme from '@salesforce/resourceUrl/Community_CSS_PP_Theme';

import getInitDataNew from '@salesforce/apex/RelevantLinksRemote.getInitDataNew';

import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';

export default class PpDiscoverLinks extends LightningElement {
    isInitialized = false;
    isAvailable = false;
    linksWrappers = [];

    open_new_tab = pp_community_icons + '/' + 'Open_New_Tab_Icon.png';

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
        getInitDataNew()
        .then((returnValue) => {
            this.isInitialized = true;
            
            let initData = JSON.parse(JSON.stringify(returnValue));
            console.log("InitData New");
            console.log(initData);
            initData.resources.forEach((resObj) => {
                this.linksWrappers.push(resObj);
            })
            this.spinner.hide();
            console.log("Links Wrapper Custom");
            console.log(this.linksWrappers);
        })
        .catch((error) => {
            communityService.showToast('', 'error', 'Failed To read the Data111...', 100);
            this.spinner.hide();
        });
    }

    openLink(event){
        window.open(event.currentTarget.dataset.link, "_blank");
    }

}