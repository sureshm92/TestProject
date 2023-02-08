import { LightningElement, api, track } from 'lwc';

export default class PpRRIconSplitter extends LightningElement {
    @api icons = '';
    @api backgroundColor = 'White';
    @api label = '';
    @api description = '';
    @api iconColour = '#b2b2b2';
    @track classListArry = [];
    @track testArray = [];
    @api name = '';
    @api ismobile=false;
    isloaded = false;
    showRight=false;
    scrollby = 160;
    @api
    resetValues() {
        this.name = '';
        this.description = '';
        this.label = '';
        this.icons = '';
    }

    renderedCallback() {
        if(this.ismobile){
            this.scrollby = 160;
        }
        let webIcons = this.template.querySelectorAll('.bio-icons');
        if (webIcons[0] && this.isloaded != true) {
            webIcons.forEach((ele) => {
                ele.classList.remove('active');
            });
            webIcons[0].classList.add('active');
            if(this.template.querySelector(".topdiv")){
                this.template.querySelector(".topdiv").addEventListener('scroll', () => this.checkChevrons());
                var contents = this.template.querySelector(".topdiv");
                var divWidth = contents.offsetWidth;
                var scrollwidth =contents.scrollWidth;
                if(divWidth!=scrollwidth){
                    this.showRight=true;         
                }
                if(divWidth<250){
                    this.scrollby = 160;
                }
                //this.start = true;
                //this.end = false;
            }
            this.isloaded = true;
        }
    }

get mobileOrDesktopSizeLeft(){
    if(this.ismobile){
        return 'padding-left: 28px;';
    }else{
        return 'padding-left: 25px;';
    }
}

get mobileOrDesktopSizeRight(){
    if(this.ismobile){
        return 'padding-right: 28px;';
    }else{
        return 'padding-right: 25px;';
    }
}

    goLeft(){
        if(this.showRight){
            var contents = this.template.querySelector(".topdiv");
            contents.scrollLeft -= this.scrollby;
            if(this.template.querySelector(".chevronR")){
                this.template.querySelector(".chevronR").className="chevronR";
                }
            if(contents.scrollLeft<=this.scrollby){
                if(this.template.querySelector(".chevronL")){
                this.template.querySelector(".chevronL").className="chevronL disableCursor";
                }         
                if(this.template.querySelector(".chevronR")){
                    this.template.querySelector(".chevronR").className="chevronR";
                    }     
            }else{
                if(this.template.querySelector(".chevronL")){
                    this.template.querySelector(".chevronL").className = "chevronL";
                }
            }        
        }
    }

    goRight(){
        if(this.showRight){
            var contents = this.template.querySelector(".topdiv");
            contents.scrollLeft += this.scrollby;
            if(this.template.querySelector(".chevronL")){
                this.template.querySelector(".chevronL").className = "chevronL";
            }
            var newScrollLeft=contents.scrollLeft;
            var divWidth = contents.offsetWidth;
            var scrollwidth =contents.scrollWidth;
            if(scrollwidth - divWidth - newScrollLeft < this.scrollby){
                if(this.template.querySelector(".chevronR")){
                    this.template.querySelector(".chevronR").className="chevronR disableCursor"; 
                }
            }else{
                if(this.template.querySelector(".chevronR")){
                    this.template.querySelector(".chevronR").className = "chevronR";
                }
            }
        }
    }    

    checkChevrons(){
        clearTimeout(this.timeoutId);
        this.timeoutId = setTimeout(this.doValidateChevron.bind(this), 750);
    }

    doValidateChevron(){
        var contents = this.template.querySelector(".topdiv");
        var newScrollLeft=contents.scrollLeft;
        var divWidth = contents.offsetWidth;
        var scrollwidth =contents.scrollWidth;
        if(scrollwidth - divWidth - newScrollLeft <1){
            if(this.template.querySelector(".chevronR")){
                this.template.querySelector(".chevronR").className="chevronR disableCursor";
            }   
        }
        if(contents.scrollLeft==0){
            this.template.querySelector(".chevronL").className="chevronL disableCursor";            
        }            
    }

    get morethan7or8(){
        if(this.icons!='' && this.icons && this.ismobile?this.icons.length >7:this.icons.length >8){
            return true;
        }else{
            return false;
        }
    }

    @api
    handleOnVisitClick() {
        this.isloaded = false;
    }

    handleonclick(event) {
        this.label = event.target.dataset.label;
        this.description = event.target.dataset.description;
        let index = event.target.dataset.index;
        let webIcons = this.template.querySelectorAll('.bio-icons');
        webIcons.forEach((ele) => {
            ele.classList.remove('active');
        });
        webIcons[index].classList.add('active');
        this.template.querySelector('.before-your-visits').scrollTop = 0;
    }
}
