import { LightningElement, track, api, wire } from 'lwc';
import loadDiary from '@salesforce/apex/ECOADiariesController.getToken';
import getSubjectGuid from '@salesforce/apex/ECOADiariesController.getSubjectGuid';
import ediariesComPref from '@salesforce/label/c.eDiaries_Comm_Preferences';
import ediaries from '@salesforce/label/c.Navigation_eDiary';
import ediariesActivation from '@salesforce/label/c.Activate_eDiaries';
import backToHome from '@salesforce/label/c.Link_Back_To_Home';
import ediariesWorkMsg from '@salesforce/label/c.eDiaries_Work_Msg';
import getisRTL from '@salesforce/apex/HomePageParticipantRemote.getIsRTL';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import desktopTemplate from './desktopTemplate.html';
import mobileTemplate from './mobileTemplate.html';
import DEVICE from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';

export default class ViewEcoaDiaries extends NavigationMixin(LightningElement) {
    @track ecoaUrl;
    @track subjectAvailable = true;
    labels = {
        ediaries,
        ediariesActivation,
        ediariesWorkMsg,
        backToHome,
        ediariesComPref
    };
    @track studyProgramName;
    underConstruction = pp_icons + '/' + 'undraw_under_construction_-46-pa.svg';
    underConstructionMble = pp_icons + '/' + 'undraw_under_construction_-46-pa-mble.svg';

    desktop = true;
    @track gfkll;
    showBackToHome = false;

    connectedCallback() {
        DEVICE != 'Small' ? (this.desktop = true) : (this.desktop = false);
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        this.showBackToHome = urlParams.get('showBackToHome');

        var participantData = communityService.getParticipantData();
        this.studyProgramName =
            participantData && participantData.ctp ? participantData.ctp.Study_Code_Name__c : '';

        let subjectGuid = getSubjectGuid()
            .then((result) => {
                console.log('Subject GUID::' + result);
                if (result) {
                    let ppGetter = loadDiary()
                        .then((result) => {
                            this.subjectAvailable = true;
                            this.ecoaUrl = result;
                        })
                        .catch(function (error) {
                            console.error('Error: ' + JSON.stringify(error));
                            //this.isLoading = false;
                        });
                } else {
                    console.log('else' + result);
                    this.subjectAvailable = false;
                }
            })
            .catch(function (error) {
                console.error('Error: ' + JSON.stringify(error));
            });
        getisRTL()
            .then((data) => {
                this.isRTL = data;
            })
            .catch(function (error) {
                console.error('Error RTL: ' + JSON.stringify(error));
            });
    }
    get cardRTL() {
        return this.isRTL ? 'cardRTL' : '';
    }
    get programName() {
        return this.isRTL ? 'po-mr-36' : '';
    }
    render() {
        return this.desktop ? desktopTemplate : mobileTemplate;
    }
    get backLinkClass() {
        return !this.desktop
            ? this.isRTL
                ? 'back-link-mble'
                : 'back-link-mble'
            : this.isRTL
            ? 'back-link'
            : 'back-link';
    }
    handleCommunicationPreferences(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'account-settings'
            },
            state: {
                showBackButton: true
            }
        });
    }
    handleBackClick(event) {
        if (this.showBackToHome) {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: 'home'
                }
            });
        }
    }
}
