import { LightningElement } from 'lwc';
import RH_RP_info from '@salesforce/label/c.RH_RP_info';
import RH_RP_select_single_patient from '@salesforce/label/c.RH_RP_select_single_patient';


export default class RP_BulkProfileSectionPage extends LightningElement {

    label = {
        RH_RP_info,
        RH_RP_select_single_patient
    };
}