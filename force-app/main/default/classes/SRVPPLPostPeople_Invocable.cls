/**
 * Created by fkleynhans on 2022/09/05.
 */

global class SRVPPLPostPeople_Invocable {
    @InvocableMethod(label='PostPeople')
    global static List<SRVPPLResponse> postPeople(List<SRVPPLRequest> requests) {
        System.debug('-' + requests[0] + '-');
        System.debug('-' + requests[0].email + '-');
        List<SRVPPLResponse> responseList = new List<SRVPPLResponse>();

        SRVPPLClient client = new SRVPPLClient();
        SRVPPLPeople_DelegateApi api = new SRVPPLPeople_DelegateApi(client);
        Integration_Parameter__mdt integrationParam = Integration_Parameter__mdt.getInstance('Subscription_Key');
        ((OAS.ApiKeyAuth) client.getAuthentication('apiKeyHeader')).setApiKey(integrationParam.Parameter_Value__c);

        for (SRVPPLRequest request : requests) {

            SRVPPLCreatePersonRequest createPersonRequest = new SRVPPLCreatePersonRequest();

            SRVPPLName name = new SRVPPLName();
            name.familyName = request.lastName;
            name.givenName = request.firstName;

            createPersonRequest.name = name;
            createPersonRequest.sourceSystemTypeId = 1;

            if (request.email.length() > 2) {

                SRVPPLCreatePersonEmailAddressDto createPersonEmailAddressDto = new SRVPPLCreatePersonEmailAddressDto();
                createPersonEmailAddressDto.value = request.email;
                createPersonEmailAddressDto.isPrimary = true;
                createPersonEmailAddressDto.emailAddressTypeId = 1;

                createPersonRequest.emailAddresses = new List<SRVPPLCreatePersonEmailAddressDto>{
                        createPersonEmailAddressDto
                };

            } else if (request.phoneNumber != null) {

                if(request.phoneNumber.startsWith('0')){
                    request.phoneNumber = '+27' + request.phoneNumber.substring(1);
                } else if (request.phoneNumber.startsWith('27')){
                    request.phoneNumber = '+' + request.phoneNumber;
                }

                SRVPPLCreatePersonPhoneNumberDto phoneNumber = new SRVPPLCreatePersonPhoneNumberDto();
                phoneNumber.value = request.phoneNumber;
                phoneNumber.isPrimary = true;
                phoneNumber.type = 'Mobile';
                phoneNumber.phoneNumberTypeId = 1;
                createPersonRequest.phoneNumbers = new List<SRVPPLCreatePersonPhoneNumberDto>{
                        phoneNumber
                };
            }

            Map<String, Object> params = new Map<String, Object>{
                    'srVPPLCreatePersonRequest' => createPersonRequest
            };

            SRVPPLResponse response = new SRVPPLResponse();

            try {
                response.message = api.postPeople(params);
                response.responseCode = 201;
                responseList.add(response);
            } catch (OAS.ApiException e) {
                response.message = e?.getBody();
                response.responseCode = e?.getStatusCode();
                responseList.add(response);
            }
        }
        return responseList;
    }

    global class SRVPPLRequest {
        @InvocableVariable(required=true)
        global String firstName;

        @InvocableVariable(required=true)
        global String lastName;

        @InvocableVariable
        global String email = '';

        @InvocableVariable
        global String phoneNumber = '';
    }

    global class SRVPPLResponse {
        @InvocableVariable
        global String message;

        @InvocableVariable
        global Integer responseCode;


    }
}