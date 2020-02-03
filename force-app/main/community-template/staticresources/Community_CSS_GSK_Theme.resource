/* Community_CSS_GSK_Theme */

.main-header-brand{
    background: linear-gradient(to right, #F35C04 0%, #F7EC68 100%);
}

.slds-spinner_brand.slds-spinner:before,
.slds-spinner_brand.slds-spinner:after,
.slds-spinner--brand.slds-spinner:before,
.slds-spinner--brand.slds-spinner:after,
.slds-spinner_brand .slds-spinner__dot-a:before,
.slds-spinner_brand .slds-spinner__dot-b:before,
.slds-spinner_brand .slds-spinner__dot-a:after,
.slds-spinner_brand .slds-spinner__dot-b:after,
.slds-spinner--brand .slds-spinner__dot-a:before,
.slds-spinner--brand .slds-spinner__dot-b:before,
.slds-spinner--brand .slds-spinner__dot-a:after,
.slds-spinner--brand .slds-spinner__dot-b:after {
    background-color: #ef5b04!important;
}

.apollo-btn.primary{
    background: #F35C04;
    box-shadow: 0 4px 8px 0 rgba(243, 92, 4, 0.16), 0 4px 4px 0 rgba(0, 0, 0, 0.04), 0 8px 16px 0 rgba(243, 92, 4, 0.32);
    color: #FFFFFF;
    font-size: 1rem;
    padding: 6px 16px;
}

.apollo-btn.primary:hover, .apollo-btn.primary:focus, .apollo-btn.primary:active {
    background: rgba(214, 84, 4, 0.99);
    transition: .25s;
    box-shadow: 0 4px 8px 0 rgba(212, 84, 5, 0.16), 0 4px 4px 0 rgba(0, 0, 0, 0.04), 0 8px 16px 0 rgba(179, 71, 4, 0.32);
}

.apollo-btn.primary > .rr-icon-default{
    fill: white!important;
}

.apollo-btn.primary:active:not(:disabled){
    background: #f35c04;
    box-shadow: 0 8px 20px 0 rgba(0,0,0,0.20), 0 8px 30px 0 rgba(243, 92, 4, 0.5);
    color: #FFFFFF;
}

.apollo-btn.primary.dark{
    background: #f85d04;
    box-shadow: 0 8px 20px 0 rgba(0,0,0,0.10);
    color: #FFFFFF;
}

.apollo-btn.primary.dark:active:not(:disabled){
    background: #e85804;
    box-shadow: 0 8px 20px 0 rgba(0,0,0,0.10);
    color: #FFFFFF;
}