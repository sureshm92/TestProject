import { LightningElement, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RR_COMMUNITY_JS from '@salesforce/resourceUrl/rr_community_js';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
import USER_NAME from '@salesforce/label/c.PG_AS_F_Username';
import EDIT_PHOTO from '@salesforce/label/c.PP_AddProfilePhoto';
import ADD_PHOTO from '@salesforce/label/c.PP_EditProfilePhoto';
import REMOVE_PHOTO from '@salesforce/label/c.PP_Remove_Photo';
import WRONG_FORMAT from '@salesforce/label/c.TST_Screenshot_Wrong_Format';
import FILE_SIZE_EXCEEDED from '@salesforce/label/c.PP_File_Size_Exceeded';
import PHOTO_UPLOADED from '@salesforce/label/c.PP_AS_PHOTO_UPLOADED';
import PHOTO_REMOVED from '@salesforce/label/c.PP_AS_PHOTO_REMOVED';
import getProfilePicture from '@salesforce/apex/ProfilePictureController.getProfilePicture';
import saveAttachment from '@salesforce/apex/ProfilePictureController.saveAttachment';
import deletePicture from '@salesforce/apex/ProfilePictureController.deletePicture';

const MAX_FILE_SIZE = 3000000;
export default class PpActionAddProfilePhoto extends LightningElement {
    @api userId;
    @api userMode;
    @api userName;
    @api isDelegate;
    @api hasProfilePic = false;
    @api isRTL;
    @api isMobile;
    message = 'Drag profile picture here';
    isInitialized = false;
    pictureSrc;
    spinner;
    toggleButton;

    labels = {
        ERROR_MESSAGE,
        USER_NAME,
        ADD_PHOTO,
        EDIT_PHOTO,
        REMOVE_PHOTO,
        WRONG_FORMAT,
        FILE_SIZE_EXCEEDED,
        PHOTO_REMOVED,
        PHOTO_UPLOADED
    };

    connectedCallback() {
        loadScript(this, RR_COMMUNITY_JS)
            .then(() => {
                this.spinner = this.template.querySelector('c-web-spinner');
                this.spinner.show();
                this.initializeData();
            })
            .catch((error) => {
                this.showToast(this.labels.ERROR_MESSAGE, error.message, 'error');
            });
    }

    initializeData() {
        if (this.hasProfilePic) {
            getProfilePicture({ parentId: this.userId, userMode: this.userMode })
                .then((result) => {
                    let attachment = result;
                    this.pictureSrc = attachment;
                    this.spinner.hide();
                })
                .catch((error) => {
                    this.showToast(this.labels.ERROR_MESSAGE, error.message, 'error');
                });
        }
        this.isInitialized = true;
        this.spinner.hide();
    }

    /**CSS Realted Getters START*/

    get bodyContainerClass() {
        return this.isMobile ? 'slds-grid mobile-body' : 'slds-grid';
    }

    get avatarIconClass() {
        return this.hasProfilePic
            ? 'no-avatar-icon slds-align_absolute-center'
            : 'avatar-icon slds-align_absolute-center';
    }

    get photoLabelClass() {
        return this.isRTL ? 'photo-label rtl' : 'photo-label';
    }
    get userNameClass() {
        return this.isRTL ? 'user-name-rtl' : 'user-name';
    }

    get fileUploadClass() {
        return this.isRTL ? 'file-upload' : 'file-upload';
    }

    get removePhotoClass() {
        return this.hasProfilePic ? 'remove-photo' : 'remove-photo remove-photo-disabled';
    }

    /**CSS Realted Getters END*/

    get profileLabel() {
        return this.hasProfilePic ? this.labels.EDIT_PHOTO : this.labels.ADD_PHOTO;
    }

    onDrop() {
        let fileInput = this.template.querySelector('[data-id="file-upload"]');
        let file = fileInput.files[0];
        this.readFile(file);
    }

    readFile(uploadedFile) {
        if (uploadedFile) {
            if (!uploadedFile.type.match(/(image.*)/)) {
                this.showToast(this.labels.WRONG_FORMAT, this.labels.WRONG_FORMAT, 'error');
                return;
            }

            if (uploadedFile.size > MAX_FILE_SIZE) {
                this.showToast(
                    this.labels.FILE_SIZE_EXCEEDED,
                    this.labels.FILE_SIZE_EXCEEDED,
                    'error'
                );
                return;
            }

            let reader = new FileReader();
            let parentRef = this;
            reader.onloadend = function () {
                let fileContents = reader.result;
                let base64Mark = 'base64,';
                let dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

                fileContents = fileContents.substring(dataStart);
                parentRef.uploadFile(uploadedFile, fileContents);
                parentRef.pictureSrc = fileContents;
            };
            reader.readAsDataURL(uploadedFile);
        }
    }

    uploadFile(uploadedFile, fileContents) {
        if (this.spinner) {
            this.spinner.show();
        }
        saveAttachment({
            parentId: this.userId,
            fileName: uploadedFile.name,
            base64Data: encodeURIComponent(fileContents),
            contentType: uploadedFile.type
        })
            .then((result) => {
                getProfilePicture({ parentId: this.userId })
                    .then((response) => {
                        this.hasProfilePic = true;
                        this.pictureSrc = response;
                        this.message = this.labels.PHOTO_UPLOADED;
                        this.spinner.hide();
                        this.showToast(this.message, this.message, 'success');
                        setTimeout(() => {
                            this.reloadPage();
                        }, 2000);
                    })
                    .catch((err) => {
                        this.showToast(this.labels.ERROR_MESSAGE, err.message, 'error');
                    });
                this.spinner.hide();
            })
            .catch((error) => {
                this.showToast(this.labels.ERROR_MESSAGE, error.message, 'error');
            });
    }

    removePhoto() {
        if (this.hasProfilePic) {
            this.spinner.show();
            deletePicture({ parentId: this.userId })
                .then((response) => {
                    this.hasProfilePic = false;
                    this.message = this.labels.PHOTO_REMOVED;
                    this.spinner.hide();
                    this.showToast(this.message, this.message, 'success');
                    setTimeout(() => {
                        this.reloadPage();
                    }, 2000);
                })
                .catch((err) => {
                    this.showToast(this.labels.ERROR_MESSAGE, err.message, 'error');
                });
        }
    }

    reloadPage() {
        communityService.navigateToPage('account-settings?profileInformation');
        sessionStorage.setItem('Cookies', 'Accepted');
        window.location.reload(true);
    }

    showToast(titleText, messageText, variantType) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: titleText,
                message: '',
                variant: variantType
            })
        );
    }
}
