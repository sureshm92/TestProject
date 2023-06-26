import { LightningElement, api } from 'lwc';
import PP_Download_Results_Data from '@salesforce/label/c.PP_Download_Results_Data';
import getBase64fromVisitSummaryReportPage_Modified from '@salesforce/apex/VisitReportContainerRemote.getBase64fromVisitSummaryReportPage_Modified';
import FORM_FACTOR from '@salesforce/client/formFactor';
import mobileTemplate from './ppDownloadResultsDataMobile.html';
import tabletTemplate from './ppDownloadResultsDataTablet.html';
import desktopTemplate from './ppDownloadResultsData.html';
export default class PpDownloadResultsData extends LightningElement {
    @api peId;
    @api isRTL;
    @api patientVisitNam;
    @api patientVisitId;
    label = {
        PP_Download_Results_Data
    };
    render() {
        if (this.isDesktop) {
            return desktopTemplate;
        } else if (this.isMobile) {
            return mobileTemplate;
        } else {
            return tabletTemplate;
        }
    }
    get isDesktop() {
        return FORM_FACTOR == 'Large';
    }

    get isMobile() {
        return FORM_FACTOR == 'Small';
    }

    get isTablet() {
        return FORM_FACTOR == 'Medium';
    }
    generateReport() {
        if (!this.isDesktop) {
            getBase64fromVisitSummaryReportPage_Modified({
                peId: this.peId,
                isRTL: this.isRTL,
                patientVisitNam: this.patientVisitNam,
                patientVisId: this.patientVisitId
            })
                .then((returnValue) => {
                    communityService.navigateToPage('mobile-pdf-viewer?pdfData=' + returnValue);
                })
                .catch((error) => {
                    console.error('Error occured during report generation', error.message, 'error');
                });
        }
        window.open(
            '/pp/apex/PatientVisitReportPage?peId=' +
                this.peId +
                '&isRTL=' +
                this.isRTL +
                '&patientVisitNam=' +
                this.patientVisitNam +
                '&patientVisitId=' +
                this.patientVisitId
        );
    }
}
