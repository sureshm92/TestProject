import { LightningElement, api } from 'lwc';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import PE_Investigator_Name from '@salesforce/label/c.PE_Investigator_Name';
import PS_Enrollment_Date from '@salesforce/label/c.PS_Enrollment_Date';
import PS_Site_Location from '@salesforce/label/c.PS_Site_Location';


export default class PpPastStudiesOverview extends LightningElement {
    userTimezone = TIME_ZONE;
    label={
        PE_Investigator_Name,
        PS_Enrollment_Date,
        PS_Site_Location
    };
    @api per;
    @api mainClass="container-overview" ;
    setStudy(){
        if(this.mainClass == 'tiles container-overview'){
            this.dispatchEvent(new CustomEvent('loaddetail', {
                detail: {
                    message: this.per.Id
                }
            }));
        }
    }
}