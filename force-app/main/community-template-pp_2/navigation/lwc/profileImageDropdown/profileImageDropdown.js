import { LightningElement, api } from 'lwc';
export default class ProfileImageDropdown extends LightningElement {
    @api isDelegate;
    @api hasProfilePic;
    @api user;

    get fullName() {
        let user = this.user;
        return user.Contact.FirstName + ' ' + user.Contact.LastName;
    }
    get profileIconName() {
        return this.isDelegate ? 'multiple-neutral-circle' : 'single-neutral';
    }
}
