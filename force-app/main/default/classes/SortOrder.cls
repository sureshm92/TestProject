/**
 * Created by Leonid Bartenev
 */

public without sharing class SortOrder {

    public static final String ORDER_LAST_CREATED = Label.PG_MRZ_L_Last_Added;
    public static final String ORDER_LAST_MODIFIED = Label.PG_MRZ_L_Last_Modified;
    public static final String ORDER_A_Z = Label.PG_MRZ_L_Alphabetical_A_Z;
    public static final String ORDER_Z_A = Label.PG_MRZ_L_Alphabetical_Z_A;
    public static final String ORDER_STUDY_SITE_STATUS = Label.PG_SFS_L_Referral_Status;
    public static final String ORDER_STUDY_SITE_DISTANCE = Label.PG_SFS_L_Distance;
    public static final String ORDER_MOST_NEAREST = 'Most Nearest';
    public static final Set<String> ORDER_SET_ALPHABETICAL = new Set<String>{ORDER_A_Z, ORDER_Z_A};

    public static final List<LabelValueItem> SORT_TYPES = new List<LabelValueItem>{
            new LabelValueItem(ORDER_LAST_CREATED, 'CreatedDate DESC'),
            new LabelValueItem(ORDER_LAST_MODIFIED, 'LastModifiedDate DESC')
    };

    public static final List<LabelValueItem> STUDIES_HCP_SORT_TYPES = new List<LabelValueItem>{
            new LabelValueItem(ORDER_MOST_NEAREST, 'Distance ASC'),
            new LabelValueItem(ORDER_LAST_CREATED, 'CreatedDate DESC')
    };

    public static final List<LabelValueItem> STUDY_SITE_SORT_TYPES = new List<LabelValueItem>{
//            new LabelValueItem(ORDER_STUDY_SITE_STATUS, 'Status')
            new LabelValueItem(ORDER_STUDY_SITE_DISTANCE, 'Distance')
    };

}