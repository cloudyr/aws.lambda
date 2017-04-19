exports.handler = function(event, context, callback) {
    callback(null,event.a+event.b);
};
