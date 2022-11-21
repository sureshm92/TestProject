import { LightningElement, api } from 'lwc';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import communityPPTheme from '@salesforce/resourceUrl/Community_CSS_PP_Theme';

import getInitDataNew from '@salesforce/apex/RelevantLinksRemote.getInitDataNew';

import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';
import DEVICE from '@salesforce/client/formFactor';

export default class PpDiscoverLinks extends LightningElement {
    isInitialized = false;
    isAvailable = false;
    linksWrappers = [];
    discoverEmptyState = false;
    desktop = true;

    @api toggleExplore = false;

    open_new_tab = pp_community_icons + '/' + 'open_in_new.png';
    empty_state = pp_community_icons + '/' + 'discover_empty.png';

    get cardContainerHeight(){
        if(!this.toggleExplore){
            return "card-container card-container-height-medium";
        }
        else if(this.toggleExplore){
            return "card-container card-container-height-small";
        }
        else{
            return "card-container";
        }
    }

    connectedCallback(){
        DEVICE != 'Small' ? (this.desktop = true) : (this.desktop = false);

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
                this.linksWrappers.push(resObj.resource);
            })
            this.spinner.hide();
            console.log("Links Wrapper Custom");
            console.log(this.linksWrappers);
            this.linksWrappers.length == 0 ? this.discoverEmptyState = true : this.discoverEmptyState = false;
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