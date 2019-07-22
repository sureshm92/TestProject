/**
 * Created by Yehor Dobrovolskyi
 */
({

    onGenerateData: function (component, helper, reportData) {
        helper.onGenerateReport(component, helper);
    },

    onGenerateReport: function (component, helper) {
        var doc = new jsPDF('p', 'pt', 'A4', true);
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
                        let splitTextFooter = doc.splitTextToSize(textFooter, 420);
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
                            doc.text('Enrollment Date: ' + reportData.enrollmentDate, 80, 140);
                            doc.text(reportData.studySiteName, 80, 160);
                            doc.setFontType('normal');

                            numberPageForTable = helper.generateTable(reportData, doc, helper);

                            for (let i = 1; i <= doc.internal.getNumberOfPages(); i++) {
                                doc.setPage(i);
                                if (numberPageForTable && numberPageForTable <= i) {
                                    helper.addBorderL(reportData, doc, iqviaLogo, splitTextFooter);
                                } else {
                                    helper.addBorder(reportData, doc, iqviaLogo, splitTextFooter, i === 1);
                                }
                            }
                            doc.save(component.get('v.documentName') + '.pdf');
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
            doc.setFontType('normal');
            doc.setFontSize(16);
            doc.setTextColor('#757575');
            heightY = helper.validationEndPage(doc, heightY + 50);
            doc.text(tableResult.tableName, 90, heightY);
            heightY += doc.internal.getLineHeight();
            tableResult.labsDescription.forEach(function (lab) {
                doc.setFontType('bold');
                doc.setFontSize(11);
                doc.setTextColor('#000000');
                heightY = helper.validationEndPage(doc, heightY + 30);
                doc.text(lab.nameLabs, 90, heightY);
                doc.setFontType('normal');
                doc.setFontSize(11);
                doc.setTextColor('#000000');
                let splitTextResult = doc.splitTextToSize(lab.descriptionLab, 480);
                splitTextResult.forEach(function (el, ind) {
                    heightY = helper.validationEndPage(doc, heightY + doc.internal.getLineHeight());
                    doc.text(el, 90, heightY);
                });
                heightY = helper.validationEndPage(doc, heightY + doc.internal.getLineHeight());

            });
            if (tableResult.tableApiName === 'Metabolic_Panel') {
                doc.addPage('a4', 'l');
                heightY = 50;
                numberPageForTable = doc.internal.getNumberOfPages();
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
                        minCellWidth: 58
                    },
                    columnStyles: {
                        0: {
                            cellWidth: 60,
                            cellPadding: 0
                        }
                    },
                    head: {
                        fontStyle: 'normal',
                        fontSize: 5,
                        halign: 'center',
                        valign: 'middle',
                    },
                    startY: heightY + 30,
                    margin: {
                        right: 40,
                        left: 70,
                        top: 60,
                        bottom: 60
                    },
                })
            } else {
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
                        minCellWidth: 70
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
                        right: 20,
                        left: 60,
                        top: 60,
                        bottom: 60
                    },
                });
            }

            heightY = doc.autoTable.previous.finalY
        });
        return numberPageForTable;
    },

    addBorder: function (reportData, doc, logo, splitTextFooter, isFirstPage) {
        if (!isFirstPage) {
            doc.setFontSize(10);
            doc.setTextColor('#6e6e6e');
            doc.text(reportData.studyCodeName, 400, 12);
            doc.text(reportData.participantLastName, 400, 24);
        }
        doc.setDrawColor(0, 0, 100);
        doc.setLineWidth(8);
        doc.line(35, 35, 35, 792);
        doc.line(30.8, 35, 97, 35);
        doc.line(193, 35, 595, 35);
        doc.line(30.8, 792, 595, 792);
        doc.addImage(logo, 'PNG', 100, 12, 90, 35);
        let helperT = this;
        splitTextFooter.forEach(function (el, ind) {
            doc.setFontSize(8);
            doc.setTextColor('#6e6e6e');
            helperT.centeredText(el, (805 + ind * doc.internal.getLineHeight()), doc);
        });
    },

    addBorderL: function (reportData, doc, logo, splitTextFooter) {
        doc.setFontSize(10);
        doc.setTextColor('#6e6e6e');
        doc.text(reportData.studyCodeName, 830, 400, -90);
        doc.text(reportData.participantLastName, 819, 400, -90);
        doc.setDrawColor(0, 0, 100);
        doc.setLineWidth(8);
        doc.line(45.8, 35, 810, 35);
        doc.line(50, 35, 50, 595);
        //todo delete next line and uncomment next 3
        doc.line(805.8, 30.8, 805, 595);
        // doc.line(805.8, 30.8, 805, 97);
        // doc.line(805.8, 193, 805.8, 595);
        // doc.addImage(logo, 'PNG', 750, 100, 90, 35, null, 'NONE', -90);
        let helperT = this;
        splitTextFooter.forEach(function (el, ind) {
            doc.setFontSize(8);
            doc.setTextColor('#6e6e6e');
            helperT.centeredTextL(el, (35 - ind * doc.internal.getLineHeight()), doc);
        });
    },

    centeredText: function (text, y, doc) {
        var textWidth = doc.getStringUnitWidth(text) * doc.internal.getFontSize() / doc.internal.scaleFactor;
        var textOffset = (doc.internal.pageSize.width - textWidth) / 2;
        doc.setFillColor(25, 25, 25);
        doc.text(textOffset + 12, y, text);
    },

    centeredTextL: function (text, x, doc) {
        var textWidth = doc.getStringUnitWidth(text) * doc.internal.getFontSize() / doc.internal.scaleFactor;
        var textOffset = (doc.internal.pageSize.height - textWidth) / 2;
        doc.setFillColor(25, 25, 25);
        doc.text(x, textOffset + 12, text, -90);
    },

    validationEndPage: function (doc, heightY) {
        if (heightY > doc.internal.pageSize.height - 65) {
            doc.addPage();
            heightY = 80;
        }
        return heightY;
    },

    generateFirstPage: function (reportData, doc, helper) {
        let heightY = 40;
        if (reportData.profilePicture) {
            doc.addImage(reportData.profilePicture, 'JPEG', 130, 150, 360, 150);
        } else {
            doc.setFontSize(18);
            doc.setTextColor('#000000');
            let splitStudyCodeName = doc.splitTextToSize(reportData.studyCodeName, 500);
            splitStudyCodeName.forEach(function (el, ind) {
                helper.centeredText(el, (150 + heightY + ind * doc.internal.getLineHeight()), doc);
            });
            heightY = doc.internal.getLineHeight() * splitStudyCodeName.length;

        }
        doc.setFontSize(16);
        doc.setTextColor('#000000');
        let splitStudyTitle = doc.splitTextToSize(reportData.studyTitle, 500);
        splitStudyTitle.forEach(function (el, ind) {
            helper.centeredText(el, (350 + heightY + ind * doc.internal.getLineHeight()), doc);
        });
        heightY = doc.internal.getLineHeight() * splitStudyTitle.length;
        helper.centeredText($A.get('$Label.c.Report_My_Study_Data'), 500 + heightY, doc);
    }
});