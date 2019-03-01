function gModal(options) {
    // size
    this.size = 'lg';
    this.id = 'gModal';
    if (typeof(options) !== 'undefined') {
        if(typeof(options.size) !== 'undefined') {
            this.size = options.size;
        }
    }
    
    // init
    this.modal = $('#'+this.id);
    if (this.modal.length === 0) {
        var html = '<div id="'+this.id+'" class="modal fade" tabindex="-1">' +
            '<div class="modal-dialog modal-'+this.size+'">' +
                '<div class="modal-content">' +
                '</div>' +
            '</div>' +
        '</div>';
        $('body').append(html);    
        this.modal = $('#'+this.id);
    }
    this.content = this.modal.find('.modal-content');
    
    var thisModal = this;
    
    // load url to modal
    this.load = function(url) {
        // loading effect
        if (thisModal.content.find('.modal-loading-overlay').length === 0) {
            thisModal.content.html('<div class="modal-loading-overlay"><i class="icon-spinner4 spinner mr-2"></i></div>');
        }
    
        this.modal.modal('show');
        
        $.ajax({
            url: url,
            method: 'GET',
            data: {
                layout: 'modal'
            }
        }).done(function(response) {
            thisModal.content.html(response);
            
            applyJs(thisModal.content);
        });
    };
}

$(document).ready(function() {
    $(document).on('click', '.modal-control', function(e) {
        e.preventDefault();
        
        var size = $(this).attr('modal-size');
        if (typeof(size) === 'undefined') {
            size = 'lg';
        }
        
        // show modal
        var m = new gModal({size: size});
        m.load($(this).attr('href'));
    });    
});