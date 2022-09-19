import { LightningElement, track, api } from "lwc";
import recordsOfTeleAndInitialVisit from "@salesforce/apex/SiteCalendarController.recordsOfTeleAndInitialVisit";
import Id from "@salesforce/user/Id";
import pirResources from "@salesforce/resourceUrl/pirResources";
import SiteVisit from "@salesforce/resourceUrl/SiteVisit";
import TeleVisit from "@salesforce/resourceUrl/TeleVisit";
import getStudyStudySiteDetails from "@salesforce/apex/PIR_BulkImportController.getStudyStudySiteDetails";
import noVisitsLabel from "@salesforce/label/c.NoVisits"; //added label for no visits for a date- remove coment
import { NavigationMixin } from "lightning/navigation";
import SiteCalCSS from "@salesforce/resourceUrl/SiteCalCSS";
import { loadStyle } from "lightning/platformResourceLoader";
import TIME_ZONE from "@salesforce/i18n/timeZone";
import LOCALE from "@salesforce/i18n/locale";
import Join from '@salesforce/label/c.WelcomeModal_Join';
import Televisit from '@salesforce/label/c.RH_Televisit';
import VisitInSite from '@salesforce/label/c.RH_Visit_in_Site';
import NoEvents from '@salesforce/label/c.RH_No_events';
import RegisterToday from '@salesforce/label/c.RH_registered_today';
const timeZone = TIME_ZONE;
const locale = LOCALE;

export default class Sitecalender extends NavigationMixin(LightningElement) {
  channel = "/event/Televisit_Event__e";
  checkIcon = pirResources + "/pirResources/icons/status-good.svg";
  SiteVisit = SiteVisit;
  TeleVisit = TeleVisit;
  noVisitsForDate = noVisitsLabel; //added label for no visits-Remove comment later
  subscription;
  label = {
    Join,
    Televisit,
    VisitInSite,
    NoEvents,
    RegisterToday
  };
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

  connectedCallback() {
    loadStyle(this, SiteCalCSS);
    this.studySiteData();
  }

  studySiteData() {
    getStudyStudySiteDetails()
      .then((result) => {
        this.studySiteDetails = result;
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
          todayDate.toLocaleString(locale, { timeZone: timeZone })
        );
        var dd = String(userDate.getDate()).padStart(2, "0");
        var mm = String(userDate.getMonth() + 1).padStart(2, "0"); //January is 0!
        var yyyy = userDate.getFullYear();

        userDate = yyyy + "-" + mm + "-" + dd;
        this.fetchVisitData(userDate);
      })
      .catch((error) => {
        this.error = error;
      });
  }
  haveVisits = true; //added for no visits
  fetchVisitData(dateSelected) {
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
        }
      })
      .catch((error) => {
        this.error = error;
        console.log(error);
      });
  }
  navigateToParticipantTab(event) {
    this.refIdName = event.currentTarget.title;
    this.fullname = event.currentTarget.name;
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        pageName: "my-referrals"
      },
      state: {
        perName: this.refIdName,
        Pname: this.fullname
      }
    });
  }

  handleDateSelection(event) {
    const newDateSelected = event.detail;
    this.fetchVisitData(newDateSelected);
  }

  handleStudySiteFilterEvent(event) {
    this.studyFilterWrapper = event.detail;
  }

  handleJoin(event) {
    let url = event.currentTarget.dataset.meeturl;
    window.open(url, "_blank");
  }
}