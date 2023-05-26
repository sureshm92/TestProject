import { LightningElement, api } from 'lwc';
import getStudyList from '@salesforce/apex/PpPastStudiesFilesController.getStudyList';
import fetchUploadedFiles from '@salesforce/apex/PpPastStudiesFilesController.fetchUploadedFiles';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';
import PP_MyFiles from '@salesforce/label/c.PP_MyFiles';
import PP_SwitchStudyProgram from '@salesforce/label/c.PP_SwitchStudyProgram';
import formFactor from '@salesforce/client/formFactor';

export default class PpPastStudiesFiles extends LightningElement {
    sycnDropDown = pp_icons + '/' + 'arrow2-sync.svg';
    contID;
    isDelegate = false;
    isFile = true;
    studyList;
    studyListToShow = [];
    threedots_imgUrl = pp_icons + '/' + 'three_dots.png';
    communityTemplate;
    showDropdown = true;
    @api dropDownLabel;
    @api stopSpinnerChild;
    isMobile = false;
    isSaving = false;
    totalSize;
    curentSize;
    selectedStudy = '';
    studyListDropDown;
    selectedStudyId;
    isLoaded = false;

    label={PP_MyFiles,
        PP_SwitchStudyProgram

    };
    connectedCallback() {
        if (formFactor === 'Small') {
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
        this.isSaving = true;
        this.fetchData();
    }
    renderOnce = false;
    renderedCallback() {
        if (!this.renderOnce) {
            if (this.isMobile) {
                this.template.querySelectorAll('.D').forEach(function (L) {
                    L.classList.add('slds-size_12-of-12');
                });
                this.template.querySelectorAll('.D').forEach(function (L) {
                    L.classList.remove('slds-size_4-of-12');
                });
            } else {
                console.log('deks');
                this.template.querySelectorAll('.D').forEach(function (L) {
                    L.classList.remove('slds-size_12-of-12');
                });
                this.template.querySelectorAll('.D').forEach(function (L) {
                    L.classList.add('slds-size_4-of-12');
                });
            }
            this.renderOnce = true;
        }
    }
    fetchData() {
        this.isSaving = true;
        getStudyList({
            contID: this.contID,
            isDelegate: this.isDelegate
        })
            .then((result) => {
                this.isSaving = false;
                this.studyList = result;
                this.totalSize = result.length;
                this.curentSize = 0;
                this.addMoreStudies();
                this.dropDownLabel = result[0].Clinical_Trial_Profile__r.Study_Code_Name__c;
                this.selectedStudyId = result[0].Clinical_Trial_Profile__c;
                if (result.length > 1) {
                    this.showDropdown = true;
                } else {
                    this.showDropdown = false;
                }
                this.isLoaded = true;
                this.template.querySelector('c-pp-past-studies-file-table').getTableFiles();
            })
            .catch((error) => {
                console.error('Error:', error);
            });
    }

    addMoreStudies() {
        console.log('OUTPUT : in addMoreAccounts');
        if (this.curentSize < this.totalSize) {
            var tempAccRec = [];
            var tempSize =
                this.curentSize + 5 < this.totalSize ? this.curentSize + 5 : this.totalSize;
            for (var i = 0; i < tempSize; i++) {
                tempAccRec.push(this.studyList[i]);
            }
            this.studyListToShow = tempAccRec;
            this.curentSize = this.studyListToShow.length;
        }
    }

    handleLazyLoading(event) {
        var scrollTop = event.target.scrollTop;
        var offsetHeight = event.target.offsetHeight;
        var scrollHeight = event.target.scrollHeight;
        if (offsetHeight + scrollTop + 10 >= scrollHeight) {
            this.addMoreStudies();
        }
    }

    showActionMenu(event) {
        this.template.querySelectorAll('.D').forEach(function (L) {
            L.classList.toggle('slds-is-open');
        });
        this.addMoreAccounts();
    }
    callMethod(event) {
        let index = event.target.dataset.id;
        this.dropDownLabel = this.studyList[index].Clinical_Trial_Profile__r.Study_Code_Name__c;
        this.selectedStudyId = this.studyList[index].Clinical_Trial_Profile__c;
        this.stopSpinnerChild = false;
        this.template.querySelector('c-pp-past-studies-file-table').isInitial = true;
        this.template.querySelector('c-pp-past-studies-file-table').stopSpinner = false;
        this.template.querySelector('c-pp-past-studies-file-table').selectedStudyId =
            this.selectedStudyId;
        this.template.querySelector('c-pp-past-studies-file-table').pageNumber = 1;
        this.template.querySelector('c-pp-past-studies-file-table').getTableFiles();
        this.template.querySelector('c-pp-past-studies-file-table').resetPage();
        this.template.querySelector('c-pp-past-studies-file-table').resetCSS();
    }
    closeMenu() {
        this.template.querySelectorAll('.D').forEach(function (L) {
            L.classList.remove('slds-is-open');
        });
    }

    //pagination
    totalRecord;
    showZeroErr = false;
    initialLoad = true;
    page;
    pageChanged(event) {
        this.page = event.detail.page;
        this.template.querySelector('c-pp-past-studies-file-table').pageNumber = this.page;
        if (!this.initialLoad) {
            this.template.querySelector('c-pp-past-studies-file-table').stopSpinner = false;
            this.template.querySelector('c-pp-past-studies-file-table').getTableFiles();
        }
        this.initialLoad = false;
    }
    changePage(event) {
        let dir = event.detail;
        if (dir == 'next') {
            this.template.querySelector('c-pir_participant-pagination').nextPage();
        }
        if (dir == 'prev') {
            this.template.querySelector('c-pir_participant-pagination').previousPage();
        }
    }
    handleUpdate = false;
    handletotalrecord(event) {
        this.totalRecord = event.detail;
        this.handleUpdate = true;
        this.handleresetpageonupdate();
    }
    isResetOnUpdate = false;
    isResetPagination = false;
    handleresetpageonupdate() {
        this.initialLoad = true;
        if (this.totalRecord) {
            this.template.querySelector('c-pir_participant-pagination').totalRecords =
                this.totalRecord;
            this.template.querySelector('c-pir_participant-pagination').updateInprogress();
        }
        this.handleUpdate = false;
        this.initialLoad = false;
    }
    handleresetpagination(event) {
        this.isResetPagination = true;
        if (this.isResetPagination) {
            this.initialLoad = true;
            this.template.querySelector('c-pir_participant-pagination').totalRecords =
                this.totalRecord;
            this.template.querySelector('c-pir_participant-pagination').goToStart();
        }
        this.isResetPagination = false;
    }
    isDelete = false;
    handleresetondelete(event) {
        this.isDelete = true;
        if (this.isDelete) {
            this.initialLoad = true;
            this.template.querySelector('c-pir_participant-pagination').totalRecords =
                this.totalRecord;
            this.template.querySelector('c-pir_participant-pagination').previousPage();
            this.template.querySelector('c-pp-past-studies-file-table').pageNumber = this.page;
            this.template.querySelector('c-pp-past-studies-file-table').stopSpinner = false;
            this.template.querySelector('c-pp-past-studies-file-table').getTableFiles();
        }
        this.isDelete = false;
    }
}