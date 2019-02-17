/**
 * Created by Leonid Bartenev
 */

public class StudyTotalPassed {
    
    public String type;
    public String title;
    public Integer total = 0;
    public Integer passed = 0;
    public Integer percentPassed = 0;
    public String totalTitle;
    public String passedTitle;
    
    public StudyTotalPassed(String type, Integer total, Integer passed){
        this.type = type;
        if(type == 'pre-screening'){
            title = Label.STP_Pre_Eligibility_Screenings_Completions;
            totalTitle = Label.STP_PS_T1 + ' <br/> ' + Label.STP_PS_T2;
            passedTitle = Label.STP_PS_PT1 + ' <br/> ' + Label.STP_PS_PT2;
        }else if(type == 'mrr'){
            title = Label.STP_Chart_review_Completions;
            totalTitle = Label.STP_MRR_T1 + ' <br/> ' + Label.STP_MRR_T2;
            passedTitle = Label.STP_MRR_PT1 + ' <br/> ' + Label.STP_MRR_PT2;
        }else{
            title = '';
            totalTitle = Label.STP_MRR_T1 + ' <br/> ' + Label.STP_ELSE_T2;
            passedTitle = Label.STP_ELSE_PT1 + ' <br/> ' + Label.STP_ELSE_PT2;
        }
        if(total != null) this.total = total;
        if(passed != null) this.passed = passed;
        if(this.total != 0) this.percentPassed = (this.passed * 100) / this.total;
    }

}