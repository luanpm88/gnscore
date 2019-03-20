function showNotification(status, message) {
    switch(status) {
        case 'success':
            new PNotify({
                icon: 'icon-checkmark3',
                title: 'Success',
                text: message,
                type: 'success'
            });
            break;
        case 'notice':
            new PNotify({
                icon: 'icon-info22',
                title: 'Notice',
                text: message,
                type: 'info'
            });
            break;
        case 'warning':
            new PNotify({
                icon: 'icon-warning',
                title: 'Warning',
                text: message,
                type: 'warning'
            });
            break;
        case 'error':
            new PNotify({
                icon: 'icon-blocked',
                title: 'Error',
                text: message,
                type: 'error'
            });
            break;
        case 'info':
          // code block
          break;
        default:
          // code block
    }
}

function uniqueId() {
    return 'id-xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
}

function applyJs(container) {
    // Select initialization
    container.find('.select').each(function () {
        $(this).select2({
            dropdownParent: $(this).parent()
        });
    });
    
    container.find('.selectAllowClear').select2({
        allowClear: true,
        minimumResultsForSearch: Infinity
    });
    
    // Infinity search field of select
    container.find('.selectPrimary').select2({
        minimumResultsForSearch: Infinity
    });
    
    // Initialize
    container.find('.radio-button').uniform();
    
    // Initialize multiple switches /switchery
    var elems = Array.prototype.slice.call(document.querySelectorAll('.form-check-input-switchery'));
    elems.forEach(function(html) {
      var switchery = new Switchery(html);
    });
    
    // Initialize multiple switches /switch
    $('.form-check-input-switch').bootstrapSwitch();
    
    // Multi select initialization
    container.find('.multiselect').multiselect();
    
    // Single picker
    container.find('.daterange-single').daterangepicker({ 
        singleDatePicker: true,
        locale: {
            format: 'DD/MM/YYYY'
        }
    });
    
    // Datalist
    container.find('.datalist').datalist();
    
    // Select2 ajax
    container.find('.select-ajax').each(function() {
        var url = $(this).attr('data-url');
        
        var allow_clear = true;
        if (typeof($(this).attr('multiple')) !== 'undefined') {
            allow_clear = false;
        }
        
        $(this).select2({
            allowClear: allow_clear,
            dropdownParent: $(this).parent(),
            ajax: {
              url: url,
              dataType: 'json'
              // Additional AJAX parameters go here; see the end of this chapter for the full code of this example
            }
        });
    });
    
    // gLink
    new gLink(container.find('.g-link'));
}

$(document).ready(function() {    
    // Apply js first load
    applyJs($('body'));
});