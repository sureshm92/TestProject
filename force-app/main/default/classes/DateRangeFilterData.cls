/**
 * Created by Leonid Bartenev
 */

public class DateRangeFilterData {
    
    public static List<LabelValueItem> getRanges(){
        List<LabelValueItem> ranges = new List<LabelValueItem>{
                new LabelValueItem(Label.DRF_L_All_date_ranges, null),
                new LabelValueItem(Label.DRF_L_Yesterday, '= YESTERDAY'),
                new LabelValueItem(Label.DRF_L_Today, '= TODAY'),
                new LabelValueItem(Label.DRF_L_Last_week, '= LAST_WEEK'),
                new LabelValueItem(Label.DRF_L_This_week, '= THIS_WEEK'),
                new LabelValueItem(Label.DRF_L_Last_month, '= LAST_MONTH'),
                new LabelValueItem(Label.DRF_L_This_month, '= THIS_MONTH'),
                new LabelValueItem(Label.DRF_L_Last_quarter, '= LAST_QUARTER'),
                new LabelValueItem(Label.DRF_L_This_quarter, '= THIS_QUARTER'),
                new LabelValueItem(Label.DRF_L_Last_year, '= LAST_YEAR'),
                new LabelValueItem(Label.DRF_L_This_year, '= THIS_YEAR')
        };
        return ranges;
    }

}