import { LightningElement, api } from 'lwc';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';

export default class ProfileImageDropdown extends LightningElement {
    @api isDelegate;
    @api hasProfilePic;
    @api user;
    icon_url = pp_icons + '/avatar-delegate-icon.svg';

    get fullName() {
        let user = this.user;
        if (user) {
            return user.Contact.FirstName + ' ' + user.Contact.LastName;
        }
        return null;
    }
    get profileIconName() {
        return this.isDelegate ? '' : 'participant_profile';
    }
}
