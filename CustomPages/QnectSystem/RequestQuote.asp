<!-- #include file ="sagecrmnohistory.js" -->

<%
var qnectVersion = "200";
var qnectHelpLocation = "https://help.qnect.cloud/Qnect"+qnectVersion;
var SID =new String(Request.Querystring("SID"));
var QuoteID =new String(Request.Querystring("Key86"));

var QmulusQuoteBlock = CRM.GetBlock('QuotePost'); 
var QuoteRecordId = Request.QueryString('Key86'); 
var QuoteRecord = CRM.FindRecord('Quotes','quot_orderquoteid='+QuoteRecordId); 
var CurrencyRecord = CRM.FindRecord('Currency','curr_currencyid='+QuoteRecord.quot_grossamt_cid);
QmulusQuoteBlock.Title = 'Requesting Quote '+QuoteRecord.quot_reference+' to Sage Accounts to the Value of '+CurrencyRecord.curr_symbol+'  '+parseFloat(QuoteRecord.quot_grossamt).toFixed(2)+'';
QmulusQuoteBlock.ArgObj = QuoteRecord;

var QmulusQ50Block = CRM.GetBlock('QnectFinancialsPostOrderScreen'); 
var QuoteRecordId = Request.QueryString('Key86'); 
var QuoteRecord = CRM.FindRecord('Quotes','quot_orderquoteid='+QuoteRecordId); 
var Q50CRecord = CRM.FindRecord('QnectCompany', 'qnco_qnectcompanyid='+QuoteRecord.quot_qs_account);
var Q50FRecord = CRM.FindRecord("QnectFinancials", "qnfi_acref='"+Q50CRecord.qnco_acref+"' and qnfi_accounttype = '" + Q50CRecord.qnco_accounttype + "' and qnfi_qnectsystemid = " + Q50CRecord.qnco_qnectsystemid);

//if(Q50FRecord.qnfi_currency != QuoteRecord.quot_currency)
if(1==2)
{
var QmulusBlockContainer = CRM.GetBlock('Container');
CurrencyBlock = CRM.GetBlock("content");
CurrencyBlock.contents = "<script>crm.ready(function() {crm.errorMessage('This quote is in a different currency to the Sage Accounts company selected. Change the Sage Accounts company for the quote and retry.');});</script>";

with (QmulusBlockContainer)
{
  AddBlock(CurrencyBlock);
  DisplayButton(1)=false;
DisplayButton(Button_Continue) = true;
}
CRM.AddContent(QmulusBlockContainer.Execute());
CRM.SetContext(""); 
Response.Write(CRM.GetPage(""));
}
else
{
QmulusQ50Block.ArgObj = Q50FRecord;

var AvailableCredit = Q50FRecord.qnfi_creditlimit - Q50FRecord.qnfi_balance;
var Q50CurrencyRecord = CRM.FindRecord('Currency','curr_currencyid='+Q50FRecord.q50f_currency);

if ((Q50FRecord.qnfi_creditlimit)-(Q50FRecord.qnfi_balance) <=  QuoteRecord.quot_grossamt) 
{
QmulusQ50Block.Title = 'Financial Summary for '+Q50CRecord.qnco_acref+' <font color=gray>(Last Synchronised on '+Q50FRecord.qnfi_updateddate+')</font><br><font color=orange><img src="../../Themes/Img/Ergonomic/Choices/case_color/amber.gif" alt=Not Enough Credit" style="float:left">&nbsp;&nbsp;Available Credit for this Account is '+CurrencyRecord.curr_symbol+' '+parseFloat(AvailableCredit).toFixed(2)+'</font>';
}
else if ((Q50FRecord.qnfi_creditlimit)-(Q50FRecord.q50f_balance) >=  QuoteRecord.quot_grossamt) 
{
QmulusQ50Block.Title = 'Financial Summary for '+Q50CRecord.qnco_acref+' <font color=gray>(Last Synchronised on '+Q50FRecord.qnfi_updateddate+')</font><br><font color=green><img src="../../Themes/Img/Ergonomic/Choices/case_color/green.gif" alt=Credit OK" style="float:left">&nbsp;&nbsp;Available Credit for this Account is '+CurrencyRecord.curr_symbol+' '+parseFloat(AvailableCredit).toFixed(2)+'</font>';
}
if ((Q50FRecord.qnfi_onhold) == 'Y') 
{
QmulusQ50Block.Title = 'Financial Summary for '+Q50CRecord.qnco_acref+' <font color=gray>(Last Synchronised on '+Q50FRecord.qnfi_updateddate+')</font><br><font color=red><span class="blink_text">Alert</span></font> - This Account is on credit hold.';
}

var QmulusContentBlock = CRM.GetBlock('Content');
var QmulusBlockContainer = CRM.GetBlock('Container');


//if ((Q50FRecord.qnfi_onhold) != 'Y') 
{
QmulusContentBlock.contents = '<a class="er_buttonItem" onclick="SageCRM.utilities.appendOverlay();" href="RequestedQuote.asp?SID='+SID+'&Key86='+QuoteID+'" id="Button_QuickPostQuote">Confirm & Request Quote</a>';
}



with (QmulusBlockContainer)
{
AddBlock(QmulusQuoteBlock);
AddBlock(QmulusQ50Block);
AddBlock(QmulusContentBlock);
DisplayButton(1)=false;
AddButton(CRM.Button("Cancel","cancel.gif",CRM.Url("1469")));

var strScript = "javascript: x = window.open('" + qnectHelpLocation + "/Default_CSH.htm#Quote/Request-Quote-To-Accounts.htm?PopupWin=Y','WebPickerNew','scrollbars=yes,toolbar=no,menubar=no,resizable=yes,top=100, width=800,height=600'); void (x)";
AddButton(CRM.Button("Help", "help.gif",strScript));
}

CRM.AddContent(QmulusBlockContainer.Execute());
CRM.SetContext(""); 
Response.Write(CRM.GetPage(""));
}
%>


















