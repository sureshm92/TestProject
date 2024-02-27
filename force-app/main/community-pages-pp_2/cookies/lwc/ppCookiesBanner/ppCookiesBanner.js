import { LightningElement, track, api } from "lwc";
import ppCookiesBannerLoginDesc from "@salesforce/label/c.PP_Cookies_Banner_Login_Desc";
import ppCookiesBannerDesc1 from "@salesforce/label/c.PP_Cookies_Banner_Desc1";
import ppCookiesBannerDesc2 from "@salesforce/label/c.PP_Cookies_Banner_Desc2";
import ppCookiesBannerDesc3 from "@salesforce/label/c.PP_Cookies_Banner_Desc3";
import ppCookiesButtonAccept from "@salesforce/label/c.PP_Cookies_Button_Accept";
import ppCookiesButtonManagePrefer from "@salesforce/label/c.PP_Cookies_Button_Manage_Prefer";
import ppCookieBannerHeader from "@salesforce/label/c.PP_Cookie_Banner_Header";
import getInitData from "@salesforce/apex/AccountSettingsController.getInitData";
import changeOptInCookies from "@salesforce/apex/AccountSettingsController.changeOptInCookies";
import updateTheRegCookieAcceptance from "@salesforce/apex/AccountSettingsController.updateTheRegCookieAcceptance";

import pp_icons from "@salesforce/resourceUrl/pp_community_icons";

import cookieManageCookiesLabel from "@salesforce/label/c.Cookies_Manage_Cookies";
import manageCookiesDesc from "@salesforce/label/c.Manage_Cookies_Desc";
import accountSettingsStrictlyNecessaryCookies from "@salesforce/label/c.AccountSettings_Strictly_Necessary_Cookies";
import cookieAlwaysActive from "@salesforce/label/c.Cookie_Always_Active";
import accountSettingsFunctionalCookiesLabel from "@salesforce/label/c.AccountSettings_Functional_Cookies";
import accountSettingsFunctionalRRCookiesLabel from "@salesforce/label/c.AccountSettings_Functional_RRCookies";
import accountSettingsRRCookiesDescriptionLabel from "@salesforce/label/c.AccountSettings_RRCookies_Description";
import accountSettingsCookiesRRLanguageLabel from "@salesforce/label/c.AccountSettings_Cookies_RRLanguage";
import accountSettingsCookiesRRLanguageDescriptionLabel from "@salesforce/label/c.AccountSettings_Cookies_RRLanguage_Description";
import bTN_AcceptLabel from "@salesforce/label/c.BTN_Accept";
import loadingLabel from "@salesforce/label/c.Loading";
import DEVICE from '@salesforce/client/formFactor';
import bTN_I_Acknowledge from '@salesforce/label/c.I_Acknowledge';
import getAlumniTemplate from "@salesforce/apex/ParticipantService.getAlumniTemplate";
import getTemp from "@salesforce/apex/ParticipantService.getTemp";
import getStudy from "@salesforce/apex/HomePageParticipantRemote.getInitData";

export default class PpCookiesBanner extends LightningElement {
  showmodal = false;
  @api
  loginPage = false;
  @api
  isRTL = false;
  @api
  termsAndConditions = false;
  @api
  isDummy = false;
  @api
  communityName;
  userMode;
  spinner;
  containerClassCss = "c-container desk-cookies-banner mob-cookies-banner ";
  containerClassCssPostLogin = "c-container desk-cookies-banner-post-login mob-cookies-banner-new";
  modalTopCss = " slds-grid card-top-bg ";
  acceptButtonCss = "accept-btn-container btn-label cookie-btn ";
  acceptAllButtonCss = "btn-container btn-label cookie-btn cookie-cursor";
  modalContainer = "slds-modal__container modal-container";
  manageButtonCss = "btn-container manage cookie-btn cookie-cursor";
  accordionCss = "accordion ";
  accordionActiveCss = "accordion active ";
  acknowledgeButtonCss = 'acknowledge_button ';
  label = {
    ppCookiesBannerLoginDesc,
    ppCookiesBannerDesc1,
    ppCookiesBannerDesc2,
    ppCookiesBannerDesc3,
    ppCookiesButtonAccept,
    ppCookiesButtonManagePrefer,
    ppCookieBannerHeader,
    cookieManageCookiesLabel,
    manageCookiesDesc,
    accountSettingsStrictlyNecessaryCookies,
    cookieAlwaysActive,
    accountSettingsFunctionalCookiesLabel,
    accountSettingsFunctionalRRCookiesLabel,
    accountSettingsRRCookiesDescriptionLabel,
    accountSettingsCookiesRRLanguageLabel,
    accountSettingsCookiesRRLanguageDescriptionLabel,
    bTN_AcceptLabel,
	bTN_I_Acknowledge
  };
  showBanner = false;
  initData;
  contact;
  dynamicCSSAppend = pp_icons + "/right.svg";
  footerUILogo = pp_icons + '/footer_ui_logo.svg';
  cookiesBannerDesc3;
  isJanssenCommunity;
  isMobile = false;
  managePrefClick = false;

  @api isJanssen = false;
  @api isAlumni = false;

  connectedCallback() {
    DEVICE != 'Small' ? (this.isMobile = false) : (this.isMobile = true);
    var temp = "";
    if(this.loginPage){
        this.loginPg(); 
    }else{
        getTemp({}).then((tmp) => {
            temp = tmp;
          }).then(() => {
              if(temp == "PatientPortal" && !this.loginPage) {
                  this.ppCookieBanner();
              }else{
              this.cookiesBannerDesc3 = " " + this.label.ppCookiesBannerDesc3;
             
              this.isJanssenCommunity = this.communityName == "Janssen Community";
          
              let rrCookies = communityService.getCookie("RRCookies");
              let data = sessionStorage.getItem("Cookies");
              if (localStorage.getItem("Cookies")) {
                data = localStorage.getItem("Cookies");
              }
              if (!this.loginPage && communityService.isInitialized()) {
                if (communityService.getParticipantData().cookiesAgreedonRegPage) {
                  if (this.isJanssenCommunity) {
                    this.setRRCookie();
                  }
                  if(rrCookies){
                    data = "Agreed";}
                  updateTheRegCookieAcceptance()
                    .then(() => {
                      communityService.setCookiesAgreedonReg(false);
                    })
                    .catch((error) => {
                      communityService.showToast(
                        "",
                        "error",
                        "Failed to read the data.",
                        100
                      );
                    });
                }
              }
              if (!this.loginPage && data) {
                this.showBanner = false;
				this.showmodal = false;
              }
              if (
                (!rrCookies || this.loginPage) &&
                !data &&
                !sessionStorage.getItem("CookiesonLoginPage")
              ) {
                if (
                  this.isDummy &&
                  !localStorage.getItem("CookiesOnTC") &&
                  !this.termsAndConditions
                ) {
                  this.showBanner = true;
				  this.showmodal = true;
                }
                if (this.isDummy) {
                  localStorage.setItem("CookiesOnTC", "Accepted");
                }
        
                if (!this.termsAndConditions && !this.isDummy) {
                  //Home Page
                  this.showBanner = true; this.showmodal = true;
                }
        
                if (
                  this.termsAndConditions &&
                  !localStorage.getItem("CookiesOnTC") &&
                  !this.isDummy
                ) {
                  //Cookies banner for terms page
                  this.showBanner = true; this.showmodal = true;
                }
                if (this.termsAndConditions) {
                  localStorage.setItem("CookiesOnTC", "Accepted");
                }
                
                if(this.showBanner){
                this.blockBackGroundEvents();
                }
                if(window.location.href.indexOf("terms-and-conditions") != -1){
                    if(this.showBanner){
                    document.body.classList.remove("cookie-block-user");
                    let htmlDivs = document.getElementsByTagName("html");
                    htmlDivs[0].classList.remove("cookie-block-user");
                    this.showBanner = false;
                    } 
                }
                if (
                  this.communityName == "Default" ||
                  this.communityName == "IQVIA Referral Hub" ||
                  this.communityName == "Janssen"                  
                ) {
                  this.containerClassCss =
                    this.containerClassCss + " rh-cookies-banner";
                  //  this.containerClassCss = this.containerClassCss + ' rh-border-radius';
                  this.modalTopCss = this.modalTopCss + " rh-card-top-bg";
                  this.acceptButtonCss =
                    this.acceptButtonCss + " rh-accept-btn-container";
                  this.modalContainer = this.modalContainer + " rh-modal-container";
                  this.manageButtonCss = this.manageButtonCss + " rh-border-radius";
                  this.acceptAllButtonCss =
                    this.acceptAllButtonCss + "  rh-border-radius";
                  this.accordionCss = this.accordionCss + "  rh-border-radius";
                  this.accordionActiveCss =
                    this.accordionActiveCss + " rh-border-radius";
				  this.acknowledgeButtonCss = this.acknowledgeButtonCss + ' rh-border-radius';	
                }
                if (this.communityName == "Janssen Community") {
                  this.modalTopCss = this.modalTopCss + " janssen-card-top-bg";
                }
              }
              sessionStorage.removeItem("Cookies");
              localStorage.removeItem("Cookies");
              sessionStorage.removeItem("CookiesonLoginPage");
              if (!this.isDummy && !this.termsAndConditions) {
                localStorage.removeItem("CookiesOnTC");
              }
              let accList = this.template.querySelectorAll("accordion");   
              }
          })
    }
  }
  loginPg(){
      
      this.cookiesBannerDesc3 = " " + this.label.ppCookiesBannerDesc3;
    
      this.isJanssenCommunity = this.communityName == "Janssen Community";
      let rrCookies = communityService.getCookie("RRCookies");
      let data = sessionStorage.getItem("Cookies");
      if (localStorage.getItem("Cookies")) {
        data = localStorage.getItem("Cookies");
      }
      if (!this.loginPage && communityService.isInitialized()) {
        if (communityService.getParticipantData().cookiesAgreedonRegPage) {
          if (this.isJanssenCommunity) {
            this.setRRCookie();
          }
          if(rrCookies){
            data = "Agreed";}
          updateTheRegCookieAcceptance()
            .then(() => {
              communityService.setCookiesAgreedonReg(false);
            })
            .catch((error) => {
              communityService.showToast(
                "",
                "error",
                "Failed to read the data.",
                100
              );
            });
        }
      }
      if (!this.loginPage && data) {
        this.showBanner = false;  this.showmodal = false;
      }
      if (
        (!rrCookies || this.loginPage) &&
        !data &&
        !sessionStorage.getItem("CookiesonLoginPage")
      ) {
        if (
          this.isDummy &&
          !localStorage.getItem("CookiesOnTC") &&
          !this.termsAndConditions
        ) {
          this.showBanner = true;  this.showmodal = true;
        }
        if (this.isDummy) {
          localStorage.setItem("CookiesOnTC", "Accepted");
        }

        if (!this.termsAndConditions && !this.isDummy) {
          //Home Page
          this.showBanner = true;  this.showmodal = true;
        }

        if (
          this.termsAndConditions &&
          !localStorage.getItem("CookiesOnTC") &&
          !this.isDummy
        ) {
          //Cookies banner for terms page
          this.showBanner = true;  this.showmodal = true;
        }
        if (this.termsAndConditions) {
          localStorage.setItem("CookiesOnTC", "Accepted");
        }
        if(this.showBanner){ 
        this.blockBackGroundEvents();
        }
        if (
          this.communityName == "Default" ||
          this.communityName == "IQVIA Referral Hub" ||
          this.communityName == "Janssen"             
        ) {
          this.containerClassCss =
            this.containerClassCss + " rh-cookies-banner";
          //  this.containerClassCss = this.containerClassCss + ' rh-border-radius';
          this.modalTopCss = this.modalTopCss + " rh-card-top-bg";
          this.acceptButtonCss =
            this.acceptButtonCss + " rh-accept-btn-container";
          this.modalContainer = this.modalContainer + " rh-modal-container";
          this.manageButtonCss = this.manageButtonCss + " rh-border-radius";
          this.acceptAllButtonCss =
            this.acceptAllButtonCss + "  rh-border-radius";
          this.accordionCss = this.accordionCss + "  rh-border-radius";
          this.accordionActiveCss =
            this.accordionActiveCss + " rh-border-radius";
		   this.acknowledgeButtonCss = this.acknowledgeButtonCss + ' rh-border-radius';	
        }
        if (this.communityName == "Janssen Community") {
          this.modalTopCss = this.modalTopCss + " janssen-card-top-bg";
        }
      }
      sessionStorage.removeItem("Cookies");
      localStorage.removeItem("Cookies");
      sessionStorage.removeItem("CookiesonLoginPage");
      if (!this.isDummy && !this.termsAndConditions) {
        localStorage.removeItem("CookiesOnTC");
      }
      let accList = this.template.querySelectorAll("accordion");
  }
  get isJanssenStudy() {
     if(this.isJanssenCommunity == true || this.isJanssen == true){
       return true;
     }else{
       return false;
     }
  }
  ppCookieBanner(){
    getAlumniTemplate({})
      .then((alumniValue) => {
        this.isAlumni = alumniValue;
      })
      .then(() => {
        getStudy({})
          .then((studyresult) => {
            let sr = JSON.parse(studyresult);
            let ctp = sr.ctp;
            if(ctp != null){
            let CommTemp = ctp.CommunityTemplate__c;
            let tempName = JSON.stringify(ctp.PPTemplate__c);

            if (CommTemp == "Janssen") {
              if (!this.isAlumni) {
                this.isJanssen = true;
              }
            } else {
              this.isJanssen = false;
           }
          }else{
            this.isJanssen = false;
          }
          
          })
          .then(() => {
            this.cookiesBannerDesc3 = " " + this.label.ppCookiesBannerDesc3;
          
            this.isJanssenCommunity =
              this.communityName == "Janssen Community";
          
            let rrCookies = communityService.getCookie("RRCookies");
            let data = sessionStorage.getItem("Cookies");
            if (localStorage.getItem("Cookies")) {
              data = localStorage.getItem("Cookies");
            }
            if (!this.loginPage && communityService.isInitialized()) {
              if (
                communityService.getParticipantData().cookiesAgreedonRegPage
              ) {
                if (this.isJanssenCommunity) {
                  this.setRRCookie();
                }
                if(rrCookies){
                  data = "Agreed";}
                updateTheRegCookieAcceptance()
                  .then(() => {
                    communityService.setCookiesAgreedonReg(false);
                  })
                  .catch((error) => {
                    communityService.showToast(
                      "",
                      "error",
                      "Failed to read the data.",
                      100
                    );
                  });
              }
            }
            if (!this.loginPage && data) {
              this.showBanner = false; this.showmodal = false;
            }
            if (
              (!rrCookies || this.loginPage) &&
              !data &&
              !sessionStorage.getItem("CookiesonLoginPage")
            ) {
              if (
                this.isDummy &&
                !localStorage.getItem("CookiesOnTC") &&
                !this.termsAndConditions
              ) {
                this.showBanner = true; this.showmodal = true;
              }
              if (this.isDummy) {
                localStorage.setItem("CookiesOnTC", "Accepted");
              }

              if (!this.termsAndConditions && !this.isDummy) {
                //Home Page
                this.showBanner = true; this.showmodal = true;
              }

              if (
                this.termsAndConditions &&
                !localStorage.getItem("CookiesOnTC") &&
                !this.isDummy
              ) {
                //Cookies banner for terms page
                this.showBanner = true; this.showmodal = true;
              }
              if (this.termsAndConditions) {
                localStorage.setItem("CookiesOnTC", "Accepted");
              }
             
              this.blockBackGroundEvents();
              if (
                this.communityName == "Default" ||
                this.communityName == "IQVIA Referral Hub"
              ) {
                this.containerClassCss =
                  this.containerClassCss + " rh-cookies-banner";
                //  this.containerClassCss = this.containerClassCss + ' rh-border-radius';
                this.modalTopCss = this.modalTopCss + " rh-card-top-bg";
                this.acceptButtonCss =
                  this.acceptButtonCss + " rh-accept-btn-container";
                this.modalContainer =
                  this.modalContainer + " rh-modal-container";
                this.manageButtonCss =
                  this.manageButtonCss + " rh-border-radius";
                this.acceptAllButtonCss =
                  this.acceptAllButtonCss + "  rh-border-radius";
                this.accordionCss = this.accordionCss + "  rh-border-radius";
                this.accordionActiveCss =
                  this.accordionActiveCss + " rh-border-radius";
				this.acknowledgeButtonCss = this.acknowledgeButtonCss + ' rh-border-radius';
              }
              if (this.communityName == "Janssen Community") {
                this.modalTopCss = this.modalTopCss + " janssen-card-top-bg";
              }
            }
            sessionStorage.removeItem("Cookies");
            localStorage.removeItem("Cookies");
            sessionStorage.removeItem("CookiesonLoginPage");
            if (!this.isDummy && !this.termsAndConditions) {
              localStorage.removeItem("CookiesOnTC");
            }
            let accList = this.template.querySelectorAll("accordion");
          });
      });
  }
  blockBackGroundEvents() {
    document.body.addEventListener("keypress", this.bodyBlock);
    document.body.addEventListener("keydown", this.bodyBlock);
    document.body.classList.add("cookie-block-user");
    let htmlDivs = document.getElementsByTagName("html");
    htmlDivs[0].classList.add("cookie-block-user");
  }
  bodyBlock(event) {
    event.preventDefault();
  }
  showManagePreferences() {
    this.managePrefClick = true;
    this.spinner = this.template.querySelector("c-web-spinner");

    if (this.spinner) this.spinner.show();
    this.userMode = communityService.getUserMode();
    this.showmodal = true;
    this.closeTheBanner();
    getInitData({
      userMode: this.userMode
    })
      .then((returnValue) => {
        if (this.spinner) this.spinner.hide();
        let initData = JSON.parse(returnValue);
        this.initData = initData;
        this.blockBackGroundEvents(); 
        this.contact = initData.myContact;
        this.contact.RRCookiesAllowedCookie__c =
          initData.myContact.RRCookiesAllowedCookie__c;
        this.contact.RRLanguageAllowedCookie__c =
          initData.myContact.RRLanguageAllowedCookie__c;
      })
      .catch((error) => {
        communityService.showToast(
          "",
          "error",
          "Failed to read the data.",
          100
        );
      });
  }
  renderedCallback() {
    let el = this.template.querySelector(".modal-header-text");
    var bodyStyles = document.body.style;
    bodyStyles.setProperty(
      "--cookieRightIcon",
      "url(" + this.dynamicCSSAppend + ")"
    );
  }

  showCookieDiv(event) {
    let el = this.template.querySelectorAll(".accordion.active");
    let divEle = this.template.querySelector(
      "[id='" + event.currentTarget.id + "']"
    );
    divEle.classList.toggle("active");
    let panel = divEle.getElementsByTagName("div")[1];
    if (panel.style.display === "block") {
      panel.style.display = "none";
    } else {
      panel.style.display = "block";
    }
  }

  closeTheBanner() {
    document.body.classList.remove("cookie-block-user");
    let htmlDivs = document.getElementsByTagName("html");
    htmlDivs[0].classList.remove("cookie-block-user");
    this.showBanner = false; this.showmodal = false;
    document.body.removeEventListener("keypress", this.bodyBlock);
    document.body.removeEventListener("keydown", this.bodyBlock);
    let bodyStyles = document.body.style;
    bodyStyles.removeProperty("--cookieRightIcon"); this.showmodal = false;
  }

  acceptAll() {
    communityService.setCookie("RRCookies", "agreed", 365);
    document.body.classList.remove("cookie-block-user");
    let htmlDivs = document.getElementsByTagName("html");
    htmlDivs[0].classList.remove("cookie-block-user");
    this.showBanner = false; this.showmodal = false;
    if (!this.isJanssenCommunity) { 
        if(!this.isJanssen){ 
          changeOptInCookies({
            rrCookieAllowed: true,
            rrLanguageAllowed: true
          })
            .then((returnValue) => {
              if (this.spinner) this.spinner.hide();
              if (this.contact) {
                this.contact.RRCookiesAllowedCookie__c = true;
                this.contact.RRLanguageAllowedCookie__c = true;
              }
              this.setRRCookie();
              this.setRRCookieLanguage();
              this.closeTheBanner();
              this.showmodal = false;
              this.initData = undefined;
            })
            .catch((error) => {
              communityService.showToast(
                "",
                "error",
                "Failed to read the data.",
                100
              );
              this.spinner.hide();
            });
        }else{
          changeOptInCookies({
            rrCookieAllowed: true,
            rrLanguageAllowed: false
          })
            .then((returnValue) => {
              if (this.spinner) this.spinner.hide();
              if (this.contact) {
                this.contact.RRCookiesAllowedCookie__c = true;
                this.contact.RRLanguageAllowedCookie__c = false;
              }
              this.setRRCookie();
              this.setRRCookieLanguage();
              this.closeTheBanner();
              this.showmodal = false;
              this.initData = undefined;
            })
            .catch((error) => {
              communityService.showToast(
                "",
                "error",
                "Failed to read the data.",
                100
              );
              this.spinner.hide();
            });
        }  
    } else {
      if (this.isJanssenCommunity){
        changeOptInCookies({
          rrCookieAllowed: true,
          rrLanguageAllowed: false
        })
          .then((returnValue) => {
            if (this.spinner) this.spinner.hide();
            if (this.contact) {
              this.contact.RRCookiesAllowedCookie__c = true;
              this.contact.RRLanguageAllowedCookie__c = false;
            }
            this.setRRCookie();
            this.setRRCookieLanguage();
            this.closeTheBanner();
            this.showmodal = false;
            this.initData = undefined;
          })
          .catch((error) => {
            communityService.showToast(
              "",
              "error",
              "Failed to read the data.",
              100
            );
            this.spinner.hide();
          });
        }else{
          if (this.spinner) this.spinner.hide();
          this.setRRCookie();
          this.closeTheBanner();
          this.showmodal = false;
          this.initData = undefined;
        }
    }
  }

  get backDropClass() {
    //return "slds-backdrop " + (this.showmodal ? " slds-backdrop_open " : "");
    if(this.managePrefClick){
      // show backdrop
      return "slds-backdrop slds-backdrop_open";
    }
    else if(this.showmodal){
      if(!this.loginPage){
        // Post login page      
          return "slds-backdrop";
      }
      else{
        // Login page
        return "slds-backdrop " + (this.showmodal ? " slds-backdrop_open " : "");
      }
    }
    else{
      return "slds-backdrop";
    }
  }

  updateCookies() {
    this.spinner.show();
    if (!this.isJanssenCommunity) {
      if(!this.isJanssen){
        let ppLangChecked =
          this.template.querySelector("[data-id=PPLang]").checked;
        let ppCookieChecked =
          this.template.querySelector("[data-id=PPCookie]").checked;
        this.contact.RRCookiesAllowedCookie__c = ppCookieChecked;
        this.contact.RRLanguageAllowedCookie__c = ppLangChecked;
        changeOptInCookies({
          rrCookieAllowed: this.contact.RRCookiesAllowedCookie__c,
          rrLanguageAllowed: this.contact.RRLanguageAllowedCookie__c
        })
          .then((returnValue) => {
            this.spinner.hide();
            if (this.contact.RRCookiesAllowedCookie__c) {
              this.setRRCookie();
              document.body.classList.remove("cookie-block-user");
              let htmlDivs = document.getElementsByTagName("html");
              htmlDivs[0].classList.remove("cookie-block-user");
            }
            if (this.contact.RRLanguageAllowedCookie__c) {
              this.setRRCookieLanguage();
            }
            this.closeTheBanner();
            this.managePrefClick = false;
            this.updateBrowserCookies();
            this.showmodal = false;
            this.initData = undefined;
          })
          .catch((error) => {
            communityService.showToast(
              "",
              "error",
              "Failed to read the data.",
              100
            );
            this.spinner.hide();
          });
      }else{
      this.contact.RRCookiesAllowedCookie__c = true;
      this.contact.RRLanguageAllowedCookie__c = false;
      changeOptInCookies({
        rrCookieAllowed: this.contact.RRCookiesAllowedCookie__c,
        rrLanguageAllowed: this.contact.RRLanguageAllowedCookie__c
      })
        .then((returnValue) => {
          this.spinner.hide();
          if (this.contact.RRCookiesAllowedCookie__c) {
            this.setRRCookie();
            document.body.classList.remove("cookie-block-user");
            let htmlDivs = document.getElementsByTagName("html");
            htmlDivs[0].classList.remove("cookie-block-user");
          }
          if (this.contact.RRLanguageAllowedCookie__c) {
            this.setRRCookieLanguage();
          }
          this.closeTheBanner();
          this.managePrefClick = false;
          this.updateBrowserCookies();
          this.showmodal = false;
          this.initData = undefined;
        })
        .catch((error) => {
          communityService.showToast(
            "",
            "error",
            "Failed to read the data.",
            100
          );
          this.spinner.hide();
        });
      }
    } else {
      if (this.isJanssenCommunity){
        changeOptInCookies({
          rrCookieAllowed: true,
          rrLanguageAllowed: false
        })
          .then((returnValue) => {
            if (this.spinner) this.spinner.hide();
            if (this.contact) {
              this.contact.RRCookiesAllowedCookie__c = true;
              this.contact.RRLanguageAllowedCookie__c = false;
            }
            this.setRRCookie();
            this.setRRCookieLanguage();
            this.closeTheBanner();
            this.managePrefClick = false;
            this.showmodal = false;
            this.initData = undefined;
          })
          .catch((error) => {
            communityService.showToast(
              "",
              "error",
              "Failed to read the data.",
              100
            );
            this.spinner.hide();
          });
        }else{
            this.setRRCookie();
            this.spinner.hide();
            this.closeTheBanner();
            this.showmodal = false;
            this.initData = undefined;
        }
    }
  }
  setRRCookie() {
    let d = new Date();
    d.setTime(d.getTime() + 365 * 24 * 60 * 60 * 1000);
    let expires = "expires=" + d.toUTCString();
    document.cookie = "RRCookies" + "=" + "agreed" + ";" + expires + ";path=/";
  }
  setRRCookieLanguage() {
    let d = new Date();
    d.setTime(d.getTime() + 365 * 24 * 60 * 60 * 1000);
    let expires = "expires=" + d.toUTCString();
    document.cookie =
      "RRLanguage" +
      "=" +
      communityService.getLanguage() +
      ";" +
      expires +
      ";path=/";
  }
  updateBrowserCookies() {
    let preventCookieList = [];
    if (!this.contact.RRCookiesAllowedCookie__c)
      preventCookieList.push("RRCookies");
    if (!this.contact.RRLanguageAllowedCookie__c)
      preventCookieList.push("RRLanguage");
    if (preventCookieList.length > 0)
      communityService.deleteCookies(preventCookieList);
  }
}