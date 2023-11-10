/**
 * Created by frans fourie on 2023/11/10.
 */

public class SRVAFFCertificateDataResponse {

    public String testValue { get; set; }
    public String referenceNumber { get; set; }
    public String validUntl { get; set; }
    public String consName { get; set; }
    public String consRegion { get; set; }
    public String consEmail { get; set; }
    public String consTel { get; set; }
    public String consCell { get; set; }
    public String clientName2 { get; set; }
    public String clientName { get; set; }
    public String clientIdNumber { get; set; }
    public String clientIdNumber2 { get; set; }
    public String depositPercentage1 { get; set; }
    public String depositPercentage2 { get; set; }
    public String depositPercentage3 { get; set; }
    public String depositPercentage4 { get; set; }
    public String depAmt1 { get; set; }
    public String depAmt2 { get; set; }
    public String depAmt3 { get; set; }
    public String depAmt4 { get; set; }
    public String rate20Yr1 { get; set; }
    public String rate20Yr2 { get; set; }
    public String rate20Yr3 { get; set; }
    public String rate20Yr4 { get; set; }
    public String mnthly1 { get; set; }
    public String mnthly2 { get; set; }
    public String mnthly3 { get; set; }
    public String mnthly4 { get; set; }
    public String saving1 { get; set; }
    public String saving2 { get; set; }
    public String saving3 { get; set; }
    public String saving4 { get; set; }
    public String totIncome { get; set; }
    public String bondRepymnt { get; set; }
    public String bondRepymntSettlemnt { get; set; }
    public String expenses { get; set; }
    public String maxRepaymnt { get; set; }
    public String purchasePrice { get; set; }

    public static SRVAFFCertificateDataResponse getExample(){
        SRVAFFCertificateDataResponse resp = new SRVAFFCertificateDataResponse();
        resp.testValue = '';
        resp.purchasePrice = '';
        resp.maxRepaymnt = '';
        resp.expenses = '';
        resp.bondRepymntSettlemnt = '';
        resp.bondRepymnt = '';
        resp.totIncome = '';
        resp.saving4 = '';
        resp.saving3 = '';
        resp.saving2 = '';
        resp.saving1 = '';
        resp.mnthly4 = '';
        resp.mnthly3 = '';
        resp.mnthly2 = '';
        resp.mnthly1 = '';
        resp.rate20Yr4 = '';
        resp.rate20Yr3 = '';
        resp.rate20Yr2 = '';
        resp.rate20Yr1 = '';
        resp.depAmt4 = '';
        resp.depAmt3 = '';
        resp.depAmt2 = '';
        resp.depAmt1 = '';
        resp.depositPercentage4 = '';
        resp.depositPercentage3 = '';
        resp.depositPercentage2 = '';
        resp.depositPercentage1 = '';
        resp.clientIdNumber2 = '';
        resp.clientIdNumber = '';
        resp.clientName = '';
        resp.clientName2 = '';
        resp.consCell = '';
        resp.consTel = '';
        resp.consEmail = '';
        resp.consRegion = '';
        resp.consName = '';
        resp.validUntl = '';
        resp.referenceNumber = '';
        resp.testValue = '';

        return resp;
    }
}