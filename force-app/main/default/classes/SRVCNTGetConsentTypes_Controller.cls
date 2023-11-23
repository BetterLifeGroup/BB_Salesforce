/**
 * Created by fkleynhans on 2022/09/12.
 */

public class SRVCNTGetConsentTypes_Controller {
    public static List<SRVCNTGetConsentTypesResult> getConsentTypes(List<String> request) {
        SRVCNTClient client = new SRVCNTClient();
        SRVCNTConsentTypes_DeligateApi api = new SRVCNTConsentTypes_DeligateApi(client);
        Integration_Parameter__mdt integrationParam = Integration_Parameter__mdt.getInstance('Subscription_Key');
        ((OAS.ApiKeyAuth) client.getAuthentication('apiKeyHeader')).setApiKey(integrationParam.Parameter_Value__c);

        Map<String, Object> params = new Map<String, Object>{
                'scopes' => request
        };

        List<SRVCNTGetConsentTypesResult> response = api.getConsenttypes(params);

        return response;
    }
}