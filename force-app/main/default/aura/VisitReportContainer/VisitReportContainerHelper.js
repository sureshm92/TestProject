/**
 * Created by Yehor Dobrovolskyi
 */
({
    generateReport: function (component, helper) {
        let ie = navigator.userAgent.match(/.NET/g);
        let oldIE = navigator.userAgent.match(/MSIE/g);
        let ieEDGE = navigator.userAgent.match(/Edge/g);
        if (ie || oldIE) {
            helper.getLogoFromIE(component, helper);
        } else {
            helper.getLogo(component, helper, ieEDGE);
        }
    },

    getLogo: function (component, helper, isSave) {
        const url = window.location.hostname;
        const resourceRelPath = $A.get('$Resource.IQVIA');
        const resourceUrl = 'https://'.concat(url).concat(resourceRelPath);
        window.fetch(resourceUrl)
            .then($A.getCallback(function (response) {
                console.log(response);
                if (!response.ok) {
                    throw new Error('HTTP error, status = '.concat(response.status));
                }
                response.blob()
                    .then($A.getCallback(function (data) {
                        let reader = new FileReader();
                        reader.readAsDataURL(data);
                        reader.onloadend = function () {
                            let iqviaLogo = reader.result;
                            helper.fillData(component, helper, iqviaLogo, isSave);
                            helper.spinnerHide(component);
                        };
                    }));
            }))
            .catch($A.getCallback(function (error) {
                console.error('Fetch Error :-S', error);
                helper.spinnerHide(component);
            }));
    },

    getLogoFromIE: function (component, helper, isSave) {
        helper.enqueue(component, 'c.getLogoFromStatic', {})
            .then(function (iqviaLogo) {
                helper.fillData(component, helper, iqviaLogo, isSave);
                helper.spinnerHide(component);
            }, function (err) {
                if (err && err[0].message) {
                    component.set('v.errorMessage', err[0].message);
                }
                console.log('error:', err[0].message);
                helper.spinnerHide(component);
            });
    },

    fillData: function (component, helper, iqviaLogo, isSave) {
        var doc = new jsPDF('l', 'pt', 'A4', true);
        let reportData = component.get('v.reportData');
        let textFooter = $A.get('$Label.c.Report_Visits_Result_Text_Footer');
        let numberPageForTable = 0;
        doc.setFontSize(8);
        doc.setTextColor('#6e6e6e');
        let splitTextFooter = doc.splitTextToSize(textFooter, 650);
        helper.generateFirstPage(reportData, doc, helper);
        doc.addPage();
        doc.setFontSize(16);
        doc.setTextColor('#000096');
        doc.setFontType('bold');
        doc.text(reportData.participantFullName, 80, 120);
        doc.text($A.get('$Label.c.Report_Enrollment_Date') + ' ' + reportData.enrollmentDate, 80, 140);
        doc.text($A.get('$Label.c.Report_Study_Site') + ': ' + reportData.studySiteName, 80, 160);
        doc.setFontType('normal');
        numberPageForTable = helper.generateTable(reportData, doc, helper);
        for (let i = 1; i <= doc.internal.getNumberOfPages(); i++) {
            doc.setPage(i);
            helper.addBorder(reportData, doc, iqviaLogo, splitTextFooter, i === 1);
        }
        if (isSave) {
            window.navigator.msSaveBlob(doc.output('blob'), $A.get('$Label.c.Report_Document_Name') + '.pdf');
        } else {
            let urlPDF = doc.output('bloburi');
            let urlViewer = $A.get('$Resource.pdfjs_dist') + '/web/viewer.html';
            window.open(urlViewer + '?file=' + urlPDF + '&fileName=' + encodeURIComponent($A.get('$Label.c.Report_Document_Name')));
        }
        reportData = {};
        component.set('v.reportData', reportData);
    },

    generateTable: function (reportData, doc, helper) {
        let numberPageForTable = 0;
        let heightY = 160;
        reportData.dataTables.forEach(function (tableResult, ind) {
            doc.setFontType('bold');
            doc.setFontSize(16);
            doc.setTextColor('#545454');
            heightY = helper.validationEndPage(doc, heightY + 50, 100);
            doc.text(tableResult.tableName, 90, heightY);
            heightY += doc.internal.getLineHeight();
            tableResult.labsDescription.forEach(function (lab) {
                doc.setFontType('bold');
                doc.setFontSize(11);
                doc.setTextColor('#000000');
                heightY = helper.validationEndPage(doc, heightY + 10, 75);
                doc.text(lab.nameLabs, 90, heightY);
                doc.setFontType('normal');
                doc.setFontSize(11);
                doc.setTextColor('#000000');
                let splitTextResult = doc.splitTextToSize(lab.descriptionLab, 720);
                splitTextResult.forEach(function (el, ind) {
                    heightY = helper.validationEndPage(doc, heightY + doc.internal.getLineHeight());
                    doc.text(el, 90, heightY);
                });
                heightY = helper.validationEndPage(doc, heightY + doc.internal.getLineHeight());
            });
            doc.autoTable({
                theme: 'plain',
                html: '#tbl' + ind,
                styles: {
                    cellPadding: 2,
                    halign: 'center',
                    valign: 'middle',
                    lineColor: 0,
                    lineWidth: 1,
                    fontStyle: 'normal',
                    minCellWidth: 63,
                },
                columnStyles: {
                    0: {
                        cellWidth: 60,
                        cellPadding: 0
                    }
                },
                head: {
                    fontStyle: 'normal',
                    fontSize: 8,
                    halign: 'center',
                    valign: 'middle',
                },
                startY: heightY + 30,
                margin: {
                    right: 10,
                    left: 50,
                    top: 60,
                    bottom: 60
                },
                useCss: true
            });
            heightY = doc.autoTable.previous.finalY
        });
        return numberPageForTable;
    },

    addBorder: function (reportData, doc, logo, splitTextFooter, isFirstPage) {
        if (!isFirstPage) {
            doc.setFontSize(10);
            doc.setTextColor('#6e6e6e');
            if (reportData.studyCodeName) {
                doc.text(reportData.studyCodeName, 600, 12);
            }
            doc.text(reportData.participantLastName, 600, 24);
        }
        doc.setDrawColor(0, 0, 100);
        doc.setLineWidth(8);
        doc.line(35, 35, 35, 550);
        doc.line(30.8, 35, 97, 35);
        doc.line(193, 35, 841, 35);
        doc.line(30.8, 550, 841, 550);
        if (logo) {
            doc.addImage(logo, 'PNG', 100, 12, 90, 35);
        }
        let helperT = this;
        splitTextFooter.forEach(function (el, ind) {
            doc.setFontSize(8);
            doc.setTextColor('#6e6e6e');
            helperT.centeredText(el, (565 + ind * doc.internal.getLineHeight()), doc);
        });
    },

    centeredText: function (text, y, doc) {
        var textWidth = doc.getStringUnitWidth(text) * doc.internal.getFontSize() / doc.internal.scaleFactor;
        var textOffset = (doc.internal.pageSize.width - textWidth) / 2;
        doc.setFillColor(25, 25, 25);
        doc.text(textOffset + 12, y, text);
    },

    validationEndPage: function (doc, heightY, margiBottom) {
        margiBottom = typeof margiBottom !== 'undefined' ? margiBottom : 55;
        if (heightY > doc.internal.pageSize.height - margiBottom) {
            doc.addPage();
            heightY = 80;
        }
        return heightY;
    },

    generateFirstPage: function (reportData, doc, helper) {
        let heightY = 40;
        if (reportData.profilePicture) {
            doc.addImage(reportData.profilePicture, 'JPEG', 262, 100, 360, 150);
            heightY += 210;
        } else {
            doc.setFontSize(18);
            doc.setTextColor('#000000');
            heightY += 150;
            if (reportData.studyCodeName) {
                let splitStudyCodeName = doc.splitTextToSize(reportData.studyCodeName, 500);
                splitStudyCodeName.forEach(function (el, ind) {
                    helper.centeredText(el, (heightY + ind * doc.internal.getLineHeight()), doc);
                });
                heightY += doc.internal.getLineHeight() * splitStudyCodeName.length;
            } else {
                heightY += 100;
            }
        }
        doc.setFontSize(16);
        doc.setTextColor('#000000');
        heightY += 50;
        if (reportData.studyTitle) {
            let splitStudyTitle = doc.splitTextToSize(reportData.studyTitle, 500);
            splitStudyTitle.forEach(function (el, ind) {
                helper.centeredText(el, (heightY + ind * doc.internal.getLineHeight()), doc);
            });
            heightY += doc.internal.getLineHeight() * splitStudyTitle.length;
        } else {
            heightY += 100;
        }
        helper.centeredText($A.get('$Label.c.Report_My_Study_Data'), 50 + heightY, doc);
    },

    spinnerShow: function (component) {
        let spinner = component.find('spinner');
        if (spinner) {
            spinner.show();
        }
    },

    spinnerHide: function (component) {
        let spinner = component.find('spinner');
        if (spinner) {
            spinner.hide();
        }
    },
});