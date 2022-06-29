import { LightningElement } from 'lwc';
import bulkicons from '@salesforce/resourceUrl/bulkicons';
export default class Pir_BulkImportFiles extends LightningElement {
    instructionsSvgURL = bulkicons+'/instructions.svg';
    downloadSvgURL = bulkicons+'/Download.svg';
    impotrtSvgURL = bulkicons+'/icon.svg';

    get studynameoptions() {
        return [
            { label: 'GSM testing study', value: 'GSM testing study' },
            { label: 'GSM testing study', value: 'GSM testing study' },
        ];
    }
    get studysitesoptions() {
        return [
            { label: 'GSM testing study site ', value: 'GSM testing study site' },
            { label: 'GSM testing study site GSM testing study', value: 'GSM testing study site GSM testing study' },       
        ];
    }
}