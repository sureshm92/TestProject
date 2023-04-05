import { LightningElement, api, track } from 'lwc';
import Biomarkers_Positive from '@salesforce/label/c.Biomarkers_Positive';
import Biomarkers_Negative from '@salesforce/label/c.Biomarkers_Negative';
import Biomarkers_Unknown from '@salesforce/label/c.Biomarkers_Unknown';
import visitResultNotAvailable from '@salesforce/label/c.PP_Visit_Result_Value_Not_Available';
import Biomarkers_Expected_Range from '@salesforce/label/c.Biomarkers_Expected_Range';
import Report_Expected_Range from '@salesforce/label/c.Report_Expected_Range';
import mobileTemplate from './ppVisitResultMobile.html';
import tabletTemplate from './ppVisitResultTablet.html';
import desktopTemplate from './ppVisitResult.html';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class PpVisitResult extends LightningElement {
    labels = {
        Biomarkers_Positive,
        Biomarkers_Negative,
        Biomarkers_Unknown,
        visitResultNotAvailable,
        Report_Expected_Range,
        Biomarkers_Expected_Range
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
                        this.ICOSRelatedResults = false;
                        if (result.value == 1) this.biomarkerResult = Biomarkers_Positive;
                        else if (result.value == -1) this.biomarkerResult = Biomarkers_Negative;
                        else if (result.value == 0) this.biomarkerResult = Biomarkers_Unknown;
                        else this.biomarkerResult = visitResultNotAvailable;
                        this.expectedRange =
                            Report_Expected_Range + ': ' + Biomarkers_Expected_Range;
                    } else {
                        this.ICOSRelatedResults = true;
                        this.showExpectedRange = false;
                    }
                } else this.expectedRange = this.getExpectedRange(this.visitResult);
            }
            this.header = result.name;
            this.toolTipText = result.description;
            let measurement = result.measurement != null ? result.measurement : '';
            this.actualResultValue =
                result.value != null ? result.value + ' ' + measurement : visitResultNotAvailable;
        }
    }

    roundValue(value) {
        return +(Math.round(value + 'e+4') + 'e-4');
    }
    getExpectedRange(result) {
        let expectedRange;
        if (this.minValue != null && this.maxValue != null) {
            expectedRange = this.minValue + '\u2013' + this.maxValue;
        } else if (this.minValue != null) {
            expectedRange = '> ' + this.minValue;
        } else {
            expectedRange = '< ' + this.maxValue;
        }
        if (expectedRange && result.measurement) expectedRange += ' ' + result.measurement;
        expectedRange = Report_Expected_Range + ': ' + expectedRange;
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

    get actualValueClass() {
        return this.visitResult.value != null
            ? 'actual-value slds-p-top_xx-small slds-p-bottom_xxx-small'
            : 'not-available-text slds-p-top_xxx-small';
    }
    get resultDisplayClass() {
        return this.visitResult.value != null
            ? 'slds-text-align_left result-available'
            : 'slds-text-align_left result-not-available';
    }
    get bioMarkerResClass() {
        return this.biomarkerResult == visitResultNotAvailable
            ? 'slds-text-align_left result-not-available'
            : 'slds-text-align_left result-available';
    }
    get isDesktop() {
        return FORM_FACTOR === 'Large' ? true : false;
    }

    get isTablet() {
        return FORM_FACTOR === 'Medium' ? true : false;
    }

    get isMobile() {
        return FORM_FACTOR === 'Small' ? true : false;
    }
    render() {
        if (this.isDesktop) {
            return desktopTemplate;
        } else if (this.isMobile) {
            return mobileTemplate;
        } else {
            return tabletTemplate;
        }
    }
}
