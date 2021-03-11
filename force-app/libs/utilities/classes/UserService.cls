/**
 * Created by Leonid Bartenev
 */

public class UserService {
    public static final Map<String, String> DATE_FORMAT_BY_LOCALE = new Map<String, String>{
        'ar' => 'dd/MM/yyyy hh:mm a',
        'ar_AE' => 'dd/MM/yyyy hh:mm a',
        'ar_BH' => 'dd/MM/yyyy hh:mm a',
        'ar_JO' => 'dd/MM/yyyy hh:mm a',
        'ar_KW' => 'dd/MM/yyyy hh:mm a',
        'ar_LB' => 'dd/MM/yyyy hh:mm a',
        'ar_SA' => 'dd/MM/yyyy hh:mm a',
        'bg_BG' => 'dd.MM.yyyy HH:mm a',
        'ca' => 'dd/MM/yyyy HH:mm',
        'ca_ES' => 'dd/MM/yyyy HH:mm',
        'ca_ES_EURO' => 'dd/MM/yyyy HH:mm',
        'cs' => 'd.M.yyyy H:mm',
        'cs_CZ' => 'dd.MM.yyyy HH:mm',
        'da' => 'dd-MM-yyyy HH:mm',
        'da_DK' => 'dd-MM-yyyy HH:mm',
        'de' => 'dd.MM.yyyy HH:mm',
        'de_AT' => 'dd.MM.yyyy HH:mm',
        'de_AT_EURO' => 'dd.MM.yyyy HH:mm',
        'de_CH' => 'dd.MM.yyyy HH:mm',
        'de_DE' => 'dd.MM.yyyy, HH:mm',
        'de_DE_EURO' => 'dd.MM.yyyy HH:mm',
        'de_LU' => 'dd.MM.yyyy HH:mm',
        'de_LU_EURO' => 'dd.MM.yyyy HH:mm',
        'el_GR' => 'd/M/yyyy h:mm a',
        'en_AU' => 'dd/MM/yyyy, hh:mm a',
        'en_B' => 'M/d/yyyy h:mm a',
        'en_BM' => 'M/d/yyyy h:mm a',
        'en_CA' => 'yyyy-MM-dd , hh:mm a',
        'en_GB' => 'dd/MM/yyyy, HH:mm',
        'en_GH' => 'M/d/yyyy h:mm a',
        'en_ID' => 'M/d/yyyy h:mm a',
        'en_IE' => 'dd/MM/yyyy HH:mm',
        'en_IE_EURO' => 'dd/MM/yyyy HH:mm',
        'en_NZ' => 'dd/MM/yyyy, HH:mm a',
        'en_SG' => 'M/d/yyyy h:mm a',
        'en_US' => 'MM/dd/yyyy, hh:mm a',
        'en_ZA' => 'yyyy/MM/dd, HH:mm',
        'es' => 'd/MM/yyyy H:mm',
        'es_AR' => 'dd/MM/yyyy HH:mm',
        'es_BO' => 'dd-MM-yyyy hh:mm a',
        'es_CL' => 'dd-MM-yyyy HH:mm',
        'es_CO' => 'dd/MM/yyyy, hh:mm a',
        'es_CR' => 'dd/MM/yyyy hh:mm a',
        'es_EC' => 'dd/MM/yyyy hh:mm a',
        'es_ES' => 'dd/MM/yyyy HH:mm',
        'es_ES_EURO' => 'd/MM/yyyy H:mm',
        'es_GT' => 'd/MM/yyyy hh:mm a',
        'es_HN' => 'MM-dd-yyyy hh:mm a',
        'es_MX' => 'dd/MM/yyyy HH:mm',
        'es_PE' => 'dd/MM/yyyy HH:mm',
        'es_PR' => 'MM-dd-yyyy hh:mm a',
        'es_PY' => 'dd/MM/yyyy hh:mm a',
        'es_SV' => 'MM-dd-yyyy hh:mm a',
        'es_UY' => 'dd/MM/yyyy hh:mm a',
        'es_VE' => 'dd/MM/yyyy hh:mm a',
        'et_EE' => 'd.MM.yyyy H:mm',
        'fi' => 'd.M.yyyy H:mm',
        'fi_FI' => 'd.M.yyyy H:mm',
        'fi_FI_EURO' => 'd.M.yyyy H:mm',
        'fr' => 'dd/MM/yyyy HH:mm',
        'fr_BE' => 'dd/MM/yyyy HH:mm',
        'fr_CA' => 'yyyy-MM-dd HH:mm',
        'fr_CH' => 'dd.MM.yyyy HH:mm',
        'fr_FR' => 'dd/MM/yyyy HH:mm',
        'fr_FR_EURO' => 'dd/MM/yyyy HH:mm',
        'fr_LU' => 'dd/MM/yyyy HH:mm',
        'fr_MC' => 'dd/MM/yyyy HH:mm',
        'hr_HR' => 'yyyy.MM.dd HH:mm',
        'hu' => 'yyyy.MM.dd. H:mm',
        'hy_AM' => 'M/d/yyyy h:mm a',
        'is_IS' => 'd.M.yyyy HH:mm',
        'it' => 'dd/MM/yyyy H.mm',
        'it_CH' => 'dd.MM.yyyy HH:mm',
        'it_IT' => 'dd/MM/yyyy, HH:mm',
        'iw' => 'HH:mm dd/MM/yyyy',
        'iw_IL' => 'HH:mm dd/MM/yyyy',
        'ja' => 'yyyy/MM/dd H:mm',
        'ja_JP' => 'yyyy/MM/dd HH:mm',
        'kk_KZ' => 'M/d/yyyy h:mm a',
        'km_KH' => 'M/d/yyyy h:mm a',
        'ko' => 'yyyy. M. d a h:mm',
        'ko_KR' => 'yyyy. M. d a h:mm',
        'lt_LT' => 'yyyy-MM-dd HH:mm',
        'lv_LV' => 'yyyy.d.M HH:mm',
        'ms_MY' => 'dd/MM/yyyy h:mm a',
        'nl' => 'd-M-yyyy H:mm',
        'nl_BE' => 'dd/MM/yyyy HH:mm',
        'nl_NL' => 'd-M-yyyy H:mm',
        'nl_SR' => 'd-M-yyyy H:mm',
        'no' => 'dd.MM.yyyy HH:mm',
        'no_NO' => 'dd.MM.yyyy HH:mm',
        'pl' => 'yyyy-MM-dd HH:mm',
        'pt' => 'dd-MM-yyyy H:mm',
        'pt_AO' => 'dd-MM-yyyy H:mm',
        'pt_BR' => 'dd/MM/yyyy HH:mm',
        'pt_PT' => 'dd/MM/yyyy, HH:mm',
        'ro_RO' => 'dd.MM.yyyy HH:mm',
        'ru' => 'dd.MM.yyyy H:mm',
        'sk_SK' => 'd.M.yyyy H:mm',
        'sl_SI' => 'd.M.y H:mm',
        'sv' => 'yyyy-MM-dd HH:mm',
        'sv_SE' => 'yyyy-MM-dd HH:mm',
        'th' => 'M/d/yyyy h:mm a',
        'th_TH' => 'dd/MM/yyyy HH:mm',
        'tr' => 'dd.MM.yyyy HH:mm',
        'ur_PK' => 'M/d/yyyy h:mm a',
        'vi_VN' => 'HH:mm, dd/MM/yyyy',
        'zh' => 'yyyy-M-d ah:mm',
        'zh_CN' => 'yyyy-M-d ah:mm',
        'zh_HK' => 'yyyy-M-d ah:mm',
        'zh_TW' => 'yyyy/M/d a h:mm',
        'tl_PH' => 'MM/dd/yyyy, hh:mm a',
        'pl_PL' => 'dd.MM.yyyy, HH:mm',
        'ru_RU' => 'dd.MM.yyyy, HH:mm',
        'af_ZA' => 'yyyy-MM-dd HH:mm',
        'xh_ZA' => 'yyyy-MM-dd HH:mm',
        'zu_ZA' => 'MM/dd/yyyy HH:mm',
        'cy_GB' => 'dd/MM/yyyy HH:mm',
        'my_MM' => 'dd-MM-yyyy HH:mm',
        'es_US' => 'dd/MM/yyyy hh:mm a'



    };
        public static String contactIDvalue;  

    public static String formatDateTime(Datetime dt, String locale) {
        if (dt == null)
            return '';
        String dateFormat = DATE_FORMAT_BY_LOCALE.get(locale);
        if (dateFormat == null)
            return dt.format();
        return dt.format(dateFormat);
    }

    public static String formatDateTimebyZone(Datetime dt, String locale,String timeZone)
    {
         if (dt == null)
            return '';
        String dateFormat = DATE_FORMAT_BY_LOCALE.get(locale);
        if( timeZone !=null &&  dateFormat == null)
        {
            return dt.format('dd/MM/yyyy hh:mm a',timeZone);
        }
        if (dateFormat == null) 
            return dt.format(); 
        return dt.format(dateFormat,timeZone);
    } 

    public static String formatDate(Date d, String locale) {
        if (d == null)
            return '';
        Datetime dt = Datetime.newInstance(d, Time.newInstance(12, 0, 0, 0));
        String result = formatDateTime(dt, locale);
        return result.substringBefore(' ');
    }
}