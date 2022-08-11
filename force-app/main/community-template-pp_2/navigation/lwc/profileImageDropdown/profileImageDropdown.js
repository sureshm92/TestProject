import { LightningElement, api } from 'lwc';
export default class ProfileImageDropdown extends LightningElement {
    @api isDelegate;
    @api hasProfilePic;
    @api user;

    get fullName() {
        let user = this.user;
        if(user){
            return user.Contact.FirstName + ' ' + user.Contact.LastName;
        }
        return null;
    }
    get profileIconName() {
        return this.isDelegate ? 'delegate_profile' : 'participant_profile';
    }
}
