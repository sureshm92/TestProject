import { LightningElement, api } from 'lwc';
import setResourceAction from '@salesforce/apex/ResourceRemote.setResourceAction';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import { NavigationMixin } from 'lightning/navigation';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
import VERSION from '@salesforce/label/c.Version_date';
import POSTING from '@salesforce/label/c.Posting_date';

export default class PpResourceContainer extends NavigationMixin(LightningElement) {
    userTimezone = TIME_ZONE;
    //@api vars
    @api isRtl = false;
    @api desktop = false;
    @api thumbnail;
    @api resourceType;
    @api resourceId;
    @api resourceTitle;
    @api resPostingDate;
    @api resUploadDate;
    @api resVersionDate;
    @api isFavourite = false;
    @api resourceSummary;
    @api isVoted = false;
    state;
    resourceForPostingDate = ['Article','Video','Multimedia'];
    isThumbnailPresent = false;

    label = {
        VERSION,
        POSTING
    };

    connectedCallback() {
        this.isThumbnailPresent = this.thumbnail ? true : false;
        if (communityService.isInitialized()) {
            this.state = communityService.getCurrentCommunityMode().participantState;
        }
    }
    handleNavigate() {
        sessionStorage.setItem('Cookies', 'Accepted');		
			this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'resource-detail'
            },
			state: {
                resourceid : this.resourceId,
                resourcetype : this.resourceType,
                state : this.state
            }
		});	
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
        //custom event to avoid refreshing data from server on each favorite/unfavorite
        const favourite = new CustomEvent('favourite', {
            detail: {
                isFavourite: this.isFavourite,
                resourceId: this.resourceId
            }
        });
        this.dispatchEvent(favourite);
    }

    handleError() {
        this.isThumbnailPresent = false;
    }

    get showPostingOrVersionDate(){
        if(this.resourceForPostingDate.includes(this.resourceType)){
            return this.resPostingDate;
        }
        return this.resVersionDate;
    }

    get showPostingOrVersionLabel(){
        if(this.resourceForPostingDate.includes(this.resourceType)){
            return this.label.POSTING;
        }
        return this.label.VERSION;
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
