import { LightningElement,api } from 'lwc';
import pirResources from '@salesforce/resourceUrl/pirResources';
export default class Pir_participantBubbleMap extends LightningElement {
   @api status = false;
   @api index;
   @api pathdetails;
   checkIcon = pirResources+'/pirResources/icons/status-good.svg';
   noneIcon = pirResources+'/pirResources/icons/circle.svg';
   nonecls = 'neutral';
   get chkstyle(){
       return 'neutral';
   }
    // get checkIcon(){
    //     if(this.status){
    //         return pirResources+'/pirResources/icons/status-good.svg';
    //     }else{
    //         return pirResources+'/pirResources/icons/circle.svg';
    //     }
    // }
    // get checkLabel(){
    //     if(this.index == 0){
    //         return 'Randomization Success'
    //     }
    //     if(this.index == 1){
    //         return 'Treatment period started'
    //     }
    //     if(this.index == 2){
    //         return 'Follow up period started'
    //     }
    //     if(this.index == 3){
    //         return 'participant Complete'
    //     }
    //     if(this.index == 4){
    //         return 'Trial Complete'
    //     }
    // }

    // get checkIndex(){
    //     if(this.index == 0){
    //         return false;
    //     }else if(this.index == 4){
    //         return false;
    //     }else{
    //         return true;
    //     }
    // }
}