import { LightningElement, track, api } from "lwc";
import formFactor from "@salesforce/client/formFactor";
import Community_CSS_PP_Theme from "@salesforce/resourceUrl/Community_CSS_PP_Theme";
import { loadStyle } from "lightning/platformResourceLoader";
import { NavigationMixin } from "lightning/navigation";
import getInit from "@salesforce/apex/PPMessagePageRemote.getInitData";
import Id from "@salesforce/user/Id";
import pp_icons from "@salesforce/resourceUrl/pp_community_icons";
import rr_community_icons from "@salesforce/resourceUrl/rr_community_icons";
import disclaimerLabel from "@salesforce/label/c.MS_Chat_Disclaimer";
import messagesLabel from "@salesforce/label/c.MS_Messages";

export default class PpMessagePage extends NavigationMixin(
  LightningElement
) {
  curentMobileView = "list";
  progressValue = false;
  @track conversationWrappers;
  @track enrollments;
  firstEnrollments;
  @track convWrapp;
  @api selectConWrap;
  @api partTodayDate;
  @api usrPic;
  @api messageTemplates;
  @api userId = Id;
  @api isLoaded = false;
  @api studyName;
  @api deviceSize;
  isMobile;
  message_disclaimer = pp_icons + "/" + "message_disclaimer.svg";
  televisitAttendees_icon = pp_icons + "/" + "televisitAttendees_icon.svg";
  message_attachment = pp_icons + "/" + "message_attachment.svg";
  homeSvg =
    rr_community_icons + "/" + "icons.svg" + "#" + "icon-home-pplite-new";
  labels = {
    disclaimerLabel,
    messagesLabel
  };
  mobileViewToggle() {
    if (this.progressValue == false) {
      if (this.curentMobileView == "list") {
        this.curentMobileView = "detail";
        this.template.querySelectorAll(".D").forEach(function (D) {
          D.classList.remove("hideMobile");
        });
        this.template.querySelectorAll(".L").forEach(function (L) {
          L.classList.add("hideMobile");
        });
      } else {
        this.curentMobileView = "list";
        this.template.querySelectorAll(".L").forEach(function (L) {
          L.classList.remove("hideMobile");
        });
        this.template.querySelectorAll(".D").forEach(function (D) {
          D.classList.add("hideMobile");
        });
      }
    }
  }
  handleHomePage() {
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        pageName: "home"
      }
    });
  }
  _handler;
  connectedCallback() {
    if (formFactor === "Small" || formFactor === "Medium") {
      this.isMobile = true;
    } else {
      this.isMobile = false;
    }
    loadStyle(this, Community_CSS_PP_Theme);
    this.initializer();
    document.addEventListener(
      "click",
      (this._handler = this.listener.bind(this))
    );
  }
  listener() {
    this.conversationWrappers[0].isLastMsgUnRead = false;
    document.removeEventListener("click", this._handler);
  }
  disconnectedCallback() {
    document.removeEventListener("click", this._handler);
  }
  refreshPage(event) {
    this.refreshConversation(event.detail);
  }
  handleSpinner(event) {
    this.loaded = true;
  }
  @api loaded = false;
  isIE;
  @track piContactNames;
  initializer() {
    this.creationMode = false;
    this.enrollments = null;
    this.partTodayDate = null;
    this.messageTemplates = null;
    this.isLoaded = false;
    let context = this;
    this.deviceSize = formFactor;
    this.isIE = navigator.userAgent.match(/Trident|Edge/) !== null;
    this.loaded = true;
    getInit({
      formFactor: formFactor,
      isIE: navigator.userAgent.match(/Trident|Edge/) !== null
    })
      .then((data) => {
        if (!data.isPageEnabled) {
          context[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
              pageName: "home"
            }
          });
        }

        context.userMode = data.userMode;
        context.enrollments = data.enrollments;
        context.statusByPeMap = data.statusByPeMap;
        context.piContactNames = data.piContactNames;
        context.isRTL = data.isRTL;
        context.messageTemplates = data.messageTemplates;
        context.partTodayDate = data.partTodayDate;

        if (data.profilePicture != undefined && data.profilePicture != null) {
          this.usrPic = data.profilePicture;
          var picMap = new Map();
          for (var key in this.usrPic) {
            picMap.set(key, this.usrPic[key]);
          }
        } else {
          this.usrPic = null;
        }
        if (
          data.conversationWrappers != undefined &&
          data.conversationWrappers != null
        ) {
          var dataConWrap = data.conversationWrappers;
          this.convWrapp = JSON.parse(
            JSON.stringify(data.conversationWrappers)
          );

          var conWrap = data.conversationWrappers[0].messages;
          var conWrapModified = conWrap;
          var isLastMsgUnRead = false;
          if (data.conversationWrappers[0].isLastMsgUnRead) {
            isLastMsgUnRead = true;
          }
          if (conWrap != undefined) {
            var partDate = data.partTodayDate;
            var d1 = new Date(partDate);
            const mymap = new Map();
            var msgwrap;
            var newMsg;
            var allCreatedDtTm = [];

            var dtList = new Map();
            var sameTimeList = [];

            var grpMsg = new Map();

            for (var i = 0; i < conWrap.length; i++) {
              let createdDate = "";
              createdDate = conWrap[i].message.CreatedDate;
              let d2 = new Date(createdDate);
              if (isLastMsgUnRead) {
                if (
                  new Date(d2) >=
                  new Date(data.conversationWrappers[0].isLastMsgUnReadDtTime)
                ) {
                  newMsg = i;
                } else {
                }
              }
              if (d1.toDateString() === d2.toDateString()) {
                msgwrap = i;
              } else {
                if (mymap.has(d2.toDateString())) {
                  mymap.delete(d2.toDateString());
                  mymap.set(d2.toDateString(), i);
                } else {
                  mymap.set(d2.toDateString(), i);
                }
              }
              allCreatedDtTm.push(createdDate);
              let createdDT = createdDate;
              createdDT = createdDT.substring(0, createdDT.length - 8);

              let grpIdDate = conWrap[i].message.CreatedById + createdDT;

              if (grpMsg.has(grpIdDate)) {
                grpMsg.get(grpIdDate).push(i);
              } else {
                grpMsg.set(grpIdDate, [i]);
              }
            }
            for (var i = 0; i < conWrap.length; i++) {
              if (picMap.has(conWrap[i].message.CreatedById)) {
                conWrapModified[i].message.pic = picMap.get(
                  conWrap[i].message.CreatedById
                );
              }
              if (i == msgwrap) {
                conWrapModified[i].message.isToday = "true";
              }
              if (i == newMsg) {
                conWrapModified[i].message.isNewMsg = "true";
              }
              let d3 = new Date(conWrap[i].message.CreatedDate);

              if (mymap.get(d3.toDateString())) {
                conWrapModified[mymap.get(d3.toDateString())].message.newDay =
                  "true";
                mymap.delete(d3.toDateString());
              }
              let lst;
              let createdDT = conWrap[i].message.CreatedDate;
              createdDT = createdDT.substring(0, createdDT.length - 8);
              let grpIdDate = conWrap[i].message.CreatedById + createdDT;
              lst = grpMsg.get(grpIdDate);
              let num = Math.max(...lst);
              if (num != i) {
                conWrapModified[i].message.isSameTime = "true";
              }
            }
            dataConWrap[0].messages = conWrapModified.reverse();
          }

          this.conversationWrappers = null;
          this.conversationWrappers = JSON.parse(JSON.stringify(dataConWrap));
          this.selectConWrap = JSON.parse(
            JSON.stringify(context.conversationWrappers[0])
          );

          this.studyName =
            context.conversationWrappers[0].conversation.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c;
          this.firstEnrollments = null;

          this.loaded = false;
        } else {
          this.conversationWrappers = null;
          this.selectConWrap = null;

          this.firstEnrollments = this.enrollments[0];

          this.studyName =
            this.enrollments[0].Clinical_Trial_Profile__r.Study_Code_Name__c;
          this.loaded = false;
        }
      })
      .catch((error) => {
        console.error("Error in getInit():" + JSON.stringify(error));
      });
  }
  get isInitialized() {
    if (this.conversationWrappers != null || this.enrollments != null) {
      return true;
    } else {
      return false;
    }
  }
  get isMessageLoaded() {
    if (this.selectConWrap != null || this.firstEnrollments != null) {
      return true;
    } else {
      return false;
    }
  }
  changeStudyConversation(event) {
    var selectedCon = JSON.parse(
      JSON.stringify(this.convWrapp[event.detail.indexvalue])
    );
    var picMap = new Map();
    if (this.usrPic != null) {
      for (var key in this.usrPic) {
        picMap.set(key, this.usrPic[key]);
      }
    }
    var conWrap = selectedCon.messages;

    var conWrapModified = [];
    conWrapModified = conWrap;
    var isLastMsgUnRead = false;

    if (selectedCon.isLastMsgUnRead) {
      isLastMsgUnRead = true;
    }
    if (conWrap != undefined) {
      var partDate = this.partTodayDate;
      var d1 = new Date(partDate);

      const mymap = new Map();

      var msgwrap;
      var newMsg;
      var allCreatedDtTm = [];
      var grpMsg = new Map();
      for (var i = 0; i < conWrap.length; i++) {
        let createdDate = "";
        createdDate = conWrap[i].message.CreatedDate;
        let d2 = new Date(createdDate);
        if (isLastMsgUnRead) {
          if (new Date(d2) >= new Date(selectedCon.isLastMsgUnReadDtTime)) {
            newMsg = i;
          } else {
          }
        }
        if (d1.toDateString() === d2.toDateString()) {
          msgwrap = i;
        } else {
          if (mymap.has(d2.toDateString())) {
            mymap.delete(d2.toDateString());
            mymap.set(d2.toDateString(), i);
          } else {
            mymap.set(d2.toDateString(), i);
          }
        }
        allCreatedDtTm.push(createdDate);
        let createdDT = createdDate;
        createdDT = createdDT.substring(0, createdDT.length - 8);

        let grpIdDate = conWrap[i].message.CreatedById + createdDT;

        if (grpMsg.has(grpIdDate)) {
          grpMsg.get(grpIdDate).push(i);
        } else {
          grpMsg.set(grpIdDate, [i]);
        }
      }
      for (var i = 0; i < conWrap.length; i++) {
        if (picMap.has(conWrap[i].message.CreatedById)) {
          conWrapModified[i].message.pic = picMap.get(
            conWrap[i].message.CreatedById
          );
        }
        if (i == msgwrap) {
          conWrapModified[i].message.isToday = "true";
        }
        if (i == newMsg) {
          conWrapModified[i].message.isNewMsg = "true";
        }
        let d3 = new Date(conWrap[i].message.CreatedDate);

        if (mymap.get(d3.toDateString())) {
          conWrapModified[mymap.get(d3.toDateString())].message.newDay = "true";
          mymap.delete(d3.toDateString());
        }

        let lst;
        let createdDT = conWrap[i].message.CreatedDate;
        createdDT = createdDT.substring(0, createdDT.length - 8);
        let grpIdDate = conWrap[i].message.CreatedById + createdDT;
        lst = grpMsg.get(grpIdDate);
        let num = Math.max(...lst);

        if (num != i) {
          conWrapModified[i].message.isSameTime = "true";
        }
      }

      selectedCon.messages = conWrapModified.reverse();
    }
    this.selectConWrap = selectedCon;
    this.studyName =
      selectedCon.conversation.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c;
  }
  refreshConversation(conversation) {
    if (this.firstEnrollments != null) {
      this.firstEnrollments = null;
      this.enrollments = null;
    }

    var selectedCon = JSON.parse(JSON.stringify(conversation));
    var picMap = new Map();
    if (this.usrPic != null) {
      for (var key in this.usrPic) {
        picMap.set(key, this.usrPic[key]);
      }
    }
    var conWrap = selectedCon.messages;
    var conWrapModified = [];
    conWrapModified = conWrap;
    var isLastMsgUnRead = false;

    if (selectedCon.isLastMsgUnRead) {
      isLastMsgUnRead = true;
    }
    if (conWrap != undefined) {
      var partDate = this.partTodayDate;
      var d1 = new Date(partDate);
      const mymap = new Map();
      var msgwrap;
      var newMsg;
      var allCreatedDtTm = [];
      var grpMsg = new Map();
      for (var i = 0; i < conWrap.length; i++) {
        let createdDate = "";
        createdDate = conWrap[i].message.CreatedDate;
        let d2 = new Date(createdDate);
        if (isLastMsgUnRead) {
          if (new Date(d2) >= new Date(selectedCon.isLastMsgUnReadDtTime)) {
            newMsg = i;
          }
        }
        if (d1.toDateString() === d2.toDateString()) {
          msgwrap = i;
        } else {
          if (mymap.has(d2.toDateString())) {
            mymap.delete(d2.toDateString());
            mymap.set(d2.toDateString(), i);
          } else {
            mymap.set(d2.toDateString(), i);
          }
        }
        allCreatedDtTm.push(createdDate);
        let createdDT = createdDate;
        createdDT = createdDT.substring(0, createdDT.length - 8);

        let grpIdDate = conWrap[i].message.CreatedById + createdDT;

        if (grpMsg.has(grpIdDate)) {
          grpMsg.get(grpIdDate).push(i);
        } else {
          grpMsg.set(grpIdDate, [i]);
        }
      }

      for (var i = 0; i < conWrap.length; i++) {
        if (picMap.has(conWrap[i].message.CreatedById)) {
          conWrapModified[i].message.pic = picMap.get(
            conWrap[i].message.CreatedById
          );
        }
        if (i == msgwrap) {
          conWrapModified[i].message.isToday = "true";
        }
        if (i == newMsg) {
          conWrapModified[i].message.isNewMsg = "true";
        }
        let d3 = new Date(conWrap[i].message.CreatedDate);

        if (mymap.get(d3.toDateString())) {
          conWrapModified[mymap.get(d3.toDateString())].message.newDay = "true";
          mymap.delete(d3.toDateString());
        }

        let lst;
        let createdDT = conWrap[i].message.CreatedDate;
        createdDT = createdDT.substring(0, createdDT.length - 8);
        let grpIdDate = conWrap[i].message.CreatedById + createdDT;
        lst = grpMsg.get(grpIdDate);
        let num = Math.max(...lst);

        if (num != i) {
          conWrapModified[i].message.isSameTime = "true";
        }
      }

      selectedCon.messages = conWrapModified.reverse();
    }

    this.selectConWrap = selectedCon;
    this.studyName =
      selectedCon.conversation.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c;

    if (this.conversationWrappers != null) {
      this.conversationWrappers[0] = JSON.parse(JSON.stringify(conversation));
    } else {
      this.conversationWrappers = null;
      this.conversationWrappers = [];
      this.conversationWrappers.push(JSON.parse(JSON.stringify(conversation)));
    }
    this.loaded = false;
    this.template.querySelector("c-pp-message-board").scrollDown();
  }
}