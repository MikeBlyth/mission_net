// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// Toggle Menu Visibility
    $(function() {
      $(".show_menu").click(function() {
        if ($("#menu").is(':visible')) {
          $("#menu").hide('500');
          $('#content').css('left','0');            
          $('#show_hide').text('Show menu');
          }
        else {
          $("#menu").show('500');
          $('#content').css('left','156px');            
          $('#show_hide').text('Hide menu');
          }
        });
    });

// Hide any ActiveScaffold links we don't want

    $(function() {
        $('a#as_field_terms-new--link.new').hide();
    });

// Message page

    $(function() { 
        $("#record_sms_only").charCount({
            allowed: 150,	
            warning: 20,
            counterText: 'Characters left for one SMS message: '	
            });      
        $('<div><p class="msg-info for-sms">About <span id="msg-count">0</span> SMS messages will be sent</p></div>')
        .insertAfter('#record_to_groups');
     toggle_sms_display();  
     toggle_email_display();  
     $('#as_messages-create--form .submit').val('Send message');
     });

// Email Selection
    $('#record_send_email').live("change", function(){
    toggle_email_display()
    });

    function toggle_email_display() {
        if ($('#record_send_email').is(':checked')) {
   //       $('.for-email').css('display','inline')
          $('.for-email').show('blind', 500)
          }
        else {
          $('.for-email').effect('blind', 500)
//          $('.for-email').css('display','none')
        } 
    } ;

// SMS Selection
    $('#record_send_sms').live("change", function(){
        if ($(this).is(':checked')) {
          $('.counter').css('display','block')
          $('.for-sms').css('display','inline')
          }
        else {
          $('.counter').css('display','none')
          $('.for-sms').css('display','none')
        }  
      });

    function toggle_sms_display() {
        if ($('#record_send_sms').is(':checked')) {
          $('.counter').css('display','block')
          $('.for-sms').css('display','inline')
          }
        else {
          $('.counter').css('display','none')
          $('.for-sms').css('display','none')
        } 
    } ;

    $('#adv-toggle').live("click", function(){
var display = $('#options').css('display');
console.log(display);
      if (display == 'block') {
        $(this).text('Show advanced options')
        }
      else {
        $(this).text('Hide advanced options')
      }        
      $('#advanced #options').toggle('blind',{},'fast');
    });

    $('#as_messages-create--messages .submit').text('Send message')

    $('#record_to_groups').live("change", function(){
 //       alert("Selected groups = " + $(this).val());
        $.getJSON("../groups/member_count.js", 
            {to_groups: $(this).val()
            },
        function(data) {
 //       alert('Those groups include ' + data + ' members' );
        $('#msg-count').text(data);                
        }            
   
        ); 
      });
      

// ****************** DATEPICKER **************************************  
	$(function() {
    $(".datepicker").live("click", function(){
        $(this).datepicker();
      });
   });
  
// ****************** COUNTRY NAME **************************************  
    $(function() {
      $( ".country_name-input" ).live("click", function(){
        $(this).autocomplete({
          source: "autocomplete/country.js"
          });
      });
    });

    $(function() {
      $('#show_wife').live('click', function() {
        if ($(this).is(':checked')) {
          $('.wife_hidden').css('display','block')
          }
        else {
          $('.wife_hidden').css('display','none')
        }  
      });
    });
    
      
/*
 * 	Character Count Plugin - jQuery plugin
 * 	Dynamic character count for text areas and input fields
 *	written by Alen Grakalic	
 *	http://cssglobe.com/post/7161/jquery-plugin-simplest-twitterlike-dynamic-character-count-for-textareas
 *
 *	Copyright (c) 2009 Alen Grakalic (http://cssglobe.com)
 *	Dual licensed under the MIT (MIT-LICENSE.txt)
 *	and GPL (GPL-LICENSE.txt) licenses.
 *
 *	Built for jQuery library
 *	http://jquery.com
 *
 */
 
(function($) {

	$.fn.charCount = function(options){
	  
		// default configuration properties
		var defaults = {	
			allowed: 140,		
			warning: 25,
			css: 'counter',
			counterElement: 'span',
			cssWarning: 'warning',
			cssExceeded: 'exceeded',
			counterText: ''
		}; 
			
		var options = $.extend(defaults, options); 
		
		function calculate(obj){
			var count = $(obj).val().length;
			var available = options.allowed - count;
			if(available <= options.warning && available >= 0){
				$(obj).next().addClass(options.cssWarning);
			} else {
				$(obj).next().removeClass(options.cssWarning);
			}
			if(available < 0){
				$(obj).next().addClass(options.cssExceeded);
			} else {
				$(obj).next().removeClass(options.cssExceeded);
			}
			$(obj).next().html(options.counterText + available);
		};
				
		this.each(function() {  			
			$(this).after('<'+ options.counterElement +' class="' + options.css + '">'+ options.counterText +'</'+ options.counterElement +'>');
			calculate(this);
			$(this).keyup(function(){calculate(this)});
			$(this).change(function(){calculate(this)});
		});
	  
	};

})(jQuery);

/* Fix Annoying facebook behavior that appends #_=_ to URL */

(function($) {
    if (window.location.href.indexOf('#_=_') > 0) {
        window.location = window.location.href.replace(/#.*/, '');
    }
});
