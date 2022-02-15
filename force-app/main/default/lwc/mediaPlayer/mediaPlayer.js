import { LightningElement,api } from 'lwc';

export default class MediaPlayer extends LightningElement {

    @api type;
    @api url;
    videotype;
    audiotype;
    Imagetype;
    Filetype;
    
    connectedCallback(){
        if(this.type =='Audio'){
            this.audiotype = this.type;
        }
        else if(this.type =='Video'){
            this.videotype = this.type;
        }
        else if(this.type =='Image'){
            this.Imagetype = this.type;
        }
      /*  else if(this.type =='File'){
            this.Filetype = this.type;
        }*/
    }
}