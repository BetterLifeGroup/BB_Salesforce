/**
 * Created by frans fourie on 2023/11/10.
 */

@IsTest
public with sharing class SRVAFFCertificateDataResponseTest {

    @IsTest
    public static void testSRVAFFCertificateDataResponse() {
        
        Assert.isNotNull(SRVAFFCertificateDataResponse.getExample());
    }
}