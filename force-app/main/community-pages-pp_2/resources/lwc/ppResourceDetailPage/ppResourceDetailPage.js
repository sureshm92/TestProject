import { LightningElement, track } from 'lwc';
import setResourceAction from '@salesforce/apex/ResourceRemote.setResourceAction';
import getResourceDetails from '@salesforce/apex/ResourcesDetailRemote.getResourcesById';
import getCtpName from '@salesforce/apex/ParticipantStateRemote.getInitData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
import VERSION from '@salesforce/label/c.Version_date';
import Back_To_Resources from '@salesforce/label/c.Link_Back_To_Resources';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
export default class PpResourceDetailPage extends NavigationMixin(LightningElement) {
    userTimezone = TIME_ZONE;
    isInitialized = false;
    resourceType;
    resourceId;
    resourceTitle;
    resUploadDate;
    resourceLink;
    isFavourite = false;
    resourceSummary;
    isVoted = false;
    isDocument = false;
    langCode;
    documentLink;
    studyTitle = '';
    state;
    label = {
        VERSION,
        Back_To_Resources
    };
    isMultimedia = false;
    isArticleVideo = false;
    @track landscape = false;

    desktop = true;
    spinner;

    connectedCallback() {
        //get resource parameters from url
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        this.resourceId = urlParams.get('resourceid');
        this.resourceType = urlParams.get('resourcetype');
        this.state = urlParams.get('state');
        if (this.resourceType == 'Study_Document') {
            this.langCode = urlParams.get('lang');
            this.isDocument = true;
        }

        switch(FORM_FACTOR) {
            case "Small":
                this.desktop = false;
                break;
            case "Medium":
                this.desktop = true;
                break;
            case "Large":
                this.desktop = true;
                break;
          }

        this.initializeData();
        // window.addEventListener("orientationchange", function() {
        //     alert("the orientation of the device is now1 " + screen.orientation.angle);
        //     screen.orientation.angle > 0 ? this.landscape = true : this.landscape = false;
        //     alert(this.landscape);         
        // });
    }

    get showSpinner() {
        return !this.isInitialized;
    }

    async initializeData() {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) {
            this.spinner.show();
        }

        //get clicked resource details
        getResourceDetails({
            resourceId: this.resourceId,
            resourceType: this.resourceType
        })
            .then((result) => {
                this.requestFullScreen();
                let resourceData = result.wrappers[0].resource;
                this.resUploadDate = resourceData.Version_Date__c;
                this.resourceTitle = resourceData.Title__c;
                this.resourceSummary = resourceData.Body__c;
                this.isArticleVideo =
                    this.resourceType == 'Article' || this.resourceType == 'Video';
                this.resourceLink =
                    this.resourceType == 'Article' ? resourceData.Image__c : resourceData.Video__c;
                if (this.resourceType == 'Multimedia') {
                    this.resourceLink = resourceData.Multimedia__c;
                    this.resourceType = 'Multimedia';
                    this.isMultimedia = true;
                }
                this.isFavourite = result.wrappers[0].isFavorite;
                this.isVoted = result.wrappers[0].isVoted;

                //get study Title
                if (
                    this.state != 'ALUMNI' &&
                    (resourceData.Content_Class__c == 'Study-Specific' || this.isDocument)
                ) {
                    getCtpName({})
                        .then((result) => {
                            let data = JSON.parse(result);
                            this.studyTitle =
                                data.pi?.pe?.Clinical_Trial_Profile__r?.Study_Code_Name__c;
                            if (this.isDocument) {
                                this.handleDocumentLoad();
                            }
                            this.isInitialized = true;
                        })
                        .catch((error) => {
                            this.showErrorToast(this.labels.ERROR_MESSAGE, error.message, 'error');
                        });
                }
            })
            .catch((error) => {
                this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
            })
            .finally(() => {
                if (this.spinner) {
                    this.spinner.hide();
                }
            });
    }

    handleDocumentLoad() {
        let subDomain = communityService.getSubDomain();
        if (FORM_FACTOR == 'Large') {
            if (subDomain) {
                this.documentLink =
                    subDomain +
                    '/apex/RRPDFViewer?resourceId=' +
                    this.resourceId +
                    '&language=' +
                    this.langCode;
            }
        } else {
            let updates = true;
            this.documentLink =
                'mobile-pdf-viewer?resId=' +
                this.resourceId +
                '&lang=' +
                this.langCode +
                '&updates=' +
                updates;
        }
    }

    handleBackClick() {
        sessionStorage.setItem('Cookies', 'Accepted');
        if (FORM_FACTOR == 'Large') {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'resources'
                }
            });
        } else {
            let resType;
            if (this.isMultimedia) {
                resType = 'engage';
            } else if (this.resourceType == 'Study_Document') {
                resType = 'documents';
            } else if (this.resourceType == 'Video' || this.resourceType == 'Article') {
                resType = 'explore';
            }    
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'resources'
                },
                state: {
                    resType : resType
                }
            });
        }
    }

    handleFavourite() {
        this.isFavourite = !this.isFavourite;
        setResourceAction({
            resourceId: this.resourceId,
            isFavorite: this.isFavourite,
            isVoted: false
        })
            .then((result) => {})
            .catch((error) => {
                this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
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

    requestFullScreen(){
        let ele = this.template.querySelectorAll(".forceOrientation");
       
    }

    goBackToPortraitMode(){
        // console.log("goBackToPortraitMode");
        // let ele = window.document.documentElement;
        // // ele[0].style.transform = "rotate(90deg)";
        //  if (ele.requestFullscreen) {
        //     ele.requestFullscreen();
        // } else if (ele.webkitRequestFullscreen) { /* Safari */
        //     ele.webkitRequestFullscreen();
        // } else if (ele.msRequestFullscreen) { /* IE11 */
        //     ele.msRequestFullscreen();
        // }

        // ele.requestFullscreen({ navigationUI: "show" })
        // .then(() => {
        //     console.log("success");
        // })
        // .catch((err) => {
        //     console.log(
        //     `An error occurred while trying to switch into fullscreen mode: ${err.message} (${err.name})`
        //     );
        // });
        // screen.orientation.lock("portrait-primary")
        // .then(function(){
        //     console.log("success");
        // })
        // .catch(function(error){
        //     console.log(error);
        // })
    }
}