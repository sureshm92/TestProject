import { LightningElement } from 'lwc';
import pp_icons from '@salesforce/resourceUrl/pp_community_icons';

export default class PpCreateTask extends LightningElement {
    task_icon = pp_icons + '/' + 'createTask_illustration.svg';
    taskNamelength;
    handleuserNameChange(event) {
        var val = event.target.value;
        this.taskNamelength = val.length;
        if (event.target.value !== '') {
            this.template.querySelector('[data-id="taskName"]').value = event.target.value;
        }
    }
}
