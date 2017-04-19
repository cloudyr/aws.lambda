exports.handler = function(event, context, callback) {
    context.succeed(context.getRemainingTimeInMillis());
};
