import { LightningElement, track } from 'lwc';
import resourcesDesktop from './ppResourceDesktopPage.html';
import resourcesMobile from './ppResourceMobilePage.html';
import DEVICE from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import rtlLanguages from '@salesforce/label/c.RTL_Languages';
import getDataWrapper from '@salesforce/apex/RelevantLinksRemote.getDataWrapper';
import getMultimediaResources from '@salesforce/apex/ResourceRemote.getMultimediaResources';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
import RELEVANT_LINKS from '@salesforce/label/c.Home_Page_RelevantLinks_Title';
import DISCOVER_TITLE from '@salesforce/label/c.Discover_Title';
import ENGAGE from '@salesforce/label/c.PP_Resource_Engage';
import EXPLORE from '@salesforce/label/c.PP_Resource_Explore';
import DOCUMENTS from '@salesforce/label/c.PP_Resource_Documents';
import FIND_ANSWERS from '@salesforce/label/c.PP_Resource_Answers';
import RESOURCES from '@salesforce/label/c.PG_SW_Tab_Resources';
import CHANGE_PREFERENCES from '@salesforce/label/c.PP_Change_Preferences';
import { NavigationMixin } from 'lightning/navigation';

import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';

export default class PpResourceContainerPage extends NavigationMixin(LightningElement) {
    //boolean var
    desktop = true;
    isRTL = false;
    isInitialized = false;
    toggleExplore = false;
    toggleLinks = false;
    toggleDocs = false;

    linksGridSize = 3;
    documentGridSize = 3;
    hideFirstColumn = false;
    rightColumnPadding = 'resource-gutter-left';
    engageHeight = 'res-box-engage-container';
    linkssHeight = 'res-box-relLinks-container pad10';
    docsHeight = 'res-box-document-container';

    //labels
    labels = {
        RESOURCES,
        RELEVANT_LINKS,
        ERROR_MESSAGE,
        ENGAGE,
        EXPLORE,
        DOCUMENTS,
        FIND_ANSWERS,
        DISCOVER_TITLE,
        CHANGE_PREFERENCES
    };
    @track linksData;
    @track trialdata;
    spinner;
    showSpinner = true;
    redirecturl = '';
    disableSave = true;
    @track textValue;
    @track selectedResourceType;
    @track options = [];
    resourcesAvailable = false;
    selectedOptions;
    containerElement;
    enableChangePref = false;
    enableChangePrefOnDocs = false;
    isDisabled = false;
    @track resourcesFilterData;
    @track resourcesData;
    @track linksWrappers = [];
    discoverEmptyState = false;
    multimedia = false;
    empty_state = pp_community_icons + '/' + 'engage_empty.png';

    get cardRTL() {
        return this.isRTL ? 'cardRTL' : '';
    }

    connectedCallback() {
        DEVICE != 'Small' ? (this.desktop = true) : (this.desktop = false);
        if (!this.desktop) {
            const queryString = window.location.search;
            const urlParams = new URLSearchParams(queryString);
            let resType = urlParams.get('resType');
            if (resType) {
                this.selectedResourceType = resType;
                if (resType == 'engage') {
                    this.selectedOptions = this.labels.ENGAGE;
                } else if (resType == 'documents') {
                    this.selectedOptions = this.labels.DOCUMENTS;
                } else if (resType == 'explore') {
                    this.selectedOptions = this.labels.EXPLORE;
                } else if (resType == 'discover') {
                    this.selectedOptions = this.labels.DISCOVER_TITLE;
                } else if (resType == 'answers') {
                    this.selectedOptions = this.labels.FIND_ANSWERS;
                }
            }
        } else {
            this.selectedOptions = this.labels.ENGAGE;
            this.selectedResourceType = 'engage';
        }
        this.initializeData();
    }
    // renderedCallback(){
    //     window.addEventListener('click', this.closeOptions);
    // }
    //template toggle
    render() {
        return this.desktop ? resourcesDesktop : resourcesMobile;
    }
    async initializeData() {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) {
            this.spinner.show();
        }
        if (communityService.isInitialized()) {
            //language support
            let paramLanguage = communityService.getUrlParameter('language');
            let lanCode = communityService.getUrlParameter('lanCode');

            if (
                rtlLanguages.includes(communityService.getLanguage()) ||
                (paramLanguage && rtlLanguages.includes(paramLanguage)) ||
                (lanCode && rtlLanguages.includes(lanCode))
            ) {
                this.isRTL = true;
            }
            //cards toggle logic
            if (communityService.getCurrentCommunityMode().participantState != 'ALUMNI') {
            } else {
                this.toggleExplore = true;
                this.toggleLinks = true;
            }
            getDataWrapper({ sortByCOI: true })
                .then((returnValue) => {
                    let initData = JSON.parse(JSON.stringify(returnValue));
                    let therapeuticAssignmentsList = [];
                    let therapeuticAssignments = {
                        resource: '',
                        id: '',
                        therapeuticArea: ''
                    };
                    if (communityService.getCurrentCommunityMode().participantState != 'ALUMNI') {
                        this.toggleExplore = initData.videoAndArticlesAreAvailable;
                        this.toggleDocs = initData.studyDocumentsAreAvailable;
                        this.toggleLinks = initData.linksAvailable;
                    }

                    this.createoptions();

                    initData.resources.forEach((resObj) => {
                        this.linksWrappers.push(resObj.resource);
                        resObj.resource.Therapeutic_Area_Assignments__r?.forEach(
                            (therapeuticArea) => {
                                therapeuticAssignments.resource = therapeuticArea.Resource__c;
                                therapeuticAssignments.id = therapeuticArea.Id;
                                therapeuticAssignments.therapeuticArea =
                                    therapeuticArea.Therapeutic_Area__c;
                                therapeuticAssignmentsList.push(therapeuticAssignments);
                            }
                        );

                        resObj.therapeuticAssignments = therapeuticAssignmentsList;
                        therapeuticAssignmentsList = [];
                        delete resObj.resource.Therapeutic_Area_Assignments__r;
                    });
                    this.linksWrappers.length == 0
                        ? (this.discoverEmptyState = true)
                        : (this.discoverEmptyState = false);
                    this.getUpdates(JSON.stringify(initData));
                })
                .catch((error) => {
                    this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
                });
        }

        if (this.spinner) {
            this.spinner.hide();
        }
    }
    async getUpdates(returnValue) {
        if (communityService.isInitialized()) {
            this.pData = communityService.getParticipantData();
            let data = JSON.stringify(this.pData);

            await getMultimediaResources({ linkWrapperText: returnValue, participantData: data })
                .then((result) => {
                    this.resourcesData = result.wrappers;
                    this.resourcesData.forEach((resObj) => {
                        resObj.isMultimedia = true;
                        if (!this.multimedia) {
                            this.multimedia = true;
                        }
                    });
                    this.resourcesFilterData = this.resourcesData[0] ? this.resourcesData : false;
                    this.isDisabled = this.resourcesData[0] ? false : true;
                    this.isInitialized = true;
                    this.showSpinner = false;
                })
                .catch((error) => {
                    this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
                });
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
    handleChangePreference() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'account-settings'
            },
            state: {
                changePref: null
            }
        });
    }
    updateResources(event) {
        this.selectedResourceType = event.currentTarget.dataset.key;
        this.getKey(this.selectedResourceType);

        let inputFields = this.template.querySelectorAll('.noselected');
        inputFields.forEach((ele) => {
            let key = ele.getAttribute('data-key');
            if (key == this.selectedResourceType) {
                ele.classList.add('selected');
            } else {
                ele.classList.remove('selected');
            }
        });
    }

    getKey(value) {
        this.options.forEach((obj, index) => {
            let key = '';
            if (obj.value == value) {
                key = obj.label;
                this.selectedOptions = key;
            }
        });
    }
    get exploreVisible() {
        return this.selectedResourceType == 'explore' ? true : false;
    }
    get documentsVisible() {
        return this.selectedResourceType == 'documents' ? true : false;
    }

    get discoverVisible() {
        return this.selectedResourceType == 'discover' ? true : false;
    }

    get answersVisible() {
        return this.selectedResourceType == 'answers' ? true : false;
    }

    get engageVisible() {
        return this.selectedResourceType == 'engage' ? true : false;
    }

    createoptions() {
        if (this.toggleExplore) {
            let option = { value: 'engage', label: this.labels.ENGAGE };
            let option1 = { value: 'explore', label: this.labels.EXPLORE };
            this.options.push(option);
            this.options.push(option1);
            this.resourcesAvailable = true;
            if (!this.selectedResourceType && !this.selectedOptions) {
                this.selectedResourceType = 'engage';
                this.selectedOptions = 'Engage';
            }
        }
        if (this.toggleLinks) {
            let option = { value: 'discover', label: this.labels.DISCOVER_TITLE };
            this.options.push(option);
            this.resourcesAvailable = true;
            if (!this.selectedResourceType && !this.selectedOptions) {
                this.selectedResourceType = 'discover';
                this.selectedOptions = 'Discover';
            }
        }
        if (this.toggleDocs) {
            let option = { value: 'documents', label: this.labels.DOCUMENTS };
            this.options.push(option);
            this.resourcesAvailable = true;
            if (!this.selectedResourceType && !this.selectedOptions) {
                this.selectedResourceType = 'documents';
                this.selectedOptions = 'Documents';
            }
        }

        // Populate Grid size
        if (!this.toggleExplore && !this.toggleDocs && this.toggleLinks) {
            this.linksGridSize = 6;
            this.enableChangePref = true;
            this.linkssHeight += ' newHeight';
        }

        if (!this.toggleExplore && !this.toggleLinks && this.toggleDocs) {
            this.hideFirstColumn = true;
            this.documentGridSize = 6;
            this.rightColumnPadding = '';
            this.enableChangePrefOnDocs = true;
            this.docsHeight += ' newHeight';
        }

        if (!this.toggleExplore && this.toggleLinks && this.toggleDocs) {
            this.enableChangePrefOnDocs = true;
            this.docsHeight += ' newHeight';
            this.linkssHeight += ' newHeight';
        }

        if (this.toggleExplore && !this.toggleLinks) {
            this.engageHeight += ' newHeight';
        }
    }

    showOptions(event) {
        this.containerElement = this.template.querySelectorAll('.res-options');
        this.containerElement[0].classList.toggle('hidden');
    }

    // closeOptions(event){
    //     if(this.containerElement[0])
    //         this.containerElement[0].classList.add('hidden');
    // }
}
