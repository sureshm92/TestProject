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
  @api isNext = false;
  @api isPrev = false;
  @api currentMonth;
  @api currentYear;
  currentDate;
  selectedDay;
  selectedDate;

  connectedCallback() {
    let userDate = new Date(
      todayDate.toLocaleString(locale, { timeZone: timeZone })
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

    for (let i = 0; i < 7; i++) {
      let calData = {};
      let css = "";
      let selectedCss = "slds-is-today";
      let datevalue = null;
      if (i == this.currentDay) {
        datevalue = this.fetchDay(this.currentDate);
        dayn = datevalue.getDate();
        css = selectedCss;
      } else {
        datevalue = this.fetchDay(this.currentDate - (this.currentDay - i));
        dayn = datevalue.getDate();
      }
      calData = { dayn: dayn, css: css, datevalue: datevalue };
      this.dayList.push(calData);
    }

    if (this.selectedDay) {
      this.userSelectedDay(this.selectedDay);
      let selectedmonth = month[this.selectedDate.getMonth()];
      let selectedYear = this.selectedDate.getFullYear();
      this.currentMonth = selectedmonth;
      this.currentYear = selectedYear;
    }
  }

  fetchDay(i) {
    let date = new Date();
    let userDate = new Date(
      date.toLocaleString(locale, { timeZone: timeZone })
    );
    userDate.toLocaleString(locale, { timeZone: timeZone });
    userDate.setDate(i);
    return userDate;
  }

  handleNext() {
    this.isNext = true;
    this.dayList = [];
    if (this.isPrev) {
      this.connectedCallback();
    } else {
      this.isPrev = false;
      var dayn = 0;

      for (let i = 0; i < 7; i++) {
        let css = "";
        let selectedCss = "slds-is-today";
        let calData = {};
        let dateValue = null;
        if (i <= this.currentDay) {
          dateValue = this.fetchDay(
            this.currentDate + (7 - (this.currentDay - i))
          );
          dayn = dateValue.getDate();
        } else if (i > this.currentDay) {
          dateValue = this.fetchDay(
            this.currentDate + (7 + (i - this.currentDay))
          );
          dayn = dateValue.getDate();
        }
        if (dayn == this.selectedDay) {
          calData = { dayn: dayn, css: selectedCss, datevalue: dateValue };
        } else {
          calData = { dayn: dayn, css: css, datevalue: dateValue };
        }
        this.dayList.push(calData);
      }
      if (this.selectedDay) {
        let selectedmonth = month[this.selectedDate.getMonth()];
        let selectedYear = this.selectedDate.getFullYear();
        this.currentMonth = selectedmonth;
        this.currentYear = selectedYear;
      }
    }
  }
  handlePrev() {
    this.dayList = [];
    this.isPrev = true;
    if (this.isNext) {
      this.connectedCallback();
    } else {
      this.isNext = false;
      let dayn = 0;
      for (let i = 0; i < 7; i++) {
        let css = "";
        let selectedCss = "slds-is-today";
        let calData = {};
        let dateValue = null;
        if (i <= this.currentDay) {
          dateValue = this.fetchDay(
            this.currentDate - (7 + this.currentDay - i)
          );
          dayn = dateValue.getDate();
        } else if (i > this.currentDay) {
          dateValue = this.fetchDay(
            this.currentDate - (7 + this.currentDay - i)
          );
          dayn = dateValue.getDate();
        }
        if (dayn == this.selectedDay) {
          calData = { dayn: dayn, css: selectedCss, datevalue: dateValue };
        } else {
          calData = { dayn: dayn, css: css, datevalue: dateValue };
        }
        this.dayList.push(calData);
      }
      if (this.selectedDay) {
        let selectedmonth = month[this.selectedDate.getMonth()];
        let selectedYear = this.selectedDate.getFullYear();
        this.currentMonth = selectedmonth;
        this.currentYear = selectedYear;
      }
    }
  }

  selectDate(event) {
    let selectedDate = new Date(event.currentTarget.dataset.whichdate);
    this.selectedDate = selectedDate;
    this.selectedDay = selectedDate.getDate();
    let dayListTemp = this.userSelectedDay(this.selectedDay);
    this.dayList = dayListTemp;
    let selectedmonth = month[selectedDate.getMonth()];
    let numMOnth = month.indexOf(selectedmonth) + 1;
    let selectedYear = selectedDate.getFullYear();
    this.currentMonth = selectedmonth;
    this.currentYear = selectedYear;
    let fullDate = `${this.currentYear}-${numMOnth}-${this.selectedDay}`;
    const selectedEvent = new CustomEvent("selected", { detail: fullDate });

    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
  }

  userSelectedDay(day) {
    let dayListTemp = this.dayList;
    for (let i = 0; i < dayListTemp.length; i++) {
      if (dayListTemp[i].dayn == day) {
        dayListTemp[i].css = "slds-is-today";
      } else {
        dayListTemp[i].css = "";
      }
    }
    return dayListTemp;
  }
}