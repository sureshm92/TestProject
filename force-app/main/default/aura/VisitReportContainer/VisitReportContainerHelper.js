/**
 * Created by Yehor Dobrovolskyi
 */
({

    onGenerateData: function (component, helper, reportData) {
        helper.onGenerateReport(component, helper);
    },

    onGenerateReport: function (component, helper) {
        var doc = new jsPDF('l', 'pt', 'A4', true);
        let reportData = component.get('v.reportData');
        const url = new URL(window.location.href);
        const resourceRelPath = $A.get('$Resource.PH_Default_Image') + '/IQVIA.png';
        const resourceUrl = `${url.origin}${resourceRelPath}`;
        window.fetch(resourceUrl)
            .then($A.getCallback((response) => {
                console.log(response);
                if (!response.ok) {
                    throw new Error(`HTTP error, status = ${response.status}`);
                }
                response.blob()
                    .then($A.getCallback((data) => {
                        let textFooter = $A.get('$Label.c.Report_Visits_Result_Text_Footer');
                        let numberPageForTable = 0;
                        doc.setFontSize(8);
                        doc.setTextColor('#6e6e6e');
                        let splitTextFooter = doc.splitTextToSize(textFooter, 650);
                        let reader = new FileReader();
                        reader.readAsDataURL(data);
                        reader.onloadend = function () {
                            let iqviaLogo = reader.result;
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
                            // doc.save(component.get('v.documentName') + '.pdf');
                            let ieEDGE = navigator.userAgent.match(/Edge/g);
                            let ie = navigator.userAgent.match(/.NET/g);
                            let oldIE = navigator.userAgent.match(/MSIE/g);
                            if (ie || oldIE || ieEDGE) {
                                window.navigator.msSaveBlob(doc.output('blob'), component.get('v.documentName') + '.pdf');
                            } else {
                                let pdfArr = doc.output('arraybuffer');
                                let urlPDF = doc.output('bloburi');
                                let urlViewer = $A.get('$Resource.pdfjs_dist') + '/web/viewer.html';
                                let newWin = window.open('/');
                                if (newWin.document.readyState === 'complete') {
                                    newWin.location = urlViewer + '?file=' + urlPDF;
                                } else {
                                    newWin.onload = function () {
                                        newWin.location = urlViewer + '?file=' + urlPDF;
                                    };
                                }
                            }
                            reportData = {};
                            component.set('v.reportData', reportData);
                        };
                    }));
            }))
            .catch($A.getCallback((error) => {
                console.error('Fetch Error :-S', error);
            }));
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
        doc.addImage(logo, 'PNG', 100, 12, 90, 35);
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
    }
});