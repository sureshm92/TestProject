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
  @api userId = Id;
  @api messageTemplates;
  @api messageTemplatesOption = [];
  @api messageValue = "";
  @api isLoaded = false;
  @api firstEnrollments;
  @api deviceSize;
  @api isIE;
  @api piContactNames;
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
    if (this.selectConWrap != null) {
      console.log("selectConWrap NOT null");
      this.msgWrapper = this.selectConWrap.messages;
      this.messageValue = "";
      // this.spinner = this.template.querySelector('c-web-spinner');
      //  console.log('this.selectConWrap.conversation-->'+JSON.stringify(this.selectConWrap.conversation));
      this.isLoaded = true;
      console.log("scroll down");
      let context = this;
      setTimeout(function () {
        let boardBody = context.template.querySelector(".chat-item");
        if (boardBody) boardBody.scrollTop = boardBody.scrollHeight;
      }, 50);
      console.log("scroll down end");
    } else {
      console.log("selectConWrap  null");
      this.messageValue = "";
      // this.spinner = this.template.querySelector('c-web-spinner');
      this.isLoaded = true;
    }
  }
  @api
  scrollDown() {
    console.log("scroll down");
    let context = this;
    setTimeout(function () {
      let boardBody = context.template.querySelector(".chat-item");
      if (boardBody) boardBody.scrollTop = boardBody.scrollHeight;
    }, 50);
    console.log("scroll down end");
  }
  mobileViewToggle() {
    const custEvent = new CustomEvent("calltoparent", {});
    this.dispatchEvent(custEvent);
  }
  handleChange(event) {
    this.messageValue = event.detail.value;
    console.log("qustion->" + this.messageValue);
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
    if (this.selectConWrap != null) {
      console.log("selectConWrap not null saving...");
      console.log(
        "conversation id->" + JSON.stringify(this.selectConWrap.conversation)
      );
      // console.log('Message text->'+this.messageValue);
      // this.isLoaded = false;
      let addspinner = new CustomEvent("savemessage");
      // this.loaded = false;
      this.dispatchEvent(addspinner);
      //this.template.querySelector('c-web-spinner').show();

      console.log("spinner show web");

      sendMessages({
        conversation: this.selectConWrap.conversation,
        messageText: this.messageValue,
        deviceSize: this.deviceSize,
        isIE: this.isIE,
        piContactNames: this.piContactNames
      })
        .then((result) => {
          console.log("success" + JSON.stringify(result));
          this.messageValue = "Select question";
          //this.messageTemplatesOption = [];
          const selectEventHeader = new CustomEvent("messageboardcmp", {
            detail: result
          });
          this.dispatchEvent(selectEventHeader);

          console.log("spinner hide");
          //this.template.querySelector('c-web-spinner').hide();
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
      console.log("selectConWrap null saving...");

      console.log(
        "Message text-> first enroll-->" +
          this.messageValue +
          "  " +
          this.firstEnrollments
      );
      // this.isLoaded = false;

      let addspinner = new CustomEvent("savemessage");
      this.dispatchEvent(addspinner);

      //this.template.querySelector('c-web-spinner').show();

      console.log("spinner show web");
      createConversations({
        enrollment: this.firstEnrollments,
        messageText: this.messageValue,
        deviceSize: this.deviceSize,
        isIE: this.isIE,
        piContactNames: this.piContactNames
      })
        .then((result) => {
          //  this.messageValue = 'Select question from here';
          this.messageValue = "Select question";
          console.log("success" + JSON.stringify(result));
          //this.messageTemplatesOption = [];
          const selectEventHeader = new CustomEvent("messageboardcmp", {
            detail: result
          });
          this.dispatchEvent(selectEventHeader);

          console.log("spinner hide");
          //this.template.querySelector('c-web-spinner').hide();
        })
        .catch((error) => {
          console.error("Error in sendMessage():" + error.message);
        });
    }
  }
}