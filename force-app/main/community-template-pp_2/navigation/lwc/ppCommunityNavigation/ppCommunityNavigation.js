import { LightningElement, api, track, wire } from 'lwc';
import getTrialDetail from '@salesforce/apex/StudyDetailViewController.getTrialDetail';
import gettelevisitData from '@salesforce/apex/StudyDetailViewController.gettelevisitData';
import menuDesktop from './ppCommunityNavigation.html';
import menuMobile from './ppCommunityNavigationMobile.html';
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
import navigationTasks from '@salesforce/label/c.PG_SW_Tab_Tasks';
import ERROR_MESSAGE from '@salesforce/label/c.CPD_Popup_Error';
import televisits from '@salesforce/label/c.Televisits';
import navigationPastStudy from '@salesforce/label/c.Navigation_Past_Studies';
import desktopLogos from '@salesforce/resourceUrl/PP_DesktopLogos';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DEVICE from '@salesforce/client/formFactor';
import { publish, MessageContext } from 'lightning/messageService';
import messagingChannel from '@salesforce/messageChannel/ppVisResults__c';

export default class PpCommunityNavigation extends LightningElement {
    @api communityServic;
    @api isRTL;
    @api showSideMenu;
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
    showAboutTelevisit = false;
    desktop = false;
    menuCss = 'phone-menu-background nav-menu slds-border_top ';
    showSubMenu = false;
    @api isInitialLoad = false;
    hasRendered = false;
    @wire(MessageContext)
    messageContext;
    renderedCallback() {
        if (!this.hasRendered) {
            this.hasRendered = true;
            this.baseLink = window.location.origin;
            this.initializeDataForDOM();
            DEVICE != 'Small' ? (this.desktop = true) : (this.desktop = false);
        }
    }
    //template toggle
    render() {
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
        this.spinner = this.template.querySelector('c-web-spinner');
        if (this.spinner) {
            this.spinner.show();
        }
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
                getTrialDetail({ trialId: recId, userMode: userMode, isNewPP: true })
                    .then((result) => {
                        let td = JSON.parse(result);
                        this.showVisits = td.tabs?.some((studyTab) => studyTab.id == 'tab-visits');
                        this.showResults = td.tabs?.some(
                            (resultTab) => resultTab.id == 'tab-lab-results'
                        );
                        this.showAboutProgram = td.pe?.Clinical_Trial_Profile__r?.Is_Program__c;
                        this.showAboutStudy = !this.showAboutProgram;
                        if (this.showAboutStudy) {
                            this.communityServic.setVisResultsAvailable(this.showResults);
                        }
                        if (DEVICE != 'Large' && this.showAboutStudy && this.showResults) {
                            let isResultTab = {
                                isVisResultsAvailable: this.showResults
                            };
                            publish(this.messageContext, messagingChannel, isResultTab);
                        }

                        if (
                            td.pe &&
                            td.pe.Clinical_Trial_Profile__r.Televisit_Vendor_is_Available__c
                        ) {
                            this.gettelevisitDetails(td.pe.Study_Site__c);
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
            }
        }

        if (this.spinner) {
            this.spinner.hide();
        }
    }
    gettelevisitDetails(studysiteId) {
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

        this.participantTabs.push(this.allPagesMap['participant-home']);
        if (this.communityServic.getCurrentCommunityMode().currentPE) {
            this.participantTabs.push(this.allPagesMap['my-study']);
        }
        if (this.communityServic.getCurrentCommunityMode().hasPastStudies)
            this.participantTabs.push(this.allPagesMap['past-studies']);
        if (this.communityServic.getEDiaryVisible()) {
            if (this.communityServic.getCurrentCommunityMode().participantState === 'PARTICIPANT') {
                if (communityService.getCurrentCommunityTemplateName() != 'PatientPortal') {
                    this.participantTabs.push(this.allPagesMap['e-diaries']);
                }
            }
        }
        if (this.communityServic.getMessagesVisible()) {
            if (communityService.getCurrentCommunityTemplateName() != 'PatientPortal') {
                this.participantTabs.push(this.allPagesMap['messages']);
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
        this.participantTabs.push(this.allPagesMap['help']);
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
    handleOnMouseOver(event) {
        this.template.querySelector('.my-submenuopen').classList.add('block-submenu-onblur');
    }
    handleOnMouseLeave(event) {
        this.template.querySelector('.my-submenuopen').classList.remove('block-submenu-onblur');
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
}
