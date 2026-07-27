<%

var getProperty = function (obj, propertyName) {
    return obj[propertyName];
};

//was planning on putting this into a grid...
function colIncolumnsToTotal(obj, name)
{
  if (obj.columnsToTotal)
  {
	  if (typeof obj=="object")
		  return obj.columnsToTotal.name.indexOf(name) > -1;
	  else
		return obj.columnsToTotal.indexOf(name) > -1;
  }
  return false;
}	
function undefinedToBlank(val)
{
	if (val+""=="undefined")
	{
		return "&nbsp;";
	}
	return val;
}
function undefinedToNum(val)
{
	if (val+""=="undefined")
	{
		return 0;
	}
	if (val=="")
		return 0;
	val=val.replace(",","");
	val=val.replace(",","");
	return val;
}
function createReportGrid(objar, CRM, returnGridCode)
{
	var totalsArray=new Array();
	var res="";
	//var allcolumns=new Array();
	for(var i=0;i<objar.length;i++)
	{		
  	  var allcolumns=new Array();
	  var totalsArray=new Array();
      var _totals="0d 0h 0m";
	  var grid="";
	  if (objar[i].title)
		grid="<h2>"+objar[i].title+"</h2>";
	  grid+="<table width=\"70%\" class=\"CONTENTGRID\" cellspacing=\"0\" cellpadding=\"1\" style=\"width:77vw;padding-left: 15px;\">";
	  var u=objar[i];
    	if (u.columnsToTotal)//currency totals
		{	
			for(var z=0;z<u.columnsToTotal.length;z++)
			{
				//totalsArray.push(u.columnsToTotal[z]);
				totalsArray[u.columnsToTotal[z]]=0;
			}
		}	
	  var q=null;
	  try{
		q=CRM.CreateQueryObj(u.sql);
		q.SelectSQL();
	  }catch(e)
	  {
		Response.Write("Error in SQL: "+u.sql);
		Response.Write("<br/><br/>Error: "+e.message);
		Response.End();
	  }
	  grid+="<tr>";
	  if (objar[i].showRowCount===true)
	  {
			grid+="<td class=\"GRIDHEAD\" >#</td>";
      }
	  if (objar[i].columns!=null)
	  {
		  for(j=0;j<objar[i].columns.length;j++)
		  {
			if (typeof objar[i].columns[j]=="string" && (objar[i].columns[j].indexOf(",")>0))
			{
				var valArray=objar[i].columns[j].split(",");
				grid+="<td class=\"GRIDHEAD\" >"+valArray[0]+"</td>";
			}else
			if (typeof objar[i].columns[j]=="object")
			{				
				grid+="<td class=\"GRIDHEAD\" >"+objar[i].columns[j].title+"</td>";
					allcolumns[objar[i].columns[j].name]="";
			}else{
				grid+="<td class=\"GRIDHEAD\" >"+objar[i].columns[j]+"</td>";
				allcolumns[objar[i].columns[j]]="";
			}
			
		  }
	  }
	  if (objar[i].columnsX!=null)
	  {
		  for(j=0;j<objar[i].columnsX.length;j++)
		  {
			if (objar[i].columnsX[j].name.indexOf(",")>0)
			{
				var valArray=objar[i].columnsX[j].name.split(",");
				grid+="<td class=\"GRIDHEAD\" >"+valArray[0].name+"</td>";
			}else{
				grid+="<td class=\"GRIDHEAD\" >"+objar[i].columnsX[j].title+"</td>";
			}
			allcolumns[objar[i].columnsX[j].name]="";
		  }
	  }	  
	  grid+="</tr>";
	  var rowClass="ROW2";
	  var intRowCount=0;
	  
	  try{
		  q.eof
	  }catch (testsqlerr){
		  Response.Write("SQL Error:"+testsqlerr.message);
		  Response.Write("SQL :"+u.sql);
		  Response.End();
	  }
	  
	  while(!q.eof)
	  {
		  
		grid+="<tr>";
		var customStyle="";
		if (rowClass=="ROW2")
		{
		  rowClass="ROW1";
		}else
		{
		  rowClass="ROW2";
		}
		if (objar[i].showRowCount===true)
		{
			intRowCount++;
			grid+="<td class=\""+rowClass+"\" >"+intRowCount+"</td>";		
		}
		if (objar[i].columns!=null)
		{		
			for(j=0;j<objar[i].columns.length;j++)
			{
				if (totalsArray.hasOwnProperty (objar[i].columns[j]))
				{
					var _nm=new Number(undefinedToNum(q(objar[i].columns[j])));
					if (!isNaN(_nm))
					{ 
						if (objar[i].columns[j].indexOf(",")>0)
						{
							var valArray=objar[i].columns[j].split(",");
							totalsArray[objar[i].columns[j]]+=valArray[0];
						}else{
							totalsArray[objar[i].columns[j]]+=_nm;
							//if (objar[i].columns[j]=="[Gross]")
							//Response.write("<br />"+objar[i].columns[j]+"="+_nm);
							//Response.write("<br />"+objar[i].columns[j]+"="+totalsArray[objar[i].columns[j]]);
						}
					
					}else{
					//Response.write("<br />"+objar[i].columns[j]+"="+_nm);
					}
				}
				if (typeof objar[i].columns[j]=="string" && (objar[i].columns[j].indexOf("_secterr")>0))
				{
					grid+="<td class=\""+rowClass+"\" >"+getTerr(q(objar[i].columns[j]))+"</td>";				
				}else 
				if  (typeof objar[i].columns[j]=="string" && (objar[i].columns[j].indexOf(",")>0))
				{ 
					var valArray=objar[i].columns[j].split(",");
					grid+="<td class=\""+rowClass+"\" >"+undefinedToBlank(CRM.GetTrans(valArray[1],q(valArray[0])))+"</td>";
				}else{
					customStyle="";	
					if (typeof objar[i].columns[j]==="object")
					{
						
						if (objar[i].columns[j].flagNumbers===true)
						{
							var _tmpNum=new Number(q(objar[i].columns[j].name));							
							if (_tmpNum<=0)
								customStyle="color:red";
							else 
								customStyle="color:green";
						}
						grid+="<td class=\""+rowClass+"\" style=\""+customStyle+"\" >"+undefinedToBlank(q(objar[i].columns[j].name))+"</td>";
					}else
						grid+="<td class=\""+rowClass+"\" style=\""+customStyle+"\" >"+undefinedToBlank(q(objar[i].columns[j]))+"</td>";
					
				}
			}
		}
		
		if (objar[i].columnsX!=null)
		{		
			for(j=0;j<objar[i].columnsX.length;j++)
			{
				if (totalsArray.hasOwnProperty (objar[i].columnsX[j].name))
				{
					var _nm=new Number(undefinedToNum(q(objar[i].columnsX[j].name)));
					if (!isNaN(_nm))
					{ 
						if (objar[i].columnsX[j].name.indexOf(",")>0)
						{
							var valArray=objar[i].columnsX[j].name.split(",");
							totalsArray[objar[i].columnsX[j].name]+=valArray[0];
						}else{
							totalsArray[objar[i].columnsX[j].name]+=_nm;
						}					
					}
				}
				if (objar[i].columnsX[j].name.indexOf("_secterr")>0)
				{
					grid+="<td class=\""+rowClass+"\" >"+getTerr(q(objar[i].columnsX[j].name))+"</td>";				
				}else 
				if (objar[i].columnsX[j].name.indexOf(",")>0)
				{ 
					var valArray=objar[i].columnsX[j].name.split(",");
					grid+="<td class=\""+rowClass+"\" >"+undefinedToBlank(CRM.GetTrans(valArray[1],q(valArray[0])))+"</td>";
				}else{
					if (Defined(objar[i].columnsX[j].email)){
						grid+="<td class=\""+rowClass+"\" >"+
						"<a href=\"mailto:"+
						objar[i].columnsX[j].email(q(objar[i].columnsX[j].linkparams[0]))+
						"\" >"+
						undefinedToBlank(q(objar[i].columnsX[j].name))+
						"</a></td>";
					}else
					if (Defined(objar[i].columnsX[j].link)){
						grid+="<td class=\""+rowClass+"\" >"+
						"<a href=\""+
						objar[i].columnsX[j].link(q(objar[i].columnsX[j].linkparams[0]))+
						"\" >"+
						undefinedToBlank(q(objar[i].columnsX[j].name))+
						"</a></td>";
					}else{
						grid+="<td class=\""+rowClass+"\" >"+undefinedToBlank(q(objar[i].columnsX[j].name))+"</td>";
					}
				}
			}
		}
		
		grid+="</tr>";
		if (u.columnsToTotalTime)
	    {
			_totals=addTime(_totals,undefinedToBlank(q(objar[i].columnsToTotalTime[0])));
	    }
		q.NextRecord();
	  }
	  if (u.columnsToTotal)////add in total columns
   	  {  
	    grid+="<tr>";
		if (rowClass=="ROW2")
		{
		  rowClass="ROW1";
		}else
		{
		  rowClass="ROW2";
		}
		if (objar[i].showRowCount===true)
		{
			grid+="<td class=\"GRIDHEAD\" ></td>";
		}		
		
		for (_col in allcolumns) {
			if (_col=="indexOf")//..weird bug
			{
				break;
			}
			var _totl="&nbsp;--";//+_col;
			
			if (totalsArray.hasOwnProperty(_col))
			{
				_totl=getProperty(totalsArray,_col);
				_totl=formatTotals(_totl);
			}
			rowClass="GRIDHEAD";
			//style=\"background-Color:blue\"
			
			grid+="<td  class=\""+rowClass+"\"  >"+_totl+"</td>";	
		}
		grid+="</tr>";
	  }
	  grid+="<table><br/><br/>";
	  if (returnGridCode===true)
	  {
		  res+=grid;
	  }else{
		CRM.AddContent(grid);
	  }
	  if ((!returnGridCode)&&(u.columnsToTotalTime))
	  {
	    CRM.AddContent("Totals: "+_totals+"<br /><br />");
	  }
	}
	if (returnGridCode===true)
	{
	  return res;
	}
}

function formatTotals(val)
{
	var valn=new Number(val);
	valn=valn.toFixed(2);
	return numberWithCommas(valn);
}

function numberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}
function _getCompanyName(id)
{
	var _res="";

	if (id)
	{
		var _x=CRM.CreateQueryObj("select comp_name from company where comp_companyid="+id);
		_x.SelectSQL();
		if (!_x.eof)
		{
			_res=_x("comp_name");
		}
	}
	return _res;
}

function _getCurrencySign(val)
{
	var _res="no currency set!!!";
	var _s="select * from Currency where Curr_CurrencyID="+val;
	var _q=CRM.CreateQueryObj(_s);
	_q.SelectSQL();
	if (!_q.eof)
	{
		_res=_q("Curr_Symbol");
	}
	return _res;
}

function getTerr(val)
{
	var _res=val;;
	var _s="select * from Territories where Terr_TerritoryID="+val;
	var _q=CRM.CreateQueryObj(_s);
	_q.SelectSQL();
	if (!_q.eof)
	{
		_res=_q("Terr_Caption");
	}
	return _res;
}

%>