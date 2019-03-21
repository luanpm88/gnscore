function ajaxBox(obj, url, callback) {
    this.box = obj;
    this.url = url;
    var main = this;
    
    this.clear = function() {
        // Add loading icon spinner
        if (main.box.find('.datalist-loading-overlay').length === 0) {
            main.box.prepend('<div class="datalist-loading-overlay"><i class="icon-spinner4 spinner mr-2"></i></div>');
        }
    };
    
    this.load = function() {
        main.clear();
        $.ajax({
            url: main.url,
            method: 'GET'
        }).done(function(response) {
            main.box.html(response);
            
            // callback function
            if(typeof(callback) !== 'undefined') {
                callback(main.box);
            }
            
            // apply js
            applyJs(main.box);
        });
    };
}