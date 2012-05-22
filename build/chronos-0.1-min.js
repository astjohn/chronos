window.chronos={},chronos.Chronos=function(){function a(){this.current=null,this.activePicker=null,this.expiredPickers=[],this.initialize()}return a.name="Chronos",a.PROP_NAME="chronos_element_settings",a._defaultOptions={pickerClass:"",dayNames:["Sun","Mon","Tue","Wed","Thu","Fri","Sat","Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],dayNamesAbbr:["Su","Mo","Tu","We","Th","Fr","Sa"],monthNames:["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec","January","February","March","April","May","June","July","August","September","October","November","December"],amLower:"am",amUpper:"AM",amAbbrLower:"a",amAbbrUpper:"A",pmLower:"pm",pmUpper:"PM",pmAbbrLower:"p",pmAbbrUpper:"P",startBlank:!1,displayFormat:"isoDate",valueFormat:"U",maxDate:void 0,minDate:void 0,startDay:0,pickedDateTime:void 0,animations:{},positionOffset:{top:0,left:0},debug:!1},a.events=["opened","closed","daySelected","previousMonthFinished","nextMonthFinished","invalidDate","validDate"],a.prototype.initialize=function(){var a=this;return $(document).mousedown(function(b){return a._externalClickClose(b)})},a.prototype.setCurrentElement=function(a){return this._expirePicker(),this.current=$.data(a,chronos.Chronos.PROP_NAME)},a.prototype.setDateRange=function(a){return this.current.activePicker?this.current.activePicker.setDateRange(a):(a.minDate&&(this.current.options.minDate=a.minDate),a.maxDate&&(this.current.options.maxDate=a.maxDate),this._saveCurrentSettings())},a.prototype._saveCurrentSettings=function(){return $.data(this.current.displayElement,chronos.Chronos.PROP_NAME,this.current)},a.prototype._attach=function(a,b){var c;return this.current={options:$.extend({},chronos.Chronos._defaultOptions,b),valueElement:a},c=this._buildDisplayElement(),this.current.displayElement=c[0],this._saveCurrentSettings(),this},a.prototype._buildDisplayElement=function(){var a,b,c,d,e,f,g=this;return f=this.current.options,c=new chronos.DateFormatter(f),b=$(this.current.valueElement),e=b.val(),e=e?c.format(e,f.displayFormat):f.startBlank?"":c.format(new Date,f.displayFormat),d="chronos_picker_display",this.current.options.pickerClass&&(d+=" "+this.current.options.pickerClass+"_display"),a=b.clone(!0).removeAttr("name").attr("id",b.attr("id")+"_display").addClass(d).val(e),f.debug||b.hide(),a.bind({focus:function(a){return g._onFocus(a)},keyup:function(a){return g._onDisplayKeyUp(a)},keydown:function(a){return g._onDisplayKeyDown(a)}}),b.before(a),this.current.displayElement=a[0],a},a.prototype._renderPicker=function(){return this.current.activePicker||this._createPicker(),this.current.activePicker.render(),this.current.activePicker.insertAfter($(this.current.displayElement)),this.current.activePicker},a.prototype._createPicker=function(){var a,b=this;return a=new chronos.Picker(this.current),this.current.activePicker=a,a.$container.on({internal_close:function(a){return b._onClose(a)}}),a},a.prototype._expirePicker=function(){return this.current.activePicker&&this.expiredPickers.push(this.current.activePicker),this.current.activePicker=null},a.prototype._closePickers=function(){var a,b;b=[];while(this.expiredPickers.length>0)a=this.expiredPickers.pop(),b.push(a.close());return b},a.prototype._directClose=function(){return this._expirePicker(),this._closePickers()},a.prototype._findPickerFromEvent=function(a){var b,c;return c=$(a.target),b=c.hasClass("chronos_picker")?c:c.parents(".chronos_picker")},a.prototype._notActivePicker=function(a,b){return a.length>0&&a[0]!==this.current.activePicker.$container[0]},a.prototype._noPickerButActive=function(a){return a.length<=0&&this.current.activePicker!==null&&this.current.activePicker!==void 0},a.prototype._notActiveDisplay=function(a){return this.current.activePicker?this.current.activePicker.$displayElement[0]!==a.target:!0},a.prototype._externalClickClose=function(a){var b;if(this.current){b=this._findPickerFromEvent(a);if(this._notActiveDisplay(a)&&(this._notActivePicker(b,a)||this._noPickerButActive(b)))return this._directClose()}},a.prototype._isCurrentPicker=function(a){return this.current.activePicker!==void 0&&this.current.activePicker!==null&&this.current.activePicker.$displayElement[0]===a},a.prototype._onFocus=function(a){if(!this._isCurrentPicker(a.target))return this.setCurrentElement(a.target),this._renderPicker()},a.prototype._onClose=function(a){return a.stopPropagation(),this._directClose()},a.prototype._onDisplayKeyUp=function(a){if(this.current.activePicker)return this.current.activePicker.checkAndSetDate()},a.prototype._onDisplayKeyDown=function(a){(a.keyCode===13||a.keyCode===27)&&this.current.activePicker.$displayElement.blur();if(a.keyCode===13||a.keyCode===9||a.keyCode===27)return this._directClose()},a}(),chronos.Picker=function(){function a(a){this.current=a,this.$container=void 0,this.startingDate=void 0,this.mode=void 0,this.todayDate=new Date,this.pickedDateTime=a.pickedDateTime,this.$valueElement=$(a.valueElement),this.$displayElement=$(a.displayElement),this.dateFormatter=new chronos.DateFormatter(a.options),this.animator=void 0,this._initialize()}return a.name="Picker",a.prototype.render=function(){this._emptyBody();switch(this.mode){case"year":return this._renderYears();case"time":return this._renderTime();default:return this._renderMonths()}},a.prototype.close=function(){if(!this.closing)return this.closing=!0,this.animator.close()},a.prototype.insertAfter=function(a){return a.after(this.$container),this.setPosition(),this.animator.open()},a.prototype.setPosition=function(a){return a=a||this._getPosition(),this.$container.css(a).css({position:"absolute"})},a.prototype.setDate=function(a){if($.isFunction(a.getMonth))return this._saveDate(a),this._updateInputValues()},a.prototype.checkAndSetDate=function(){var a;return a=this.dateFormatter.unformat(this.$displayElement.val(),this.current.options.displayFormat),a!==!1?(this._saveDate(a),this._updateValueElement(),this.$container.trigger("validDate"),this.render()):this.$container.trigger("invalidDate")},a.prototype.setDateRange=function(a){return a.minDate&&(this._isValidDate(a.minDate)?(this.current.options.minDate=a.minDate,this._saveSettings()):console.warn("chronos: Invalid minDate")),a.maxDate&&(this._isValidDate(a.maxDate)?(this.current.options.maxDate=a.maxDate,this._saveSettings()):console.warn("chronos: Invalid maxDate")),this.render()},a.prototype._initialize=function(){return this._initializeContainer(),this._initializeAnimator(),this._setStartingDate(),this._setPickedDate(),this._setInitialMode()},a.prototype._initializeContainer=function(){return this.$container=this._createContainer(),this._bindContainerEvents(),this.$container.append(this._createHeader.call(this)),this.$container.append(this._createBody.call(this)),this.$container},a.prototype._initializeAnimator=function(){return this.animator=new chronos.Animator(this,this.current.options.animations),this.animator.setPicker(this.$container),this.animator},a.prototype._saveDate=function(a){return this.pickedDateTime=a,this.current.pickedDateTime=a,this._saveSettings()},a.prototype._setInitialMode=function(){return this.current.options.useTimePicker&&this.current.options.timePickerOnly?this.mode="time":this.current.options.yearOnly?this.mode="year":this.mode="month"},a.prototype._setStartingDate=function(){if(this.current.options.maxDate!==null||this.current.options.minDate!==null)this.current.options.maxDate&&this.todayDate.valueOf()>this.current.options.maxDate.valueOf()&&(this.startingDate=new Date(this.current.options.maxDate.valueOf())),this.current.options.minDate&&this.todayDate.valueOf()<this.current.options.minDate.valueOf()&&(this.startingDate=new Date(this.current.options.minDate.valueOf()));return this.startingDate===void 0&&(this.startingDate=new Date(this.todayDate.valueOf())),this.startingDate},a.prototype._setPickedDate=function(){if(!this.current.options.startBlank)if(this.pickedDateTime===void 0||this.pickedDateTime===null)return this.pickedDateTime=new Date(this.startingDate.valueOf())},a.prototype._createContainer=function(){var a;return a="chronos_picker",this.current.options.pickerClass&&(a+=" "+this.current.options.pickerClass),$("<div class='"+a+"' />")},a.prototype._createHeader=function(){var a,b,c=this;return a=$('<div class="header"/>'),a.append($('<div class="previous">&larr;</div>').click(function(a){return c._onPrevious(a)})),b=$('<div class="title"/>').click(function(a){return c._onZoomOut(a)}),b.append($('<span class="titleText"/>')),a.append(b),a.append($('<div class="next">&rarr;</div>').click(function(a){return c._onNext(a)})),a},a.prototype._createBody=function(){var a;return a=$('<div class="body" />'),a.append($('<div class="body_prev">')).append($('<div class="body_curr">')).append($('<div class="body_next">'))},a.prototype._emptyBody=function(){return this.$container.find(".body_curr").html(""),this.$container.find(".body_prev").html(""),this.$container.find(".body_next").html("")},a.prototype._renderTitle=function(a){return this.$container.find(".titleText").html(a)},a.prototype._renderMonths=function(){var a;return a=this.pickedDateTime||this.startingDate,this._buildMonth(a,this.$container.find(".body_curr")),this._renderTitle(this.$container.find(".body_curr").find(".monthBody").attr("data-date_title")),this._buildMonth(this._changeMonthBy(a,-1),this.$container.find(".body_prev")),this._buildMonth(this._changeMonthBy(a,1),this.$container.find(".body_next"))},a.prototype._buildMonth=function(a,b){var c,d,e=this;return d=new chronos.PanelMonth({givenDate:a,startDay:this.current.options.startDay,dayNamesAbbr:this.current.options.dayNamesAbbr,monthNames:this.current.options.monthNames,choice:this.pickedDateTime,maxDate:this.current.options.maxDate,minDate:this.current.options.minDate}),c=d.render(),c.bind("daySelected",function(a,b,c){return e._onDaySelected(a,c,b)}),b.append(c)},a.prototype._changeMonthBy=function(a,b){var c;return c=new Date(a.valueOf()),c.setMonth(c.getMonth()+b),c},a.prototype._saveSettings=function(){return $.data(this.current.displayElement,chronos.Chronos.PROP_NAME,this.current)},a.prototype._updateInputValues=function(){return this._updateValueElement(),this._updateDisplayElement()},a.prototype._updateValueElement=function(){var a;if(this.pickedDateTime)return a=this.dateFormatter.format(this.pickedDateTime,this.current.options.valueFormat),this.$valueElement.val(a)},a.prototype._updateDisplayElement=function(){var a;if(this.pickedDateTime)return a=this.dateFormatter.format(this.pickedDateTime,this.current.options.displayFormat),this.$displayElement.val(a)},a.prototype._getWindowHeight=function(){return $(window).height()},a.prototype._getScrollTop=function(){return $(window).scrollTop()},a.prototype._getPosition=function(){var a,b,c,d,e,f,g,h;return f={left:this.$displayElement.offset().left+this.current.options.positionOffset.left,top:this.$displayElement.offset().top+this.current.options.positionOffset.top},c=this._getWindowHeight(),g=this._getScrollTop(),e=this.$container.outerHeight(),d=Math.abs(c-f.top+this.$displayElement.outerHeight()),h=f.top+g,b=d>e,a=h>e,!a&&!b?(f.top=c/2-e/2,c+g<e&&console.warn("chronos: Not enough room to display date picker.")):b?f.top+=this.$displayElement.outerHeight():f.top-=e,f},a.prototype._isValidDate=function(a){return Object.prototype.toString.call(a)==="[object Date]"},a.prototype._onZoomOut=function(a){return console.log("ZOOM!")},a.prototype._onPrevious=function(a){return this.animator.previousMonth()},a.prototype._onNext=function(a){return this.animator.nextMonth()},a.prototype._onDaySelected=function(a,b,c){if(!this.current.options.useTimePicker)return this.pickedDateTime=c,this.current.pickedDateTime=c,this._saveSettings(),this._updateInputValues(),this.$container.trigger("internal_close")},a.prototype._bindContainerEvents=function(){var a,b,c,d,e,f=this;d=chronos.Chronos.events,e=[];for(b=0,c=d.length;b<c;b++)a=d[b],e.push(this.$container.on(a,function(a){var b;return b=Array.prototype.slice.apply(arguments),f._passEvents(a,b.slice(1,b.length))}));return e},a.prototype._passEvents=function(a,b){return a.stopPropagation(),this.$valueElement.trigger(a.type,b)},a}(),chronos.DateFormatter=function(){function a(a){this.i18n={dayNames:a.dayNames,monthNames:a.monthNames,amLower:a.amLower,amUpper:a.amUpper,amAbbr:a.amAbbr,pmLower:a.pmLower,pmUpper:a.pmUpper,pmAbbr:a.pmAbbr}}return a.name="DateFormatter",a.prototype.masks={"default":"ddd mmm dd yyyy HH:MM:ss",shortDate:"d/m/yy",USshortDate:"m/d/yy",mediumDate:"mmm d, yyyy",longDate:"mmmm d, yyyy",fullDate:"dddd, mmmm d, yyyy",shortTime:"h:MM TT",mediumTime:"h:MM:ss TT",longTime:"h:MM:ss TT Z",isoDate:"yyyy-mm-dd",isoTime:"HH:MM:ss",isoDateTime:"yyyy-mm-dd'T'HH:MM:ss",isoUtcDateTime:"UTC:yyyy-mm-dd'T'HH:MM:ss'Z'"},a.prototype.token=/U{1}|d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g,a.prototype.timezone=/\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g,a.prototype.timezoneClip=/[^-+\dA-Z]/g,a.prototype.pad=function(a,b){a=String(a),b=b||2;while(a.length<b)a="0"+a;return a},a.prototype.newZeroDate=function(){var a;return a=new Date,a.setDate(0),a.setMonth(0),a.setFullYear(0),a.setHours(0),a.setMinutes(0),a.setSeconds(0),a.setMilliseconds(0),a},a.prototype.unformat=function(a,b,c){var d,e,f,g,h,i,j,k,l,m,n,o;d=this,b=String(d.masks[b]||b||d.masks["default"]),e=this.newZeroDate(),e.setHours(0),h=b.split(/\W+/),f=a.split(/\W+/),i=0,l=c?"setUTC":"set",m=c?"getUTC":"get";for(g=n=0,o=h.length-1;0<=o?n<=o:n>=o;g=0<=o?++n:--n){k=h[g],j=f[g];switch(k){case"d":case"dd":e[l+"Date"](j);break;case"ddd":case"dddd":null;break;case"m":case"mm":e[l+"Month"](parseInt(j)-1);break;case"mmm":e[l+"Month"](d.i18n.monthNames.indexOf(j));break;case"mmmm":e[l+"Month"](d.i18n.monthNames.indexOf(j)-12);break;case"yyyy":e[l+"FullYear"](j);break;case"h":case"hh":e[l+"Hours"](j%12||12);break;case"H":case"HH":e[l+"Hours"](j);break;case"M":case"MM":e[l+"Minutes"](j);break;case"s":case"ss":e[l+"Seconds"](j);break;case"l":case"L":e[l+"Milliseconds"](j);break;case"t":d.i18n.pmAbbrLower===j&&e[l+"Hours"](e[m+"Hours"]()+12);break;case"tt":d.i18n.pmLower===j&&e[l+"Hours"](e[m+"Hours"]()+12);break;case"T":d.i18n.pmAbbrUpper===j&&e[l+"Hours"](e[m+"Hours"]()+12);break;case"TT":d.i18n.pmUpper===j&&e[l+"Hours"](e[m+"Hours"]()+12);break;case"Z":null;break;case"U":e[l+"Time"](j);break;default:i+=1}}return i>0||h.length!==f.length?!1:e},a.prototype.format=function(a,b,c){var d,e;return e=this,d=arguments,function(){var f,g,h,i,j,k,l,m,n,o,p,q;d.length===1&&Object.prototype.toString.call(a)==="[object String]"&&!/\d/.test(a)&&(b=a,a=void 0),a=a?new Date(a):new Date;if(isNaN(a))throw SyntaxError("invalid date");return b=String(e.masks[b]||b||e.masks["default"]),b.slice(0,4)==="UTC:"&&(b=b.slice(4),c=!0),q=c?"getUTC":"get",k=a[q+"Date"](),f=a[q+"Day"](),m=a[q+"Month"](),p=a[q+"FullYear"](),g=a[q+"Hours"](),i=a[q+"Minutes"](),o=a[q+"Seconds"](),h=a[q+"Milliseconds"](),n=c?0:a.getTimezoneOffset(),j=a.valueOf(),l={d:k,dd:e.pad(k),ddd:e.i18n.dayNames[f],dddd:e.i18n.dayNames[f+7],m:m+1,mm:e.pad(m+1),mmm:e.i18n.monthNames[m],mmmm:e.i18n.monthNames[m+12],yy:String(p).slice(2),yyyy:p,h:g%12||12,hh:e.pad(g%12||12),H:g,HH:e.pad(g),M:i,MM:e.pad(i),s:o,ss:e.pad(o),l:e.pad(h,3),L:e.pad(h>99?Math.round(h/10):h),t:g<12?e.i18n.amAbbrLower:e.i18n.pmAbbrLower,tt:g<12?e.i18n.amLower:e.i18n.pmLower,T:g<12?e.i18n.amAbbrUpper:e.i18n.pmAbbrUpper,TT:g<12?e.i18n.amUpper:e.i18n.pmUpper,Z:c?"UTC":(String(a).match(e.timezone)||[""]).pop().replace(e.timezoneClip,""),o:(n>0?"-":"+")+e.pad(Math.floor(Math.abs(n)/60)*100+Math.abs(n)%60,4),S:["th","st","nd","rd"][k%10>3?0:(k%100-k%10!==10)*k%10],U:j},b.replace(e.token,function(a){return a in l?l[a]:a.slice(1,a.length-1)})}()},a}(),chronos.PanelMonth=function(){function a(a){a.givenDate&&(this.givenDate=new Date(a.givenDate.valueOf())),a.choice&&(this.choice=new Date(a.choice)),a.maxDate&&(this.maxDate=new Date(a.maxDate.valueOf())),a.minDate&&(this.minDate=new Date(a.minDate.valueOf())),this.startDay=a.startDay,this.dayNamesAbbr=a.dayNamesAbbr,this.monthNames=a.monthNames,this.today=new Date,this.container={}}return a.name="PanelMonth",a.prototype.render=function(){return this.container=$("<div class='monthPanel' />"),this.container.append(this._getMonthHeader.call(this)),this.container.append(this._getMonthDays.call(this)),this.container},a.prototype._getMonthStart=function(){var a;a=new Date(this.givenDate),a.setDate(1);while(a.getDay()!==this.startDay)a.setDate(a.getDate()-1);return a},a.prototype._getMonthHeader=function(){var a,b,c,d,e,f,g;c=$('<div class="monthHeader" />');for(a=e=f=this.startDay,g=this.startDay+6;f<=g?e<=g:e>=g;a=f<=g?++e:--e)b="title day day"+a%7,d=this.dayNamesAbbr[a%7],c.append($("<div class='"+b+"'>"+d+"</div>")),a++;return c},a.prototype._isToday=function(a){return a.toDateString()===this.today.toDateString()},a.prototype._isChoice=function(a){return this.choice?a.toDateString()===this.choice.toDateString():!1},a.prototype._isMonth=function(a){return this.givenDate.getMonth()===a.getMonth()},a.prototype._isAvailable=function(a){return this.maxDate===void 0&&this.minDate===void 0?!0:this.maxDate&&this.minDate?a.valueOf()>=this.minDate.valueOf()&&a.valueOf()<=this.maxDate.valueOf():this.maxDate?a.valueOf()<=this.maxDate.valueOf():a.valueOf()>=this.minDate.valueOf()},a.prototype._clearTimePortion=function(a){return a.setHours(0),a.setMinutes(0),a.setSeconds(0),a.setMilliseconds(0),a},a.prototype._getMonthTitle=function(){return""+this.monthNames[this.givenDate.getMonth()+12]+" "+this.givenDate.getFullYear()},a.prototype._getMonthDays=function(){var a,b,c,d,e,f,g,h,i,j,k,l,m=this;l=[this.givenDate,this.choice,this.today,this.maxDate,this.minDate];for(i=0,k=l.length;i<k;i++)e=l[i],e&&this._clearTimePortion(e);h=this._getMonthStart(),d=$("<div class='monthBody'                   data-date='"+this.givenDate.valueOf()+"'                   data-date_title='"+this._getMonthTitle()+"' />");for(b=j=0;j<=41;b=++j)a=["day","day"+h.getDay()],this._isToday(h)&&a.push("today"),this._isChoice(h)&&a.push("selected"),this._isMonth(h)||a.push("otherMonth"),this._isAvailable(h)||a.push("unavailable"),b%7===0&&(g=Math.floor(b/7),f=$("<div class='week week"+g+"' />"),d.append(f)),a=a.join(" "),c=$("<div class='"+a+"' >"+h.getDate()+"</div>"),c.click({date:new Date(h.valueOf())},function(a){return m._onDaySelect(a,a.data.date)}),f.append(c),h.setDate(h.getDate()+1);return d},a.prototype._onDaySelect=function(a,b){var c;c=$(a.target);if(!c.hasClass("unavailable"))return this.container.trigger("daySelected",[b,a.target])},a}(),chronos.Animator=function(){function a(a,b){this.pickerManager=a,this.animating=!1,this.animations=b,this.$picker=void 0,this.$body=void 0,this.$next=void 0,this.$curr=void 0,this.$prev=void 0}return a.name="Animator",a.prototype.setPicker=function(a){return this.$picker=a,this._setElements()},a.prototype.previousMonth=function(){var a;return a=this.animations.previousMonth||this._animatePreviousMonth,this._animate(a,"previousMonthFinished")},a.prototype.nextMonth=function(){var a;return a=this.animations.nextMonth||this._animateNextMonth,this._animate(a,"nextMonthFinished")},a.prototype.close=function(){var a;return a=this.animations.close||this._animateClose,this._animate(a,"closed",!0)},a.prototype.open=function(){var a;return a=this.animations.open||this._animateOpen,this._animate(a,"opened")},a.prototype.animationFinished=function(){return this.animating=!1,this.currentEventName&&this.$picker.trigger(this.currentEventName),this.currentEventName=null},a.prototype._animate=function(a,b,c){c&&(this.animating=!1);if(!this.animating){this.animating=!0,this.currentEventName=b;if($.isFunction(a))return a.apply(this,[this.pickerManager])}},a.prototype._setElements=function(){return this.$body=this.$picker.find(".body"),this.$next=this.$body.find(".body_next"),this.$curr=this.$body.find(".body_curr"),this.$prev=this.$body.find(".body_prev")},a.prototype._animatePreviousMonth=function(a){var b,c=this;return a._renderTitle(this.$prev.find(".monthBody").attr("data-date_title")),b=this.$curr.outerWidth(),this.$curr.animate({left:"+="+b},500),this.$prev.animate({left:"+="+b},500,function(){return c._animatePreviousMonthCallback(a),c.animationFinished()})},a.prototype._animatePreviousMonthCallback=function(a){var b,c;return this.$next.remove(),this.$curr.removeClass("body_curr").addClass("body_next"),this.$prev.removeClass("body_prev").addClass("body_curr"),b=$("<div class='body_prev' />"),this.$body.prepend(b),this.$curr.removeAttr("style"),this.$prev.removeAttr("style"),this.$next.removeAttr("style"),c=new Date(parseInt(this.$prev.find(".monthBody").attr("data-date"))),a._buildMonth(a._changeMonthBy(c,-1),b),this._setElements()},a.prototype._animateNextMonth=function(a){var b,c=this;return a._renderTitle(this.$next.find(".monthBody").attr("data-date_title")),b=this.$curr.outerWidth(),this.$curr.animate({left:"-="+b},500),this.$next.animate({left:"-="+b},500,function(){return c._animateNextMonthCallback(a),c.animationFinished()})},a.prototype._animateNextMonthCallback=function(a){var b,c;return this.$prev.remove(),this.$curr.removeClass("body_curr").addClass("body_prev"),this.$next.removeClass("body_next").addClass("body_curr"),b=$("<div class='body_next' />"),this.$body.append(b),this.$curr.removeAttr("style"),this.$prev.removeAttr("style"),this.$next.removeAttr("style"),c=new Date(parseInt(this.$next.find(".monthBody").attr("data-date"))),a._buildMonth(a._changeMonthBy(c,1),b),this._setElements()},a.prototype._animateClose=function(a){var b=this;return this.$picker.animate({opacity:0},300,function(){return b.$picker.remove(),b.animationFinished()})},a.prototype._animateOpen=function(a){var b=this;return this.$picker.fadeIn("fast",function(){return b.animationFinished()})},a}(),function(a,b,c){return a.fn.chronos=function(b){var c,d,e;return c="chronos",d=Array.prototype.slice.call(arguments,1),this.each(function(){var e,f,g,h;h=this,f=a(this),e=a("#"+f.attr("id")+"_display"),g=a.data(h,c);if(typeof b=="string")return a.chronos[b]?g?e.length>0?(a.chronos.setCurrentElement.apply(a.chronos,[e[0]]),a.chronos[b].apply(a.chronos,d)):console.warn("chronos: Unknown datepicker.  Make sure id attribute is present"):console.warn("chronos: Unknown datepicker."):(console.error("chronos: Unknown command: "+b),null);if(!g)return a.chronos._attach(h,b||{}),a.data(h,c,!0)}),this.setDateRange=function(b){return e.apply(this),a.chronos.setDateRange(b),this},e=function(){var b;b=a("#"+this.attr("id")+"_display");if(b.length>0)return a.chronos.setCurrentElement(b[0])},this},a.chronos=new chronos.Chronos}(jQuery||Zepto,window,document);