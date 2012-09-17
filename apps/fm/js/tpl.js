this["JST"] = this["JST"] || {};

this["JST"]["file"] = function(obj){
var __p='';var print=function(){__p+=Array.prototype.join.call(arguments, '')};
with(obj||{}){
__p+=''+
_.escape( basename )+
'\n';
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
'</span>:<span class="dir">'+
_.escape( pwd )+
'</span>\n';
}
return __p;
};