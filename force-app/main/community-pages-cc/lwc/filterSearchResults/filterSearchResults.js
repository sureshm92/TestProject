import { LightningElement, track, wire } from 'lwc';
import formFactor from '@salesforce/client/formFactor';
import { registerListener, unregisterAllListeners } from 'c/pubSub';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class FilterSearchResults extends LightningElement {}
