import { LightningElement, api } from "lwc";
import Id from "@salesforce/user/Id";
import sendMessages from "@salesforce/apex/PPMessagePageRemote.sendMessages";
import createConversations from "@salesforce/apex/PPMessagePageRemote.createConversations";
import pp_icons from "@salesforce/resourceUrl/pp_community_icons";
import PP_No_Messages from "@salesforce/label/c.PP_No_Messages";
import PP_Select_Question_Below from "@salesforce/label/c.PP_Select_Question_Below";
import BTN_Send from "@salesforce/label/c.BTN_Send";
import PP_Select_Question from "@salesforce/label/c.PP_Select_Question";
import PP_Select_Questions from "@salesforce/label/c.PP_Select_Questions";

export default class PpMessageBoard extends LightningElement {
  value = "inProgress";
  @api selectConWrap;
  @api msgWrapper;
  @api studyConfiguartion;
  @api userId = Id;
  @api messageTemplates;
  @api isPastStudy;
  @api messageTemplatesOption = [];
  @api messageValue = "";
  @api isLoaded = false;
  @api firstEnrollments;
  @api deviceSize;
  @api isIE;
  @api piContactNames;
  @api isSecondary;
  @api isMobile;
  @api isSinglePartAlumni = false;
  spinner;
  msgIllustration = pp_icons + "/" + "messages_Illustration.svg";
  message_attachment = pp_icons + "/" + "message_attachment.svg";
  file_default = pp_icons + "/" + "file_default_illustration.svg";
  labels = {
    PP_No_Messages,
    PP_Select_Question_Below,
    BTN_Send,
    PP_Select_Question,
    PP_Select_Questions
  };
  get options() {
    this.messageTemplatesOption = [];
    this.messageTemplatesOption.push({
      label: this.labels.PP_Select_Questions,
      value: "Select question"
    });
    for (var i = 0; i < this.messageTemplates.length; i++) {
      this.messageTemplatesOption.push({
        label: this.messageTemplates[i],
        value: this.messageTemplates[i]
      });
    }
    return this.messageTemplatesOption;
  }
  

  connectedCallback() {
    this.selectConWrap = this.studyConfiguartion ;
    if (this.selectConWrap != null) {
      if (!this.selectConWrap.noConversation) {
        this.msgWrapper = this.selectConWrap.messages;
      }
      this.messageValue = "";
      this.isLoaded = true;
      let context = this;
      setTimeout(function () {
        let boardBody = context.template.querySelector(".child-chat-item-sec");
        if (boardBody) boardBody.scrollTop = boardBody.scrollHeight;
      }, 50);
    } else {
      this.messageValue = "";
      this.isLoaded = true;
    }
  }
  @api isRendered = false;
  @api
  scrollDown() {
    let context = this;
    setTimeout(function () {
      let boardBody = context.template.querySelector(".child-chat-item-sec");
      if (boardBody) boardBody.scrollTop = boardBody.scrollHeight;
    }, 50);
  }
  mobileViewToggle() {
    const custEvent = new CustomEvent("calltoparent", {});
    this.dispatchEvent(custEvent);
  }
  handleChange(event) {
    this.messageValue = event.detail.value;
  }
  handleChanges() {
    const focusEventHeader = new CustomEvent("messagetemplateselection", {});
    this.dispatchEvent(focusEventHeader);
  }

  
  get handleValidation() {
    if (this.messageValue != "Select question" && this.messageValue != "") {
      return false;
    } else {
      return true;
    }
  }
  loaded = true;
  handleSendClick() {
    this.handleChanges();
    if (this.selectConWrap != null) {
      if (!this.selectConWrap.noConversation) {
        let addspinner = new CustomEvent("savemessage");
        this.dispatchEvent(addspinner);

        sendMessages({
          conversation: this.selectConWrap.conversation,
          messageText: this.messageValue,
          deviceSize: this.deviceSize,
          isIE: this.isIE,
          piContactNames: this.piContactNames
        })
          .then((result) => {
            this.messageValue = "Select question";
            const selectEventHeader = new CustomEvent("messageboardcmp", {
              detail: result
            });
            this.dispatchEvent(selectEventHeader);
          })
          .catch((error) => {
            console.error(
              "Error in sendMessage():" +
                error.message +
                " " +
                JSON.stringify(error)
            );
          });
      } else {
        let addspinner = new CustomEvent("savemessage");
        this.dispatchEvent(addspinner);

        createConversations({
          enrollment: this.selectConWrap.firstEnrollments,
          messageText: this.messageValue,
          deviceSize: this.deviceSize,
          isIE: this.isIE,
          piContactNames: this.piContactNames
        })
          .then((result) => {
            this.messageValue = "Select question";
            const selectEventHeader = new CustomEvent("messageboardcmp", {
              detail: result
            });
            this.dispatchEvent(selectEventHeader);
          })
          .catch((error) => {
            console.error("Error in sendMessage():" + error.message);
          });
      }
    } else {
      let addspinner = new CustomEvent("savemessage");
      this.dispatchEvent(addspinner);

      createConversations({
        enrollment: this.firstEnrollments,
        messageText: this.messageValue,
        deviceSize: this.deviceSize,
        isIE: this.isIE,
        piContactNames: this.piContactNames
      })
        .then((result) => {
          this.messageValue = "Select question";
          const selectEventHeader = new CustomEvent("messageboardcmp", {
            detail: result
          });
          this.dispatchEvent(selectEventHeader);
        })
        .catch((error) => {
          console.error("Error in sendMessage():" + error.message);
        });
    }
  }
}