import { LightningElement, api } from 'lwc';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import { loadScript } from 'lightning/platformResourceLoader';
import getInitData from '@salesforce/apex/ParticipantVisitsRemote.getParticipantVisits';
import getIcon from '@salesforce/apex/PatientVisitService.getVisitIcons';
import WTELabel from '@salesforce/label/c.Home_Page_StudyVisit_WhToEx';

export default class PpStudyVisitWhatToExpect extends LightningElement {
    initialized = '';
    visitMode = 'All';
    visitWrappers = [];
    @api icondetails = [];
    @api visitid;
    isError = false;

    labels = {
        WTELabel
    };

    connectedCallback() {
        console.log('Error in COnnectedCallback', this.isError);
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                this.initializeData();
            })
            .catch((error) => {
                this.showErrorToast(this.labels.ERROR_MESSAGE, error.message, 'error');
            });
    }

    initializeData() {
        this.initialized = 'false';
        console.log('visit id is-->', this.visitid);

        getIcon({
            visitId: this.visitid //'a0y17000003smV5AAI' ////'' ////
        })
            .then((result) => {
                console.log('result', result);
                console.log('result length', result.length);
                this.icondetails = result;
                console.log('result', this.icondetails);
                if (result.length === 0) {
                    this.isError = true;
                } else {
                    this.isError = false;
                }
                console.log('iserror ', this.isError);
                console.log('result is -->', result.length);
                let iconNames = '';
                for (let i = 0; i < result.length; i++) {
                    iconNames += result[i].icons + ';';
                }
            })
            .catch((error) => {
                this.showErrorToast('error occured', error.message, 'error');
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
}
