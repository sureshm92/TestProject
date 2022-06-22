import { LightningElement, api } from 'lwc';
import Viewing_as_Self from '@salesforce/label/c.Viewing_as_Self';
import Viewing_as_Participant from '@salesforce/label/c.Viewing_as_Participant';
import Viewing_as_Investigative_Site from '@salesforce/label/c.Viewing_as_Investigative_Site';
import Viewing_as_Referring_Provider from '@salesforce/label/c.Viewing_as_Referring_Provider';
import Space_Delegate from '@salesforce/label/c.Space_Delegate';
export default class ProfileHeaderIconInfo extends LightningElement {
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
        Space_Delegate
    };

    get fullName() {
        let user = this.user;
        return user.Contact.FirstName + ' ' + user.Contact.LastName;
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
        return '';
    }
    get accountSettingsClass() {
        return '';
    }
    get accSettSvgClass() {
        return '';
    }
    get accSettIconName() {
        return '';
    }
    get manageDelegatesClass() {
        return this.currentMode.participantState === 'ALUMNI' && !this.currentMode.isDelegate
            ? 'slds-hide'
            : '';
    }
    get manageDelSvgClass() {
        return '';
    }
    get manageDelIconName() {
        return '';
    }
    connectedCallback() {
        this.reset = true;
        let currentMode = this.currentMode;
        let mode = '';
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
}
