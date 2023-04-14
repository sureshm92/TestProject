import { LightningElement, track, api } from 'lwc';
import past from '@salesforce/label/c.Visits_Past';
import upcoming from '@salesforce/label/c.Visits_Upcoming';
import Televisits from '@salesforce/label/c.Televisits';
import No_upcoming_televisits from '@salesforce/label/c.No_upcoming_televisits';
import No_past_televisits from '@salesforce/label/c.No_past_televisits';
import getParticipantDetails from '@salesforce/apex/ParticipantTelevisitRemote.getParticipantTelevisits';
import pp_community_icons from '@salesforce/resourceUrl/pp_community_icons';
import { NavigationMixin } from 'lightning/navigation';
import DEVICE from '@salesforce/client/formFactor';
import rr_community_icons from '@salesforce/resourceUrl/rr_community_icons';
export default class PpTelevisit extends NavigationMixin(LightningElement) {
    @track contentLoaded = false;
    @track upcomingTelevisitslist = [];
    @track pastTelevisitlist = [];
    empty_state = pp_community_icons + '/' + 'empty_visits.png';
    homeSvg = rr_community_icons + '/' + 'icons.svg' + '#' + 'icon-home-pplite-new';
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
    timechanges ;
    reloadupcomingcomponent = false;
    isdelegate = false;
    selectedNavHandler(event) {
        if(event.detail.filter == 'showblankupcomingtelevisits:false'){
            this.upcomingTelevisitslist = event.detail.upcomingdata;
            this.pastTelevisitlist = event.detail.details;
            this.showblankupcomingtelevisits = false;
        }
        if(event.detail.filter == 'showblankupcomingtelevisits:true'){
            this.showblankupcomingtelevisits = true;
            this.pastTelevisitlist = event.detail.details;
            this.upcomingTelevisitslist = event.detail.upcomingdata;    
            this.showblankpasttelsvisits = false;       
            if(this.past){
                this.showuppasttelevisits = true;
            }
            
        }
        if(event.detail.filter == 'datachange'){
            this.pastTelevisitlist = event.detail.details;
            this.upcomingTelevisitslist = event.detail.upcomingdata; 
            this.showblankpasttelsvisits = false; 
            if(this.past){
                this.showuppasttelevisits = true;
            }

        }
    }
    onPastClick (){
        this.reloadupcomingcomponent = false;
        this.past = true;
        this.showupcomingtelevisits = false;
        if(!this.showblankpasttelsvisits){
            this.showuppasttelevisits = true;
        }
    }
    onUpcomingClick (){  
        this.past = false; 
        this.reloadupcomingcomponent = true;
        this.showuppasttelevisits = false;
        if(!this.showblankupcomingtelevisits){
            this.showupcomingtelevisits = true;
        }            
    }
    gettelevisitdetails(){
        getParticipantDetails({joinbuttonids : null})
        .then((result) => {
            if(result != undefined && result != '' &&
               (result.televisitupcomingList.length > 0 || result.televisitpastList.length > 0)){
                this.timechanges = result.tz;
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
            this.isdelegate = result.isdelegate;
            this.contentLoaded = true;
            this.reloadupcomingcomponent = true;
            this.template.querySelector('c-web-spinner').hide();
        })
        .catch((error) => {
           this.template.querySelector('c-web-spinner').hide();
            this.contentLoaded = true;
        });
    }
    connectedCallback() {
        DEVICE != 'Small' ? (this.isMobile = false) : (this.isMobile = true);
        this.gettelevisitdetails();
    }
    redircttohomepage(){
        window.open(window.location.origin + '/pp/s/',"_self");
    }
}