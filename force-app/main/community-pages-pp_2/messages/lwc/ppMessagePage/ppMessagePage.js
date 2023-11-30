import { LightningElement, track, api, wire } from "lwc";
import formFactor from "@salesforce/client/formFactor";
import { loadStyle } from "lightning/platformResourceLoader";
import { NavigationMixin } from "lightning/navigation";
import getInit from "@salesforce/apex/PPMessagePageRemote.getInitData";
import markConversationAsRead from "@salesforce/apex/PPMessagePageRemote.markConversationAsRead";
import Id from "@salesforce/user/Id";
import pp_icons from "@salesforce/resourceUrl/pp_community_icons";
import rr_community_icons from "@salesforce/resourceUrl/rr_community_icons";
import disclaimerLabel from "@salesforce/label/c.MS_Chat_Disclaimer";
import messagesLabel from "@salesforce/label/c.MS_Messages";
import profileTZ from "@salesforce/i18n/timeZone";
import { CurrentPageReference } from 'lightning/navigation';
import Back_To_PastStudies from '@salesforce/label/c.Back_to_Past_Studies_and_Programs';
export default class PpMessagePage extends NavigationMixin(LightningElement) {
  curentMobileView = "list";
  progressValue = false;
  @track conversationWrappers;
  @track enrollments;
  firstEnrollments;
  @track convWrapp;
  @track selectConWrap;
  @api partTodayDate;
  @api usrPic;
  @api messageTemplates;
  @api userId = Id;
  @api isLoaded = false;
  @api studyName;
  @api deviceSize;
  @wire(CurrentPageReference)
  currentPageRef;
  backtopaststudies = false;
  isMobile;
  message_disclaimer = pp_icons + "/" + "message_disclaimer.svg";
  team_Selected = pp_icons + "/" + "team_Selected_icon.svg";
  televisitAttendees_icon = pp_icons + "/" + "televisitAttendees_icon.svg";
  message_attachment = pp_icons + "/" + "message_attachment.svg";
  homeSvg =
    rr_community_icons + "/" + "icons.svg" + "#" + "icon-home-pplite-new";
  labels = {
    disclaimerLabel,
    messagesLabel,
    Back_To_PastStudies
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
    if(this.currentPageRef.state.c__study){
      this.backtopaststudies = true;
    }
    if (formFactor === "Small" || formFactor === "Medium") {
      this.isMobile = true;
    } else {
      this.isMobile = false;
    }
    this.initializer();
    if (!this.isMobile) {
      document.addEventListener(
        "click",
        (this._handler = this.listener.bind(this))
      );
    }
  }
  listener() {
    if (!this.isMobile) {
      this.conversationWrappers[0].isLastMsgUnRead = false;
    }
    document.removeEventListener("click", this._handler);
  }
  disconnectedCallback() {
    document.removeEventListener("click", this._handler);
  }
  refreshPage(event) {
    this.refreshConversation(event.detail);
  }
  handleGroupMenu() {
    if (this.showParticipantsList) {
      this.template.querySelector(".box-container").style.display = "none";
      this.showParticipantsList = false;
      if (this.isMobile) {
        this.template.querySelector(".img-color").src =
          this.televisitAttendees_icon;
      } else {
        this.template.querySelector(".img-color").src =
          this.televisitAttendees_icon;
      }
      this.template.querySelector(".team-color").style.color = "#595959";
    }
  }
  handleSpinner(event) {
    this.loaded = true;
  }
  @api loaded = false;
  isIE;
  @track piContactNames;
  @api peopleCount = 0;
  @api nameList = [];
  @api usrList = [];
  @api showCount = false;
  @api selectedStudy = 0;
  @api isSecondary = false;
  @api isSinglePartAlumni = false;
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
      isIE: navigator.userAgent.match(/Trident|Edge/) !== null,
      studyId: this.currentPageRef.state.c__study
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
        this.isSecondary = data.isSecondary;
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
            d1 = d1.toLocaleDateString("en-US", {
              timeZone: profileTZ
            });
            const mymap = new Map();
            var msgwrap;
            var newMsg;

            var grpMsg = new Map();

            for (var i = 0; i < conWrap.length; i++) {
              let createdDate = new Date(conWrap[i].message.CreatedDate);
              createdDate = createdDate.toLocaleString("en-US", {
                timeZone: profileTZ
              });
              let d2 = new Date(conWrap[i].message.CreatedDate);
              d2 = d2.toLocaleDateString("en-US", {
                timeZone: profileTZ
              });
              if (isLastMsgUnRead) {
                let a = new Date(conWrap[i].message.CreatedDate);
                a = a.toLocaleString("en-US", {
                  timeZone: profileTZ
                });
                let b = new Date(
                  data.conversationWrappers[0].isLastMsgUnReadDtTime
                );
                b = b.toLocaleString("en-US", {
                  timeZone: profileTZ
                });
                if (new Date(a) >= new Date(b)) {
                  newMsg = i;
                }
              }

              if (d1 === d2) {
                msgwrap = i;
              } else {
                if (mymap.has(d2)) {
                  mymap.delete(d2);

                  mymap.set(d2, i + 1);
                } else {
                  mymap.set(d2, i + 1);
                }
              }
              createdDate = createdDate.substring(0, createdDate.length - 6);
              let grpIdDate = conWrap[i].message.CreatedById + createdDate;

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

              d3 = d3.toLocaleDateString("en-US", {
                timeZone: profileTZ
              });

              if (mymap.get(d3)) {
                let k = mymap.get(d3);
                k = k - 1;
                conWrapModified[k].message.newDay = "true";
                mymap.delete(d3);
              }

              let createdDT = new Date(conWrap[i].message.CreatedDate);

              createdDT = createdDT.toLocaleString("en-US", {
                timeZone: profileTZ
              });

              createdDT = createdDT.substring(0, createdDT.length - 6);
              let grpIdDate = conWrap[i].message.CreatedById + createdDT;
              var sameMsg;
              sameMsg = grpMsg.get(grpIdDate);
              let sameMsgs = Math.max(...sameMsg);
              if (sameMsgs != i) {
                conWrapModified[i].message.isSameTime = "true";
              }
              if (conWrap.length - 1 == i) {
                conWrapModified[i].message.isFirstMsg = "true";
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
          this.peopleCount = context.conversationWrappers[0].peopleCount;
          if (this.peopleCount > 0) {
            this.showCount = true;
          }
          var usrlst = context.conversationWrappers[0].nameList;
          for (var key in usrlst) {
            this.nameList.push({
              value: usrlst[key],
              key: key
            });
          }
          if (isLastMsgUnRead && !this.isMobile) {
            this.convWrapp[0].isLastMsgUnRead = false;
          }

          var enrollmentLst = [];
          var convLst = [];
          this.enrollments.forEach(
            (e) => enrollmentLst.push(e.Clinical_Trial_Profile__c)
          );
          this.convWrapp.forEach((c) =>
            convLst.push(
              c.conversation.Participant_Enrollment__r.Clinical_Trial_Profile__r
                .Id
            )
          );
          let alumniLst = [].concat(
            enrollmentLst.filter((obj1) =>
              convLst.every((obj2) => obj1 !== obj2)
            ),
            convLst.filter((obj2) =>
              enrollmentLst.every((obj1) => obj2 !== obj1)
            )
          );
          if (alumniLst.length != 0) {
            for (var h = 0; h < this.enrollments.length; h++) {
              for (var c = 0; c < alumniLst.length; c++) {
                if (
                  this.enrollments[h].Clinical_Trial_Profile__c == alumniLst[c]
                ) {
                  let con = {
                    conversation: null,
                    noConversation: true,
                    isPastStudy: this.checkAlumniStudy(
                      this.enrollments[h].Participant_Status__c
                    ),
                    studyName:
                      this.enrollments[h].Clinical_Trial_Profile__r
                        .Study_Code_Name__c,
                    firstEnrollments: this.enrollments[h],
                    peopleCount: 0
                  };
                  this.conversationWrappers.push(con);
                  this.convWrapp.push(con);
                }
              }
            }
          }

          this.loaded = false;
        } else {
          if (this.enrollments.length > 1) {
            this.conversationWrappers = [];
            this.convWrapp = [];
            this.firstEnrollments = null;
            for (var h = 0; h < this.enrollments.length; h++) {
              let con = {
                conversation: null,
                noConversation: true,
                isPastStudy: this.checkAlumniStudy(
                  this.enrollments[h].Participant_Status__c
                ),
                studyName:
                  this.enrollments[h].Clinical_Trial_Profile__r
                    .Study_Code_Name__c,
                firstEnrollments: this.enrollments[h],
                peopleCount: 0
              };
              this.conversationWrappers.push(con);
              this.convWrapp.push(con);
            }
            this.selectConWrap = JSON.parse(
              JSON.stringify(context.conversationWrappers[0])
            );
            this.studyName = this.conversationWrappers[0].studyName;
            this.peopleCount = 0;

            this.showCount = false;
          } else {
            this.conversationWrappers = null;
            this.selectConWrap = null;

            this.firstEnrollments = this.enrollments[0];
            this.studyName =
              this.enrollments[0].Clinical_Trial_Profile__r.Study_Code_Name__c;
            this.peopleCount = 0;
            this.isSinglePartAlumni =  this.checkAlumniStudy(this.enrollments[0].Participant_Status__c);
          }
          this.loaded = false;
        }
      })
      .catch((error) => {
        console.error("Error in getInit():" + error);
      });
  }
  
  alumniGroups = [
    "Failed Review",
    "Failed Referral",
    "Pre-review Failed",
    "Contacted - Not Suitable",
    "Excluded from Referring",
    "Referral Declined",
    "Unable to Reach",
    "Eligibility Failed",
    "Declined Consent",
    "Withdrew Consent",
    "Screening Failed",
    "Unable to Screen",
    "Enrollment Failed",
    "Randomization Failed",
    "Withdrew Consent After Screening",
    "Drop Out",
    "Participation Complete",
    "Trial Complete"
  ];
  checkAlumniStudy(status) {
    if (this.alumniGroups.includes(status)) {
      return true;
    } else {
      return false;
    }
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
  get addPointer() {
    if (this.showCount) {
      return "slds-p-vertical_large pointer people-group";
    } else {
      return "slds-p-vertical_large people-group";
    }
  }
  curentMobileView = "list";
  get showBack() {
    if (this.curentMobileView == "detail") {
      return true;
    } else {
      return false;
    }
  }
  handleBack() {
    if (this.showParticipantsList) {
      this.template.querySelector(".box-container").style.display = "none";
      this.showParticipantsList = false;
      if (this.isMobile) {
        this.template.querySelector(".img-color").src =
          this.televisitAttendees_icon;
      } else {
        this.template.querySelector(".img-color").src =
          this.televisitAttendees_icon;
      }
      this.template.querySelector(".team-color").style.color = "#595959";
    }
    this.curentMobileView = "list";
    this.template.querySelector(".L").classList.remove("hideMobile");
    this.template.querySelector(".conversations").classList.add("hideMobile");
  }
  changeStudyConversation(event) {
    if (this.showParticipantsList) {
      this.template.querySelector(".box-container").style.display = "none";
      this.showParticipantsList = false;
      if (this.isMobile) {
        this.template.querySelector(".img-color").src =
          this.televisitAttendees_icon;
      } else {
        this.template.querySelector(".img-color").src =
          this.televisitAttendees_icon;
      }
      this.template.querySelector(".team-color").style.color = "#595959";
    }
    if (this.isMobile) {
      this.curentMobileView = "detail";
      this.template
        .querySelector(".conversations")
        .classList.remove("hideMobile");
      this.template.querySelector(".L").classList.add("hideMobile");
    }
    if (this.selectedStudy != event.detail.indexvalue || this.isMobile) {
      var selectedCon = JSON.parse(
        JSON.stringify(this.convWrapp[event.detail.indexvalue])
      );
      this.selectedStudy = event.detail.indexvalue;
      var picMap = new Map();
      if (this.usrPic != null) {
        for (var key in this.usrPic) {
          picMap.set(key, this.usrPic[key]);
        }
      }
      if (!selectedCon.noConversation) {
        var conWrap = selectedCon.messages;
        var conWrapModified = [];
        conWrapModified = conWrap;
        var isLastMsgUnRead = false;

        if (selectedCon.isLastMsgUnRead) {
          isLastMsgUnRead = true;
          this.hasReadConversation();
        }
        if (conWrap != undefined) {
          var partDate = this.partTodayDate;
          var d1 = new Date(partDate);
          d1 = d1.toLocaleDateString("en-US", {
            timeZone: profileTZ
          });
          const mymap = new Map();
          var msgwrap;
          var newMsg;

          var grpMsg = new Map();

          for (var i = 0; i < conWrap.length; i++) {
            let createdDate = new Date(conWrap[i].message.CreatedDate);
            createdDate = createdDate.toLocaleString("en-US", {
              timeZone: profileTZ
            });

            let d2 = new Date(conWrap[i].message.CreatedDate);
            d2 = d2.toLocaleDateString("en-US", {
              timeZone: profileTZ
            });
            if (isLastMsgUnRead) {
              let a = new Date(conWrap[i].message.CreatedDate);
              a = a.toLocaleString("en-US", {
                timeZone: profileTZ
              });
              let b = new Date(selectedCon.isLastMsgUnReadDtTime);
              b = b.toLocaleString("en-US", {
                timeZone: profileTZ
              });
              if (new Date(a) >= new Date(b)) {
                newMsg = i;
              }
            }
            if (d1 === d2) {
              msgwrap = i;
            } else {
              if (mymap.has(d2)) {
                mymap.delete(d2);
                mymap.set(d2, i + 1);
              } else {
                mymap.set(d2, i + 1);
              }
            }

            createdDate = createdDate.substring(0, createdDate.length - 6);

            let grpIdDate = conWrap[i].message.CreatedById + createdDate;

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

            d3 = d3.toLocaleDateString("en-US", {
              timeZone: profileTZ
            });

            if (mymap.get(d3)) {
              let k = mymap.get(d3);
              k = k - 1;
              conWrapModified[k].message.newDay = "true";
              mymap.delete(d3);
            }

            let createdDT = new Date(conWrap[i].message.CreatedDate);

            createdDT = createdDT.toLocaleString("en-US", {
              timeZone: profileTZ
            });

            createdDT = createdDT.substring(0, createdDT.length - 6);
            let grpIdDate = conWrap[i].message.CreatedById + createdDT;
            var sameMsg;
            sameMsg = grpMsg.get(grpIdDate);
            let sameMsgs = Math.max(...sameMsg);
            if (sameMsgs != i) {
              conWrapModified[i].message.isSameTime = "true";
            }
            if (conWrap.length - 1 == i) {
              conWrapModified[i].message.isFirstMsg = "true";
            }
          }
          selectedCon.messages = conWrapModified.reverse();
        }

        this.template.querySelector("c-pp-message-board").selectConWrap =
          selectedCon;
        this.studyName =
          selectedCon.conversation.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c;

        this.peopleCount = selectedCon.peopleCount;
        this.showCount = true;
        var usrlst = selectedCon.nameList;
        this.nameList = [];
        for (var key in usrlst) {
          this.nameList.push({
            value: usrlst[key],
            key: key
          });
        }
        this.template.querySelector("c-pp-message-board").messageValue =
          "Select question";
        this.template.querySelector("c-pp-message-board").scrollDown();
      } else {
        this.template.querySelector("c-pp-message-board").selectConWrap =
          selectedCon;
        this.studyName = selectedCon.studyName;
        this.peopleCount = selectedCon.peopleCount;
        this.showCount = false;
        this.template.querySelector("c-pp-message-board").messageValue =
          "Select question";
        this.template.querySelector("c-pp-message-board").scrollDown();
      }
    }
  }
  hasReadConversation() {
    this.conversationWrappers[this.selectedStudy].isLastMsgUnRead = false;
    this.convWrapp[this.selectedStudy].isLastMsgUnRead = false;
    markConversationAsRead({
      convId: this.conversationWrappers[this.selectedStudy].conversation.Id
    })
      .then((result) => {})
      .catch((error) => {
        console.error(
          "Error in markConversationAsRead():" +
            error.message +
            " " +
            JSON.stringify(error)
        );
      });
  }
  refreshConversation(conversation) {
    if (this.showParticipantsList) {
      this.template.querySelector(".box-container").style.display = "none";
      this.showParticipantsList = false;
      if (this.isMobile) {
        this.template.querySelector(".img-color").src =
          this.televisitAttendees_icon;
      } else {
        this.template.querySelector(".img-color").src =
          this.televisitAttendees_icon;
      }
      this.template.querySelector(".team-color").style.color = "#595959";
    }
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

      d1 = d1.toLocaleDateString("en-US", {
        timeZone: profileTZ
      });

      const mymap = new Map();
      var msgwrap;
      var newMsg;

      var grpMsg = new Map();

      for (var i = 0; i < conWrap.length; i++) {
        let createdDate = new Date(conWrap[i].message.CreatedDate);
        createdDate = createdDate.toLocaleString("en-US", {
          timeZone: profileTZ
        });

        let d2 = new Date(conWrap[i].message.CreatedDate);
        d2 = d2.toLocaleDateString("en-US", {
          timeZone: profileTZ
        });
        if (isLastMsgUnRead) {
          let a = new Date(conWrap[i].message.CreatedDate);
          a = a.toLocaleString("en-US", {
            timeZone: profileTZ
          });
          let b = new Date(selectedCon.isLastMsgUnReadDtTime);
          b = b.toLocaleString("en-US", {
            timeZone: profileTZ
          });
          if (new Date(a) >= new Date(b)) {
            newMsg = i;
          }
        }
        if (d1 === d2) {
          msgwrap = i;
        } else {
          if (mymap.has(d2)) {
            mymap.delete(d2);
            mymap.set(d2, i + 1);
          } else {
            mymap.set(d2, i + 1);
          }
        }
        createdDate = createdDate.substring(0, createdDate.length - 6);

        let grpIdDate = conWrap[i].message.CreatedById + createdDate;

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

        d3 = d3.toLocaleDateString("en-US", {
          timeZone: profileTZ
        });

        if (mymap.get(d3)) {
          let k = mymap.get(d3);
          k = k - 1;
          conWrapModified[k].message.newDay = "true";
          mymap.delete(d3);
        }

        let createdDT = new Date(conWrap[i].message.CreatedDate);

        createdDT = createdDT.toLocaleString("en-US", {
          timeZone: profileTZ
        });

        createdDT = createdDT.substring(0, createdDT.length - 6);
        let grpIdDate = conWrap[i].message.CreatedById + createdDT;
        var sameMsg;
        sameMsg = grpMsg.get(grpIdDate);
        let sameMsgs = Math.max(...sameMsg);
        if (sameMsgs != i) {
          conWrapModified[i].message.isSameTime = "true";
        }
        if (conWrap.length - 1 == i) {
          conWrapModified[i].message.isFirstMsg = "true";
        }
      }
      selectedCon.messages = conWrapModified.reverse();
    }

    this.selectConWrap = selectedCon;
    this.studyName =
      selectedCon.conversation.Participant_Enrollment__r.Clinical_Trial_Profile__r.Study_Code_Name__c;
    this.peopleCount = selectedCon.peopleCount;
    this.showCount = true;
    var usrlst = selectedCon.nameList;
    this.nameList = [];
    for (var key in usrlst) {
      this.nameList.push({
        value: usrlst[key],
        key: key
      });
    }
    if (this.conversationWrappers != null) {
      this.conversationWrappers[this.selectedStudy] = JSON.parse(
        JSON.stringify(conversation)
      );
      this.convWrapp[this.selectedStudy] = JSON.parse(
        JSON.stringify(conversation)
      );
    } else {
      this.conversationWrappers = null;
      this.conversationWrappers = [];
      this.conversationWrappers.push(JSON.parse(JSON.stringify(conversation)));
    }
    this.loaded = false;
    this.template.querySelector("c-pp-message-board").scrollDown();
  }
  showParticipantsList = false;
  showParticipants() {
    if (this.peopleCount > 0) {
      if (this.showParticipantsList) {
        this.template.querySelector(".box-container").style.display = "none";

        this.showParticipantsList = false;
        if (this.isMobile) {
          this.template.querySelector(".img-color").src =
            this.televisitAttendees_icon;
        } else {
          this.template.querySelector(".img-color").src =
            this.televisitAttendees_icon;
        }
        this.template.querySelector(".team-color").style.color = "#595959";
      } else {
        this.template.querySelector(".box-container").style.display = "block";
        this.showParticipantsList = true;
        if (this.isMobile) {
          this.template.querySelector(".img-color").src = this.team_Selected;
        } else {
          this.template.querySelector(".img-color").src = this.team_Selected;
        }
        this.template.querySelector(".team-color").style.color = "#015FF1";
      }
    }
  }
  handleBackToPastStudies(event) {
    this[NavigationMixin.Navigate]({
        type: 'comm__namedPage',
        attributes: {
            pageName: 'past-studies'
        }
    })
  }
}