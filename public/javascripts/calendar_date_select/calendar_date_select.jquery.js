// CalendarDateSelect version 1.15 - a prototype based date picker BUT USING JQUERY
// Questions, comments, bugs? - see the project page: http://code.google.com/p/calendardateselect
if (typeof jQuery == 'undefined') alert("CalendarDateSelect Error: jQuery could not be found. Please make sure that your application's layout includes jquery.js (.g. <%= javascript_include_tag :defaults %>) *before* it includes calendar_date_select.js (.g. <%= calendar_date_select_includes %>).");

function $w(string) { return string.split(' '); }
var _translations = {
  "OK": "OK",
  "Now": "Now",
  "Today": "Today",
  "Clear": "Clear"
};

(function($) {
	nil = null;
	function $R(f,t) { a = []; for (i=f; i<=t; i++) { a.push(i); }; 
		a.start = this[0]; a.end = this[this.length-1];
		a.include = function(needle) { return $.inArray(needle, this) != -1; }
		a.select = function(x) { return $.grep(this, x) };
		return a;
	}
	function $A(a) { return a; }
	function $H(obj) { obj.get = function(key) { return this[key] }; return obj; }
	
	Date.one_day = 24*60*60*1000;
	Date.weekdays = $w("S M T W T F S");
	Date.first_day_of_week = 0;
	Date.months = $w("January February March April May June July August September October November December" );
	Date.padded2 = function(hour) { var padded2 = parseInt(hour, 10); if (hour < 10) padded2 = "0" + padded2; return padded2; }
	Date.prototype.getPaddedMinutes = function() { return Date.padded2(this.getMinutes()); }
	Date.prototype.getAMPMHour = function() { var hour = this.getHours(); return (hour == 0) ? 12 : (hour > 12 ? hour - 12 : hour ) }
	Date.prototype.getAMPM = function() { return (this.getHours() < 12) ? "AM" : "PM"; }
	Date.prototype.stripTime = function() { return new Date(this.getFullYear(), this.getMonth(), this.getDate());};
	Date.prototype.daysDistance = function(compare_date) { return Math.round((compare_date - this) / Date.one_day); };
	Date.prototype.toFormattedString = function(include_time){
		var hour, str;
		str = Date.months[this.getMonth()] + " " + this.getDate() + ", " + this.getFullYear();
		
		if (include_time) { hour = this.getHours(); str += " " + this.getAMPMHour() + ":" + this.getPaddedMinutes() + " " + this.getAMPM() }
		return str;
	}
	Date.parseFormattedString = function(string) { return new Date(string);}
	Math.floor_to_interval = function(n, i) { return Math.floor(n/i) * i;}
	window.f_height = function() { return $(window).height() };
	window.f_scrollTop = function() { return $(document).scrollTop() };
	if (!Event.KEY_ESC) Event.KEY_ESC = 27;
	
	CalendarDateSelect = function(target_element, options) {
		
		this.target_element = $(target_element); // make sure it's an element, not a string
		
		if (!this.target_element) { alert("Target element " + target_element + " not found!"); return false;}
		if (!this.target_element.is('input')) this.target_element = this.target_element.find("INPUT")
		
		this.target_element.calendar_date_select = this;
    	this.last_click_at = 0;
	    // initialize the date control
		this.options = $H($.extend({
				embedded: false,
				popup: nil,
				time: false,
				buttons: true,
				clear_button: true,
				year_range: 10,
				close_on_click: nil,
				minute_interval: 5,
				popup_by: this.target_element,
				month_year: "dropdowns",
				onchange: this.target_element.onchange,
				valid_date_check: nil
		}, (options||{})));
		this.use_time = this.options.get("time");
	    this.parseDate();
	    this.callback("before_show")
		this.initCalendarDiv();
		    if(!this.options.get("embedded")) {
		    	this.positionCalendarDiv()
		    		    // set the click handler to check if a user has clicked away from the document
		    cds = this;
		    $(document).bind('mousedown.calendar_date_select', function(e) {
			    if ( $(e.target).parents('.calendar_date_select').length == 0 ) cds.close(); 
		    	}).bind('keypress.calendar_date_select', function(e) { if (e.keyCode==Event.KEY_ESC) cds.close(); } );
		    }
	    this.callback("after_show")
	};
	
	CalendarDateSelect.instanceMethods = {
	  positionCalendarDiv: function() {
		gd = function() { return { width: this.outerWidth(), height: this.outerHeight() }; }
		co = function() { p = this.offset(); return [p.left, p.top] }
		this.calendar_div.getDimensions = gd;
		this.calendar_div.cumulativeOffset = co;
		var popup_by = this.options.get("popup_by");
		popup_by.getDimensions = gd;
		popup_by.cumulativeOffset = co;
		
	    var above = false;
	    var c_pos = this.calendar_div.cumulativeOffset(), c_left = c_pos[0], c_top = c_pos[1], c_dim = this.calendar_div.getDimensions(), c_height = c_dim.height, c_width = c_dim.width;
	    var w_top = window.f_scrollTop(), w_height = window.f_height();
	    var e_dim = popup_by.cumulativeOffset(), e_top = e_dim[1], e_left = e_dim[0], e_height = popup_by.getDimensions().height, e_bottom = e_top + e_height;
	    if ( (( e_bottom + c_height ) > (w_top + w_height)) && ( e_bottom - c_height > w_top )) above = true;
	    var left_px = e_left.toString() + "px", top_px = (above ? (e_top - c_height ) : ( e_top + e_height )).toString() + "px";
	    
		this.calendar_div.css({left: left_px, top: top_px, visibility: ""});
	    
	    // draw an iframe behind the calendar -- ugly hack to make IE 6 happy     TODO:
//	    if(navigator.appName=="Microsoft Internet Explorer") this.iframe = $(document.body).build("iframe", {src: "javascript:false", className: "ie6_blocker"}, { left: left_px, top: top_px, height: c_height.toString()+"px", width: c_width.toString()+"px", border: "0px"})
	  },
		initCalendarDiv: function() {
			
			if (this.options.get("embedded")) {
				var parent = this.target_element.parent();
				var style = {}
			} else {
				var parent = document.body
				var style = { position:"absolute", visibility: "hidden", left:0, top:0 }
			}
			this.calendar_div = $('<div>').addClass("calendar_date_select").css(style).appendTo($(parent)).show();
			
			var that = this;
			// create the divs
			$.each(["top", "header", "body", "buttons", "footer", "bottom"], function(){
				that[this+'_div'] = $('<div>').addClass('cds_'+this).css({clear:'left'}).appendTo(that.calendar_div);
			});
			
			this.initHeaderDiv();
			this.initButtonsDiv();
			this.initCalendarGrid();
			this.updateFooter("&#160;");
			
			this.refresh();
			this.setUseTime(this.use_time);
		},
		initHeaderDiv: function() {
			var header_div = this.header_div;
			this.close_button = $('<a>').attr({href:'#'}).html('x').click(function () { this.close(); return false; }).addClass('close').appendTo(header_div);
			cds = this;
			this.next_month_button = $('<a>').attr({href:'#'}).html('&gt;').click(function () { cds.navMonth(cds.date.getMonth() + 1); return false; }).addClass('next').appendTo(header_div);
			this.prev_month_button = $('<a>').attr({href:'#'}).html('&lt;').click(function () { cds.navMonth(cds.date.getMonth() - 1); return false; }).addClass('prev').appendTo(header_div);
			if (this.options.get("month_year")=="dropdowns") {
				this.month_select = $('<select>').addClass('month').change(function () { cds.navMonth(cds.month_select.val()) }).appendTo(header_div);
				options = '';
				$.each([0,1,2,3,4,5,6,7,8,9,10,11], function(){ options += '<option value="'+this+'">'+Date.months[this]+'</option>' });
				$(options).appendTo(this.month_select);
				this.year_select = $('<select>').addClass('year').change(function () { cds.navYear(cds.year_select.val()) }).appendTo(header_div);
				this.populateYearRange();
			} else {
				this.month_year_label = $("<span>").appendTo(header_div);
			}		
		},
		initCalendarGrid: function() {
			cds = this;
			var body_div = this.body_div;
			this.calendar_day_grid = [];
			days_table = $("<table>").attr({ cellPadding: "0px", cellSpacing: "0px"}).width("100%").appendTo(body_div);
			
		    // make the weekdays!
		    var weekdays_row = $('<tr>').appendTo($('<thead>').appendTo(days_table));
			$.each(Date.weekdays, function(k, v) { 
				$('<th>').html(v).appendTo(weekdays_row);
			});
			
			var days_tbody = $('<tbody>').appendTo(days_table);
		    // Make the days!
			var row_number=0
			for(cell_index=0; cell_index<42; cell_index++)
			{
				weekday=(cell_index+Date.first_day_of_week ) % 7;
				if ( cell_index % 7==0 ) days_row = $('<tr>').addClass('row_'+row_number++).appendTo(days_tbody);
				this.calendar_day_grid[cell_index] = $('<td>').addClass((weekday==0) || (weekday==6) ? "weekend" : "").css('cursor', 'pointer').appendTo(days_row
				).mouseover(function(){cds.dayHover(this)}).mouseout(function(){cds.dayHoverOut(this)}).click(function(){cds.updateSelectedDate(this, true);}).append($('<div>'));
			}
			
		},
		initButtonsDiv: function()
		  {
			var that = this;
		    var buttons_div = this.buttons_div;
		    if (this.options.get("time"))
		    {
		      var blank_time = $A(this.options.get("time")=="mixed" ? [" - ", ""] : false);
		      $('<span>').html("@").addClass("at_sign").appendTo(buttons_div);
		      
		      var t = new Date();
		      this.hour_select = $('<select>').appendTo(buttons_div).addClass("hour").change(function(){ that.updateSelectedDate( { hour: $(this).val() }); });
		      if (blank_time) $('<option>').val(blank_time[1]).html(blank_time[0]).appendTo(this.hour_select);
		      $.each( $R(0,23), function(x) {t.setHours(x); $('<option>').val(''+x).html(''+t.getAMPMHour()+ " " + t.getAMPM()).appendTo(cds.hour_select) } );
		      $("<span>").html(":").addClass("seperator").appendTo(buttons_div);
		      this.minute_select = $('<select>').appendTo(buttons_div).addClass("minute").change(function(){ that.updateSelectedDate( { minute: $(this).val() }); });
		      if (blank_time) $('<option>').val(blank_time[1]).html(blank_time[0]).appendTo(this.minute_select);
		      $.each( $R(0,59).select(function(x){return (x % that.options.get('minute_interval')==0)}).map(function(x){ return $A([ Date.padded2(x), x]); }),
	    		  	function() { $('<option>').val(this[1]).html(this[0]).appendTo(cds.minute_select) } );
		    } else if (! this.options.get("buttons")) buttons_div.remove();
		    
		    if (this.options.get("buttons")) {
		    	$('<span>').html("&#160;").appendTo(buttons_div);
		      if (this.options.get("time")=="mixed" || !this.options.get("time"))
		    	  b = $('<a>').html(_translations["Today"]).attr('href', "#").appendTo(buttons_div).click(function() {that.today(false); return false;});
		      
		      if (this.options.get("time")=="mixed") $("<span>").html("&#160;|&#160;").addClass("button_seperator").appendTo(buttons_div); 
		      
		      if (this.options.get("time")) b = $("<a>").html(_translations["Now"]).attr('href', "#").click(function(){ that.today(true); return false}).appendTo(buttons_div); 
		      
		      if (!this.options.get("embedded") && !this.closeOnClick())
		      {
		    	$("<span>").html("&#160;|&#160;").addClass("button_seperator");
		    	$("<a>").html(_translations["OK"]).html("#").addClass("button_seperator").click(function() {that.close(); return false;});
		      }
		      if (this.options.get('clear_button')) {
		    	$("<span>").html("&#160;|&#160;").addClass("button_seperator");
		    	$("<a>").html(_translations["Clear"]).attr('href', "#").click(function() {that.clearDate(); if (!that.options.get("embedded")) that.close(); return false;})
		      }
		    }
		  },
		refresh: function ()
		  {
		    this.refreshMonthYear();
		    this.refreshCalendarGrid();
		    
		    this.setSelectedClass();
		    this.updateFooter();
		  },
		  refreshCalendarGrid: function () {
		    this.beginning_date = new Date(this.date).stripTime();
		    this.beginning_date.setDate(1);
		    this.beginning_date.setHours(12); // Prevent daylight savings time boundaries from showing a duplicate day
		    var pre_days = this.beginning_date.getDay() // draw some days before the fact
		    if (pre_days < 3) pre_days += 7;
		    this.beginning_date.setDate(1 - pre_days + Date.first_day_of_week);
		    
		    var iterator = new Date(this.beginning_date);
		    
		    var today = new Date().stripTime();
		    var this_month = this.date.getMonth();
		    vdc = this.options.get("valid_date_check");
		    for (var cell_index = 0;cell_index<42; cell_index++)
		    {
		      day = iterator.getDate(); month = iterator.getMonth();
		      cell = this.calendar_day_grid[cell_index].empty();
		      div = $('<div>').html(day).appendTo(cell)
		      if (month!=this_month) div.className = "other";
		      xcell = cell.get(0);
		      xcell.day = day; xcell.month = month; xcell.year = iterator.getFullYear();
		      if (vdc) { if (vdc(iterator.stripTime())) cell.removeClass("disabled"); else cell.addClass("disabled") };
		      iterator.setDate( day + 1);
		    }
		    
		    if (this.today_cell) this.today_cell.removeClass("today");
		    
		    if ( $R( 0, 41 ).include(days_until = this.beginning_date.stripTime().daysDistance(today)) ) {
		      this.today_cell = this.calendar_day_grid[days_until].addClass("today");
		    }
		  },
		  refreshMonthYear: function() {
		    var m = this.date.getMonth();
		    var y = this.date.getFullYear();
		    // set the month
		    if (this.options.get("month_year") == "dropdowns") 
		    {
		      this.month_select.val(m);
		      
		      var e = this.year_select.element; 
		      if (this.flexibleYearRange() && (!(this.year_select.val(y)) || e.selectedIndex <= 1 || e.selectedIndex >= e.options.length - 2 )) this.populateYearRange();
		      
		      this.year_select.val(y);
		      
		    } else {
		      this.month_year_label.update( Date.months[m] + " " + y.toString()  );
		    }
		  },
		populateYearRange: function() {
			options = '';
			$.each(this.yearRange(), function() { options += '<option value="'+this+'">'+this+'</option>'});
			$(options).appendTo(this.year_select);
		},
		yearRange: function() {
		    if (!this.flexibleYearRange())
		      return $R(this.options.get("year_range")[0], this.options.get("year_range")[1]);
		      
		    var y = this.date.getFullYear();
		    return $R(y - this.options.get("year_range"), y + this.options.get("year_range"));
		  },
	  flexibleYearRange: function() { return (typeof(this.options.get("year_range")) == "number"); },
	  validYear: function(year) { if (this.flexibleYearRange()) { return true;} else { return $.inArray(year, this.yearRange()) != -1;}  },
	  dayHover: function(element) {
		  	element = $(element).addClass("hover").get(0);
		    hover_date = new Date(this.selected_date);
		    hover_date.setYear(element.year); hover_date.setMonth(element.month); hover_date.setDate(element.day);
		    this.updateFooter(hover_date.toFormattedString(this.use_time));
		  },
		  dayHoverOut: function(element) { $(element).removeClass("hover"); this.updateFooter(); },
		  clearSelectedClass: function() {if (this.selected_cell) this.selected_cell.removeClass("selected");},
		  setSelectedClass: function() {
		    if (!this.selection_made) return;
		    this.clearSelectedClass()
		    if ($R(0,42).include( days_until = this.beginning_date.stripTime().daysDistance(this.selected_date.stripTime()) )) {
		      this.selected_cell = this.calendar_day_grid[days_until].addClass("selected");
		    }
		  },
		  reparse: function() { this.parseDate(); this.refresh(); },
		  dateString: function() {
		    return (this.selection_made) ? this.selected_date.toFormattedString(this.use_time) : "&#160;";
		  },
		  parseDate: function()
		  {
		    var value = $.trim(this.target_element.val())
		    this.selection_made = (value != "");
		    this.date = value=="" ? NaN : Date.parseFormattedString(this.options.get("date") || value);
		    if (isNaN(this.date)) this.date = new Date();
		    if (!this.validYear(this.date.getFullYear())) this.date.setYear( (this.date.getFullYear() < this.yearRange().start) ? this.yearRange().start : this.yearRange().end);
		    this.selected_date = new Date(this.date);
		    this.use_time = /[0-9]:[0-9]{2}/.exec(value) ? true : false;
		    this.date.setDate(1);
		  },
		  updateFooter:function(text) { if (!text) text = this.dateString(); this.footer_div.empty().append($("<span>").html(text)); },
		  clearDate:function() {
		    if ((this.target_element.disabled || this.target_element.readOnly) && this.options.get("popup") != "force") return false;
		    var last_value = this.target_element.value;
		    this.target_element.value = "";
		    this.clearSelectedClass();
		    this.updateFooter('&#160;');
		    if (last_value!=this.target_element.value) this.callback("onchange");
		  },
		  updateSelectedDate:function(partsOrElement, via_click) {
		    var parts = $H(partsOrElement);
		    
		    if ((this.target_element.disabled || this.target_element.readOnly) && this.options.get("popup") != "force") return false;
		    if (parts.get("day")) {
		      var t_selected_date = this.selected_date, vdc = this.options.get("valid_date_check");
		      for (var x = 0; x<=3; x++) t_selected_date.setDate(parts.get("day"));
		      t_selected_date.setYear(parts.get("year"));
		      t_selected_date.setMonth(parts.get("month"));
		      
		      if (vdc && ! vdc(t_selected_date.stripTime())) { return false; }
		      this.selected_date = t_selected_date;
		      this.selection_made = true;
		    }
		    
		    if (!isNaN(parts.get("hour"))) this.selected_date.setHours(parts.get("hour"));
		    if (!isNaN(parts.get("minute"))) this.selected_date.setMinutes( Math.floor_to_interval(parts.get("minute"), this.options.get("minute_interval")) );
		    if (parts.get("hour") === "" || parts.get("minute") === "") 
		      this.setUseTime(false);
		    else if (!isNaN(parts.get("hour")) || !isNaN(parts.get("minute")))
		      this.setUseTime(true);
		    
		    this.updateFooter();
		    this.setSelectedClass();
		    
		    if (this.selection_made) this.updateValue();
		    if (this.closeOnClick()) { this.close(); }
		    if (via_click && !this.options.get("embedded")) {
		      if ((new Date() - this.last_click_at) < 333) this.close();
		      this.last_click_at = new Date();
		    }
		  },
		  closeOnClick: function() {
		    if (this.options.get("embedded")) return false;
		    if (this.options.get("close_on_click")===nil )
		      return (this.options.get("time")) ? false : true
		    else
		      return (this.options.get("close_on_click"))
		  },
		  navMonth: function(month) { (target_date = new Date(this.date)).setMonth(month); return (this.navTo(target_date)); },
		  navYear: function(year) { (target_date = new Date(this.date)).setYear(year); return (this.navTo(target_date)); },
		  navTo: function(date) {
		    if (!this.validYear(date.getFullYear())) return false;
		    this.date = date;
		    this.date.setDate(1);
		    this.refresh();
		    this.callback("after_navigate", this.date);
		    return true;
		  },
		  setUseTime: function(turn_on) {
		    this.use_time = this.options.get("time") && (this.options.get("time")=="mixed" ? turn_on : true) // force use_time to true if time==true && time!="mixed"
		    if (this.use_time && this.selected_date) { // only set hour/minute if a date is already selected
		      var minute = Math.floor_to_interval(this.selected_date.getMinutes(), this.options.get("minute_interval"));
		      var hour = this.selected_date.getHours();
		      
		      this.hour_select.val(hour);
		      this.minute_select.val(minute)
		    } else if (this.options.get("time")=="mixed") {
		      this.hour_select.val(""); this.minute_select.val("");
		    }
		  },
		  updateValue: function() {
		    var last_value = this.target_element.val();
		    this.target_element.val(this.dateString());
		    if (last_value!=this.target_element.val()) this.callback("onchange");
		  },
		  today: function(now) {
		    var d = new Date(); this.date = new Date();
		    var o = $H({ day: d.getDate(), month: d.getMonth(), year: d.getFullYear(), hour: d.getHours(), minute: d.getMinutes()});
		    if ( ! now ) o = $.extend(o, {hour: "", minute:""}); 
		    this.updateSelectedDate(o, true);
		    this.refresh();
		  },
		  close: function() {
		    if (this.closed) return false;
		    this.callback("before_close");
		    this.target_element.calendar_date_select = nil;
		    $(document).unbind('mousedown.calendar_date_select').unbind('keypress.calendar_date_select');
		    this.calendar_div.remove(); this.closed = true;
		    if (this.iframe) this.iframe.remove();
		    if (this.target_element.type != "hidden" && ! this.target_element.disabled) this.target_element.focus();
		    this.callback("after_close");
		  },
		  callback: function(name, param) { if (this.options.get(name)) { this.options.get(name).apply(this.target_element, param); } }
	}
	
	$.extend(CalendarDateSelect.prototype, CalendarDateSelect.instanceMethods);
}(jQuery))