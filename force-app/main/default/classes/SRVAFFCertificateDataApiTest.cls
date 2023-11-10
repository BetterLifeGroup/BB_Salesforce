/**
 * Created by frans fourie on 2023/11/10.
 */

@IsTest
public class SRVAFFCertificateDataApiTest {

    /**
     * Generates and returns a Pre-Approval Certificate Data
     */

    @IsTest
    private static void postPreapprovalCertificateDataTest() {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        res.setHeader('Content-Type','application/json');
        res.setBody('{"interestRate1":"11.75 %","interestRate2":"12.00 %","interestRate3":"12.25 %","interestRate4":"12.50 %","loanTerm1":"20 years","loanTerm2":"20 years","loanTerm3":"20 years","loanTerm4":"20 years","loanAmount1":"R 1 845 517.18","loanAmount2":"R 1 816 388.33","loanAmount3":"R 1 788 005.68","loanAmount4":"R 1 760 345.58","bondRepayment1":"R 20 000.00","bondRepayment2":"R 20 000.00","bondRepayment3":"R 20 000.00","bondRepayment4":"R 20 000.00","bondRepaymentCosts1":"R 38 302.50","bondRepaymentCosts2":"R 38 302.50","bondRepaymentCosts3":"R 38 302.50","bondRepaymentCosts4":"R 38 302.50","transferCosts1":"R 112 920.53","transferCosts2":"R 111 172.80","transferCosts3":"R 101 445.84","transferCosts4":"R 99 786.24","totalBondTransferCosts1":"R 151 223.03","totalBondTransferCosts2":"R 149 475.30","totalBondTransferCosts3":"R 139 748.34","totalBondTransferCosts4":"R 138 088.74","testValue":null,"referenceNumber":null,"validUntl":"2024-02-10","consName":"JOHANN CONSULTANT","consRegion":"TD_Johannesburg North TD_Johannesburg North West","consEmail":"johann+predtest@exah.co.za","consTel":"0800007111","consCell":"0000000000","clientName2":null,"clientName":"TR TEST 36921","clientIdNumber":"9007180251080","clientIdNumber2":null,"depositPercentage1":"5 %","depositPercentage2":"10 %","depositPercentage3":"15 %","depositPercentage4":"20 %","depAmt1":"92 275.86","depAmt2":"184 551.72","depAmt3":"276 827.58","depAmt4":"369 103.44","rate20Yr1":"0.00","rate20Yr2":"46 632.29","rate20Yr3":"92 069.98","rate20Yr4":"136 350.94","mnthly1":"20 000.00","mnthly2":"19 684.33","mnthly3":"19 376.74","mnthly4":"19 076.99","saving1":"0.00","saving2":"315.67","saving3":"623.26","saving4":"923.01","totIncome":"70 000.00","bondRepymnt":"21 000.00","bondRepymntSettlemnt":"20 000.00","expenses":"13 000.00","maxRepaymnt":"20 000.00","purchasePrice":"R 1 845 517.18"}');
        Test.setMock(HttpCalloutMock.class, new OASResponseMock(res));


        SRVAFFCreatePreApprovalCertificateRe req = new SRVAFFCreatePreApprovalCertificateRe();
        req.totalExpenses = 1234;

        Map<String, Object> params = new Map<String, Object>{
                'SRVAFFCertificateDataApi' => req
        };

        SRVAFFClient client = new SRVAFFClient();
        SRVAFFCertificateDataApi api = new SRVAFFCertificateDataApi(client);
        ((OAS.ApiKeyAuth)client.getAuthentication('apiKeyHeader')).setApiKey('foo-bar-api-key');

        api.postCertificateData(params);
    }
}