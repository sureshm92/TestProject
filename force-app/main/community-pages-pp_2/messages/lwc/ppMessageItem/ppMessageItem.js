import { LightningElement, api } from "lwc";
import profileTZ from "@salesforce/i18n/timeZone";
import AvatarColorCalculator from "c/avatarColorCalculator";
import DRF_L_Today from "@salesforce/label/c.DRF_L_Today";
import PP_New_Message from "@salesforce/label/c.PP_New_Message";
import PP_Time_At from "@salesforce/label/c.PP_Time_At";
import PP_Attachment_Saved_To_Files from "@salesforce/label/c.PP_Attachment_Saved_To_Files";

export default class PpMessageItem extends LightningElement {
  @api msgItem;
  @api userId;
  @api userMode;
  @api msgIndex;
  @api message_attachment;
  @api file_default;
  labels = {
    DRF_L_Today,
    PP_New_Message,
    PP_Time_At,
    PP_Attachment_Saved_To_Files
  };
  renderedCallback() {
    if (!this.msgItem.message.pic && !this.msgItem.message.isSameTime) {
      this.template.querySelector(".ms-item-icon-circle").style.background =
        new AvatarColorCalculator().getColorFromString(
          this.msgItem.message.Sender_Name__c
        );
    }
  }
  get timeZone() {
    return profileTZ;
  }
  get initials() {
    let initials = this.msgItem.message.Sender_Name__c.match(/\b\w/g) || [];
    initials = (
      (initials.shift() || "") + (initials.shift() || "")
    ).toUpperCase();

    return initials;
  }
  get isCurrentParticipant() {
    if (this.userId == this.msgItem.message.CreatedById) {
      return "float:right";
    } else {
      return "float:left";
    }
  }
  get styleAlignment() {
    if (this.userId == this.msgItem.message.CreatedById) {
      return "right-ms-item-txt-pp";
    } else {
      return "left-ms-item-txt-pp";
    }
  }
  get isCurrParticipant() {
    if (this.userId == this.msgItem.message.CreatedById) {
      return true;
    } else {
      return false;
    }
  }
  get userPic() {
    if (
      this.msgItem.message.pic != undefined &&
      this.msgItem.message.pic != null
    ) {
      let pic = this.msgItem.message.pic;
      return pic;
    }
  }
  get thumbnail() {
    if (this.msgItem.attachmentWrapper.fileExtension == "csv") {
      return this.file_default;
    } else {
      let preview =
        this.msgItem.attachmentWrapper.siteBaseUrl +
        "/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=" +
        this.msgItem.attachmentWrapper.versionId +
        "&operationContext=CHATTER&contentId=" +
        this.msgItem.attachmentWrapper.conDocId;
      return preview;
    }
  }
  get fileName() {
    let title = this.msgItem.attachmentWrapper.fileName;
    return (title = title.substring(0, title.lastIndexOf(".")));
  }
  get isCSV() {
    if (this.msgItem.attachmentWrapper.fileExtension == "csv") {
      return "thumbnail-img-aspect-ratio";
    } else {
      return "img-asp-ratio";
    }
  }
}