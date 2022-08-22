import { LightningElement, api, track } from 'lwc';
import Viewing_as_Self from '@salesforce/label/c.Viewing_as_Self';
import Viewing_as_Participant from '@salesforce/label/c.Viewing_as_Participant';
import Viewing_as_Investigative_Site from '@salesforce/label/c.Viewing_as_Investigative_Site';
import Viewing_as_Referring_Provider from '@salesforce/label/c.Viewing_as_Referring_Provider';
import Space_Delegate from '@salesforce/label/c.Space_Delegate';
import PP_ManageDelegates from '@salesforce/label/c.PP_ManageDelegates';
import PP_Account_Settings from '@salesforce/label/c.PP_Account_Settings';
import { NavigationMixin } from 'lightning/navigation';
import getContact from '@salesforce/apex/ContactService.getContact';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';

export default class ProfileHeaderIconInfo extends NavigationMixin(LightningElement) {
    @api user;
    @api currentMode;
    @api hasProfilePic;
    @api isRTL;
    @api communityModes;
    fullName;
    reset = true;
    viewMode = '';
    label = {
        Viewing_as_Self,
        Viewing_as_Participant,
        Viewing_as_Investigative_Site,
        Viewing_as_Referring_Provider,
        Space_Delegate,
        PP_ManageDelegates,
        PP_Account_Settings
    };
    icon_url = pp_icons + '/user_delegate_avatar.svg';

    @track contactDetails;
    @track error;
    contactId;
    @track userCommunityIsDelegate = true;

    get fullName() {
        let user = this.user;
        if (user) return user.Contact.FirstName + ' ' + user.Contact.LastName;
        return '';
    }
    get fullNameClass() {
        return '';
    }
    get userNameClass() {
        return '';
    }
    get profileSvgClass() {
        return '';
    }
    get isDelegate() {
        if (this.currentMode) {
            return this.currentMode.isDelegate ? true : false;
        }
        return '';
    }
    get accountSettingsClass() {
        return '';
    }

    get accountSettingIcon() {
        return 'gear_icon';
    }
    get accountSettIconColor() {
        return '#005587';
    }
    get accSettSvgClass() {
        return '';
    }

    /* get manageDelegatesClass() {
        if (this.currentMode) {
            return this.currentMode.participantState === 'ALUMNI' && !this.currentMode.isDelegate
                ? 'slds-col switcher-list'
                : 'slds-hide';
        }
        return '';
    }
    */

    get isUserDelegate() {
        return this.userCommunityIsDelegate;
    }
    get manageDelSvgClass() {
        return '';
    }

    connectedCallback() {
        if (this.user) {
            this.fullName = this.user.Contact.FirstName + ' ' + this.user.Contact.LastName;
            this.contactId = this.user.ContactId;
        }
        this.getContactData();
        this.reset = true;
        let currentMode = this.currentMode;
        let mode = '';
        let label = this.label;
        if (!currentMode) return;
        if (currentMode.participantState === 'ALUMNI' && !currentMode.isDelegate)
            mode = label.Viewing_as_Self;
        else {
            if (currentMode.userMode === 'Participant') mode = label.Viewing_as_Participant;
            if (currentMode.userMode === 'PI') mode = label.Viewing_as_Investigative_Site;
            if (currentMode.userMode === 'HCP') mode = label.Viewing_as_Referring_Provider;
            if (currentMode.isDelegate) mode += ' ' + label.Space_Delegate;
        }
        this.viewMode = mode;
        this.reset = false;
    }
    getContactData() {
        getContact({ contactId: this.contactId })
            .then((result) => {
                this.contactDetails = result;
                this.userCommunityIsDelegate = this.contactDetails.UserCommunityIsDelegate__c;
            })
            .catch((error) => {
                this.error = error;
            });
    }

    doManageDelegates() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'my-team'
            }
        });
        this.doCloseModal();
    }
    doNavigateToAccountSettings() {
        let item;
        let commModes = this.communityModes.ppModeItems;
        for (let i = 0; i < commModes.length; i++) {
            for (let j = 0; j < commModes[i].subItems.length; j++) {
                if (this.fullName == commModes[i].subItems[j].title) {
                    item = commModes[i].subItems[j];
                    break;
                }
            }
        }
        const selectedEvent = new CustomEvent('itemselection', {
            detail: {
                itemValue: item,
                navigateTo: 'account-settings'
            }
        });
        this.dispatchEvent(selectedEvent);
        //   this.doCloseModal();
    }
    doCloseModal() {
        const pageNavigation = new CustomEvent('pagenavigation');
        this.dispatchEvent(pageNavigation);
    }
}
