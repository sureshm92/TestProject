import { LightningElement, track, api, wire } from "lwc";
import TIME_ZONE from '@salesforce/i18n/timeZone';
import Blank_Bell_Notifications from "@salesforce/label/c.Blank_Bell_Notifications";
import Bell_Notification_Link from "@salesforce/label/c.Bell_Notification_Link";
import { NavigationMixin } from 'lightning/navigation';
import { publish, MessageContext } from 'lightning/messageService';
import messagingChannel from '@salesforce/messageChannel/rhrefresh__c';
import { CurrentPageReference } from 'lightning/navigation';

export default class BellNotifications extends NavigationMixin(LightningElement) {
  @api channel = "/event/bellNotification__e";
  currentPageReference;
  urlStateParameters;

  label = {Blank_Bell_Notifications,
           Bell_Notification_Link};

  @api get sendResultsDataFromParent(){
    return this.notificationWrap;
  }

  @wire(MessageContext)
  messageContext;

@wire(CurrentPageReference)
getStateParameters(currentPageReference) {
   if (currentPageReference) {
    this.currentPageReference = currentPageReference;
      this.urlStateParameters = currentPageReference.state;
   }
}

  set sendResultsDataFromParent(value){
    if(value.length > 0 ){
      this.notificationWrap = value;
    }else{
      this.isSendResult = true;
    }
  }
  isSendResult = false;
  cometd;
  subscription;
  notificationWrap = [];
  error;
  userTimeZone = TIME_ZONE;
  message;
  updatedResult
  isSaving  = false;
  unreadClose = false;
  notificationUnreadID;
  @api isDelete = false;
  @track allNotificationsWrap = [];
  @track allActivateNotification = [];

  renderedCallback() {
    //do something
    var NodeS = this.template.querySelector('[data-id="ScrollNode"]');
    if (NodeS && this.notificationWrap.length > 4) {
      this.template
        .querySelector('[data-id="ScrollNode"]')
        .classList.add("vertical-scroll");
    } else {
      this.template
        .querySelector('[data-id="ScrollNode"]')
        .classList.remove("vertical-scroll");
    }
  }

  onReadMark(event) {
   if(!this.isDelete){
      const keyEl = event.currentTarget.dataset.id;
      const index = this.notificationWrap.findIndex((item) => item.Id == keyEl);

    if (this.notificationWrap[index].Is_Read__c == false){
        const readEvent = new CustomEvent("updatereadevent", {
          detail: {
          notificationIndex: index,
          notificationId: this.notificationWrap[index].Id
          }
        });
       this.dispatchEvent(readEvent);
    }
  }

  }

  handleLazyLoading(event) {
   this.isSaving = true;
    const lazyLoadingevent = new CustomEvent("lazyloadingevent", {
      detail: {
        scrollTop: event.target.scrollTop ,
        offsetHeight: event.target.offsetHeight,
        scrollHeight: event.target.scrollHeight,
        sendResultData: this.notificationWrap
      }
  });
    this.dispatchEvent(lazyLoadingevent);

   window.setTimeout(this.isSaving = false, 5000);
  }

  removeNotification(event) {
    this.isDelete = true;
    const noteKey = event.currentTarget.dataset.id;
    const index = this.notificationWrap.findIndex((item) => item.Id == noteKey);

    const removeNotifyEvent = new CustomEvent("removesendresultevent", {
      detail: {
        closeSendResIndex: index,
        closeSendResId: this.notificationWrap[index].Id
      }
    });
    this.dispatchEvent(removeNotifyEvent);


  }

 /*
  * @description: if bell notification message contains a redirection link, then this method handles redirection on click of link
    @params: event - JS event oject
    @created: 01 Nov 2022
    @modified: 02 Nov 2022
    @author: Naman J
  */
  redirection(event){
    event.preventDefault();
    let linkStr = event.target.href;

    let result = {
      type : "comm__namedPage",
      attributes:{},
      state:{}
    };

    var temp = {};
    temp['name'] = linkStr.substring(linkStr.indexOf("/s/")+3, linkStr.indexOf("__c")+3 );//get communitypage API Name;
    result['attributes'] = temp;
    var stateObj ={};
    if(linkStr.indexOf("?") > 0 ){//check if params are present in link
      let paramStr = linkStr.substring(linkStr.indexOf("?")+1,linkStr.length );
      let params = paramStr.split("&");

      for(let i=0;i<params.length; i++){
        let a = params[i].split("=");
        stateObj[a[0]] = a[1];
      }
    }

    result['state'] = stateObj;

    this[NavigationMixin.Navigate]({
      type: 'comm__namedPage',
      attributes: {
          name: result.attributes.name
      },
      state : result.state
  });

  if(this.urlStateParameters.activeTab == 'Televisit' && this.currentPageReference.attributes && this.currentPageReference.attributes.name == 'My_Referrals__c'){
    let payload = {};
    publish(this.messageContext, messagingChannel, payload);
  }
  const closeOverlay = new CustomEvent("closebelloverlayevent", {});
  this.dispatchEvent(closeOverlay);

  }
}