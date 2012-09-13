this['JST'] = this['JST'] || {};

this['JST']['item'] = function(obj){
var __p='';var print=function(){__p+=Array.prototype.join.call(arguments, '')};
with(obj||{}){
__p+='<a href="#list/'+
( name )+
'">'+
( name )+
'</a>\n';
}
return __p;
};