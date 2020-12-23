import { LightningElement, track, wire } from 'lwc';
import formFactor from '@salesforce/client/formFactor';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubSub';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class SiteListPage extends NavigationMixin(LightningElement) {}
