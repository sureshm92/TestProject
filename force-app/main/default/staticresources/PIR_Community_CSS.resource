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
@media (max-device-width: 767px) {
    .pir-parent .slds-tabs_default__nav{
        justify-content: space-between;
    }
    .pir-parent .slds-tabs_default__link {
      max-width: 190px;
    }
   
}