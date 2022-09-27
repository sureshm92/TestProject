import { LightningElement, wire, api } from "lwc";
import RH_StudyName_Import from "@salesforce/label/c.Dashboard_Study_Name";
import RH_StudySite_Import from "@salesforce/label/c.RH_StudySite_Import";
import AllStudy from "@salesforce/label/c.PIR_All_Study";
import AllStudySite from "@salesforce/label/c.PIR_All_Study_Site";
import PG_AC_Select from "@salesforce/label/c.PG_AC_Select";
import Clear_All from "@salesforce/label/c.RPR_Clear_All";
import Site_Calendar_All_Studies_Sites from "@salesforce/label/c.Site_Calendar_All_Studies_Sites";
import Apply_Filters from "@salesforce/label/c.Site_Calendar_Apply_Filters";
import More from "@salesforce/label/c.PIR_more";

export default class Site_CalenderStudyFilter extends LightningElement {
  isLoading = false;
  @api selectedSite = "";
  @api studylist;
  @api siteaccesslevels;
  @api selectedStudyChild;
  @api selectedStudySiteChild;
  @api stopSpinnerChild;
  studyToStudySite;
  studysiteaccess = false;
  studySiteList;
  selectedStudy = [];
  selectedStudSites = [];
  options = [];
  studyListStr = "";
  studySiteListStr = "";
  allStudy = false;
  label = {
    AllStudy,
    AllStudySite,
    RH_StudyName_Import,
    RH_StudySite_Import,
    PG_AC_Select,
    Clear_All,
    More,
    Site_Calendar_All_Studies_Sites,
    Apply_Filters
  };
  @api studyFilterWrapper = {
    studyList: [],
    siteList: []
  };
  isbuttonenabled = true;
  allStudyCheckboses = true;
  @api studysitedetails;
  initialLoad = true;
  initialLoadCount = true;
  initialLoadSite = true;
  initialLoadSiteCount = true;
  clearAll = false;
  clearAllCount = false;
  clearAllSite = false;
  clearAllSiteCount = false;
  listOfStudy = [];
  listOfStudySites = [];
  getFirstSelecedStudyy;
  getFirstSelecedStudySitess;
  studydata;
  studyCountStr;
  studySiteCountStr;
  isApply = true;
  openAccordian = false;
  disablecss =
    "slds-form-element__control slds-grow slds-input slds-p-around--none ssBox comboboxContainer dropdown-width";

  connectedCallback() {
    this.participantAccess();
    this.getFirstSelecedStudy();
    this.getFirstSelecedStudySites();
    this.toggleApply(true);
  }

  toggleApply(isInitial) {
    if (
      !isInitial &&
      this.selectedStudy.length > 0 &&
      this.selectedStudSites.length > 0
    ) {
      this.isApply = false;
    } else {
      this.isApply = true;
    }
  }

  participantAccess() {
    if (this.studysitedetails) {
      this.isloading = true;
      var siteAccessLevels = this.studysitedetails.siteAccessLevels;
      var ctpListNoAccess = [];
      var studySiteMap = this.studysitedetails;
      var studylist;
      var studyToStudySite;
      ctpListNoAccess = this.studysitedetails.ctpNoAccess;
      var k = 0;
      var a = 0;
      var accesslevels = Object.keys(siteAccessLevels).length;
      if (studySiteMap.ctpMap) {
        var conts = studySiteMap.ctpMap;
        let options = [];
        options.push({ label: this.label.AllStudy, value: "All Study" });
        var sites = studySiteMap.studySiteMap;
        for (var key in conts) {
          if (!ctpListNoAccess.includes(conts[key])) {
            var temp = sites[conts[key]];
            let z = 0;
            for (var j in temp) {
              if (accesslevels == 0) {
                z = z + 1;
                a = a + 1;
              } else {
                var level = siteAccessLevels[temp[j].Id];
                if (level != "Level 3" && level != "Level 2") {
                  z = z + 1;
                  a = a + 1;
                }
              }
            }
            if (z != 0) {
              options.push({
                label: key,
                value: conts[key],
                isSelected: false
              });
              k = k + 1;
            }
          }
        }
        studylist = options;
        if (studySiteMap.studySiteMap) {
          studyToStudySite = studySiteMap.studySiteMap;
        }
      }
      if (k != 0 && a != 0) {
        this.studylist = studylist;
        this.siteAccessLevels = siteAccessLevels;
        this.studyToStudySite = studyToStudySite;

        if (this.studyToStudySite) {
          this.selectedStudy = this.studylist[0].value;
          var picklist_Value;
          picklist_Value = this.selectedStudy;
          var accesslevels = Object.keys(this.siteAccessLevels).length;
          var conts = this.studyToStudySite;
          let options = [];
          options.push({
            label: this.label.AllStudySite,
            value: "All Study Site"
          });
          var i = this.siteAccessLevels;
          if (picklist_Value != "All Study") {
            for (var key in conts) {
              if (key == picklist_Value) {
                var temp = conts[key];
                for (var j in temp) {
                  if (accesslevels == 0) {
                    options.push({ label: temp[j].Name, value: temp[j].Id });
                  } else {
                    var level = this.siteAccessLevels[temp[j].Id];
                    if (level != "Level 3" && level != "Level 2") {
                      options.push({ label: temp[j].Name, value: temp[j].Id });
                    }
                  }
                }
              }
            }
          } else {
            for (var key in conts) {
              var temp = conts[key];
              for (var j in temp) {
                if (accesslevels == 0) {
                  options.push({ label: temp[j].Name, value: temp[j].Id });
                } else {
                  var level = this.siteAccessLevels[temp[j].Id];
                  if (level != "Level 3" && level != "Level 2") {
                    options.push({ label: temp[j].Name, value: temp[j].Id });
                  }
                }
              }
            }
          }
          this.studySiteList = options;
          this.selectedSite = this.studySiteList[0].value;
          this.studysiteaccess = false;
          this.selectedStudyChild = this.selectedStudy;
          var getStudySiteList = [];
          if (
            this.selectedSite != null &&
            this.selectedSite == "All Study Site"
          ) {
            for (var i = 1; i < this.studySiteList.length; i++) {
              getStudySiteList.push(this.studySiteList[i].value);
              this.studySiteList = getStudySiteList;
            }
          } else if (
            this.selectedSite != null &&
            this.selectedSite != "All Study Site"
          ) {
            this.studySiteList = getStudySiteList;
          }
          this.stopSpinnerChild = false;
        }
      }
      this.isloading = false;
    }
  }

  divSetStudy(event) {
    event.currentTarget.getElementsByTagName("input")[0].checked =
      !event.currentTarget.getElementsByTagName("input")[0].checked;
  }
  handleStudySiteChange(event) {
    let selectedLabel = event.target.name;
    let isChecked = event.target.checked;
    let selectedValue = event.target.value;
    let studySiteElement = this.template.querySelector(
      '[data-id="studySiteBox"]'
    );
    let opts = studySiteElement.getElementsByTagName("input");
    let tempList = [];
    for (var i = 0; i < opts.length; i++) {
      if (opts[i].checked) {
        tempList.push({ label: opts[i].name, value: opts[i].value });
      }
    }
    this.selectedStudSites = [];
    this.selectedStudSites = this.selectedStudSites.concat(tempList);
    if (selectedValue === "All Study Site") {
      this.handleAllSelected(isChecked, false);
    } else {
      this.handleSingleSelection(selectedValue, isChecked, false);
    }
    this.toggleApply(false);
    this.template.querySelector(".ssBox").focus();
  }

  handleStudyChange(event) {
    let label = event.target.name;
    let isChecked = event.target.checked;
    let value = event.target.value;
    let studyElement = this.template.querySelector('[data-id="studyBox"]');
    let opts = studyElement.getElementsByTagName("input");
    let tempList = [];
    let studyOpts = [];
    for (var i = 0; i < opts.length; i++) {
      if (opts[i].checked) {
        tempList.push({ label: opts[i].name, value: opts[i].value });
      }
    }
    this.selectedStudy = [];
    this.selectedStudy = this.selectedStudy.concat(tempList);
    if (value === "All Study") {
      this.handleAllSelected(isChecked, true);
    } else {
      this.handleSingleSelection(value, isChecked, true);
    }
    this.studyhandleChange();
    this.toggleApply(false);
    this.template.querySelector(".sBox").focus();
  }
  handleSingleSelection(selectedValue, isChecked, isStudy) {
    if (isStudy) {
      let selectedStudies = [];
      this.selectedStudy = [];
      for (let i = 0; i < this.studylist.length; i++) {
        if (!isChecked && this.studylist[i].value === "All Study") {
          this.studylist[i].check = isChecked;
        } else if (this.studylist[i].value === selectedValue) {
          this.studylist[i].check = isChecked;
        }
        if (this.studylist[i].check) {
          selectedStudies.push(this.studylist[i].label);
          this.selectedStudy.push(this.studylist[i]);
        }
      }
      if (selectedStudies.length == this.studylist.length - 1) {
        for (let i = 0; i < this.studylist.length; i++) {
          if (this.studylist[i].value === "All Study") {
            this.studylist[i].check = isChecked;
          }
        }
      }
      this.getFirstSelecedStudyy = selectedStudies[0];
      if (selectedStudies.length > 1) {
        this.studyCountStr =
          "+" + (selectedStudies.length - 1) + " " + this.label.More;
      } else {
        this.studyCountStr = "";
      }
    } else {
      let selectedStudySites = [];
      this.selectedStudSites = [];
      for (let i = 0; i < this.studySiteList.length; i++) {
        if (!isChecked && this.studySiteList[i].value === "All Study Site") {
          this.studySiteList[i].check = isChecked;
        } else if (this.studySiteList[i].value === selectedValue) {
          this.studySiteList[i].check = isChecked;
        }
        if (this.studySiteList[i].check) {
          selectedStudySites.push(this.studySiteList[i].label);
          this.selectedStudSites.push(this.studySiteList[i]);
        }
      }
      if (selectedStudySites.length == this.studySiteList.length - 1) {
        for (let i = 0; i < this.studySiteList.length; i++) {
          if (this.studySiteList[i].value === "All Study Site") {
            this.studySiteList[i].check = isChecked;
          }
        }
      }
      this.getFirstSelecedStudySitess = selectedStudySites[0];
      if (selectedStudySites.length > 1) {
        this.studySiteCountStr =
          "+" + (selectedStudySites.length - 1) + " " + this.label.More;
      } else {
        this.studySiteCountStr = "";
      }
    }
  }
  handleAllSelected(isChecked, isStudy) {
    if (isStudy) {
      let selectedStudies = [];
      this.selectedStudy = [];
      for (let i = 0; i < this.studylist.length; i++) {
        this.studylist[i].check = isChecked;
        if (
          this.studylist[i].label != "All Studies" &&
          this.studylist[i].check
        ) {
          selectedStudies.push(this.studylist[i].label);
          this.selectedStudy.push(this.studylist[i]);
        }
      }
      if (selectedStudies.length > 0) {
        this.getFirstSelecedStudyy = selectedStudies[0];
        if (selectedStudies.length > 1) {
          this.studyCountStr =
            "+" + (selectedStudies.length - 1) + " " + this.label.More;
        }
      } else {
        this.getFirstSelecedStudyy = "";
        this.studyCountStr = "";
      }
      if (!isChecked) {
        this.clearStudySites();
      }
    } else {
      let selectedStudySites = [];
      this.selectedStudSites = [];
      this.disablecss =
        "slds-form-element__control slds-grow slds-input slds-p-around--none ssBox comboboxContainer dropdown-width";
      for (let i = 0; i < this.studySiteList.length; i++) {
        this.studySiteList[i].check = isChecked;
        if (
          this.studySiteList[i].label != "All Study Sites" &&
          this.studySiteList[i].check
        ) {
          selectedStudySites.push(this.studySiteList[i].label);
          this.selectedStudSites.push(this.studySiteList[i]);
        }
      }
      if (selectedStudySites.length > 0) {
        this.getFirstSelecedStudySitess = "";
        this.getFirstSelecedStudySitess = selectedStudySites[0];
        this.studySiteCountStr = "";
        if (selectedStudySites.length > 1) {
          this.studySiteCountStr =
            "+" + (selectedStudySites.length - 1) + " " + this.label.More;
        }
      } else {
        this.getFirstSelecedStudySitess = "";
        this.studySiteCountStr = "";
        if (this.studySiteList.length == 1) {
          this.studySiteList = [];
          this.disablecss =
            "slds-form-element__control slds-grow slds-input slds-p-around--none ssBox comboboxContainer dropdown-width dropdowndisable";
        } else {
          this.disablecss =
            "slds-form-element__control slds-grow slds-input slds-p-around--none ssBox comboboxContainer dropdown-width";
        }
      }
    }
  }

  studyhandleChange(event) {
    this.isDataLoading = true;
    var picklist_Value = this.selectedStudy;
    this.selectedStudy = picklist_Value;

    let picklistVal = [];
    for (var keyVal in picklist_Value) {
      picklistVal.push({
        label: picklist_Value[keyVal].label,
        value: picklist_Value[keyVal].value
      });
      if (picklistVal[keyVal].value != "All Study") {
        this.allStudy = true;
      } else {
        this.allStudy = false;
      }
    }
    var accesslevels = Object.keys(this.siteAccessLevels).length;
    var conts = this.studyToStudySite;
    this.options = [];
    this.options.push({
      label: this.label.AllStudySite,
      value: "All Study Site"
    });
    var i = this.siteAccessLevels;
    if (this.allStudy) {
      for (var key in conts) {
        for (var k in picklistVal) {
          var temp1 = picklistVal[k].value;
          if (key == temp1) {
            var temp = conts[key];
            for (var j in temp) {
              if (accesslevels == 0) {
                this.options.push({ label: temp[j].Name, value: temp[j].Id });
              } else {
                var level = this.siteaccesslevels[temp[j].Id];
                if (level != "Level 3" && level != "Level 2") {
                  this.options.push({ label: temp[j].Name, value: temp[j].Id });
                }
              }
            }
          }
        }
      }
    } else {
      for (var key in conts) {
        var temp = conts[key];
        for (var j in temp) {
          if (accesslevels == 0) {
            this.options.push({ label: temp[j].Name, value: temp[j].Id });
          } else {
            var level = this.siteaccesslevels[temp[j].Id];
            if (level != "Level 3" && level != "Level 2") {
              this.options.push({ label: temp[j].Name, value: temp[j].Id });
            }
          }
        }
      }
    }
    this.studySiteList = this.options;
    this.handleAllSelected(true, false);
  }

  toggleAccordian(event) {
    this.template
      .querySelectorAll("." + event.currentTarget.dataset.name)
      .forEach(function (L) {
        L.classList.toggle("slds-hide");
      });

    if (!this.openAccordian) {
      this.openAccordian = true;
    } else {
      this.openAccordian = false;
    }
    const accordEvent = new CustomEvent("accordianevent", {
      detail: {
        isOpenAccordian: this.openAccordian
      }
    });
    this.dispatchEvent(accordEvent);
  }

  /* Study Multiselected code start*/
  getFirstSelecedStudy() {
    this.handleAllSelected(true, true);
    this.studyhandleChange();
  }

  clearStudySites() {
    this.studySiteList = [];
    this.getFirstSelecedStudySitess = "";
    this.disablecss =
      "slds-form-element__control slds-grow slds-input slds-p-around--none ssBox comboboxContainer dropdown-width dropdowndisable";
  }
  removeAllStudy() {
    this.handleAllSelected(false, true);
    this.template.querySelector(".sBox").blur();
  }

  openETH() {
    this.template.querySelector(".sBoxOpen").classList.add("slds-is-open");
  }
  closeETH() {
    this.template.querySelector(".sBoxOpen").classList.remove("slds-is-open");
  }
  /* Study Multiselected code end*/

  /* Study Site Multiselected code start*/
  getFirstSelecedStudySites() {
    this.handleAllSelected(true, false);
  }

  removeAllStudySites() {
    this.handleAllSelected(false, false);
    this.template.querySelector(".sBox").blur();
  }

  openStudySites() {
    this.template.querySelector(".ssBoxOpen").classList.add("slds-is-open");
  }
  closeStudySites() {
    this.template.querySelector(".ssBoxOpen").classList.remove("slds-is-open");
  }

  @api
  applyStudySiteFilter() {
    this.studyFilterWrapper.studyList.push(this.selectedStudy);
    this.studyFilterWrapper.siteList.push(this.selectedStudSites);
    const selectEvent = new CustomEvent("applystudysitefilterevent", {
      detail: {
        study: this.selectedStudy,
        studySite: this.selectedStudSites
      }
    });
    this.isApply = true;
    this.dispatchEvent(selectEvent);
  }
}