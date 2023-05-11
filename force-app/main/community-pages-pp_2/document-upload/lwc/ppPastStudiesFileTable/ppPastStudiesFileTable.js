import { LightningElement, track, api } from 'lwc';
import formFactor from '@salesforce/client/formFactor';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import fetchUploadedFiles from '@salesforce/apex/PpPastStudiesFilesController.fetchUploadedFiles';
import deleteFile from '@salesforce/apex/PpPastStudiesFilesController.deleteFile';
import profileTZ from '@salesforce/i18n/timeZone';

export default class PpPastStudiesFileTable extends LightningElement {
    noDocumentAvailable = pp_icons + '/' + 'noDocumentAvailable.svg';
    uploadNewDocuments = pp_icons + '/' + 'uploadNewDocuments.svg';
    noRecords = false;
    @api pageNumber = 1;
    isFile = true;
    isDelegate = false;
    totalRecord;
    isMobile = false;
    selectedmenu = 'Uploaded';
    selectedsortOption = 'Sort By';
    @api selectedStudyId;
    fileList;
    deleteFileID;
    saving;
    @api stopSpinner = false;
    isSpinnerRunning = false;
    sortOn = 'CreatedDate';
    sortType = 'DESC';
    @api isInitial;
    arrowDownDate = true; //desc
    arrowUpDate = false;
    arrowDownTitle = false; //desc
    arrowUpTitle = false;
    arrowDownType = false; //desc
    arrowUpType = false;
    firstClick = false;
    resetPagination = false;
    filePreview = '../apex/MedicalHistoryPreviewVF?resourceId=+';
    totalSize;
    curentSize;

    connectedCallback() {
        if (formFactor === 'Small' || formFactor === 'Medium') {
            this.isMobile = true;
        } else {
            this.isMobile = false;
        }

        if (communityService.getCurrentCommunityMode().currentDelegateId) {
            this.isDelegate = true;
        }
        if (!communityService.isDummy()) {
            this.communityTemplate = communityService.getCurrentCommunityTemplateName();
            if (this.isDelegate) {
                this.contID = communityService.getCurrentCommunityMode().currentDelegateId; //participant contact id
            } else {
                this.contID = communityService.getParticipantData().currentContactId; //part contact id
            }
        }
        this.isInitial = true;
        this.getTableFiles();
    }
    get timeZone() {
        return profileTZ;
    }
    @api resetPage() {
        this.arrowDownDate = true; //desc
        this.arrowUpDate = false;
        this.arrowDownTitle = false; //desc
        this.arrowUpTitle = false;
        this.arrowDownType = false; //desc
        this.arrowUpType = false;
        this.firstClick = false;
    }

    @api getTableFiles() {
        if (!this.stopSpinner) {
            this.saving = true;
            this.isSpinnerRunning = true;
        }
        fetchUploadedFiles({
            contID: this.contID,
            pageNumber: this.pageNumber,
            selectedStudyId: this.selectedStudyId,
            sortOn: this.sortOn,
            sortType: this.sortType,
            isInitial: this.isInitial,
            firstClick: this.firstClick
        })
            .then((result) => {
                this.fileList = result.cvList;
                this.totalRecord = result.totalCount;
                this.totalSize = this.fileList.length;
                this.curentSize = 0;

                var linkMap = new Map();
                if (result.previewLinks != undefined && result.previewLinks != null) {
                    for (var key in result.previewLinks) {
                        linkMap.set(key, result.previewLinks[key]);
                    }
                }
                for (var i = 0; i < this.fileList.length; i++) {
                    this.fileList[i].ContentDocumentId = this.fileList[i].ContentDocumentId;
                    if (linkMap.has(this.fileList[i].ContentDocumentId)) {
                        this.fileList[i].previewUrl = linkMap.get(
                            this.fileList[i].ContentDocumentId
                        );
                    }
                }

                const selectEvent = new CustomEvent('gettotalrecord', {
                    detail: this.totalRecord
                });
                this.dispatchEvent(selectEvent);

                if (this.resetPagination) {
                    const selectEventnew = new CustomEvent('resetpagination', {
                        detail: ''
                    });
                    this.dispatchEvent(selectEventnew);
                }

                this.resetPagination = false;
                if (this.fileList.length > 0) {
                    this.noRecords = false;
                } else {
                    if (this.isDelete) {
                        const selectEventnew = new CustomEvent('resetondelete', {
                            detail: ''
                        });
                        this.dispatchEvent(selectEventnew);
                    } else {
                        this.noRecords = true;
                    }
                }

                this.isDelete = false;
                if (this.isSpinnerRunning) {
                    this.saving = false;
                    this.isSpinnerRunning = false;
                    this.stopSpinner = true;
                }
            })
            .catch((error) => {
                this.saving = true;
                console.error('Error:', error);
            });
    }

    handleLazyLoading(event) {
        var scrollTop = event.target.scrollTop;
        var offsetHeight = event.target.offsetHeight;
        var scrollHeight = event.target.scrollHeight;
        this.counter = this.counter + 1;

        this.rowOffSet = this.rowOffSet + this.rowLimit;

        if (offsetHeight + scrollTop + 10 >= scrollHeight) {
            // this.getMoreFiles();
            this.pageNumber = this.counter;
            this.getTableFiles();
        }
    }

    filesListToShow;
    counter = 0;
    rowLimit = 20;
    rowOffSet = 0;
    getMoreFiles() {
        if (this.curentSize < this.totalSize) {
            var tempAccRec = [];
            var tempSize =
                this.curentSize + 10 < this.totalSize ? this.curentSize + 10 : this.totalSize;
            for (var i = 0; i < tempSize; i++) {
                tempAccRec.push(this.fileList[i]);
                console.log('OUTPUT : in addMoreAccounts', i);
                console.log('OUTPUT : in addMoreAccounts', this.fileList[i]);
            }
            this.rowOffSet = this.rowOffSet + this.rowLimit;

            this.getTableFiles();
            this.filesListToShow = tempAccRec;
            this.curentSize = this.filesListToShow.length;
        }
    }

    showArrow = false;
    openmodel = false;
    modalHeaderFilePage = false;
    previewHeader;
    deleteFileIDPreview;
    isPreview = false;
    onPreview(event) {
        var y = window.outerHeight / 2 + window.screenY - 500 / 2;
        var x = window.outerWidth / 2 + window.screenX - 600 / 2;
        window.open(
            event.currentTarget.dataset.id,
            'popup',
            'toolbar=no,scrollbars=no,resizable=no,top=' +
                y +
                ',left=' +
                x +
                ',width=600,height=500'
        );
        return false;
    }
    closeModal() {
        this.openmodel = false;
        this.modalHeaderFilePage = false;
        this.isPreview = false;
    }
    sortByTitle(event) {
        this.arrowUpDate = this.arrowDownDate = this.arrowUpType = this.arrowDownType = false;
        this.isInitial = false;
        this.firstClick = !this.firstClick; //true meaning desc title
        this.arrowUpTitle = this.firstClick; // up true asc
        this.arrowDownTitle = !this.firstClick; // down desc

        if (this.sortOn != 'Title') {
            this.firstClick = true; // true
            this.arrowUpTitle = true;
            this.arrowDownTitle = false;
        }

        this.sortOn = 'Title';
        this.pageNumber = 1;
        this.stopSpinner = false;
        this.resetPagination = true;
        this.getTableFiles();
    }

    sortByDate(event) {
        this.arrowUpTitle = this.arrowDownTitle = this.arrowUpType = this.arrowDownType = false;

        this.isInitial = false;
        this.firstClick = !this.firstClick; //true meaning desc title
        this.arrowUpDate = this.firstClick; // up true asc
        this.arrowDownDate = !this.firstClick; // down desc

        if (this.sortOn != 'CreatedDate') {
            this.firstClick = true; // true
            this.arrowDownDate = false;
            this.arrowUpDate = true;
        }

        this.sortOn = 'CreatedDate';
        this.pageNumber = 1;
        this.stopSpinner = false;
        this.resetPagination = true;
        this.getTableFiles();
    }

    sortByType(event) {
        this.arrowUpTitle =
            this.arrowDownTitle =
            this.arrowUpDate =
            this.arrowDownDate =
            this.showArrow =
                false;
        this.isInitial = false;
        this.firstClick = !this.firstClick; //true meaning desc title //false
        this.arrowUpType = this.firstClick; // up true asc //false
        this.arrowDownType = !this.firstClick; // down desc //true

        //asc meanin first click true meaning u up arrow true
        if (this.sortOn != 'FileType') {
            this.firstClick = true; // true
            this.arrowUpType = true;
            this.arrowDownType = false;
        }

        this.sortOn = 'FileType';
        this.pageNumber = 1;
        this.stopSpinner = false;
        this.resetPagination = true;
        this.getTableFiles();
    }

    get optionstab() {
        return [
            { label: 'Uploaded', value: 'uploaded' },
            { label: 'Shared with Me', value: 'sharewithme' }
        ];
    }
    handleChange(event) {
        this.value = event.detail.value;
    }
    openDeleteModel = false;
    onDelete(event) {
        this.openDeleteModel = true;
        this.deleteFileID = event.target.dataset.id;
    }

    handleCancelModel(event) {
        this.openDeleteModel = false;
    }
    isDelete = false;
    handleContinueModel(event) {
        this.openDeleteModel = false;
        this.saving = true;
        deleteFile({
            fileID: this.deleteFileID
        })
            .then((result) => {
                this.saving = false;
                this.stopSpinner = false;
                this.openmodel = false;
                this.modalHeaderFilePage = false;
                this.isPreview = false;
                this.isDelete = true;
                this.getTableFiles();
                this.template.querySelector('c-custom-toast-files-p-p').showToast('success','File deleted succesfully' ,'utility:success',1000);
            })
            .catch((error) => {
                console.error('Error:', error);
            });
    }
    get optionsSort() {
        return [
            { label: 'Title: A-Z', value: 'titleasc' },
            { label: 'Title: Z-A', value: 'titledesc' },
            { label: 'File Type: A-Z', value: 'filetypeasc' },
            { label: 'File Type: Z-A', value: 'filetypedesc' },
            { label: 'Date: Last Uploaded', value: 'datedesc' },
            { label: 'Date: First Uploaded', value: 'dateasc' }
        ];
    }

    opendropdown(event) {
        this.template.querySelectorAll('.D').forEach(function (L) {
            L.classList.toggle('slds-is-open');
        });
    }
    handleonblur(event) {
        let classListforUploaded = this.template.querySelector('.D').classList;

        if (classListforUploaded.contains('slds-is-open')) {
            this.template.querySelectorAll('.D').forEach(function (L) {
                L.classList.remove('slds-is-open');
            });
        }
        let classListforSort = this.template.querySelector('.Sort').classList;
        if (classListforSort.contains('slds-is-open')) {
            this.template.querySelectorAll('.Sort').forEach(function (L) {
                L.classList.remove('slds-is-open');
            });
        }
    }
    handlenewOnSelect(event) {
        this.selectedmenu = event.target.dataset.title;
    }
    handlenewOnSelectSort(event) {
        this.selectedsortOption = 'By: ' + event.target.dataset.title;
    }
    opendropdownSort(event) {
        this.template.querySelectorAll('.Sort').forEach(function (L) {
            L.classList.toggle('slds-is-open');
        });
    }
}
