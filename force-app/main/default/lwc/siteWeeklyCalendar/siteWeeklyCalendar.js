import { LightningElement, api } from "lwc";
import TIME_ZONE from "@salesforce/i18n/timeZone";
import LOCALE from "@salesforce/i18n/locale";
import January from '@salesforce/label/c.January';
import February from '@salesforce/label/c.February';
import March from '@salesforce/label/c.March';
import April from '@salesforce/label/c.April';
import May from '@salesforce/label/c.May';
import June from '@salesforce/label/c.June';
import July from '@salesforce/label/c.July';
import August from '@salesforce/label/c.August';
import September from '@salesforce/label/c.September';
import October from '@salesforce/label/c.October';
import November from '@salesforce/label/c.November';
import December from '@salesforce/label/c.December';
import MaxWeek from '@salesforce/label/c.RH_MaxNoWeek';
import MinWeek from '@salesforce/label/c.RH_MinNoWeek';
import TodayLabel from '@salesforce/label/c.DRF_L_Today';

const month = [
  January,
  February,
  March,
  April,
  May,
  June,
  July,
  August,
  September,
  October,
  November,
  December
];
const timeZone = TIME_ZONE;
const locale = LOCALE;
const todayDate = new Date();

export default class SiteWeeklyCalendar extends LightningElement {
  @api dayList = [];
  @api currentDay;
  isNext = false;
  isPrev = false;
  @api currentMonth;
  @api currentYear;
  currentDate;
  selectedDay;
  selectedMonth;
  selectedDate;
  selectedNextWeek = 0;
  selectedPrevWeek = 0;
  label = {
    MaxWeek,
    MinWeek,
    TodayLabel
  };
  isCurrentWeek;

  connectedCallback() {
    let userDate = new Date(
      todayDate.toLocaleDateString(locale, { timeZone: timeZone })
    );
    let date;
    this.dayList = [];
    this.isNext = false;
    this.isPrev = false;
    this.currentDate = userDate.getDate();
    this.currentDay = userDate.getDay();
    this.currentMonth = month[userDate.getMonth()];
    this.currentYear = userDate.getFullYear();
    let dayn = 0;
    let daym = 0;
    var dayy = 0;

    for (let i = 0; i < 7; i++) {
      let calData = {};
      let css = "";
      let selectedCss = "slds-is-today";
      let datevalue = null;
      if (i == this.currentDay) {
        datevalue = this.fetchDay(this.currentDate);
        dayn = datevalue.getDate();
        daym = month[datevalue.getMonth()];
        dayy = datevalue.getFullYear();
        css = selectedCss;
      } else {
        datevalue = this.fetchDay(this.currentDate - (this.currentDay - i));
        dayn = datevalue.getDate();
        daym = month[datevalue.getMonth()]
        dayy = datevalue.getFullYear();
      }
      calData = { dayn: dayn, css: css, datevalue: datevalue };
      this.dayList.push(calData);
    }

    if (this.selectedDay) {
      this.userSelectedDay(this.selectedDate);
      this.selectedmonth = month[this.selectedDate.getMonth()];
      let selectedYear = this.selectedDate.getFullYear();
      this.currentMonth = this.selectedmonth;
      this.currentYear = selectedYear;
      let selectedDatee=this.selectedDate.getDate(); 		
        if(selectedDatee!=this.currentDate){		
          this.isCurrentWeek=false;		
        }		
        else{		
          this.isCurrentWeek=true;		
        }		
    }	
    else{	
      this.isCurrentWeek=true;	
    }
    
    this.currentMonth = daym;
    this.currentYear = dayy;
  }

  fetchDay(i) {
    let date = new Date();
    let userDate = new Date(
      date.toLocaleDateString(locale, { timeZone: timeZone })
    );
    userDate.toLocaleDateString(locale, { timeZone: timeZone });
    userDate.setDate(i);
    return userDate;
  }

  handlePastFutureDates(event) {
    let selectedEvent = event.currentTarget.dataset.whichevent;

    if(selectedEvent === 'next' && !this.isNext) {
      this.selectedNextWeek++;
    } else if(selectedEvent === 'prev' && !this.isPrev) {
      this.selectedPrevWeek++;
    }   
    let selectedWeek = this.selectedNextWeek - this.selectedPrevWeek;
    
    
    if( selectedWeek > 0) {
      this.handleNext(Math.abs(selectedWeek));
    } else if(selectedWeek < 0) {
      this.handlePrev(Math.abs(selectedWeek));
    } else {
      this.connectedCallback();
    }
    if(selectedWeek == parseInt(this.label.MaxWeek)) {
      this.isNext = true;
      this.template.querySelector(".next").classList.add("disable-next");
    } else {
      this.isNext = false;
      if(this.template.querySelector(".disable-next")) {
        this.template.querySelector(".next").classList.remove("disable-next");
      }
    }
    if(selectedWeek == parseInt(-this.label.MinWeek)) {
      this.isPrev = true;
      this.template.querySelector(".prev").classList.add("disable-prev");
    } else {
      this.isPrev = false;
      if(this.template.querySelector(".disable-prev")) {
        this.template.querySelector(".prev").classList.remove("disable-prev");
      }
    }
    
  }

  handleNext(currentWeek) {
    this.dayList = [];
    var dayn = 0;
    let daym = 0;
    var dayy = 0;
    this.isCurrentWeek = false;
    for (let i = 0; i < 7; i++) {
      let css = "";
      let selectedCss = "slds-is-today";
      let calData = {};
      let dateValue = null;
      if (i <= this.currentDay) {
        dateValue = this.fetchDay(
          this.currentDate + (7+((currentWeek-1) * 7) - (this.currentDay - i))
        );
        dayn = dateValue.getDate();
        daym = month[dateValue.getMonth()];
        dayy = dateValue.getFullYear();
      } else if (i > this.currentDay) {
        dateValue = this.fetchDay(
          this.currentDate + (7+((currentWeek-1) * 7) + (i - this.currentDay))
        );
        dayn = dateValue.getDate();
        daym =month[dateValue.getMonth()];
        dayy = dateValue.getFullYear();
      }
      if (dayn == this.selectedDay && daym == this.selectedmonth) {
        calData = { dayn: dayn, css: selectedCss, datevalue: dateValue };
      } else {
        calData = { dayn: dayn, css: css, datevalue: dateValue };
      }
      this.dayList.push(calData);
      
    }
    if (this.selectedDay) {
      this.selectedmonth = month[this.selectedDate.getMonth()];
      let selectedYear = this.selectedDate.getFullYear();
      this.currentMonth = this.selectedmonth;
      this.currentYear = selectedYear;
    }
      this.currentMonth = daym;
      this.currentYear = dayy;
  }

  handlePrev(currentWeek) {
    this.dayList = [];
    let dayn = 0;
    let daym = 0;
    var dayy = 0;
    this.isCurrentWeek = false;
    for (let i = 0; i < 7; i++) {
      let css = "";
      let selectedCss = "slds-is-today";
      let calData = {};
      let dateValue = null;
      if (i <= this.currentDay) {
       
        dateValue = this.fetchDay(
          this.currentDate - (7+((currentWeek-1) * 7) + this.currentDay - i)
        );
        dayn = dateValue.getDate();
        daym = month[dateValue.getMonth()];
        dayy = dateValue.getFullYear();
      } else if (i > this.currentDay) {
        dateValue = this.fetchDay(
          this.currentDate - (7+((currentWeek-1) * 7) + this.currentDay - i)
        );
        dayn = dateValue.getDate();
        daym = month[dateValue.getMonth()];
        dayy = dateValue.getFullYear();
      }
      if (dayn == this.selectedDay && daym == this.selectedmonth) {
        calData = { dayn: dayn, css: selectedCss, datevalue: dateValue };
      } else {
        calData = { dayn: dayn, css: css, datevalue: dateValue };
      }
      this.dayList.push(calData);
    }
    if (this.selectedDay) {
      this.selectedmonth = month[this.selectedDate.getMonth()];
      let selectedYear = this.selectedDate.getFullYear();
      this.currentMonth = this.selectedmonth;
      this.currentYear = selectedYear;
    }
      this.currentMonth = daym;
      this.currentYear = dayy;
  }

  selectDate(event) {
    let selectedDate = new Date(event.currentTarget.dataset.whichdate);
    let selectedDatee=selectedDate.getDate(); 		
    if(selectedDatee!=this.currentDate){		
      this.isCurrentWeek=false;		
    }		
    else{		
      this.isCurrentWeek=true;		
    }
    this.fetchDataOnDateSelected(selectedDate);
  }

  fetchDataOnDateSelected(selecteddateval) {
    this.selectedDate = selecteddateval;
    let dayListTemp = this.userSelectedDay(this.selectedDate);
    this.dayList = dayListTemp;
    this.selectedmonth = month[this.selectedDate.getMonth()];
    let numMOnth = month.indexOf(this.selectedmonth) + 1;
    let selectedYear = this.selectedDate.getFullYear();
    this.currentMonth = this.selectedmonth;
    this.currentYear = selectedYear;
    let fullDate = `${this.currentYear}-${numMOnth}-${this.selectedDay}`;
    const selectedEvent = new CustomEvent("selected", { detail: fullDate });

    // Dispatches the event.
    this.dispatchEvent(selectedEvent);

  }
  userSelectedDay(selectedDate) {
    this.selectedDay = selectedDate.getDate();
    this.selectedmonth = month[selectedDate.getMonth()];
    let dayListTemp = this.dayList;
    for (let i = 0; i < dayListTemp.length; i++) {
      //let iDate = new Date(dayListTemp[i].datevalue);
      let monthval = new Date(dayListTemp[i].datevalue).getMonth();
      let monthText = month[monthval];
      if (dayListTemp[i].dayn == this.selectedDay && monthText == this.selectedmonth) {
        dayListTemp[i].css = "slds-is-today";
      } else {
        dayListTemp[i].css = "";
      }
    }
    return dayListTemp;
  }

  handleToday() {
    this.selectedNextWeek = 0;
    this.selectedPrevWeek = 0;
    let userDate = new Date(
      todayDate.toLocaleDateString(locale, { timeZone: timeZone })
    );    
    this.selectedDate = userDate;
    this.selectedDay = userDate.getDate();
    this.fetchDataOnDateSelected(this.selectedDate);
    let selectedWeek = this.selectedNextWeek - this.selectedPrevWeek;
    if(selectedWeek == parseInt(this.label.MaxWeek)) {
      this.isNext = true;
      this.template.querySelector(".next").classList.add("disable-next");
    } else {
      this.isNext = false;
      if(this.template.querySelector(".disable-next")) {
        this.template.querySelector(".next").classList.remove("disable-next");
      }
    }
    if(selectedWeek == parseInt(-this.label.MinWeek)) {
      this.isPrev = true;
      this.template.querySelector(".prev").classList.add("disable-prev");
    } else {
      this.isPrev = false;
      if(this.template.querySelector(".disable-prev")) {
        this.template.querySelector(".prev").classList.remove("disable-prev");
      }
    }
    this.connectedCallback();
  }
}