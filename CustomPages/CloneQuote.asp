<!-- #include file ="../sagecrm.js" -->
<%


     
      var CompanyId=Request.QueryString("CompId")
	  var PersonId=Request.QueryString("PID")
	  var SageId=Request.QueryString("SageID")
      
	  var userid=CRM.GetContextInfo("user","user_userid")
	  var User_PrimaryTerritory=CRM.GetContextInfo("user","User_PrimaryTerritory")

	  var opportunityID=CRM.GetContextInfo("Opportunity","Oppo_opportunityid")
	  var recParentOppo=CRM.FindRecord("Opportunity","Oppo_opportunityid="+opportunityID)
	  
	  var QuoteId=CRM.GetContextInfo("Quotes","Quot_OrderQuoteID")
      var RecParentQuote=CRM.FindRecord("Quotes","Quot_OrderQuoteID="+QuoteId)


       var d = new Date();
		var CYear=d.getFullYear()
		var CMonth=d.getMonth()+1
		if (CMonth < 10)
		{
		CMonth="0"+CMonth
		}

		var CDate=d.getDate()
		if (CDate < 10)
		{
		CDate="0"+CDate
		}
		var NYear=d.getFullYear()+1

		var CurrentDate=CYear+"/"+CMonth+"/"+CDate



var RecOpportunity=eWare.CreateRecord("Opportunity")
RecOpportunity("oppo_stage")='Lead'
RecOpportunity("oppo_status")='In Progress'
RecOpportunity("Oppo_ChannelId")=1
RecOpportunity("Oppo_PrimaryCompanyId")=CompanyId
RecOpportunity("Oppo_AssignedUserId")=userid
RecOpportunity("Oppo_SecTerr")=recParentOppo("Oppo_SecTerr")
RecOpportunity("Oppo_PrimaryPersonId")=PersonId
RecOpportunity("Oppo_Description")='HF-'+recParentOppo("Oppo_Description")
RecOpportunity("Oppo_Type")=recParentOppo("Oppo_Type")
RecOpportunity("Oppo_Source")=recParentOppo("Oppo_Source")
RecOpportunity("Oppo_Note")=recParentOppo("Oppo_Note")
RecOpportunity("Oppo_Forecast")=recParentOppo("Oppo_Forecast")
RecOpportunity("Oppo_Certainty")="10"
RecOpportunity("Oppo_Priority")=recParentOppo("Oppo_Priority")
RecOpportunity("Oppo_Total")=recParentOppo("Oppo_Total")
RecOpportunity("Oppo_Forecast_CID")=recParentOppo("Oppo_Forecast_CID")
RecOpportunity("Oppo_Total_CID")=recParentOppo("Oppo_Total_CID")
RecOpportunity("oppo_Currency")=recParentOppo("oppo_Currency")
RecOpportunity("oppo_TotalOrders_CID")=recParentOppo("oppo_TotalOrders_CID")
RecOpportunity("oppo_TotalOrders")=recParentOppo("oppo_TotalOrders")
RecOpportunity("oppo_totalQuotes_CID")=recParentOppo("oppo_totalQuotes_CID")
RecOpportunity("oppo_totalQuotes")=recParentOppo("oppo_totalQuotes")
RecOpportunity("oppo_c_parentopportunity")=opportunityID
RecOpportunity("oppo_iscloned")='Y'
RecOpportunity.SaveChanges();


var sql="update opportunity set Oppo_Opened='"+CurrentDate+"',Oppo_Forecast='"+recParentOppo("Oppo_Forecast")+"' where oppo_opportunityid="+RecOpportunity("oppo_opportunityid")
	  CRM.ExecSQL(sql);


if (RecParentQuote.RecordCount >=1)
{
	var RecQuote=eWare.CreateRecord("Quotes")
	RecQuote("quot_status")='Active'
	RecQuote("quot_description")="CL: "+ RecParentQuote("quot_description")
	RecQuote("quot_discounttype")='PC'
	RecQuote("quot_grossamt")=RecParentQuote("quot_grossamt")
	RecQuote("quot_grossamt_CID")=RecParentQuote("quot_currency")
	RecQuote("quot_nettamt_CID")=RecParentQuote("quot_currency")
	RecQuote("quot_discountamt")=RecParentQuote("quot_discountamt")
	RecQuote("quot_discountamt_CID")=RecParentQuote("quot_currency")
	RecQuote("quot_DiscountPC")=RecParentQuote("quot_DiscountPC")
	RecQuote("quot_lineitemdisc")=RecParentQuote("quot_lineitemdisc")
	RecQuote("quot_lineitemdisc_CID")=RecParentQuote("quot_currency")
	RecQuote("quot_nettamt")=RecParentQuote("quot_lineitemdisc")
	RecQuote("quot_nettamt_CID")=RecParentQuote("quot_currency")
	RecQuote("quot_currency")=RecParentQuote("quot_currency")
	RecQuote("quot_NoDiscAmt_CID")=3
	RecQuote("quot_NoDiscAmt")=RecParentQuote("quot_NoDiscAmt")
	RecQuote("quot_tax_CID")=3
	RecQuote("quot_tax")=RecParentQuote("quot_tax")
	RecQuote("quot_pricinglistid")=16007
	RecQuote("quot_reference")='QT-'+RecOpportunity("oppo_opportunityid")+'/1'
	RecQuote("quot_opportunityid")=RecOpportunity("oppo_opportunityid")
	// RecQuote("quot_shipaddress")=RecParentQuote("quot_shipaddress")
	// RecQuote("quot_billaddress")=RecParentQuote("quot_billaddress")
	RecQuote("quot_synchstatus")="notlinked"
	RecQuote("quot_promote")="N"
	 RecQuote("quot_contactid")=PersonId
	RecQuote("quot_rollup")='Y'


	RecQuote("quot_c_totalvat") =RecParentQuote("quot_c_totalvat")
	RecQuote("quot_c_totalvat_CID") =RecParentQuote("quot_c_totalvat_CID")
	RecQuote("quot_c_totalincvat") =RecParentQuote("quot_c_totalincvat")
	RecQuote("quot_c_totalincvat_CID") =RecParentQuote("quot_c_totalincvat_CID")
	//RecQuote("quot_c_totalMargin") =RecParentQuote("quot_c_totalMargin")
	//RecQuote("quot_c_totalMargin_CID") =RecParentQuote("quot_c_totalMargin_CID")
	//RecQuote("quot_c_marginpercent") =RecParentQuote("quot_c_marginpercent")
	//RecQuote("quot_c_type") =RecParentQuote("quot_c_type")
        
        RecQuote("quot_c_clauses") =RecParentQuote("quot_c_clauses")
        RecQuote("quot_c_clauses") =RecParentQuote("quot_c_clauses")
	
	
	RecQuote.SaveChanges();
	  
	  
var sql="update Quotes set quot_opened='"+CurrentDate+"' where Quot_OrderQuoteID="+RecQuote("Quot_OrderQuoteID")
CRM.ExecSQL(sql);


 var RecParentQuoteItems=CRM.FindRecord("QuoteItems","QuIt_orderquoteid="+RecParentQuote("Quot_OrderQuoteID"))
  if (RecParentQuoteItems.RecordCount >=1)
  {
        while (!RecParentQuoteItems.eof)
		{
         var RecQtItems=eWare.CreateRecord("QuoteItems")
		 
           RecQtItems("QuIt_discount_CID")=RecParentQuoteItems("QuIt_discount_CID")
           RecQtItems("QuIt_discount")=RecParentQuoteItems("QuIt_discount")
           RecQtItems("QuIt_discountsum_CID")=RecParentQuoteItems("QuIt_discountsum_CID")
           RecQtItems("QuIt_discountsum")=RecParentQuoteItems("QuIt_discountsum")
           RecQtItems("QuIt_listprice_CID")=RecParentQuoteItems("QuIt_listprice_CID")
           RecQtItems("QuIt_listprice")=RecParentQuoteItems("QuIt_listprice")
           RecQtItems("QuIt_orderquoteid")=RecQuote("Quot_orderquoteid")
           RecQtItems("QuIt_productid")=RecParentQuoteItems("QuIt_productid")
           RecQtItems("QuIt_quantity")=RecParentQuoteItems("QuIt_quantity")
           RecQtItems("QuIt_quotedprice_CID")=RecParentQuoteItems("QuIt_quotedprice_CID")
           RecQtItems("QuIt_quotedprice")=RecParentQuoteItems("QuIt_quotedprice")
           RecQtItems("QuIt_quotedpricetotal_CID")=RecParentQuoteItems("QuIt_quotedpricetotal_CID")
           RecQtItems("QuIt_quotedpricetotal")=RecParentQuoteItems("QuIt_quotedpricetotal")
           RecQtItems("QuIt_linenumber")=RecParentQuoteItems("QuIt_linenumber")
           RecQtItems("QuIt_UOMID")=RecParentQuoteItems("QuIt_UOMID")
           RecQtItems("QuIt_productfamilyid")=RecParentQuoteItems("QuIt_productfamilyid")
           RecQtItems("QuIt_intforeignid")=RecParentQuoteItems("QuIt_intforeignid")
           RecQtItems("QuIt_intid")=RecParentQuoteItems("QuIt_intid")
           
           RecQtItems("QuIt_description")=RecParentQuoteItems("QuIt_description")
           RecQtItems("QuIt_LineType")=RecParentQuoteItems("QuIt_LineType")
           RecQtItems("QuIt_DoNotreprice")=RecParentQuoteItems("QuIt_DoNotreprice")
          
           RecQtItems("QuIt_RepricingStatus")=RecParentQuoteItems("QuIt_RepricingStatus")
           RecQtItems("QuIt_ERPLocation")=RecParentQuoteItems("QuIt_ERPLocation")
           RecQtItems("QuIt_tax_CID")=RecParentQuoteItems("QuIt_tax_CID")
           RecQtItems("QuIt_taxrate")=RecParentQuoteItems("QuIt_taxrate")
           RecQtItems("QuIt_discountrate")=RecParentQuoteItems("QuIt_discountrate")
           RecQtItems("QuIt_tax")=RecParentQuoteItems("QuIt_tax")
           RecQtItems("QuIt_promote")=RecParentQuoteItems("QuIt_promote")
		   RecQtItems("quit_q_warehouse")=RecParentQuoteItems("quit_q_warehouse")
		   RecQtItems("quit_q_taxcode")=RecParentQuoteItems("quit_q_taxcode")
		   
	   RecQtItems("quit_c_vatsum")=RecParentQuoteItems("quit_c_vatsum")
       RecQtItems("quit_c_vatsum_CID")=RecParentQuoteItems("quit_c_vatsum_CID")
       RecQtItems("quit_c_vatvalue")=RecParentQuoteItems("quit_c_vatvalue")
       RecQtItems("quit_c_totalincvat")=RecParentQuoteItems("quit_c_totalincvat")
       RecQtItems("quit_c_totalincvat_CID")=RecParentQuoteItems("quit_c_totalincvat_CID")
       RecQtItems("quit_c_discount")=RecParentQuoteItems("quit_c_discount")
       RecQtItems("quit_c_includequoteitem") =RecParentQuoteItems("quit_c_includequoteitem")
       RecQtItems("quit_c_addtoforecast") =RecParentQuoteItems("quit_c_addtoforecast")
	

      // RecQtItems("quit_c_buyprice")=RecParentQuoteItems("quit_c_buyprice")
       //RecQtItems("quit_c_buyprice_CID")=RecParentQuoteItems("quit_c_buyprice_CID")
       //RecQtItems("quit_c_profitmargin")=RecParentQuoteItems("quit_c_profitmargin")
      // RecQtItems("quit_c_marginpercent")=RecParentQuoteItems("quit_c_marginpercent")
       //RecQtItems("quit_c_discounttype")=RecParentQuoteItems("quit_c_discounttype")
       //RecQtItems("quit_c_discountamount")=RecParentQuoteItems("quit_c_discountamount")
       //RecQtItems("quit_c_discountamount_CID")=RecParentQuoteItems("quit_c_discountamount_CID")
      
      // RecQtItems("quit_c_totaldiscount")=RecParentQuoteItems("quit_c_totaldiscount")
      // RecQtItems("quit_c_totaldiscount_CID")=RecParentQuoteItems("quit_c_totaldiscount_CID")
       //RecQtItems("quit_c_quotedafterdiscount")=RecParentQuoteItems("quit_c_quotedafterdiscount")
      // RecQtItems("quit_c_quotedafterdiscount_CID")=RecParentQuoteItems("quit_c_quotedafterdiscount_CID")
		   
		     
       
          
		 RecQtItems.SaveChanges()
		 RecParentQuoteItems.NextRecord();
		 }
  }



 }



	var sql="update quotes set 	quot_c_clonecompany=Null, quot_c_clonecontact=Null,quot_c_sageaccount=Null where Quot_OrderquoteId="+QuoteId
			CRM.ExecSQL(sql);


var str = CRM.Url(260);
var url = str.split("&Key0");

Response.write(url[0])

if (CompanyId >0)
Response.Redirect(url[0]+"&Key0=7&Key7="+RecOpportunity("oppo_opportunityid")+"&Key1="+CompanyId+"&T=Opportunity")
else
Response.Redirect(url[0]+"&Key0=7&Key7="+RecOpportunity("oppo_opportunityid")+"&T=Opportunity")







%>

