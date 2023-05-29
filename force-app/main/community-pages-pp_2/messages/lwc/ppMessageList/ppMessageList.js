import { LightningElement, api } from "lwc";
import profileTZ from "@salesforce/i18n/timeZone";

export default class PpMessageList extends LightningElement {
  @api conversationWrappers;
  @api enrollments;
  @api selectedIndex = -1;
  @api message_attachment;

  get timeZone() {
    return profileTZ;
  }
  handleMouseSelect(event) {
    if (this.selectedIndex != event.currentTarget.dataset.id) {
      this.selectedIndex = event.currentTarget.dataset.id;
      this.changeSelected();
      let paramData = { indexvalue: this.selectedIndex };
      let ev = new CustomEvent("studyselected", { detail: paramData });
      // this.dispatchEvent(ev);
    }
  }
  changeSelected() {
    if (this.selectedIndex != -1) {
      var cards = this.template.querySelectorAll(".select-study");
      for (var j = 0; j < cards.length; j++) {
        if (j == this.selectedIndex) {
          cards[j].classList.add("selected");
        } else {
          cards[j].classList.remove("selected");
        }
      }
    }
  }
}