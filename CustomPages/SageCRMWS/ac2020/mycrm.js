<%

    function getPipelineStatsJSON(_pipelinedata, _pipelinedatadataLabels) {
        var res = {
            "datasets": [{
                "data": _pipelinedata,

                "backgroundColor": [
                    "rgba(255, 99, 132, 0.2)",
                    "rgba(54, 162, 235, 0.2)",
                    "rgba(255, 206, 86, 0.2)",
                    "rgba(75, 192, 192, 0.2)",
                    "rgba(153, 102, 255, 0.2)",
                    "rgba(255, 159, 64, 0.2)"
                ],
                "borderColor": [
                    "rgba(255,99,132,1)",
                    "rgba(54, 162, 235, 1)",
                    "rgba(255, 206, 86, 1)",
                    "rgba(75, 192, 192, 1)",
                    "rgba(153, 102, 255, 1)",
                    "rgba(255, 159, 64, 1)"
                ],
                "borderWidth": 1

            }],
            "labels": _pipelinedatadataLabels
        }
        return res;
    }

function getSalesMetadataDataForUser(userid) {
    if (!Defined(userid))
        userid = getUserId();
    //var _teamid=CRM.GetContextInfo("user","User_PrimaryChannelId");
    var _userObject = getUserObject("and user_userid=" + userid);

    var _teamid = _userObject.user_primarychannelid;

    var sqlfilterWhere = "Oppo_AssignedUserId=" + userid + " AND (oppo_status = N'" + getDefaultStatus('oppo_status') + "' or oppo_status is null)";
    var _useSalesTeam = GetWebConfigValue("TeamNotUser") == "Y";

    if (_useSalesTeam) {
        sqlfilterWhere = "Oppo_ChannelId=" + _teamid + " AND (oppo_status = N'" + getDefaultStatus('oppo_status') + "' or oppo_status is null)";
    }else
	if (GetWebConfigValue("oppopipelinebyTerr")=="Y")
	{
		sqlfilterWhere="Oppo_SecTerr>="+CRM.GetContextInfo("user","User_PrimaryTerritory")+" AND (oppo_status = N'" + getDefaultStatus('oppo_status') + "' or oppo_status is null)";
	}
    var sqlFilter = CRM.FindRecord("opportunity,vListOpportunity",sqlfilterWhere);
    var oppoIdFilter = "";
    while (!sqlFilter.eof) {
        if (oppoIdFilter != "")
            oppoIdFilter += ",";
        oppoIdFilter += sqlFilter("oppo_opportunityid")
        sqlFilter.NextRecord();
    }
    if (oppoIdFilter != "")
        oppoIdFilter = "(" + oppoIdFilter + ")";
    else
        oppoIdFilter = "(-1)";

    var salessql = "SELECT COUNT(*) AS Qry_Count, AVG(Capt_Order) AS Qry_Order, Oppo_Stage AS Qry_Stage, " +
        "SUM((Oppo_Forecast/Curr_Rate) * 1.000000) AS Qry_SumForecast,  " +
        "SUM(((Oppo_Forecast/Curr_Rate) * 1.000000) * Oppo_Certainty)/ 100 AS Qry_WeightedForecast,  " +
        "SUM(Oppo_Certainty) AS Qry_SumCertainty FROM vListOpportunity  " +
        "LEFT JOIN Currency oppo_forecast_Currency ON Oppo_Forecast_CID = Curr_CurrencyID  " +
        "LEFT JOIN Custom_Captions ON Oppo_Stage = Capt_Code AND  capt_familytype = N'choices'  " +
        "WHERE Oppo_AssignedUserId=" + userid + " AND  (oppo_status = N'" + getDefaultStatus('oppo_status') + "' or oppo_status is null)" +
        "and ( Capt_Family = N'Oppo_Stage' OR Capt_Family IS NULL) " +
        "and oppo_opportunityid in " + oppoIdFilter +
        " GROUP BY Oppo_Stage ORDER BY 2 DESC";
	if (GetWebConfigValue("oppopipelinebyTerr")=="Y")
	{
		salessql = "SELECT COUNT(*) AS Qry_Count, AVG(Capt_Order) AS Qry_Order, Oppo_Stage AS Qry_Stage, " +
        "SUM((Oppo_Forecast/Curr_Rate) * 1.000000) AS Qry_SumForecast,  " +
        "SUM(((Oppo_Forecast/Curr_Rate) * 1.000000) * Oppo_Certainty)/ 100 AS Qry_WeightedForecast,  " +
        "SUM(Oppo_Certainty) AS Qry_SumCertainty FROM vListOpportunity  " +
        "LEFT JOIN Currency oppo_forecast_Currency ON Oppo_Forecast_CID = Curr_CurrencyID  " +
        "LEFT JOIN Custom_Captions ON Oppo_Stage = Capt_Code AND  capt_familytype = N'choices'  " +
        "WHERE Oppo_SecTerr>="+CRM.GetContextInfo("user","User_PrimaryTerritory") + " AND  (oppo_status = N'" + getDefaultStatus('oppo_status') + "' or oppo_status is null)" +
        "and ( Capt_Family = N'Oppo_Stage' OR Capt_Family IS NULL) " +
        "and oppo_opportunityid in " + oppoIdFilter +
        " GROUP BY Oppo_Stage ORDER BY 2 DESC";
    } else if (_useSalesTeam) {
        salessql = "SELECT COUNT(*) AS Qry_Count, AVG(Capt_Order) AS Qry_Order, Oppo_Stage AS Qry_Stage, " +
            "SUM((Oppo_Forecast/Curr_Rate) * 1.000000) AS Qry_SumForecast,  " +
            "SUM(((Oppo_Forecast/Curr_Rate) * 1.000000) * Oppo_Certainty)/ 100 AS Qry_WeightedForecast,  " +
            "SUM(Oppo_Certainty) AS Qry_SumCertainty FROM vListOpportunity  " +
            "LEFT JOIN Currency oppo_forecast_Currency ON Oppo_Forecast_CID = Curr_CurrencyID  " +
            "LEFT JOIN Custom_Captions ON Oppo_Stage = Capt_Code AND  capt_familytype = N'choices'  " +
            "WHERE Oppo_ChannelId=" + _teamid + " AND  (oppo_status = N'" + getDefaultStatus('oppo_status') + "' or oppo_status is null) " +
            "and ( Capt_Family = N'Oppo_Stage' OR Capt_Family IS NULL) " +
            "and oppo_opportunityid in " + oppoIdFilter +
            " GROUP BY Oppo_Stage ORDER BY 2 DESC";
    }			
    return {
        "salessql": salessql
    }

}
function getSalesData(userid) {
    var _metadata = getSalesMetadataDataForUser(userid)
	
    var q = CRM.CreateQueryObj(_metadata.salessql);

    q.SelectSQL();
    var res = [];
	//Response.Write(_metadata.salessql);
	//Response.End();
    while (!q.eof) {
        var Qry_SumForecast = q.FieldValue("Qry_Count");
        if (!Qry_SumForecast)
            Qry_SumForecast = 0;
        Qry_SumForecast = (new Number(Qry_SumForecast))
        res.push(Qry_SumForecast.toFixed(2))
        q.NextRecord();
    }
    return res;
}
function getSalesDataLabel(userid) {
    var _metadata = getSalesMetadataDataForUser(userid)
	
    var q = CRM.CreateQueryObj(_metadata.salessql);
    q.SelectSQL();
    var res = [];
    while (!q.eof) {
        Qry_Stage = CRM.GetTrans("Oppo_Stage", q.FieldValue("Qry_Stage"));
        res.push(Qry_Stage);
        q.NextRecord();
    }
    return res;
}

function getSalesStats(userid) {
    var _metadata = getSalesMetadataDataForUser(userid)
	
    var q = CRM.CreateQueryObj(_metadata.salessql);
    q.SelectSQL();

    var Qry_Count = 0;
    var Qry_Order = 0;
    var Qry_Stage = 0;
    var Qry_SumForecast = 0;
    var Qry_WeightedForecast = 0;
    var Qry_SumCertainty = 0;

    while (!q.eof) {
        Qry_Count += (new Number(q.FieldValue("Qry_Count")));
        Qry_SumForecast += (new Number(q.FieldValue("Qry_SumForecast")))
        Qry_WeightedForecast += (new Number(q.FieldValue("Qry_WeightedForecast")))
        Qry_SumCertainty += (new Number(q.FieldValue("Qry_SumCertainty")))
        q.NextRecord();
    }
    Qry_SumForecast = Qry_SumForecast.toFixed(2);
    var avg_Certainty = 0;
    if (Qry_SumCertainty > 0)
        avg_Certainty = (Qry_SumCertainty / Qry_Count);
    var avg_value = 0;
    if (Qry_SumForecast > 0)
        avg_value = (Qry_SumForecast / Qry_Count);
    var w_avg = 0;
    if (avg_Certainty > 0)
        w_avg = ((avg_value / 100) * avg_Certainty);
    var _DefaultCurrencyDisplay = getCurrencyCID(getSysParam("BaseCurrency")) + " ";
    var res = {
        item1Caption: CRM.GetTrans('ColNames', 'qry_Count'),
        item1Value: Qry_Count,
        item2Caption: CRM.GetTrans('ColNames', 'Qry_SumForecast'),
        item2Value: _DefaultCurrencyDisplay + _formatMoneyVal(Qry_SumForecast),
        item3Caption: CRM.GetTrans('ColNames', 'qry_weightedForecast'),
        item3Value: _DefaultCurrencyDisplay + _formatMoneyVal(Qry_WeightedForecast),
        item4Caption: CRM.GetTrans('ColNames', 'qry_avgdealvalue'),
        item4Value: _DefaultCurrencyDisplay + _formatMoneyVal(avg_value),
        item5Caption: CRM.GetTrans('ColNames', 'qry_avgcertainty'),
        item5Value: avg_Certainty.toFixed(2) + "%",
        item6Caption: CRM.GetTrans('ColNames', 'qry_avgweighted'),
        item6Value: _DefaultCurrencyDisplay + _formatMoneyVal(w_avg)
    }
    return res;
}

//cases
function getCasesMetadataDataForUser(userid) {
    if (!Defined(userid))
        userid = getUserId();

    var sqlFilter2 = CRM.FindRecord("cases,vListCases", "case_AssignedUserId=" + userid + " AND (case_status = N'" + getDefaultStatus('case_status') + "' or case_status is null)");
    var caseIdFilter = "";
    while (!sqlFilter2.eof) {
        if (caseIdFilter != "")
            caseIdFilter += ",";
        caseIdFilter += sqlFilter2("case_caseid")
        sqlFilter2.NextRecord();
    }
    if (caseIdFilter != "")
        caseIdFilter = "(" + caseIdFilter + ")";
    else
        caseIdFilter = "(-1)";

    var casesql = "SELECT COUNT(*) AS Qry_Count, AVG(Capt_Order) AS " +
        " Qry_Order, Case_Stage AS Qry_Stage FROM vListCases LEFT JOIN Custom_Captions ON  " +
        " Case_Stage = Capt_Code WHERE Case_AssignedUserId=" + userid + " AND (case_status = N'" + getDefaultStatus('case_status') + "' or case_status is null) AND  " +
        "  (UPPER(RTRIM(Capt_Family)) = UPPER(RTRIM('Case_Stage')) OR Capt_Family IS NULL) " +
        " and case_caseid in " + caseIdFilter +
        "  GROUP BY Case_Stage ORDER BY 2 DESC"
    return {
        "casesql": casesql
    }

}


function getCasesData(userid) {
    var _metadata = getCasesMetadataDataForUser(userid);
    var q = CRM.CreateQueryObj(_metadata.casesql);
    q.SelectSQL();
    var res = [];
    while (!q.eof) {
        Qry_Count = (new Number(q("Qry_Count")))
        res.push(Qry_Count)
        q.NextRecord();
    }
    return res;
}

function getCasesDataLabel(userid) {
    var _metadata = getCasesMetadataDataForUser(userid);
    var q = CRM.CreateQueryObj(_metadata.casesql);
    q.SelectSQL();
    var res = [];
    while (!q.eof) {
        Qry_Stage = CRM.GetTrans("Case_Stage", q.FieldValue("Qry_Stage"));
        res.push(Qry_Stage);
        q.NextRecord();
    }
    return res;
}


function getCustomMyCRMTabs() {
    var res = [];
    var _menu = "acdashboard";

    var sql = "select distinct Tabs_Caption, tabs_customfilename, Tabs_Order,convert(nvarchar(max),Tabs_WhereSQL) as Tabs_WhereSQL from Custom_Tabs " +
        "where Tabs_Entity='" + _menu + "' " +
        "and tabs_deviceid is null and tabs_deleted is null ";
		
    if (isPortalRequest) {
        sql += " AND (tabs_customfilename LIKE '%_acplus%') ";
    } else {
        sql += " AND (tabs_customfilename NOT LIKE '%_acplus%') ";
    }
	if (G_appMode=="AC")
	{
		sql += " AND (tabs_customfilename NOT LIKE 'listmx_%')";
		//EXCLUDE MX asp pages
		sql += " AND (tabs_customfilename NOT LIKE '%mxonly_%')";
	}		
	else
		if (G_appMode=="MX")
		{
			sql += " AND (tabs_customfilename NOT LIKE 'listac_%')";
			//EXCLUDE AC asp pages
			sql += " AND (tabs_customfilename NOT LIKE '%aconly_%')";
		}	
    sql+=" order by Tabs_Order";
		
    Glog("getScreenTabs sql:" + sql);
    var q1 = CRM.CreateQueryObj(sql);
    q1.SelectSQL();
    while (!q1.eof) {
        var xtab = JSON.clone(_tab);
        xtab.tabName = q1.FieldValue("Tabs_Caption");
		xtab.tabwheresql = q1.FieldValue("Tabs_WhereSQL");
        if (Defined(q1.FieldValue("tabs_customfilename")))
            xtab.tabAction = q1.FieldValue("tabs_customfilename");
        if ((xtab) && (xtab.tabAction.indexOf(".asp") > 0)) {
            xtab.tabAction = CRM.Url(xtab.tabAction) + isportalcode();
            if (isPortalRequest) {
                xtab.tabAction += "5=5";
            }
            xtab.tabAction = http_protocol + get_SERVER_NAME() + xtab.tabAction;
            xtab.tabAction += "&app=ac2020&appmode="+G_appMode+"&appplatform="+G_appPlatform;//app=ac2020 is to allow the page know what is calling it
            if (isPortalRequest)
                xtab.tabAction += "&token=" + authToken;
			/*
            if (!isPortalRequest) {
                var securityoff = GetWebConfigValue("securityoff") == "true";
                if (!securityoff) {
                    //now put in our normal SID...needed to work around browser security issue
                    var crmsid = getLastFullSID();
                    var thisSID = Request.QueryString("SID");
                    if (crmsid != "") {
                        xtab.tabAction = xtab.tabAction.replace(thisSID, crmsid);
                    }
                }
            }*/
        }
        xtab.tabCaption = CRM.GetTrans("TabNames", q1.FieldValue("Tabs_Caption"));
        xtab.tabOrder = q1.FieldValue("Tabs_Order");
        xtab.enabled = true;
		
		if ((!isPortalRequest)&&(Defined(xtab.tabwheresql)))
		{
			//check the where clause doesn't omit it...
			try {
					var _tabsqlfiter = "";
					_tabsqlfiter = "select user_userid from vUsers where 471355=471355 "+
									"and user_userid=" + getUserId() +
									" and " + xtab.tabwheresql;//eg user_per_admin=3
					var _tabsqlfiterq = CRM.CreateQueryObj(_tabsqlfiter);
					_tabsqlfiterq.SelectSQL();
					if (_tabsqlfiterq.eof)
						xtab.enabled = false;
			} catch (e) {
				//carry on
			}
		}
		if (xtab.enabled)
			res.push(xtab);
        q1.NextRecord();
    }
    return res;
}

%>