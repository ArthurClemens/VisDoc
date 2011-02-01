(function($){$.fn.reverse=[].reverse;$.fn.shift=[].shift;$.fn.simpletreeview=function(options){var settings=$.extend({},{open:"&#9660;",close:"&#9658;",slide:false,speed:'normal',collapsed:false,collapse:null,expand:null},options);var $tree=$(this);this.expand=function(node){var $node=this.getNode(node);var $nodes=$node.parents('ul').reverse().andSelf();$nodes.shift();expandNode($nodes);var $siblings=$node.parents('ul').siblings();if($siblings){expandNode($siblings);}
var $children=$node.children();if($children){expandNode($children);}}
function expandNode($nodes){if($nodes.size()==0)return;var $node=$($nodes.get(0));$nodes.shift();toggle($node,"open",function(){expandNode($nodes);});}
this.collapse=function(node){collapseNode(this.getNode(node));}
function collapseNode($node){if($node.parent("li").size()==0)return;toggle($node,"close",function(){collapseNode($node.parent("li").parent("ul"));});}
function toggle($ul,method,callback){if(callback===undefined)callback=function(){};var $handle=$ul.parent("li").children("span.handle");if(method=="open"){$handle.html(settings.open);if(settings.slide){$ul.slideDown(settings.speed,callback);}
else{$ul.show();callback();}}
else if(method=="close"){$handle.html(settings.close);if(settings.slide){$ul.slideUp(settings.speed,callback);}
else{$ul.hide();callback();}}
else{$handle.html($ul.is(':hidden')?settings.open:settings.close);if(settings.slide){$ul.slideToggle(settings.speed,callback);}
else{$ul.toggle();callback();}}}
this.getNode=function(index){if(typeof index!="object"){selector=$.map(index.toString().split('.'),function(i){return"li:eq("+i+") > ul";}).join(" > ");index=$tree.find(">"+selector);}
return index;}
function setup($nodes){$nodes.each(function(){var $node=$(this);var $ul=$node.children("ul");var $childs=$ul.children("li");if($childs.size()>0){$node.prepend('<span class="handle">'+(settings.collapsed||$ul.is(":hidden")?settings.close:settings.open)+'</span>');if(settings.collapsed){$ul.hide();}
$node.children("span.handle").click(function(){toggle($ul);return false;});setup($childs);}});}
setup($tree.children("li"));if(settings.expand){this.expand(settings.expand);}
if(settings.collapse){this.collapse(settings.collapse);}
return this;}})(jQuery);