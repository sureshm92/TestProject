import { LightningElement, track, api } from 'lwc';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import communityPPTheme from '@salesforce/resourceUrl/Community_CSS_PP_Theme';
import getInitDataNew from '@salesforce/apex/RelevantLinksRemote.getInitDataNew';
import getUpdateResources from '@salesforce/apex/ResourceRemote.getUpdateResources';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';
import DEVICE from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import updatesLabel from '@salesforce/label/c.Updates_Label';
import viewAllResource from '@salesforce/label/c.View_All_Resource';
import caughtup from '@salesforce/label/c.Caught_up';
export default class PpUpdates extends NavigationMixin(LightningElement) {
    @api desktop;
    @api showvisitsection;
    linksWrappers = [];
    resourcedData = [];
    resourcePresent = false;
    desktop = true;
    isInitialized = false;
    counter;
    displayCounter = false;
    open_new_tab = pp_community_icons + '/' + 'open_in_new.png';
    empty_state = pp_community_icons + '/' + 'empty_updates.PNG';
    link_state = pp_community_icons + '/' + 'linkssvg.svg';
    label = {
        updatesLabel,
        viewAllResource,
        caughtup
    };

    connectedCallback() {
        DEVICE != 'Small' ? (this.desktop = true) : (this.desktop = false);
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                Promise.all([loadStyle(this, communityPPTheme)])
                    .then(() => {
                        this.initializeData();
                    })
                    .catch((error) => {
                        communityService.showToast('', 'error', error.message, 100);
                    });
            })
            .catch((error) => {
                communityService.showToast('', 'error', error.message, 100);
            });
    }

    initializeData() {
        this.spinner = this.template.querySelector('c-web-spinner');
        this.spinner.show();
        getInitDataNew()
            .then((returnValue) => {
                this.isInitialized = true;
                let initData = JSON.parse(JSON.stringify(returnValue));
                initData.resources.forEach((resObj) => {
                    this.linksWrappers.push(resObj.resource);
                });
                this.getUpdates(JSON.stringify(returnValue));
            })
            .catch((error) => {
                communityService.showToast('', 'error', 'Failed To read the Data111...', 100);
                this.spinner.hide();
            });
    }

    openLink(event) {
        window.open(event.currentTarget.dataset.link, '_blank');
    }

    async getUpdates(returnValue) {
        await getUpdateResources({ linkWrapperText: returnValue })
            .then((result) => {
                var counterForLoop = 0;
                let data = JSON.parse(JSON.stringify(result));
                this.counter = data.counter;
                if (this.counter > 0) {
                    this.displayCounter = true;
                }
                data.resources.every((resObj) => {
                    ++counterForLoop;
                    this.resourcedData.push(resObj);
                    if (counterForLoop >= 4) {
                        return false;
                    }
                    return true;
                });
                if (counterForLoop > 0) {
                    this.resourcePresent = true;
                }
                this.resourcedData.forEach((resObj) => {
                    if (
                        resObj.resource.Content_Type__c == 'Article' ||
                        resObj.resource.Content_Type__c == 'Video'
                    ) {
                        resObj.isExplore = true;
                    } else if (resObj.resource.Content_Type__c == 'Study_Document') {
                        resObj.isDoc = true;
                    } else {
                        resObj.isLink = true;
                    }
                });
                this.spinner.hide();
            })
            .catch((error) => {
                this.showErrorToast('Error occured', error.message, 'error');
            });
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

    navigateResources() {
        let subDomain = communityService.getSubDomain();
        let detailLink = window.location.origin + subDomain + '/s/resources';

        const config = {
            type: 'standard__webPage',

            attributes: {
                url: detailLink
            }
        };

        this[NavigationMixin.GenerateUrl](config).then((url) => {
            window.open(url, '_self');
        });
    }
}
