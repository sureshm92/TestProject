import { LightningElement, api } from 'lwc';
import navigationHelp from '@salesforce/label/c.Navigation_Help';
import navigationHome from '@salesforce/label/c.Navigation_Home';
import navigationMyStudy from '@salesforce/label/c.Navigation_My_Study';
import navigationResources from '@salesforce/label/c.Navigation_Resources';
import navigationMessages from '@salesforce/label/c.Navigation_Messages';
import navigationEDiary from '@salesforce/label/c.Navigation_eDiary';
import trailMatch from '@salesforce/label/c.Trial_Match';

export default class PpCommunityNavigationMobile extends LightningElement {
    @api communityServic; 
    @api showSideMenu;

    participantTabs = [];
    currentPageName;

    menuCss = "phone-menu-background nav-menu slds-border_top slds-p-vertical_large ";

    
    connectedCallback() {
        this.populateNavigationItems();
    }
    populateNavigationItems() {       
        let allPagesMap = {
            help: {
                page: 'help',
                label: navigationHelp,
                icon: 'help'
            },
            'participant-home': {
                page: '',
                label: navigationHome,
                icon: 'icon-home-brand-new'
            },
            'my-study': {
                page: 'study-workspace',
                label: navigationMyStudy,
                icon: 'about-the-study'
            },
            resources: {
                page: 'study-workspace',
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
        this.participantTabs.push(allPagesMap['participant-home']);
        if (this.communityServic.getCurrentCommunityMode().currentPE) {
            this.participantTabs.push(allPagesMap['my-study']);
        } else {
            this.participantTabs.push(allPagesMap['resources']);
        }
        if (this.communityServic.getCurrentCommunityMode().hasPastStudies)
            this.participantTabs.push(allPagesMap['past-studies']);
        if (this.communityServic.getEDiaryVisible()) {
            if (this.getCurrentCommunityMode().participantState === 'PARTICIPANT') {
                this.participantTabs.push(allPagesMap['e-diaries']);
            }
        }
        if (this.communityServic.getMessagesVisible()) {
            this.participantTabs.push(allPagesMap['messages']);
        }
        if (this.communityServic.getTrialMatchVisible()) {
            if (this.communityServic.getCurrentCommunityMode().participantState === 'PARTICIPANT') {
                this.participantTabs.push(allPagesMap['trial-match']);
            }
        }
        this.participantTabs.push(allPagesMap['help']);
    }
    handleNavigation(event) {
        if (event.currentTarget.dataset.pageName) {
            this.currentPageName = event.currentTarget.dataset.pageName;
            this.updateCurrentPage(this.currentPageName);
        }
        try{
            //this.menuCss += "toggleClass";
            !this.showSideMenu ? this.menuCss += "toggleClass" : "";
            this.communityServic.navigateToPage(event.currentTarget.dataset.pageName);
            currentPageName = this.communityServic.getPageName();
        }catch (e) {
            console.error(e);
        }
        
    }

    updateCurrentPage(pageNam) {
        document.title = this.participantTabs[pageNam];
    }
}
