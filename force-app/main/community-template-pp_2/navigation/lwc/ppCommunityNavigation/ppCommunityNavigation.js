import { LightningElement, api, track, wire } from 'lwc';
import getTrialDetail from '@salesforce/apex/StudyDetailViewController.getTrialDetail';
import gettelevisitData from '@salesforce/apex/StudyDetailViewController.gettelevisitData';
import menuDesktop from './ppCommunityNavigation.html';
import menuMobile from './ppCommunityNavigationMobile.html';
import menuTablet from './ppCommunityNavigationTab.html';
import navigationHelp from '@salesforce/label/c.Navigation_Help';
import navigationHome from '@salesforce/label/c.Navigation_Home';
import navigationMyStudy from '@salesforce/label/c.Navigation_My_Study';
import navigationMyProgram from '@salesforce/label/c.Navigation_My_Program';
import navigationResources from '@salesforce/label/c.Navigation_Resources';
import navigationMessages from '@salesforce/label/c.Navigation_Messages';
import navigationEDiary from '@salesforce/label/c.Navigation_eDiary';
import trailMatch from '@salesforce/label/c.Trial_Match';
import navigationResults from '@salesforce/label/c.PP_Tab_Results';
import navigationVisits from '@salesforce/label/c.PP_Tab_Visits';
import navigationEvents from '@salesforce/label/c.PP_Tab_Events';
import navigationProgram from '@salesforce/label/c.Navigation_AboutProgram';
import navigationStudy from '@salesforce/label/c.Navigation_AboutStudy';
import navigationFiles from '@salesforce/label/c.PP_Tab_Files';
import navigationTasks from '@salesforce/label/c.PG_SW_Tab_Tasks';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
import televisits from '@salesforce/label/c.Televisits';
import navigationPastStudy from '@salesforce/label/c.Navigation_Past_Studies';
import desktopLogos from '@salesforce/resourceUrl/PP_DesktopLogos';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DEVICE from '@salesforce/client/formFactor';

export default class PpCommunityNavigation extends LightningElement {
    @api communityServic;
    @api isRTL;
    @api showSideMenu;
    @track participantTabs = [];
    @track participantTabsOne = [];
    @track participantTabsTwo = [];
    currentPageName;
    navDivider = desktopLogos + '/Nav_Tab_Divider.svg';
    allPagesMap = [];
    allPagesSubMenu = [];
    @track submenu = [];
    baseLink;
    showVisits = false;
    showResults = false;
    showMore = false;
    showAboutProgram = false;
    showAboutStudy = false;
    showEdaries = false;
    isInitialized = false;
    showAboutTelevisit = false;
    desktop = false;
    menuCss = 'phone-menu-background nav-menu slds-border_top ';
    showSubMenu = false;
    @api isInitialLoad = false;
    hasRendered = false;
    shouldDisplayFilesTab = false;
    shouldDisplayPastStudyTab = false;
    @track isTablet;
    iosString;
    @track iosString2;
    msgs;
    count = 0;
    connectedCallback() {
        window.addEventListener('orientationchange', this.onOrientationChange);
    }
    onOrientationChange = () => {
        this.participantTabs = [];
        this.participantTabsOne = [];
        this.participantTabsTwo = [];
        this.isTabletMenu();
        this.populateNavigationItems();
    };
    renderedCallback() {
        if (!this.hasRendered) {
            this.hasRendered = true;
            this.baseLink = window.location.origin;
            this.initializeDataForDOM();
            DEVICE != 'Small' ? (this.desktop = true) : (this.desktop = false);
        }
    }
    isTabletMenu() {
        let orientation = screen.orientation.type;
        let portrait = true;
        if (orientation === 'landscape-primary') {
            portrait = false;
        }
        if (window.innerWidth >= 768 && window.innerWidth < 1279 && portrait) {
            if (/iphone|ipad|ipod/i.test(navigator.userAgent.toLowerCase())) {
                this.isTablet = true;
                return true;
            } else if (/macintel|iPad Simulator/i.test(navigator.platform.toLowerCase())) {
                this.isTablet = true;
                return true;
            }
        } else {
            this.isTablet = false;
        }
        return false;
    }
    //template toggle
    render() {
        this.count = this.count += 1;
        this.iosString2 = this.isTabletMenu();
        if (this.isTablet) {
            return menuTablet;
        }
        return DEVICE == 'Large' ? menuDesktop : menuMobile;
    }
    @api
    handleCloseHamberungMenu() {
        let mobileDiv = this.template.querySelector(`[data-id="mobileMenu"]`);
        if (mobileDiv && !mobileDiv.classList.contains('slds-hide')) {
            mobileDiv.classList.add('slds-hide');
        }
        this.showSubMenu = false;
    }
    get handleDynamicCSS() {
        return 'font-size: 50px;color: #FFFFFF;';
    }
    @api
    handleClick() {
        let mobileDiv = this.template.querySelector(`[data-id="mobileMenu"]`);
        let element = this.template.querySelector(`[data-id="my-menu"]`);
        mobileDiv && mobileDiv.classList.contains('slds-hide')
            ? mobileDiv.classList.remove('slds-hide')
            : mobileDiv.classList.add('slds-hide');
        element && element.classList.contains('slds-is-open')
            ? element.classList.remove('slds-is-open')
            : '';
        this.showSubMenu = false;
    }
    handleNavigationSubMenu(event) {
        if (DEVICE != 'Large') {
            let mobileDiv = this.template.querySelector(`[data-id="mobileMenu"]`);
            mobileDiv && !mobileDiv.classList.contains('slds-hide')
                ? mobileDiv.classList.add('slds-hide')
                : '';
        }
        if (event.currentTarget.dataset.pagename) {
            this.communityServic.navigateToPage(event.currentTarget.dataset.pagename);
        }
        let element = this.template.querySelector('.my-submenuopen');
        if (element) {
            element.classList.remove('block-submenu-onblur');
            this.removeElementFocus();
        }
    }
    handleNavigationMoreButton(event) {
        if (event.currentTarget.dataset.pagename) {
            this.communityServic.navigateToPage(event.currentTarget.dataset.pagename);
        }
        let element = this.template.querySelector('.my-submenuopenone');
        if (element) {
            element.classList.remove('block-submenu-onblur');
            this.removeElementFocus();
        }
    }
    initializeDataForDOM() {
        if (communityService.isInitialized()) {
            if (!this.isInitialLoad && !this.desktop) {
                //add css class for mobile
                let mobileDiv = this.template.querySelector(`[data-id="mobileMenu"]`);
                mobileDiv && mobileDiv.classList.contains('mobileMenu')
                    ? mobileDiv.classList.add('slds-hide')
                    : 'Not Today!';
                this.isInitialLoad = true;
            }
            this.initializeData();
        }
    }
    initializeData() {
        if (communityService.isInitialized()) {
            var recId = communityService.getUrlParameter('id');
            var userMode = communityService.getUserMode();
            if (communityService.isDummy()) {
                const loadTelevisitBanner = true;
                const valueChangeEvent = new CustomEvent('handleLoadTelevisitBanner', {
                    detail: { loadTelevisitBanner }
                });
                this.dispatchEvent(valueChangeEvent);
            } else {
                setTimeout(() => {
                    getTrialDetail({ trialId: recId, userMode: userMode, isNewPP: true })
                        .then((result) => {
                            let td = JSON.parse(result);
                            this.shouldDisplayFilesTab = td.tabvisiblity.isFileTabVisiblity;
                            this.shouldDisplayPastStudyTab = td.tabvisiblity.isPastStudyVisible;
                            this.showVisits = td.tabs?.some(
                                (studyTab) => studyTab.id == 'tab-visits'
                            );
                            this.showResults = td.tabs?.some(
                                (resultTab) => resultTab.id == 'tab-lab-results'
                            );
                            this.showAboutProgram = td.pe?.Clinical_Trial_Profile__r?.Is_Program__c;
                            this.showAboutStudy = !this.showAboutProgram;
                            this.showEdaries =
                                td.perInTrail &&
                                td.pe?.Clinical_Trial_Profile__r?.ECOA_Is_Avaialble__c;
                            if (this.showAboutStudy) {
                                this.setVisResultsAvailable();
                            }

                            if (
                                td.pe &&
                                td.pe.Clinical_Trial_Profile__r.Televisit_Vendor_is_Available__c
                            ) {
                                this.getTelevisitDetails(td.pe.Study_Site__c);
                            } else {
                                this.showAboutTelevisit = false;
                                if (this.participantTabs.length < 1) {
                                    this.populateNavigationItems();
                                }
                                this.isInitialized = true;
                            }
                        })
                        .catch((error) => {
                            this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
                        });
                }, 10);
            }
        }

        // if (this.spinner) {
        //     this.spinner.hide();
        // }
    }
    getTelevisitDetails(studysiteId) {
        gettelevisitData({ siteId: studysiteId })
            .then((result) => {
                this.showAboutTelevisit = result;
                if (this.participantTabs.length < 1) {
                    this.populateNavigationItems();
                }
                this.isInitialized = true;
            })
            .catch((error) => {
                this.showErrorToast(ERROR_MESSAGE, error.message, 'error');
            });
    }
    populateNavigationItems() {
        this.allPagesMap = {
            help: {
                page: 'help',
                label: navigationHelp,
                icon: 'help-wheel'
            },
            'participant-home': {
                page: '',
                label: navigationHome,
                icon: 'icon-home-pplite-new',
                displayIcon: true
            },
            'my-study': {
                page: '',
                label: this.showAboutProgram ? navigationMyProgram : navigationMyStudy,
                icon: 'folder_study',
                expand: true,
                displayIcon: false
            },
            tasks: {
                page: 'tasks',
                label: navigationTasks,
                icon: 'icon_bell'
            },
            resources: {
                page: 'resources',
                label: navigationResources,
                icon: 'folder_study'
            },
            'past-studies': {
                page: 'past-studies',
                label: navigationPastStudy,
                icon: 'Past_study_icon'
            },
            messages: {
                page: 'messages',
                label: navigationMessages,
                icon: 'message_menu_icon',
                ismsg: true
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
                page: 'visits',
                label: navigationVisits,
                icon: '',
                visible: this.showAboutProgram ? false : this.showVisits,
                parentMenu: this.showAboutProgram ? navigationMyProgram : navigationMyStudy
            },
            events: {
                page: 'events',
                label: navigationEvents,
                icon: '',
                visible: this.showAboutProgram ? this.showVisits : false,
                parentMenu: this.showAboutProgram ? navigationMyProgram : navigationMyStudy
            },
            'about-televisit': {
                page: 'televisit',
                label: televisits,
                icon: '',
                visible: this.showAboutTelevisit,
                parentMenu: this.showAboutProgram ? navigationMyProgram : navigationMyStudy
            },
            results: {
                page: 'results',
                label: navigationResults,
                icon: '',
                visible: this.showResults,
                parentMenu: this.showAboutProgram ? navigationMyProgram : navigationMyStudy
            },
            'e-diaries': {
                page: 'e-diaries',
                label: navigationEDiary,
                icon: 'icon-e-diaries',
                visible: this.showEdaries,
                parentMenu: this.showAboutProgram ? navigationMyProgram : navigationMyStudy
            },
            files: {
                page: 'files',
                link: this.baseLink + '/pp/s/files',
                label: navigationFiles,
                icon: '',
                visible: this.shouldDisplayFilesTab,
                parentMenu: this.showAboutProgram ? navigationMyProgram : navigationMyStudy
            },

            'about-study': {
                page: 'about-study-and-overview',
                label: navigationStudy,
                icon: '',
                visible: this.showAboutStudy,
                parentMenu: this.showAboutProgram ? navigationMyProgram : navigationMyStudy
            },
            'about-program': {
                page: 'overview',
                label: navigationProgram,
                icon: '',
                visible: this.showAboutProgram,
                parentMenu: this.showAboutProgram ? navigationMyProgram : navigationMyStudy
            }
        };
        this.allPagesSubMenuTwo = {
            resources: {
                page: 'resources',
                label: navigationResources,
                icon: 'folder_study',
                visible: true
            },
            'trial-match': {
                page: 'trial-match',
                label: trailMatch,
                icon: 'trial-match-mob',
                visible: true
            },
            messages: {
                page: 'messages',
                label: navigationMessages,
                icon: '',
                visible: true
            },
            help: {
                page: 'help',
                label: navigationHelp,
                icon: '',
                visible: true
            }
        };
        this.isTabletMenu();
        this.participantTabs.push(this.allPagesMap['participant-home']);
        if (this.communityServic.getCurrentCommunityMode().currentPE) {
            this.participantTabs.push(this.allPagesMap['my-study']);
        }
        if (
            this.communityServic.getCurrentCommunityMode().hasPastStudies &&
            this.shouldDisplayPastStudyTab
        )
            //shouldDisplayPastStudyTab chekc is for primary delegate
            this.participantTabs.push(this.allPagesMap['past-studies']);
        if (this.communityServic.getEDiaryVisible()) {
            if (this.communityServic.getCurrentCommunityMode().participantState === 'PARTICIPANT') {
                if (communityService.getCurrentCommunityTemplateName() != 'PatientPortal') {
                    this.participantTabs.push(this.allPagesMap['e-diaries']);
                }
            }
        }
        if (this.communityServic.getTrialMatchVisible()) {
            if (this.communityServic.getCurrentCommunityMode().participantState === 'PARTICIPANT') {
                if (communityService.getCurrentCommunityTemplateName() != 'PatientPortal') {
                    this.participantTabs.push(this.allPagesMap['trial-match']);
                }
            }
        }
        this.participantTabs.push(this.allPagesMap['tasks']);
        this.participantTabs.push(this.allPagesMap['resources']);
        if (this.communityServic.getMessagesVisible()) {
            if (communityService.getCurrentCommunityTemplateName() === 'PatientPortal') {
                this.participantTabs.push(this.allPagesMap['messages']);
            }
        }
        this.participantTabs.push(this.allPagesMap['help']);
        const i = this.participantTabs.findIndex((e) => e.page === 'messages');
        if (i > -1 && this.isTablet) {
            this.msgs = this.participantTabs[i];
            this.participantTabs[i] = this.participantTabs[2];
            this.participantTabs[2] = this.msgs;
        }
        this.participantTabsOne = this.participantTabs.slice(0, 3);
        this.participantTabsTwo = this.participantTabs.slice(3, this.participantTabs.length);
        this.submenu = Object.keys(this.allPagesSubMenu).map((key) => ({
            key: key,
            ...this.allPagesSubMenu[key]
        }));
        const loadTelevisitBanner = true;
        const valueChangeEvent = new CustomEvent('handleLoadTelevisitBanner', {
            detail: { loadTelevisitBanner }
        });
        this.dispatchEvent(valueChangeEvent);
    }
    handleMessageNotification(event) {
        if (!this.desktop) {
            this.dispatchEvent(
                new CustomEvent('msgnotify', {
                    detail: {
                        message: event.detail.message
                    }
                })
            );
        }
    }
    handleNavigation(event) {
        if (!this.desktop) {
            let mobileDiv = this.template.querySelector(`[data-id="mobileMenu"]`);
            mobileDiv && !mobileDiv.classList.contains('slds-hide')
                ? mobileDiv.classList.add('slds-hide')
                : '';
        }
        if (event.currentTarget.dataset.pageName) {
            this.currentPageName = event.currentTarget.dataset.pageName;
            this.updateCurrentPage(this.currentPageName);
        }
        try {
            //!this.showSideMenu ? (this.menuCss += 'toggleClass') : '';
            this.communityServic.navigateToPage(event.currentTarget.dataset.pageName);
            this.currentPageName = this.communityServic.getPageName();
            this.removeElementFocus();
        } catch (e) {
            console.error(e);
        }
    }
    handleNavKeyDown(event) {
        if (event.key === 'Enter') {
            event.preventDefault();
            this.handleNavigation(event);
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
    dropdownMenu(event) {
        this.newVar = !this.newVar;
        var element = this.template.querySelector('.my-menu');
        var headerMenu = element.getAttribute('data-key');
        var subMenu = Object.keys(this.allPagesSubMenu).map((key) => ({
            key: key,
            ...this.allPagesSubMenu[key]
        }));
        //filtering submenu based on parentmenu clicked
        this.submenu = subMenu.filter((subItem) => subItem.parentMenu == headerMenu);
        if (this.submenu && DEVICE != 'Large') {
            this.showSubMenu = !this.showSubMenu;
        }
        var isOpen = element.classList.contains('slds-is-open');
        //dropdown toggle->adds class if second param true and remove if false
        element.classList.toggle('slds-is-open', !isOpen);
        event.stopPropagation();
    }
    dropdownMenuTwo(event) {
        this.newVar = !this.newVar;
        var element = this.template.querySelector('.my-menuOne');
        var headerMenu = element.getAttribute('data-key');
        var subMenu = Object.keys(this.allPagesSubMenuTwo).map((key) => ({
            key: key,
            ...this.allPagesSubMenuTwo[key]
        }));
        //filtering submenu based on parentmenu clicked
        this.submenu = subMenu.filter((subItem) => subItem.parentMenu == headerMenu);
        if (this.submenu && DEVICE != 'Large') {
            this.showSubMenu = !this.showSubMenu;
        }
        var isOpen = element.classList.contains('slds-is-open');
        //dropdown toggle->adds class if second param true and remove if false
        element.classList.toggle('slds-is-open', !isOpen);
        event.stopPropagation();
    }
    handleOnMouseOver(event) {
        this.template.querySelector('.my-submenuopen').classList.add('block-submenu-onblur');
    }
    handleOnMouseLeave(event) {
        this.template.querySelector('.my-submenuopen').classList.remove('block-submenu-onblur');
    }
    handleOnMouseOverOne(event) {
        this.template.querySelector('.my-submenuopenone').classList.add('block-submenu-onblur');
    }
    handleOnMouseLeaveOne(event) {
        this.template.querySelector('.my-submenuopenone').classList.remove('block-submenu-onblur');
    }
    //on removing focus from dropdown
    removeElementFocus(event) {
        var element = this.template.querySelector('.slds-is-open');
        //Stop closing sub menu drop when we click on sub menu item.
        if (element && !element.classList.contains('block-submenu-onblur')) {
            element.classList.remove('slds-is-open');
        }
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
        this.participantTabs = [];
        this.initializeDataForDOM();
    }
    async setVisResultsAvailable() {
        await this.communityServic.setVisResultsAvailable(this.showResults);
    }
}
