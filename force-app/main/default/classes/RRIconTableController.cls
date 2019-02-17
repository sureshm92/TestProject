/**
 * Created by D.Yasinskyi on 25.04.2018
 */
public without sharing class RRIconTableController {

    @AuraEnabled
    public static String getFilterInfoAndSummaryInfo() {

        RRIconTableController.FilterInfoAndSummaryInfo infoDetail = new RRIconTableController.FilterInfoAndSummaryInfo();

        //set filterPill info
        infoDetail.filterInfo = new FilterPillInfo(10, 'Pending items');

        //set SummrayPill info
        infoDetail.summaryContainers.add(new SummaryContainer('No sub info', String.valueOf(113)));
        SummaryContainer twoSubInfo = new SummaryContainer('Two sub info', String.valueOf(3));
        twoSubInfo.items.add(new LabelValueItem('Sub info one', String.valueOf(1)));
        twoSubInfo.items.add(new LabelValueItem('Sub info two', String.valueOf(2)));
        infoDetail.summaryContainers.add(twoSubInfo);
        SummaryContainer fourSubInfo = new SummaryContainer('Four sub info (60px)', String.valueOf(10));
        fourSubInfo.labelMaxWidth = '60px';
        fourSubInfo.items.add(new LabelValueItem('Sub info one', String.valueOf(1)));
        fourSubInfo.items.add(new LabelValueItem('Sub info two', String.valueOf(2)));
        fourSubInfo.items.add(new LabelValueItem('Sub info three', String.valueOf(3)));
        fourSubInfo.items.add(new LabelValueItem('Sub info four', String.valueOf(4)));
        infoDetail.summaryContainers.add(fourSubInfo);

        return JSON.serialize(infoDetail);
    }

    public class FilterInfoAndSummaryInfo {
        List<SummaryContainer> summaryContainers;
        FilterPillInfo filterInfo;

        public FilterInfoAndSummaryInfo(){
            summaryContainers = new List<SummaryContainer>();
        }
    }
}