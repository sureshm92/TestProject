import { LightningElement,api, track } from 'lwc';
import AvatarColorCalculator from "c/avatarColorCalculator";

export default class PpPeopleCount extends LightningElement {
 @api userName;
 @api userpicId;
 @api usrPic;
 @track hasImages = false;
 @track imgPath;
 @track isTab;
 connectedCallback() {
    this.isTab=this.isTablet();
    var usrlst = this.usrPic;
    for(var key in usrlst){
        if(this.userpicId == key){
            console.log('hasimg');
            this.hasImages = true;
            this.imgPath = usrlst[key];
            break;
        }
    }
 }
 renderedCallback() {
    if (!this.hasImages) {
      this.template.querySelector(".ms-item-icon-circle").style.background =
        new AvatarColorCalculator().getColorFromString(
            this.userName
        );
    }
  }
 get peopleName(){
   console.log('usr name->'+this.userName+'  '+this.userpicId);
   return this.userName;
 }
 
 get initials() {
    let initial = this.userName.match(/\b\w/g) || [];
    initial = (
      (initial.shift() || "") + (initial.shift() || "")
    ).toUpperCase();
    return initial;
  }
  
  isTablet() {
    if (window.innerWidth >= 768 && window.innerWidth <= 1280) {
        if (/android/i.test(navigator.userAgent.toLowerCase())) {
            return true;
        } else {
            return false;
        }
    } else {
        return false;
    }
    }
}