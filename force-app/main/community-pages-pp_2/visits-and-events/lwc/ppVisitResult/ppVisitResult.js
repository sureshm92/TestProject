import { LightningElement, api, track } from 'lwc';
import Biomarkers_Positive from '@salesforce/label/c.Biomarkers_Positive';
import Biomarkers_Negative from '@salesforce/label/c.Biomarkers_Negative';
import Biomarkers_Unknown from '@salesforce/label/c.Biomarkers_Unknown';
import visitResultNotAvailable from '@salesforce/label/c.PP_Visit_Result_Value_Not_Available';

export default class PpVisitResult extends LightningElement {
    labels = {
        Biomarkers_Positive,
        Biomarkers_Negative,
        Biomarkers_Unknown,
        visitResultNotAvailable
    };
    minValue;
    maxValue;
    @api visitResult;
    @api visitResultType;
    biomarkerResult;
    @track expectedRange;
    header;
    toolTipText;
    actualResultValue;

    showExpectedRange = true;
    connectedCallback() {
        this.initializeData();
    }
    initializeData() {
        let result = this.visitResult;
        if (result) {
            if (
                (this.visitResultType == 'Vitals' &&
                    (result.name == 'Weight' || result.name == 'Height')) ||
                (this.visitResultType != 'Biomarkers' &&
                    result.minValue == null &&
                    result.maxValue == null) ||
                (this.visitResultType == 'Biomarkers' && result.value == null)
            ) {
                this.showExpectedRange = false;
            } else {
                if (result.minValue != null) {
                    this.minValue = this.roundValue(this.visitResult.minValue);
                }
                if (result.maxValue != null) {
                    this.maxValue = this.roundValue(result.maxValue);
                }
                if (this.visitResultType === 'Biomarkers') {
                    if (!result.name.includes('ICOS')) {
                        if (result.value === 1) this.biomarkerResult = Biomarkers_Positive;
                        else if (result.value === -1) this.biomarkerResult = Biomarkers_Negative;
                        else if (result.value === 0) this.biomarkerResult = Biomarkers_Unknown;
                    } else {
                        this.showExpectedRange = false;
                    }
                }
                this.expectedRange = this.getExpectedRange(this.visitResult);
            }
            this.header = result.name;
            this.toolTipText = result.description;
            this.actualResultValue =
                result.value != null
                    ? result.value + ' ' + result.measurement
                    : visitResultNotAvailable;
        }
    }
    roundValue(value) {
        console.log('JJ 2' + value);
        return +(Math.round(value + 'e+4') + 'e-4');
    }
    getExpectedRange(result) {
        let expectedRange;
        if (this.minValue != null && this.maxValue != null) {
            expectedRange = this.minValue + '-' + this.maxValue;
        } else if (this.minValue != null) {
            expectedRange = '> ' + this.minValue;
        } else {
            expectedRange = '< ' + this.maxValue;
        }
        if (expectedRange && result.measurement) expectedRange += ' ' + result.measurement;
        this.expectedRange = expectedRange;
        return expectedRange;
    }
    get isVitalsResult() {
        return this.visitResultType === 'Vitals';
    }

    get isLabsResult() {
        return this.visitResultType === 'Labs';
    }

    get isBiomarkersResult() {
        return this.visitResultType === 'Biomarkers';
    }
}
