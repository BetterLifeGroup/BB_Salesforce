/**
 * Created by frans fourie on 2023/11/10.
 */

public virtual class SRVAFFCertificateDataApi {

    SRVAFFClient client;

    public SRVAFFCertificateDataApi(SRVAFFClient client) {
        this.client = client;
    }

    public SRVAFFCertificateDataApi() {
        this.client = new SRVAFFClient();
    }

    public SRVAFFClient getClient() {
        return this.client;
    }

    /**
     * Generates and returns a Pre-Approval Certificate Data
     * @return SRVAFFCertificateDataResponse
     * @throws OAS.ApiException if fails to make API call
     */
    public virtual SRVAFFCertificateDataResponse postCertificateData(Map<String, Object> params) {
        List<OAS.Param> query = new List<OAS.Param>();
        List<OAS.Param> form = new List<OAS.Param>();

        return (SRVAFFCertificateDataResponse) client.invoke(
                'POST', '/PreApproval/CertificateData',
                (SRVAFFCreatePreApprovalCertificateRe) params.get('SRVAFFCertificateDataApi'),
                query, form,
                new Map<String, Object>{},
                new Map<String, Object>(),
                new List<String>{ 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;true', 'application/json;odata.metadata&#x3D;minimal;odata.streaming&#x3D;false', 'application/json;odata.metadata&#x3D;minimal', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;true', 'application/json;odata.metadata&#x3D;full;odata.streaming&#x3D;false', 'application/json;odata.metadata&#x3D;full', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;true', 'application/json;odata.metadata&#x3D;none;odata.streaming&#x3D;false', 'application/json;odata.metadata&#x3D;none', 'application/json;odata.streaming&#x3D;true', 'application/json;odata.streaming&#x3D;false', 'application/json', 'application/xml', 'text/plain', 'application/octet-stream', 'text/json' },
                new List<String>{ 'application/json' },
                new List<String> { 'apiKeyHeader', 'apiKeyQuery' },
                SRVAFFCertificateDataResponse.class
        );
    }
}