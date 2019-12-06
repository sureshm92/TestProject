/**
 * Created by Kryvolap on 21.08.2019.
 */

public interface SearchFilter {

    String getQueryType();
    List<String> getFields();
    String getFilterString();
    String getOrderBy();
    SObjectType getSObjectType();
}