/**
 * Created by Leonid Bartenev
 */

public without sharing class SortOrder {

    public static final String ORDER_LAST_CREATED = Label.PG_MRZ_L_Last_Added;
    public static final String ORDER_LAST_MODIFIED = Label.PG_MRZ_L_Last_Modified;
    public static final String ORDER_A_Z = Label.PG_MRZ_L_Alphabetical_A_Z;
    public static final String ORDER_Z_A = Label.PG_MRZ_L_Alphabetical_Z_A;
    public static final Set<String> ORDER_SET_ALPHABETICAL = new Set<String>{ORDER_A_Z, ORDER_Z_A};

    public static final List<LabelValueItem> SORT_TYPES = new List<LabelValueItem>{
            new LabelValueItem(ORDER_LAST_CREATED, 'CreatedDate DESC'),
            new LabelValueItem(ORDER_LAST_MODIFIED, 'LastModifiedDate DESC')
    };

}