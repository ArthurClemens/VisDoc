
(function($) {

	var navigationElements=[];
	//var privateElements=[];
	//var typeInfoElements=[];
	var summariesElements=[];
	var sortSections=[];

	/* NAVIGATION */
	function toggleNavigation() {
		if ( $('body').hasClass('isShowingNavigation') ) {
			updateNavigation("hide");
		} else {
			updateNavigation("show");
		}
	};
	function showNavigation() {
		$('body').addClass('isShowingNavigation');
	};
	function hideNavigation() {
		$('body').removeClass('isShowingNavigation');
	};
	function updateNavigation(inState) {
		if (inState == "show") {
			showNavigation();
			$.cookie('isShowingNavigation', 'true', { expires: 365 });
		} else if (inState == "hide") {
			hideNavigation();
			$.cookie('isShowingNavigation', 'false', { expires: 365 });
		} else {
			if ($.cookie('isShowingNavigation') == 'false') {
				hideNavigation();
			} else {
				showNavigation();
			}
		}
	};
	/* SOURCE CODE */
	function updateSourceCode(inState) {
		if (inState == "show") {
			showSourceCode();
			$.cookie('isShowingSourceCode', 'true', { expires: 365 });
		} else if (inState == "hide") {
			hideSourceCode();
			$.cookie('isShowingSourceCode', 'false', { expires: 365 });
		} else {
			if ($.cookie('isShowingSourceCode') == 'true') {
				showSourceCode();
			} else {
				hideSourceCode();
			}
		}
	};
	function showSourceCode() {
		$('body').addClass('isShowingSourceCode');
	};
	function hideSourceCode() {
		$('body').removeClass('isShowingSourceCode');
	};
	/* PRIVATE */
	function updatePrivate(inState) {
		if (inState == "show") {
			showPrivate();
			$.cookie('isHidingPrivate', 'false', { expires: 365 });
		} else if (inState == "hide") {
			hidePrivate();
			$.cookie('isHidingPrivate', 'true', { expires: 365 });
		} else {
			if ($.cookie('isHidingPrivate') == 'true') {
				hidePrivate();
			} else {
				showPrivate();
			}
		}
	};
	function showPrivate() {
		$('body').removeClass('isHidingPrivate');
	};
	function hidePrivate() {
		$('body').addClass('isHidingPrivate');
	};
	/* TYPE INFO */
	function updateTypeInfo(inState) {
		if (inState == "show") {
			showTypeInfo();
			$.cookie('isHidingTypeInfo', 'false', { expires: 365 });
		} else if (inState == "hide") {
			hideTypeInfo();
			$.cookie('isHidingTypeInfo', 'true', { expires: 365 });
		} else {
			if ($.cookie('isHidingTypeInfo') == 'true') {
				hideTypeInfo();
			} else {
				showTypeInfo();
			}
		}
	};
	function showTypeInfo() {
		$('body').removeClass('isHidingTypeInfo');
	};
	function hideTypeInfo() {
		$('body').addClass('isHidingTypeInfo');
	};
	/* SUMMARIES */
	function updateSummaries(inState) {
		if (inState == "show") {
			showSummaries();
			$.cookie('isHidingSummaries', 'false', { expires: 365 });
		} else if (inState == "hide") {
			hideSummaries();
			$.cookie('isHidingSummaries', 'true', { expires: 365 });
		} else {
			if ($.cookie('isHidingSummaries') == 'true') {
				hideSummaries();
			} else {
				showSummaries();
			}
		}
	};
	function showSummaries() {
		$('body').removeClass('isHidingSummaries');
	};
	function hideSummaries() {
		$('body').addClass('isHidingSummaries');
	};

	/*
	// inMode: either 'alphabetically' or 'sourceorder'
	function updateSort(inMode) {
		if (inMode == "alphabetically") {
			sortMembers(inMode);
			$.cookie(SORT, 'true', { expires: 365 });
			return;
		} else if (inMode == "sourceorder") {
			sortMembers(inMode);
			$.cookie(SORT, 'false', { expires: 365 });
			return;		
		}
		if (!inMode) {
			var sortState = $.cookie(SORT);
			if (sortState == 'false') {
				sortMembers("sourceorder");
			} else {
				sortMembers("alphabetically");
			}
		}
	};
	// inMode: either 'alphabetically' or 'sourceorder'
	function sortMembers(inMode) {
		var i,ilen = sortSections.length;
		for (i=0; i<ilen; ++i) {
			var section = sortSections[i];
			var id = section.element.id;
			var elements = $('ul#' + id + ' li.sortli').remove().get();
			if (inMode == 'alphabetically') {
				elements.sort(compareAlphabetically);
			}
			if (inMode == 'sourceorder') {
				elements.sort(compareSourceOrder);
			}
			$(elements).appendTo('#' + id);
			
		}
	};
	function compareAlphabetically (a,b) {
		var memberNameA = a.innerText.toLowerCase().split(" ")[0];
		var memberNameB = b.innerText.toLowerCase().split(" ")[0];
		if (memberNameA < memberNameB) {
			return -1;
		}
		if (memberNameA > memberNameB) {
			return 1;
		}
		return 0;
	};
	function compareSourceOrder (a,b) {
		var re = new RegExp(/\blistnum([0-9]+)\b/);
		var memberNumA = parseInt(re.exec(a.className)[1]);
		var memberNumB = parseInt(re.exec(b.className)[1]);
		if (memberNumA < memberNumB) {
			return -1;
		}
		if (memberNumA > memberNumB) {
			return 1;
		}
		return 0;
	};
	*/

	var pageIdQuery;
	$(function() {
		$("#toggleTocButton").click(function() {
			toggleNavigation();
			return false;
		});
		$(".sourceCodeShow a").click(function() {
			updateSourceCode("show");
			return false;
		});
		$(".sourceCodeHide a").click(function() {
			updateSourceCode("hide");
			return false;
		});
		$(".privateShow a").click(function() {
			updatePrivate("show");
			return false;
		});
		$(".privateHide a").click(function() {
			updatePrivate("hide");
			return false;
		});
		$(".summariesHide a").click(function() {
			updateSummaries("hide");
			return false;
		});
		$(".summariesShow a").click(function() {
			updateSummaries("show");
			return false;
		});
		$(".typeInfoShow a").click(function() {
			updateTypeInfo("show");
			return false;
		});
		$(".typeInfoHide a").click(function() {
			updateTypeInfo("hide");
			return false;
		});
		/*
		$(".memberSummaryPart ul.sortable").each(function() {
			//add(SORT, this);
		});
		$("#twistySort_show a").click(function() {
			updateSort("sourceorder");
		});
		$("#twistySort_hide a").click(function() {
			updateSort("alphabetically");
		});
		*/
	});
	
	function initTreeMenu(inPageIdQuery) {
		$("ul#treemenu").simpletreeview({
			open: '<span class="closure"><a href="#">&#9660;</a></span>',
			close: '<span class="disclosure"><a href="#">&#9658;</a></span>',
			slide: false,
			collapsed: true,
			expand: $(inPageIdQuery)
		});
	};
	
	function highlightMenuItem(inPageIdQuery) {
		var $el = $(inPageIdQuery + " a").first();
		$el.attr('id', 'selected');
	}
	
	$(document).ready(function() {
		var pageId = $("body").attr("id").replace(/^page_/, '');
		var pageIdQuery = "#" + "menu_" + pageId;
		highlightMenuItem(pageIdQuery);
		initTreeMenu(pageIdQuery);
		updateNavigation();
		updatePrivate();
		updateTypeInfo();
		updateSummaries();
		updateSourceCode();
		//updateSort();
		SyntaxHighlighter.all();
	});

})(jQuery);



/* Define innerText for Mozilla based browsers */
/*
if((typeof HTMLElement != 'undefined') && (HTMLElement.prototype.__defineGetter__ != 'undefined'))   {
	HTMLElement.prototype.__defineGetter__("innerText", function () {
		var r = this.ownerDocument.createRange();       r.selectNodeContents(this);
		return r.toString();
	});
}
*/
