import { LightningElement,api } from 'lwc';

export default class MediaPlayer extends LightningElement {

    @api type;
    @api url;
    videotype;
    audiotype;
    
    connectedCallback(){
        if(this.type =='Audio'){
            this.audiotype = this.type;
        }
        else if(this.type =='Video'){
            this.videotype = this.type;
        }
    }

    @api
    get isPlaying() {
        const player = this.template.querySelector('audio');
        return player !== null && player.paused === false;
    }

    @api
    play() {
        const player = this.template.querySelector('audio');
        // the player might not be in the DOM just yet
        if (player) {
            player.play();
        }
    }

    @api
    pause() {
        const player = this.template.querySelector('audio');
        if (player) {
            // the player might not be in the DOM just yet
            player.pause();
        }
    }
}