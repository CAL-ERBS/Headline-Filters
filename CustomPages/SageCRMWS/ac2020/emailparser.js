<%

function applyRegex(entity, screen, regexdata){
  if (regexdata==null || regexdata.length==0)
	  return;
  if (entity=="address")
  {
	for(var oo=0;oo<screen.formElements.length;oo++)
	{
	  var _elmnt=screen.formElements[oo];
	  var addrstr=new String(regexdata[0].matchObject[0]);
	  var addrstrarr=addrstr.split(" ");
	  if (_elmnt.name=="addr_address1")
	    _elmnt.value=addrstrarr[0];
	  if ((_elmnt.name=="addr_address2")&&(addrstrarr.length>1))
	    _elmnt.value=addrstrarr[1];	
	  if ((_elmnt.name=="addr_address2")&&(addrstrarr.length>2))
	    _elmnt.value=addrstrarr[2];	
	  if ((_elmnt.name=="addr_address3")&&(addrstrarr.length>3))
	    _elmnt.value=addrstrarr[3];	
	  if ((_elmnt.name=="addr_city")&&(addrstrarr.length>4))
	    _elmnt.value=addrstrarr[4];	
	  if ((_elmnt.name=="addr_postcode")&&(addrstrarr.length>5))
	    _elmnt.value=addrstrarr[5];	
	  if ((_elmnt.name=="addr_state")&&(addrstrarr.length>6))
	    _elmnt.value=addrstrarr[6];	
	}	  
  }else   
  if (entity=="phone")
  {
	for(var oo=0;oo<screen.formElements.length;oo++)
	{
	  var _elmnt=screen.formElements[oo];
	  var _mappedarray=regexdata[0].mappedField.split(",");
	  for(var bb=0;bb<_mappedarray.length;bb++)
	  {
		if (Defined(regexdata[0].matchObject[bb])&&(_elmnt.name=="phonefield_"+_mappedarray[bb]))
			_elmnt.value.phonenumber_value=regexdata[0].matchObject[bb];
	  }
	}
  }else   
  if (entity=="email")
  {
	for(var oo=0;oo<screen.formElements.length;oo++)
	{
	  var _elmnt=screen.formElements[oo];
	  var _mappedarray=regexdata[0].mappedField.split(",");
	  for(var bb=0;bb<_mappedarray.length;bb++)
	  {
		if (Defined(regexdata[0].matchObject[bb])&&(_elmnt.name=="emailfield_"+_mappedarray[bb]))
			_elmnt.value.emailaddress=regexdata[0].matchObject[bb];
	  }
	}	  
  }else  
  if (entity=="person")
  {
	for(var oo=0;oo<screen.formElements.length;oo++)
	{
	  var _elmnt=screen.formElements[oo];
	  for(var yy=0;yy<regexdata.length;yy++)
	  {	  
		  var persname=new String(regexdata[0].matchObject[0]);
		  var persnamearr=persname.split(" ");
		  persnamearr = removeArrayEmptyItems(persnamearr);
		  if ((regexdata[yy])&&(regexdata[yy].mappedField)&&(regexdata[0].mappedField=="fullname"))
		  {	  
			  if (_elmnt.name=="pers_firstname")
				_elmnt.value=persnamearr[0];
			  if ((_elmnt.name=="pers_lastname")&&(persnamearr.length>1))
				_elmnt.value=persnamearr[1];
		  }
	  }
	}
  }else  
  if (entity=="lead")
  {
	for(var oo=0;oo<screen.formElements.length;oo++)
	{
	  var _elmnt=screen.formElements[oo];
	  for(var yy=0;yy<regexdata.length;yy++)
	  {
		  var persname=new String(regexdata[yy].matchObject[0]);
		  var persnamearr=persname.split(" ");
		  if ((regexdata[yy])&&(regexdata[yy].mappedField)&&(regexdata[yy].mappedField=="fullname"))
		  {
			  if (_elmnt.name=="lead_personfirstname")
				_elmnt.value=persnamearr[0];
			  if ((_elmnt.name=="lead_personlastname")&&(persnamearr.length>1))
				_elmnt.value=persnamearr[1];
		  }
	  }
	}
  }
  //////everything else....
	for(var oo=0;oo<screen.formElements.length;oo++)
	{
	  var _elmnt=screen.formElements[oo];
	  //Response.Write("--"+_elmnt.name+"=="+regexdata[0].mappedField);
	  for(var yy=0;yy<regexdata.length;yy++)
	  {
		  if ((regexdata[yy])&&(regexdata[yy].mappedField)&&(regexdata[yy].mappedField!="fullname"))
		  {
			if (_elmnt.name==regexdata[yy].mappedField)
				_elmnt.value=regexdata[yy].matchObject[0];
		  }
	  }
	}	  
	  
  
}

function parseEmail(valuetoParse, regexList){
	var res={
		parsedby: "parseEmail regex",
		regexList:JSON.stringify(regexList),
		person:[],
		company:[],
		lead:[],
		address:[],
		email:[],
		phone:[],
		alldata:[],
		errors:[]
	}
	var _sregexObj;
	//Response.Write(valuetoParse);
	for(var u=0;u<regexList.length;u++)
	{
		var regexObj=regexList[u];
		try{
			try{
				if (regexObj.param && regexObj.param!="")
				  _sregexObj=new RegExp(regexObj.Exp, regexObj.param);
				else
				  _sregexObj=new RegExp(regexObj.Exp);
			}catch(e) { 
				res.errors.push({errorexpcore:regexObj.Exp,message:e.message});
			}			
			var _parsematch=parseStringX(valuetoParse, _sregexObj);
			if ((_parsematch!=null)&&(_parsematch.length>0))
			{
				for(var tt=0;tt<_parsematch.length;tt++)
				{
					if (regexObj.extract)
						_parsematch[tt]=replaceAlli(_parsematch[tt],regexObj.extract,"");
					//remove any white spaces
					_parsematch[tt]=_parsematch[tt].trim();
				}			
				if (Defined(_parsematch)&& _parsematch[tt]!="")		
					res.alldata.push({matchedon:regexObj.Exp,matchObject:_parsematch});		
				if (!res[regexObj.entity.toLowerCase()])
					res[regexObj.entity.toLowerCase()]=[];
				
				if (Defined(_parsematch)&& _parsematch[tt]!="" && _parsematch[0]!="")
					res[regexObj.entity.toLowerCase()].push({x:tt,matchedon:regexObj.Exp,matchObject:_parsematch,
						entity:regexObj.entity.toLowerCase(), mappedField:regexObj.mappedField});	
			}
		}catch(exreg){
			res.errors.push({errorexp:regexObj.Exp,message:exreg.message});
		}
	}
	return res;
}

function parseStringX(valuetoParse, regexObj)
{	
	var res= valuetoParse.match(regexObj);		
	return res;
}

%>