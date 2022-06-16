import { LightningElement } from 'lwc';
import PIR_InvalidPreset from "@salesforce/label/c.PIR_InvalidPreset";
import PIR_InvailPresetMessage from "@salesforce/label/c.PIR_InvailPresetMessage";
import BTN_OK from "@salesforce/label/c.BTN_OK";

export default class Pir_presetInvalid extends LightningElement {
    label={BTN_OK,
        PIR_InvailPresetMessage,
        PIR_InvalidPreset
     };
     editPreset(){
        const closeEventModel = new CustomEvent("editpr", {
            detail: "closed"
            });
        this.dispatchEvent(closeEventModel);
     }
}