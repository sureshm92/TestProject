import { LightningElement, api, track } from 'lwc';
import getTrialDetail from '@salesforce/apex/StudyDetailViewController.getTrialDetail';
import navigationHelp from '@salesforce/label/c.Navigation_Help';
import navigationHome from '@salesforce/label/c.Navigation_Home';
import navigationMyStudy from '@salesforce/label/c.Navigation_My_Study';
import navigationResources from '@salesforce/label/c.Navigation_Resources';
import navigationMessages from '@salesforce/label/c.Navigation_Messages';
import navigationEDiary from '@salesforce/label/c.Navigation_eDiary';
import trailMatch from '@salesforce/label/c.Trial_Match';
import navigationResults from '@salesforce/label/c.PG_SW_Tab_Lab_Results';
import navigationVisits from '@salesforce/label/c.PG_SW_Tab_Visits';
import navigationProgram from '@salesforce/label/c.Navigation_AboutProgram';
import navigationStudy from '@salesforce/label/c.Navigation_AboutStudy';
import navigationTasks from '@salesforce/label/c.PG_SW_Tab_Tasks';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
import desktopLogos from '@salesforce/resourceUrl/PP_DesktopLogos';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DEVICE from '@salesforce/client/formFactor';

export default class PpCommunityNavigation extends LightningElement {
    @api communityServic;
    @api isRTL;
    @track participantTabs = [];
    currentPageName;
    navDivider = desktopLogos + '/Nav_Tab_Divider.svg';
    allPagesMap = [];
    allPagesSubMenu = [];
    @track submenu = [];
    baseLink;
    showVisits = false;
    showResults = false;
    showAboutProgram = false;
    showAboutStudy = false;
    isInitialized = false;
    desktop=false;

    connectedCallback() {
        this.baseLink = window.location.origin;
        this.initializeData();
        DEVICE != 'Small' ? (this.desktop = true) : (this.desktop = false);
    }
    initializeData() {
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) {
            this.spinner.show();
        }
        if (communityService.isInitialized()) {
            var recId = communityService.getUrlParameter('id');
            var userMode = communityService.getUserMode();
            getTrialDetail({ trialId: recId, userMode: userMode })
                .then((result) => {
                    let td = JSON.parse(result);
                    this.showVisits = td.tabs?.some(
                        (studyTab) => studyTab.title == navigationVisits
                    );
                    this.showResults = td.tabs?.some(
                        (resultTab) => resultTab.title == navigationResults
                    );
                    this.showAboutProgram = td.pe?.Clinical_Trial_Profile__r?.Is_Program__c;
                    this.showAboutStudy = !this.showAboutProgram;
                    this.populateNavigationItems();
                    this.isInitialized = true;
                })
                .catch((error) => {
                    this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
                });
        }

        if (this.spinner) {
            this.spinner.hide();
        }
    }
    populateNavigationItems() {
        this.allPagesMap = {
            help: {
                page: 'help',
                label: navigationHelp,
                icon: 'help'
            },
            'participant-home': {
                page: '',
                label: navigationHome,
                icon: 'icon-home-pplite-new',
                displayIcon: true
            },
            'my-study': {
                page: '',
                label: navigationMyStudy,
                icon: 'about-the-study',
                expand: true,
                displayIcon: false
            },
            tasks: {
                page: 'tasks',
                label: navigationTasks,
                icon: 'tasks'
            },
            resources: {
                page: 'resources',
                label: navigationResources,
                icon: 'resources'
            },
            'past-studies': {
                page: 'past-studies',
                label: navigationHelp,
                icon: 'plan-check-in-square'
            },
            messages: {
                page: 'messages',
                label: navigationMessages,
                icon: 'icon-envelope'
            },
            'e-diaries': {
                page: 'e-diaries',
                label: navigationEDiary,
                icon: 'icon-e-diaries'
            },
            'trial-match': {
                page: 'trial-match',
                label: trailMatch,
                icon: 'trial-match-mob'
            }
        };
        //variable for dropdown items
        this.allPagesSubMenu = {
            visits: {
                link: this.baseLink + '/pp/s/visits',
                label: navigationVisits,
                icon: '',
                visible: this.showVisits,
                parentMenu: navigationMyStudy
            },
            results: {
                link: this.baseLink + '/pp/s/results',
                label: navigationResults,
                icon: '',
                visible: this.showResults,
                parentMenu: navigationMyStudy
            },
            'about-study': {
                link: this.baseLink + '/pp/s/study-workspace',
                label: navigationStudy,
                icon: '',
                visible: this.showAboutStudy,
                parentMenu: navigationMyStudy
            },
            'about-program': {
                link: this.baseLink + '/pp/s/overview',
                label: navigationProgram,
                icon: '',
                visible: this.showAboutProgram,
                parentMenu: navigationMyStudy
            }
        };

        this.participantTabs.push(this.allPagesMap['participant-home']);
        if (this.communityServic.getCurrentCommunityMode().currentPE) {
            this.participantTabs.push(this.allPagesMap['my-study']);
        }
        if (this.communityServic.getCurrentCommunityMode().hasPastStudies)
            this.participantTabs.push(this.allPagesMap['past-studies']);
        if (this.communityServic.getEDiaryVisible()) {
            if (this.getCurrentCommunityMode().participantState === 'PARTICIPANT') {
                this.participantTabs.push(this.allPagesMap['e-diaries']);
            }
        }
        if (this.communityServic.getMessagesVisible()) {
            this.participantTabs.push(this.allPagesMap['messages']);
        }
        if (this.communityServic.getTrialMatchVisible()) {
            if (this.communityServic.getCurrentCommunityMode().participantState === 'PARTICIPANT') {
                this.participantTabs.push(this.allPagesMap['trial-match']);
            }
        }
        this.participantTabs.push(this.allPagesMap['resources']);
        this.participantTabs.push(this.allPagesMap['tasks']);
        this.participantTabs.push(this.allPagesMap['help']);
        this.submenu = Object.keys(this.allPagesSubMenu).map((key) => ({
            key: key,
            ...this.allPagesSubMenu[key]
        }));
    }

    handleNavigation(event) {
        if (event.currentTarget.dataset.pageName) {
            this.currentPageName = event.currentTarget.dataset.pageName;
            this.updateCurrentPage(this.currentPageName);
        }
        try {
            this.communityServic.navigateToPage(event.currentTarget.dataset.pageName);
            currentPageName = this.communityServic.getPageName();
        } catch (e) {
            console.error(e);
        }
    }

    updateCurrentPage(pageNam) {
        let pageDetails;
        if (pageNam) {
            pageDetails = this.participantTabs.filter(function (item) {
                return item.page == pageNam;
            });
        }
        let page = pageDetails[0].label;
        document.title = page;
    }
    get iconName() {
        return this.navDivider;
    }
    // onclick of header menu for populating submenu and toggling dropdown
    dropdownMenu() {
        var element = this.template.querySelector('.my-menu');
        var headerMenu = element.getAttribute('data-key');
        var subMenu = Object.keys(this.allPagesSubMenu).map((key) => ({
            key: key,
            ...this.allPagesSubMenu[key]
        }));
        //filtering submenu based on parentmenu clicked
        this.submenu = subMenu.filter((subItem) => subItem.parentMenu == headerMenu);
        var isOpen = element.classList.contains('slds-is-open');
        //dropdown toggle->adds class if second param true and remove if false
        element.classList.toggle('slds-is-open', !isOpen);
    }
    //on removing focus from dropdown
    removeElementFocus() {
        var element = this.template.querySelector('.my-menu');
        element.classList.remove('slds-is-open');
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
    @api forceRefresh() {
        this.isInitialized = false;
        this.participantTabs=[];
        this.initializeData();
    }
}
