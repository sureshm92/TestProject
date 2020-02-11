/**
 * Created by Igor Malyuta on 18.11.2019.
 */

import {LightningElement, api} from 'lwc';
import rrIcons from '@salesforce/resourceUrl/rr_community_icons';
import rrImages from '@salesforce/resourceUrl/rr_community_images';
import SvgLoader from 'c/svgLoader';

export default class WebIcon extends LightningElement {

    @api iconName;
    @api iconColor = '#CCCCCC';
    @api iconSize = 'default';//default/small/big
    @api iconWidth;
    @api iconHeight;
    @api printMode = false;

    renderedCallback() {
        let context = this;
        let svgElement = this.template.querySelector('.' + this.svgClass);
        new SvgLoader().getIconBody(rrIcons + '/icons.svg', this.iconName, function (symbol) {
            svgElement.setAttribute('viewBox', symbol.getAttribute('viewBox'));
            context.cloneNodes(symbol, svgElement);
        });
        if (this.iconHeight) svgElement.style.height = this.iconHeight + 'px';
        if (this.iconWidth) svgElement.style.width = this.iconWidth + 'px';
    }

    get icon() {
        return rrIcons + '/icons.svg#' + this.iconName;
    }

    get imageSrc() {
        return rrImages + '/' + this.iconName + '.png';
    }

    get svgClass() {
        return 'rr-icon-' + this.iconSize;
    }

    cloneNodes(sourceEl, targetEl) {
        if (sourceEl.hasChildNodes()) {
            let context = this;
            sourceEl.childNodes.forEach(function (childNode) {
                if (childNode.nodeType !== 1) return;
                try {
                    let newElement = document.createElementNS('http://www.w3.org/2000/svg', childNode.nodeName);
                    if (childNode.attributes) {
                        for (let i = 0; i < childNode.attributes.length; i++) {
                            newElement.setAttribute(childNode.attributes[i].name, childNode.attributes[i].value);
                        }
                    }
                    targetEl.appendChild(newElement);
                    context.cloneNodes(childNode, targetEl.lastChild);
                } catch (e) {
                    console.error(e);
                }
            })
        }
    }
}