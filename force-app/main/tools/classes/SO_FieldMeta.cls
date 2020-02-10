/**
 * Created by Slav on 06.02.2020.
 */

public class SO_FieldMeta {
    public String       fieldName       { get; set; }
    public String       fieldType       { get; set; }
    public String       stringValue     { get; set; }
    public String       picklistValue   { get; set; }
    public Boolean      booleanValue    { get; set; }
    public Integer      intValue        { get; set; }
    public Double       numberValue     { get; set; }
    public Date         dateValue       { get; set; }
    public Datetime     datetimeValue   { get; set; }
    public List<SelectOption> picklistOptions { get; set; }
    
    public SO_FieldMeta () {
        dateValue       = Date.today();
        datetimeValue   = Datetime.now();
    }
    
    public void reset () {
        fieldName       = null;
        fieldType       = null;
        stringValue     = null;
        picklistValue   = null;
        booleanValue    = null;
        intValue        = null;
        numberValue     = null;
        dateValue       = Date.today();
        datetimeValue   = Datetime.now();
        picklistOptions = null;
    }
}