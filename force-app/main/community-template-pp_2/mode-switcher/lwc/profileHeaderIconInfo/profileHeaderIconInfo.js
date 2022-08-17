import { LightningElement, api } from 'lwc';
import Viewing_as_Self from '@salesforce/label/c.Viewing_as_Self';
import Viewing_as_Participant from '@salesforce/label/c.Viewing_as_Participant';
import Viewing_as_Investigative_Site from '@salesforce/label/c.Viewing_as_Investigative_Site';
import Viewing_as_Referring_Provider from '@salesforce/label/c.Viewing_as_Referring_Provider';
import Space_Delegate from '@salesforce/label/c.Space_Delegate';
import PP_ManageDelegates from '@salesforce/label/c.PP_ManageDelegates';
import PP_Account_Settings from '@salesforce/label/c.PP_Account_Settings';
import { NavigationMixin } from 'lightning/navigation';
export default class ProfileHeaderIconInfo extends NavigationMixin(LightningElement) {
    @api user;
    @api currentMode;
    @api hasProfilePic;
    @api isRTL;
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
    get profileIconName() {
        if (this.currentMode) {
            return this.currentMode.isDelegate ? 'delegate_switcher' : 'participant_switcher';
        }
        return '';
    }
    get accountSettingsClass() {
        return '';
    }
    get accSettSvgClass() {
        return '';
    }
    get manageDelegatesClass() {
        if (this.currentMode) {
            return this.currentMode.participantState === 'ALUMNI' && !this.currentMode.isDelegate
                ? 'slds-hide'
                : 'slds-col switcher-list';
        }
        return '';
    }
    get manageDelSvgClass() {
        return '';
    }

    connectedCallback() {
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
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'account-settings'
            }
        });
        this.doCloseModal();
    }
    doCloseModal() {
        const pageNavigation = new CustomEvent('pagenavigation');
        this.dispatchEvent(pageNavigation);
    }
}
