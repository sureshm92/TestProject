import { LightningElement, track, api } from "lwc";
import recordsOfTeleAndInitialVisit from "@salesforce/apex/SiteCalendarController.recordsOfTeleAndInitialVisit";
import Id from "@salesforce/user/Id";
import pirResources from "@salesforce/resourceUrl/pirResources";
import SiteVisit from "@salesforce/resourceUrl/SiteVisit";
import TeleVisit from "@salesforce/resourceUrl/TeleVisit";
import NoVisitIcon from "@salesforce/resourceUrl/NoVisitIcon";
import getStudyStudySiteDetails from "@salesforce/apex/PIR_BulkImportController.getStudyStudySiteDetails";
import { NavigationMixin } from "lightning/navigation";
import SiteCalCSS from "@salesforce/resourceUrl/SiteCalCSS";
import { loadStyle } from "lightning/platformResourceLoader";
import TIME_ZONE from "@salesforce/i18n/timeZone";
import LOCALE from "@salesforce/i18n/locale";
import Join from "@salesforce/label/c.WelcomeModal_Join";
import Televisit from "@salesforce/label/c.RH_Televisit";
import VisitInSite from "@salesforce/label/c.RH_Visit_in_Site";
import NoVisits from "@salesforce/label/c.RH_No_Visits";
import NoActiveStudy from "@salesforce/label/c.RH_No_Active_Study";
import propertyName from "@salesforce/community/basePath";

const timeZone = TIME_ZONE;
const locale = LOCALE;

export default class Sitecalender extends NavigationMixin(LightningElement) {
  channel = "/event/Televisit_Event__e";
  checkIcon = pirResources + "/pirResources/icons/status-good.svg";
  SiteVisit = SiteVisit;
  TeleVisit = TeleVisit;
  NoVisitDataIcon = NoVisitIcon;
  subscription;
  userTimeZone = timeZone;
  label = {
    Join,
    Televisit,
    VisitInSite,
    NoVisits,
    NoActiveStudy
  };
  noData = '';
  clearAll = false;
  divcss =
    "slds-col slds-size_1-of-1 slds-medium-size_12-of-12 slds-large-size_12-of-12 slds-scrollable scroll-mobile filterclose";
  //Accordian
  toggleAccordian(event) {
    this.template
      .querySelectorAll("." + event.currentTarget.dataset.name)
      .forEach(function (L) {
        L.classList.toggle("slds-hide");
      });
  }
  userId = Id;
  @track visitData;
  totalTime = false;
  studyValues = [];
  studySiteValues = [];
  studySiteIds = [];
  studyValuesId = [];
  filterData = { calendarDate: "", study: {}, studySite: {} };
  subscription;
  studyFilterWrapper = {
    studyList: [],
    siteList: []
  };
  isLoaded = true;
  myreferral;
  perName;
  pName;
  refIdName;
  fullname;
  studySiteDetails = [];
  isStudyDetailsFilled;
  loginUserDate;
  selectedDate;
  disableFilters = false;

  connectedCallback() {
    loadStyle(this, SiteCalCSS);
    this.studySiteData();
  }

  studySiteData() {
    this.isStudyDetailsFilled = false;
    getStudyStudySiteDetails()
      .then((result) => {
        this.studySiteDetails = result;
        this.isStudyDetailsFilled = true;
        for (var key in result.ctpMap) {
          this.studyValues.push(result.ctpMap[key]);
        }
        for (var key in result.studySiteMap) {
          this.studySiteValues.push(result.studySiteMap[key]);
        }
        for (let i = 0; i < this.studyValues.length; i++) {
          this.studyValuesId.push(this.studyValues[i]);
        }

        for (let i = 0; i < this.studySiteValues.length; i++) {
          for (let j = 0; j < this.studySiteValues[i].length; j++) {
            this.studySiteIds.push(this.studySiteValues[i][j].Id);
          }
        }

        this.filterData.study = this.studyValuesId;
        this.filterData.studySite = this.studySiteIds;
        // below date build moved from fetch visit to this method to handle parameter-- remove this comment
        var todayDate = new Date();
        let userDate = new Date(
          todayDate.toJSON(locale, { timeZone: timeZone })
        );
        var dd = String(userDate.getDate()).padStart(2, "0");
        var mm = String(userDate.getMonth() + 1).padStart(2, "0"); //January is 0!
        var yyyy = userDate.getFullYear();

        userDate = yyyy + "-" + mm + "-" + dd;
        this.selectedDate = userDate;
        if(this.studyValuesId.length > 0 && this.studySiteValues.length > 0) {
          this.disableFilters = false;
          this.fetchVisitData(userDate);
        } else {
          this.disableFilters = true;
          this.haveVisits = false;
          this.noData = this.label.NoActiveStudy;
          this.isLoaded = false;
        }
      })
      .catch((error) => {
        this.error = error;
        console.log('error:'+error);
      });
  }
  haveVisits = true; //added for no visits
  fetchVisitData(dateSelected) {
    if(this.clearAll || this.disableFilters) {
      return;
    }else {
      this.filterData.calendarDate = dateSelected;
      recordsOfTeleAndInitialVisit({
        filterData: JSON.stringify(this.filterData)
      })
        .then((result) => {
          this.isLoaded = false;
          if (result.length != 0) {
            this.haveVisits = true;
            this.visitData = result;
            if (this.visitData.durationTime != null) {
              this.visitData.forEach(function (vss) {
                var now = new Date();
                let dateNow = new Date(now);
                let bannerStartTime = new Time(vss.visitTime);
                if (dateNow >= bannerStartTime) {
                  this.totalTime = true;
                }
              });
            }
            this.error = undefined;
          } else {
            this.haveVisits = false;
            this.noData = this.label.NoVisits
          }
        })
        .catch((error) => {
          this.error = error;
          console.log('error:'+error);
        });
    }
  }
  navigateToParticipantTab(event) {
    this.refIdName = event.currentTarget.title;
    this.fullname = event.currentTarget.name;
    if (!event.currentTarget.id) {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          pageName: "my-referrals"
        },
        state: {
          perName: this.refIdName,
          Pname: this.fullname,
          dTime: "false"
        }
      });
    } else {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          pageName: "my-referrals"
        },
        state: {
          perName: this.refIdName,
          Pname: this.fullname,
          dTime: "true"
        }
      });
    }
  }

  handleDateSelection(event) {
    const newDateSelected = event.detail;
    this.selectedDate = newDateSelected;
    this.fetchVisitData(newDateSelected);
  }

  handleStudySiteFilterEvent(event) {
    this.isLoaded = true;
    let studyIds = [];
    let siteIds = [];
    this.clearAll = false;
    for (let i = 0; i < event.detail.study.length; i++) {
      studyIds.push(event.detail.study[i].value);
    }
    for (let i = 0; i < event.detail.studySite.length; i++) {
      siteIds.push(event.detail.studySite[i].value);
    }
    this.filterData.study = studyIds;
    this.filterData.studySite = siteIds;
    this.fetchVisitData(this.selectedDate);
  }

  handleJoin(event) {
    let url = propertyName.replace('/s', '') + event.currentTarget.dataset.meeturl;
    window.open(url, "_blank");
  }

  handleAccordianEvent(event) {
    let isOpenAccordian = event.detail.isOpenAccordian;
    if (isOpenAccordian) {
      this.divcss =
        "slds-col slds-size_1-of-1 slds-medium-size_12-of-12 slds-large-size_12-of-12 slds-scrollable scroll-mobile filteropen";
    } else {
      this.divcss =
        "slds-col slds-size_1-of-1 slds-medium-size_12-of-12 slds-large-size_12-of-12 slds-scrollable scroll-mobile filterclose";
    }
  }

  handleClearAll(event) {
    this.clearAll = true;
    this.haveVisits = false;
    this.filterData.study = [];
    this.filterData.studySite = [];
    this.noData = event.detail.msg;
  }
  
}