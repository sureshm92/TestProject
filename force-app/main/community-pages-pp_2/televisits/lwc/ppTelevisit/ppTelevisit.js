import { LightningElement, track, api } from 'lwc';
import past from '@salesforce/label/c.Visits_Past';
import upcoming from '@salesforce/label/c.Visits_Upcoming';
import Televisits from '@salesforce/label/c.Televisits';
import No_upcoming_televisits from '@salesforce/label/c.No_upcoming_televisits';
import No_past_televisits from '@salesforce/label/c.No_past_televisits';
import getParticipantDetails from '@salesforce/apex/ParticipantTelevisitRemote.getParticipantTelevisits';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';
import { NavigationMixin } from 'lightning/navigation';
export default class PpTelevisit extends NavigationMixin(LightningElement) {
    @track contentLoaded = false;
    @track upcomingTelevisitslist = [];
    @track pastTelevisitlist = [];
    empty_state = pp_community_icons + '/' + 'empty_visits.png';
    showupcomingtelevisits = false;
    showuppasttelevisits = false;
    showblankupcomingtelevisits = false;
    showblankpasttelsvisits = false;
    isMobile = false;
    label = {
        past,
        upcoming,
        Televisits,
        No_upcoming_televisits,
        No_past_televisits
    };
    past = false;
    onPastClick (){
        this.past = true;
        this.showupcomingtelevisits = false;
        if(!this.showblankpasttelsvisits){
            this.showuppasttelevisits = true;
        }
    }
    onUpcomingClick (){  
        this.past = false; 
        this.showuppasttelevisits = false;
        if(!this.showblankupcomingtelevisits){
            this.showupcomingtelevisits = true;
        }            
    }

    connectedCallback() {
        getParticipantDetails()
        .then((result) => {
            if(result != undefined && result != ''){
                this.pastTelevisitlist = result.televisitpastList;
                this.upcomingTelevisitslist = result.televisitupcomingList;
                if(this.pastTelevisitlist.length == 0){
                    this.showblankpasttelsvisits = true;
                }
                if(this.upcomingTelevisitslist.length == 0){
                    this.showblankupcomingtelevisits = true;
                }
                if(result.showDefault == 'upcoming'){
                    this.past = false;
                    this.showupcomingtelevisits = true; 
                }else{
                    this.past = true;
                    this.showuppasttelevisits = true; 
                }
            }else{
                this.showblankupcomingtelevisits = true;
                this.showblankpasttelsvisits = true;
            }
            this.template.querySelector('c-web-spinner').hide();
            this.contentLoaded = true;
        })
        .catch((error) => {
            this.template.querySelector('c-web-spinner').hide();
            this.contentLoaded = true;
        });
    }
}