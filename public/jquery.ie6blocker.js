var IE6 = (navigator.userAgent.indexOf("MSIE 6")>=0) ? true : false;
var IE7 = (navigator.userAgent.indexOf("MSIE 7")>=0) ? true : false;
var IE8 = (navigator.userAgent.indexOf("MSIE 8")>=0) ? true : false;

if(IE6 && !(IE7 || IE8)) {

	$(function(){
		
		$("<div>")
			.css({
				'position': 'absolute',
				'top': '0px',
				'left': '0px',
				backgroundColor: 'black',
				'opacity': '0.75',
				'width': '100%',
				'height': $(window).height(),
				zIndex: 5000
			})
			.appendTo("body");
			
		$("<div><img src='images/no-ie6.png' alt='' style='float: left;'/><p><br /><strong>Sorry! This website doesn't support Internet Explorer 6.</strong><br /><br />If you'd like to read our content please <a href='http://getfirefox.org'>upgrade your browser</a> or, if you're unable to do that because you're on a work computer, please email your IT department and ask them to upgrade. The more people that do this, the more likley they are to upgrade from an out-dated and non-secure browser!</p>")
			.css({
				backgroundColor: 'white',
				'top': '50%',
				'left': '50%',
				marginLeft: -210,
				marginTop: -100,
				width: 410,
				paddingRight: 10,
				height: 200,
				'position': 'absolute',
				zIndex: 6000
			})
			.appendTo("body");
	});		
}

// Quick Dirty hacks for IE7

if(IE7 && !(IE6 || IE8)) {
	$(function(){
	  $("#content").width(650).css({"margin-top":"-500px"});
	});
}
