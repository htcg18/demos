this["JST"] = this["JST"] || {};

this["JST"]["file"] = function(obj){
var __p='';var print=function(){__p+=Array.prototype.join.call(arguments, '')};
with(obj||{}){
__p+='<div class="basename">'+
_.escape( basename )+
'</div><div class="stats">'+
_.escape( stats )+
'</div>\n';
}
return __p;
};

this["JST"]["header"] = function(obj){
var __p='';var print=function(){__p+=Array.prototype.join.call(arguments, '')};
with(obj||{}){
__p+='<span class="user">'+
_.escape( user )+
'@'+
_.escape( hostname )+
'</span>:<span class="directory">'+
_.escape( dirname )+
'</span>'+
_.escape( basename )+
'\n';
}
return __p;
};