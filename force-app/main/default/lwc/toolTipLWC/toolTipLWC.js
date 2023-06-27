import { LightningElement, api } from 'lwc';

export default class ToolTipLWC extends LightningElement {
    @api helpText;
    @api height;
    @api width;
    @api marginTop;
    @api marginLeft;
    @api backgroundColor ='#444444'; // Default Value.
    @api textColor ='#ffff'; //Default Value.
    @api fontSize = '13px'; // Default Value.
    @api boxShadow ='0 8px 20px 0 rgba(0,0,0,0.08)'; // Default Value.
    @api borderRadius = '4px' //Default Value.

    connectedCallback() {
        console.log('toolTipLWC');
    }
    renderedCallback(){
        let toolTipElement  = this.template.querySelector('.tool-tip-lwc');
        toolTipElement.style.position = 'absolute';
        toolTipElement.style.display = 'block';
        toolTipElement.style.zIndex="1"
        if (this.height) toolTipElement.style.height = this.height;
        if (this.width) toolTipElement.style.width = this.width;
        if (this.marginTop) toolTipElement.style.marginTop = this.marginTop;
        if (this.marginLeft) toolTipElement.style.marginLeft = this.marginLeft;
        if (this.backgroundColor) toolTipElement.style.backgroundColor = this.backgroundColor;
        if (this.textColor) toolTipElement.style.color = this.textColor;
        if (this.fontSize) toolTipElement.style.fontSize = this.fontSize;
        if (this.boxShadow) toolTipElement.style.boxShadow = this.boxShadow;
        if (this.borderRadius) toolTipElement.style.borderRadius = this.borderRadius;
    }
    //Return the help text value which is passed from the parent component.
    get helpTextValue(){
        return this.helpText;
    }
}
