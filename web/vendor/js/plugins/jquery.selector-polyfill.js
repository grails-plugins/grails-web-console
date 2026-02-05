/**
 * jQuery Selector Polyfill
 * Restores the deprecated .selector property that was removed in jQuery 3.0
 * Required for older plugins like jQuery Layout that rely on this property
 */
(function ($) {
    if (!$.fn.selector) {
        // Store the original init method
        var originalInit = $.fn.init;

        // Override init to track selector
        $.fn.init = function (selector, context, root) {
            var result = new originalInit(selector, context, root);

            // Set the selector property
            if (typeof selector === 'string') {
                result.selector = selector;
            } else if (selector && selector.selector) {
                result.selector = selector.selector;
            } else {
                result.selector = '';
            }

            return result;
        };

        // Copy prototype
        $.fn.init.prototype = $.fn;

        // Ensure selector is preserved through find()
        var originalFind = $.fn.find;
        $.fn.find = function (selector) {
            var result = originalFind.call(this, selector);
            result.selector = this.selector ? this.selector + ' ' + selector : selector;
            return result;
        };
    }
})(jQuery);
