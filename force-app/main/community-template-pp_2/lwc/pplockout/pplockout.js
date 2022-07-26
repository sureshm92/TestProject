import { LightningElement, api } from 'lwc';
import lockoutErrorMessage from '@salesforce/label/c.PP_Lockout_Error_Message';
import lockoutLabel from '@salesforce/label/c.PP_Lockout';

export default class Pplockout extends LightningElement {
    labels = {
        lockoutErrorMessage,
        lockoutLabel
    };
    @api milliSecondsLeft;
    countDownValue;
    @api isRTLLanguage = false;

    connectedCallback() {
        let context = this;
        var timer = setInterval(function () {
            // Time calculations for days, hours, minutes and seconds
            var minutes =
                '' + Math.floor((context.milliSecondsLeft % (1000 * 60 * 60)) / (1000 * 60));
            var seconds = '' + Math.floor((context.milliSecondsLeft % (1000 * 60)) / 1000);
            if (minutes === '0' && seconds === '0') {
                clearInterval(timer);
                context.dispatchEvent(new CustomEvent('unlock'));
            }
            if (minutes.length == 1) {
                minutes = '0' + minutes;
            }
            if (seconds.length == 1) {
                seconds = '0' + seconds;
            }
            context.countDownValue = minutes + ':' + seconds;
            context.milliSecondsLeft = context.milliSecondsLeft - 1000;
        }, 1000);
    }
    get lockoutDiv() {
        return this.isRTLLanguage ? 'rtl' : '';
    }
}
