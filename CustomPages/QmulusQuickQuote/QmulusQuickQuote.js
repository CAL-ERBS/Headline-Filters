var fieldTemplates = {
    uomid: "<select v-model='uomIndexSelected' v-show='pricing.length' @change='uomChanged'>\
  <option v-for='(price, index) in pricing' :key='price.$key' :value='index'>{{window.crm.getTrans('UOM', price.pric_UOMID.toString())}}</option>\
  </select>",
    quantity: "<input type='number' v-model='linedata.quantity' @change='onChange(\"quantity\", $event)' :disabled='lineType === \"c\"'/>"
}
crm.ready(function () {
    if (window.QuickQuoteCustomFieldTemplates) {
        fieldTemplates = $.extend(fieldTemplates, QuickQuoteCustomFieldTemplates);
    }
    if (typeof window.CompanyChanged === "undefined") {
        window.CompanyChanged = function () { };
    }
    if (typeof window.PersonChanged === "undefined") {
        window.PersonChanged = function () { };
    }

    function newPerson(personField, companyField) {
        if (!crm.fields(companyField).val()) {
            alert('Please select a company');
            return;
        }
        u = '/' + crm.installName() + '/eware.dll/Do?SID=' + crm.getArg('SID') + '&Act=1232&Key1=' + crm.fields(companyField).val() + '&Mode=1&ViewField=Pers_FullName,Pers_PhoneFullNumber,&JumpReturnCol=' + personField + '&JumpIdField=Pers_PersonId&JumpNameField=Pers_FullName&SearchEntity=Person&SearchTable=vSearchListPerson&SearchSql=&searchsqld=&SsDef=20&LinkedField=&TiedField=' + personField + '&PopupWin=Y&SearchText=' + encodeURIComponent(document.EntryForm['_HIDDEN' + personField + 'TEXT'].value);
        if (document.EntryForm[companyField]) {
            u += '&RestrictorValue=' + encodeURIComponent(document.EntryForm[companyField].value) + '&RestrictorTEXT=' + encodeURIComponent(document.EntryForm['_HIDDEN' + companyField + 'TEXT'].value);
        }
        WebPickerNewWin = window.open(u, 'WebPickerNew', 'scrollbars=yes,resizable=yes,width=700,height=600');
        SetID = window['SetID' + personField];
    }

    function newCompany(companyField) {
        u = '/' + crm.installName() + '/eware.dll/Do?SID=' + crm.getArg('SID') + '&Act=1230&Mode=1&ViewField=Comp_Name,Comp_Type,Comp_Status,&JumpReturnCol=' + companyField + '&JumpIdField=Comp_CompanyId&JumpNameField=Comp_Name&SearchEntity=Company&SearchTable=Company&SearchSql=&searchsqld=&SsDef=20&LinkedField=&TiedField=' + companyField + '&PopupWin=Y&SearchText=' + encodeURIComponent(document.EntryForm['_HIDDEN' + companyField + 'TEXT'].value);
        WebPickerNewWin = window.open(u, 'WebPickerNew', 'scrollbars=yes,resizable=yes,width=700,height=600');
        SetID = window['SetID' + companyField];
    }
    var personField = crm.fields("oppo_primarypersonid")[0];
    if (personField.mode === "edit") {
        var newPersLink = document.createElement("a");
        newPersLink.className = "SmallButtonItem";
        newPersLink.href = "#";
        newPersLink.innerText = "New Person";
        newPersLink.onclick = function () {
            newPerson("oppo_primarypersonid", "oppo_primarycompanyid")
        };
        var newCompLink = document.createElement("a");
        newCompLink.className = "SmallButtonItem";
        newCompLink.href = "#";
        newCompLink.innerText = "New Company";
        newCompLink.onclick = function () {
            newCompany("oppo_primarycompanyid")
        };
        var newTd = document.createElement("td");
        newTd.appendChild(newCompLink);
        newTd.appendChild(document.createElement("br"));
        newTd.appendChild(newPersLink);
        newTd.setAttribute("nowrap", "nowrap")
        var fieldContainer = personField.elements.container.parent().closest("td")[0];
        fieldContainer.parentNode.insertBefore(newTd, fieldContainer.nextSibling);
    }
    var addressFields = $("#quot_billaddress,#orde_billaddress,#quot_shipaddress,#orde_shipaddress");
    if (addressFields.length) {
        addressFields.each(function (index, field) {
            var fieldName = field.name;
            $(field).after("<br><select class='qaddresses' data-addrfield='" + fieldName + "'></select>");
        });
        var addressSelections = $(".qaddresses");
        addressSelections.on("change", function () {
            if (this.value < 0) {
                $("#" + this.dataset.addrfield).val("");
            } else {
                var address = addresses[this.value];
                console.log(address);
                var addressArr = [];
                if (address.addr_address1) {
                    addressArr.push(address.addr_address1);
                }
                if (address.addr_address2) {
                    addressArr.push(address.addr_address2);
                }
                if (address.addr_address3) {
                    addressArr.push(address.addr_address3);
                }
                if (address.addr_address4) {
                    addressArr.push(address.addr_address4);
                }
                var cityCounty = [];
                if (address.Addr_City) {
                    cityCounty.push(address.Addr_City)
                }
                if (address.Addr_State) {
                    cityCounty.push(address.Addr_State);
                }
                if (cityCounty.length) {
                    addressArr.push(cityCounty.join(" "));
                }
                var postcodeCountry = [];
                if (address.Addr_PostCode) {
                    postcodeCountry.push(address.Addr_PostCode);
                }
                if (address.Addr_Country) {
                    postcodeCountry.push(crm.getTrans("addr_country", address.Addr_Country));
                }
                if (postcodeCountry.length) {
                    addressArr.push(postcodeCountry.join(" "));
                }
                $("#" + this.dataset.addrfield).val(addressArr.join("\n"));
            }
        })
        var addresses = [];
        var compField = crm.fields("oppo_primarycompanyid");
        var getAddresses = function () {
            var companyId = compField.val();
            addressSelections.empty();
            addressSelections.append("<option value='-1'>--None--</option>");
            addresses = [];
            if (!companyId) {
                return;
            }
            var where = "adli_companyid eq " + companyId;
            var searchUrl = "/sdata/" + crm.installName() + "j/sagecrm2/-/vAddressCompany?SID=" + crm.getArg("SID") + "&count=1000&where=" + where;
            $.ajax({
                url: searchUrl,
                dataType: "json"
            }).then(function (data) {
                addresses = data.$resources;
                console.log(addresses);
                $.each(addresses, function (index, address) {
                    console.log(address);
                    var addrLine = [address.addr_address1, address.addr_address2, address.addr_address3, address.addr_address4].filter(function (el) {
                        return el;
                    }).join(", ");
                    if (addrLine.length > 45) {
                        addrLine = addrLine.substring(0, 43) + "...";
                    }
                    addressSelections.append($("<option></option>").attr("value", index).text(addrLine));
                });
            });
        }
        getAddresses();
    }

    window.additionalLineTemplate = function () {
        return window.listFieldInfo.map(function (field) {
            var template = (window.fieldTemplates[field.FieldName] || field.DefaultTemplate);
            return "<td>" + template + "</td>";
        }).join("");
    }


    window.eventBus = new Vue({
        created: function () {
            var self = this;
            if (window.QuickQuoteEventHandlers) {
                for (var i = 0; i < QuickQuoteEventHandlers.length; i++) {
                    console.log("Adding handler for " + QuickQuoteEventHandlers[i].name);
                    self.$on(QuickQuoteEventHandlers[i].name, QuickQuoteEventHandlers[i].callback)
                }
            }
        }
    });
    Vue.component("autocomplete", {
        props: ["entity", "valuefield", 'autocompletedisplay', 'where', 'initSearchCriteria', 'extraSelect', 'maxlength', 'disabled'],
        data: function () {
            return {
                selectedResult: undefined,
                resultSet: [],
                showList: false,
                searchCriteria: this.initSearchCriteria,
                autoCompleteArrowIndex: 0,
                showingError: null,
                focused: false,
                dirty: false,
                searchTimeout: null
            }
        },
        computed: {
            hasSearchTextButNoValueSelected: function () {
                return (this.dirty && !this.focused && this.searchCriteria && !this.selectedResult);
            }
        },
        methods: {
            search: function () {
                clearTimeout(this.searchTimeout);
                this.dirty = true;
                this.selectedResult = null;
                this.autoCompleteArrowIndex = 0;
                if (!this.searchCriteria) {
                    this.showList = false;
                    this.resultSet = [];
                    return;
                }
                var self = this;
                this.searchTimeout = setTimeout(function () {

                    var searchUrl = "/sdata/" + crm.installName() + "j/sagecrm2/-/" + self.entity + "?SID=" + crm.getArg("SID") + "&startindex=1&count=10&where=";
                    var cleanSearchCriteria = self.searchCriteria.replace(/'/g, "''");
                    var tmpWhere = self.where;
                    if (typeof tmpWhere === "function") {
                        tmpWhere = tmpWhere();
                    }
                    searchUrl += encodeURIComponent(tmpWhere.replace(/#/g, cleanSearchCriteria));
                    searchUrl += "&select=" + self.valuefield;
                    if (self.extraSelect) {
                        searchUrl += "," + self.extraSelect;
                    }
                    $.ajax({
                        url: searchUrl,
                        dataType: "json"
                    }).then(function (data) {
                        self.resultSet = data.$resources;
                        self.showList = true;
                    }).catch(function (response) {
                        console.error(response);
                        //Only display the error once every 10 seconds.
                        if (!self.showingError) {
                            self.showingError = setTimeout(function () {
                                self.showingError = null;
                            }, 10000);
                            alert("Error searching (HTTP " + response.status + " " + response.statusText + "), please make sure Tomcat and sData 2 are running correctly");
                        }
                    });

                }, 500);
            },
            autocompleteSelect: function (selected) {
                this.searchCriteria = selected[this.valuefield];
                this.selectedResult = selected;
                this.showList = false;
            },
            leaveTextBox: function () {
                var self = this;
                if (this.showList) {
                    setTimeout(function () {
                        self.showList = false;
                    }, 500);
                }
                this.focused = false;
            },
            enterTextBox: function () {
                this.focused = true;
            },
            notifyChange: function () {
                this.$emit("selectedResultChanged", this.selectedResult, this.searchCriteria);
            },
            arrowDown: function () {
                this.autoCompleteArrowIndex = Math.min(this.resultSet.length - 1, this.autoCompleteArrowIndex + 1);
            },
            arrowUp: function () {
                this.autoCompleteArrowIndex = Math.max(0, this.autoCompleteArrowIndex - 1);
            },
            nextKeyPressed: function () {
                var selectedItem = this.resultSet[this.autoCompleteArrowIndex];
                if (selectedItem) {
                    this.autocompleteSelect(selectedItem);
                }
            }
        },
        watch: {
            selectedResult: function () {
                this.notifyChange();
            },
            initSearchCriteria: function (newVal) {
                this.searchCriteria = newVal;
            }
        },
        template: "<div class='autocomplete'><input :maxlength='maxlength' type='text' :disabled='disabled' v-model='searchCriteria' @input='search' @focus='enterTextBox' @blur='leaveTextBox' @keydown.down='arrowDown' @keydown.up='arrowUp' @keydown.prevent.enter='nextKeyPressed' @keydown.tab='nextKeyPressed' :class='{invalid: hasSearchTextButNoValueSelected}'/>\
  <ul v-show='showList' class='autocomplete-results'>\
  <li v-show='!resultSet.length' class='autocomplete-result'>No Results Found</li>\
  <li class='autocomplete-result' :class=\"{'is-active': index === autoCompleteArrowIndex}\" v-for='(result, index) in resultSet' :key='result.$key' @click='autocompleteSelect(result)'>{{autocompletedisplay(result)}}</li>\
  </ul>\
  </div>",
    });
    Vue.component("quote-line", {
        props: ["linedata", "lineindex"],
        data: function () {
            return {
                pricing: [],
                uomIndexSelected: undefined,
                ready: true
            }
        },
        computed: {
            lineType: function () {
                var lineType;
                if (this.linedata.productid) {
                    lineType = "i";
                    if (this.linedata.quantity == null) {
                        this.linedata.quantity = 1;
                    }
                } else if (this.linedata.quotedprice === null || this.linedata.quotedprice.length === 0) {
                    lineType = "c";
                } else {
                    lineType = "f";
                    if (this.linedata.quantity == null) {
                        this.linedata.quantity = 1;
                    }
                }
                this.linedata.linetype = lineType;
                return lineType;
            },
            quotedTotal: function () {
                var total = this.linedata.quotedprice * this.linedata.quantity;
                if (isNaN(total)) {
                    total = null;
                }
                this.linedata.quotedpricetotal = total;
                return total;
            },
            discount: function () {
                var discount = 0;
                var discountSum = 0;
                if (this.lineType === "i") {
                    discount = this.linedata.listprice - this.linedata.quotedprice;
                    discountSum = discount * this.linedata.quantity;
                    if (isNaN(discount)) {
                        discount = 0;
                    }
                    if (isNaN(discountSum)) {
                        discountSum = 0;
                    }
                }
                this.linedata.discount = discount;
                this.linedata.discountsum = discountSum;
                return discount;
            },
            rowClass: function () {
                var trClass = "";
                if (!this.linedata._valid) {
                    trClass += "invalid ";
                }
                if (this.lineindex % 2) {
                    trClass += "ROW1";
                } else {
                    trClass += "ROW2";
                }
                return trClass;
            }
        },
        methods: {
            deleteLine: function () {
                this.$emit("onDelete", this.lineindex);
            },
            startDrag: function (e) {
                e.dataTransfer.setData("text", this.lineindex.toString());
            },
            allowDrop: function (e) { },
            drop: function (e) {
                this.$emit("onRowDropped", e.dataTransfer.getData("text"), this.lineindex);
            },
            productChanged: function (prod) {
                var self = this;
                this.uomIndexSelected = null;
                var oldProdId = this.linedata.productid;
                var finishUp = function () {
                    self.uomChanged();
                    if (oldProdId !== self.linedata.productid) {
                        self.onChange("productid", self.linedata);
                    }
                }
                if (prod) {
                    this.linedata.productid = prod.$key;
                    this.linedata.prodcode = prod.prod_code;
                    this.linedata.description = prod.prod_name;
                    eventBus.$emit("setproddesc", this.linedata, prod);
                    this.linedata.productfamilyid = prod.prod_productfamilyid;
                    this.selectedResult = null;
                    this.loadPrices().then(function (data) {
                        if (self.pricing.length === 1) {
                            self.uomIndexSelected = 0;
                        }
                        finishUp();
                    });
                    return;
                } else {
                    this.linedata.productid = null;
                    this.linedata.productfamilyid = null;
                    this.pricing = [];
                    finishUp();
                }
            },
            autoCompleteChanged: function (fieldName, resultObj) {
                eventBus.$emit(fieldName + "autocompletechanged", this.linedata, resultObj);
            },
            loadPrices: function () {
                var self = this;
                var currencyId = $("#quot_currency,#orde_currency").val();
                var priceListId = $("#quot_pricinglistid,#orde_pricinglistid").val();
                var searchUrl = "/sdata/" + crm.installName() + "j/sagecrm2/-/Pricing?SID=" + crm.getArg("SID") + "&count=1000&where=";
                searchUrl += "pric_productid eq " + this.linedata.productid + " and pric_active eq 'Y' and pric_price_CID eq " + currencyId + " and pric_PricingListId eq " + priceListId;
                searchUrl += "&select=pric_UOMID,pric_price";
                return $.ajax({
                    url: searchUrl,
                    dataType: "json"
                }).then(function (data) {
                    self.pricing = data.$resources;
                });
            },
            uomChanged: function () {
                var oldUomId = this.linedata.uomid;
                if (this.uomIndexSelected !== null) {
                    var priceRec = this.pricing[this.uomIndexSelected];
                    this.linedata.uomid = priceRec.pric_UOMID;
                    this.linedata.quotedprice = priceRec.pric_price;
                    this.linedata.listprice = priceRec.pric_price;
                } else {
                    this.linedata.uomid = null;
                    this.linedata.quotedprice = null;
                    this.linedata.listprice = null;
                }
                if (oldUomId !== this.linedata.uomid) {
                    this.onChange("uomid");
                }
            },
            getProductFilter: function () {
                var priceListId = $("#quot_pricinglistid,#orde_pricinglistid").val();
                if (!priceListId) {
                    alert("Please select a pricing list");
                    return "1=2";
                }
                var currencyId = $("#quot_currency,#orde_currency").val();
                return "(prod_name like '#%' or prod_code like '#%') and prli_pricinglistid eq " + priceListId + " and curr_currencyid eq " + currencyId;
            },
            getProductAutocompleteText: function (prod) {
                return prod.prod_code + " - " + prod.prod_name;
            },
            onChange: function (fieldName, e) {
                eventBus.$emit(fieldName, this.linedata, e);
            }
        },
        mounted: function () {
            var self = this;
            if (this.linedata._prodFromSdata) {
                this.productChanged(this.linedata._prodFromSdata);
                this.linedata._prodFromSdata = null;
                return;
            }
            if (this.linedata.productid) {
                if (!this.linedata.prodcode) {
                    this.ready = false;
                    var searchUrl = "/sdata/" + crm.installName() + "j/sagecrm2/-/NewProduct('" + this.linedata.productid + "')?SID=" + crm.getArg("SID") + "&select=prod_code,prod_name" + (window.QuickQuoteProductSelectFields || "");
                    $.ajax({
                        url: searchUrl,
                        dataType: "json",
                    }).then(function (data) {
                        self.linedata.prodcode = data.prod_code;
                        if (!self.linedata.description) {
                            self.linedata.description = data.prod_name;
                            eventBus.$emit("setproddesc", self.linedata, data);
                        }
                        self.ready = true;
                    }).catch(function (response) {
                        self.ready = true;
                    })
                }
                this.loadPrices().then(function () {
                    $.each(self.pricing, function (index, value) {
                        if (value.pric_UOMID == self.linedata.uomid) {
                            self.uomIndexSelected = index;
                            return false;
                        }
                    })
                });
            }
        },
        template: "<tr :class='rowClass'>\
    <template v-if='ready'>\
  <td>"+ (window.QuickQuoteProductTemplateExtraPre || "") + "<autocomplete maxlength='100' class='focusThis' :initSearchCriteria='linedata.prodcode' @selectedResultChanged='productChanged' entity='vNewProductPriceList' valuefield='prod_code' :autocompletedisplay='getProductAutocompleteText' :where='getProductFilter' extraSelect='prod_productfamilyid,prod_name" + (window.QuickQuoteProductSelectFields || "") + "'/>" + (window.QuickQuoteProductTemplateExtra || "") + "</td>" + window.additionalLineTemplate() + "<td>{{quotedTotal.toFixed(2)}}</td>\
  <td>\
    <div v-if='lineType === \"i\"'>Product</div>\
    <div v-else-if='lineType === \"f\"'>Freetext</div>\
    <div v-else-if='lineType === \"c\"'>Comment</div>\
  </td>\
  <td align='center'><img src='/" + crm.installName() + "/Themes/img/ergonomic/Buttons/green/trash-bin.svg' @click.prevent='deleteLine'/></td>\
  <td align='center'><img src='/" + crm.installName() + "/CustomPages/QmulusQuickQuote/draghandle.png' draggable='true' @dragstart='startDrag' @dragover.prevent='allowDrop' @drop='drop'/>\
  <div style='display: none;'>{{discount}}</div></td>\
  </template>\
  <template v-else>\
  <td colspan='999'>Loading...</td>\
  </template>\
  </tr>"
    });
    Vue.component('quick-quote', {
        props: {
            options: {
                default: function () { return {}; },
                type: Object
            }
        },
        data: function () {
            return {
                quoteLines: []
            }
        },
        template: "<div>\
  <table style='width: 100%'>\
  <tbody>\
  <tr>\
  <td class='GRIDHEAD'>Product</td>" + window.additionalLineHeading + "<td class='GRIDHEAD'>Total</td><td class='GRIDHEAD'>Line Type</td><td class='GRIDHEAD'></td><td class='GRIDHEAD'></td>\
  </tr>\
  <quote-line v-for='(quoteLine, index) in quoteLines' :key='quoteLine._uniqueId' :linedata='quoteLine' :lineindex='index' @onDelete='removeLine' @onRowDropped='rowDropped'/>\
  </tbody>\
  </table>\
  <div v-show='!options.disableTotalAndNew' style='float: right; display: block !important;'>Total: {{quotedTotal.toFixed(2)}}<img tabindex='0' style='width: 30px; margin-left: 50px;' src='/" + crm.installName() + "/Themes/img/ergonomic/Icons/green/plus.svg' @click.prevent='addLine(true)' @keyup.enter.tab.prevent='addLine(true)'></div>\
  </div>",
        computed: {
            quotedTotal: function () {
                var total = 0;
                $.each(this.quoteLines, function (index, line) {
                    if (!isNaN(line.quotedpricetotal) && typeof line.quotedpricetotal === "number") {
                        total += line.quotedpricetotal;
                    }
                });
                return total;
            }
        },
        methods: {
            addLine: function (doFocus) {
                var newLine = {
                    _valid: true,
                    _uniqueId: Date.now(),
                    productid: null,
                    productfamilyid: null,
                    description: null,
                    linetype: null,
                    uomid: null,
                    quantity: null,
                    listprice: null,
                    quotedprice: null,
                    quotedpricetotal: null,
                    discount: 0,
                    discountsum: 0,
                    prodcode: null
                }

                if (fieldDefaults) {
                    //Any configured defaults should override the above.
                    newLine = Object.assign(newLine, fieldDefaults);

                    //Except for quantity, we always want this empty, but it has a default "1" by default.
                    newLine.quantity = null;
                }

                eventBus.$emit("_newline", newLine);
                this.quoteLines.push(newLine);
                if (doFocus) {
                    crm.ready(function () {
                        $(".focusThis:last() input")[0].focus();
                    });
                }
                return newLine;
            },
            removeLine: function (index) {
                this.quoteLines.splice(index, 1);
            },
            rowDropped: function (fromIndex, toIndex) {
                var draggedLine = this.quoteLines.splice(fromIndex, 1);
                this.quoteLines.splice(toIndex, 0, draggedLine[0]);
            },
            validate: function () {
                var result = {
                    valid: true,
                    message: ""
                }
                if (!this.quoteLines.length) {
                    result.valid = false;
                    result.message = "Please add at least one line";
                    return result;
                }
                result.message = "One or more lines are invalid";
                $.each(this.quoteLines, function (index, line) {
                    //Always required
                    if (!line.linetype || !line.description) {
                        line._valid = false;
                    } else if (line.linetype === "i") {
                        line._valid = (line.productid && line.uomid && line.quantity !== null && line.quotedprice !== null);
                    } else if (line.linetype === "f") {
                        line._valid = (line.quantity !== null && line.quotedprice !== null);
                    } else {
                        line._valid = true;
                    }
                    if (line._valid) {
                        eventBus.$emit("_validate", line);
                    }
                    if (!line._valid) {
                        result.valid = false;
                    }
                });
                return result;
            }
        },
        mounted: function () {
            Vue.prototype.window = window;
            var self = this;
            if (!window.QuickQuoteWindowLinesSet) {
                if (window.lines) {
                    window.lines.forEach(function (line) {
                        if (line.linetype === "c") {
                            line.quotedprice = null;
                            line.quantity = null;
                        }
                        eventBus.$emit("lineloaded", line);
                    });
                    this.quoteLines = window.lines;
                } else {
                    this.addLine();
                }
                window.QuickQuoteWindowLinesSet = true;
            }
            if (!window.QuickQuoteSubmitOverridden) {

                window.QuickQuoteValidateAndSubmit = function () {
                    var validateResult = self.validate();
                    if (validateResult.valid) {
                        $("#linesField").val(JSON.stringify(self.quoteLines));
                        document.EntryForm.HiddenMode.value = 'Save';
                        document.EntryForm.submit();
                    } else {
                        alert(validateResult.message);
                    }
                }

                window.QuickQuoteSubmitOverridden = true;
            }
        }
    });
    window.QuickQuoteMainApp = new Vue({
        el: '#lines-app',
        template: '<quick-quote></quick-quote>'
    });
});