/* PIR_Community_CSS */
.pir-parent .slds-tabs_default__item.slds-active:after, 
.pir-parent .slds-tabs_default__item.slds-is-active:after, 
.pir-parent .slds-tabs--default__item.slds-active:after, 
.pir-parent .slds-tabs--default__item.slds-is-active:after{
    background-color:#0768FD;
    border-radius:80px;
    height:calc(var(--sds-c-tabs-list-sizing-border, 2px) + 2.5px);
}
.pir-parent .slds-tabs_default__item.slds-active .slds-tabs_default__link, 
.pir-parent .slds-tabs_default__item.slds-active .slds-tabs--default__link, 
.pir-parent .slds-tabs_default__item.slds-is-active .slds-tabs_default__link, 
.pir-parent .slds-tabs_default__item.slds-is-active .slds-tabs--default__link,
.pir-parent .slds-tabs--default__item.slds-active .slds-tabs_default__link, 
.pir-parent .slds-tabs--default__item.slds-active .slds-tabs--default__link,
.pir-parent .slds-tabs--default__item.slds-is-active .slds-tabs_default__link, 
.pir-parent .slds-tabs--default__item.slds-is-active .slds-tabs--default__link{ 
    color: #000000 !important;
    font-weight: 700 !important;
    text-decoration: none !important;
}
.pir-parent .tab {
    color: #000000;
    font-family: "Proxima Nova";
    font-size: 16px;
    font-weight: 600;
    letter-spacing: 0;
}
.pir-parent .slds-tabs_default__link {
    font-family: "Proxima Nova";
    font-size: 16px!important;
    letter-spacing: 0;    
}
.pir-parent .all-tabs .slds-tabs_default__item:after {
    width: 90%;
    margin: 0 auto;
    border-radius:80px;
    height: calc(var(--sds-c-tabs-list-sizing-border, 2px) + 2.5px);
}
.dropdown-fonts .slds-listbox__option .slds-media__body {
    font-size: 12px;
}
.addInfoCssDiv .slds-textarea{
height: 70px;
}
.dropdown-fonts_bulk .slds-listbox__option .slds-media__body {
    font-size: 14px;
}
.pir-parent .bulkimportTab .slds-tabs_default__item{
    padding-left: 0;
    padding-right: 0;
}
.rh-initial-visit-date input{ 
    min-width:100%;
    -webkit-appearance:none;
}
/* only for ios app start+ */
@media not all and (min-resolution:.001dpcm)
{ @supports (-webkit-appearance:none) and (stroke-color:transparent) {
    .addInfoCssDiv .slds-textarea{
     font-weight: 800;
     color:black;
    }

    .iosopacitycss .slds-input{
    font-weight: 800;
     color:black;
    }

}}
/* only for ios end */

.pir-parent .bulkimportTab .slds-tabs_default__content{
    padding-bottom: 0;
}
.importInputPopup .slds-required{
    float: right;
}
.importInputPopup .slds-form-element__label{
    font-size: 14px !important;
}
.filter-area .slds-listbox__option .slds-media__body {
    font-size: 12px;
}
.checkboxalignonePDelegate .slds-checkbox{
    display: inline-flex !important;
}
.checkboxalignonePDelegate .slds-form-element__help{
    top: -18px;
    position: absolute;
    width: 200px;
    left: 8px;
} 
 .checkboxalignUSPDelegate .slds-checkbox{
    display: inline-flex !important;
} 
.checkboxalignUSPDelegate .slds-form-element__help{
    top: -18px;
    position: absolute;
    width: 200px;
    left: 8px;
} 
.checkboxalignNonUSPDelegate .slds-checkbox{
    display: inline-flex !important;
} 
.checkboxalignNonUSPDelegate .slds-form-element__help{
    top: -18px;
    position: absolute;
    width: 200px;
    left: 8px;
} 
.checkboxalignEmancipation .slds-checkbox{
    display: inline-flex !important;
} 
.checkboxalignEmancipation .slds-form-element__help{
    top: -16px;
    position: absolute;
    width: 200px;
    left: 8px;
} 
.dateErrAlign .slds-form-element__help{	
    width: 300px;	
}
@media (max-device-width: 767px) {
    .pir-parent .slds-tabs_default__link {
      max-width: 190px;
    } 
    .addInfoCssDiv .slds-textarea{
        height: 67px;
    }
    .dropdown_truncate .slds-truncate {
        width:12rem;
    }
    .checkboxalignonePDelegate .slds-form-element__label{
        width: 83%;
        margin-top: 33px;
    }
    .checkboxalignonePDelegate .slds-form-element__help{
        top: -20px;
    } 
    .checkboxalignUSPDelegate .slds-form-element__help{
        top: -20px;
    } 
    .checkboxalignNonUSPDelegate .slds-form-element__help{
        top: 16px;
    } 
    .checkboxalignNonUSPDelegate .slds-form-element__help{
        top: -20px;
    } 
   
}
