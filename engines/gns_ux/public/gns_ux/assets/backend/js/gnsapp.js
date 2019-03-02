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
    container.find('.select').select2();
    
    // Infinity search field of select
    container.find('select.select-not-search-field').select2({
        minimumResultsForSearch: Infinity
    });
    
    // Initialize
    container.find('.radio-button').uniform();
    
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
        
        $(this).select2({
            allowClear: true,
            ajax: {
              url: url,
              dataType: 'json'
              // Additional AJAX parameters go here; see the end of this chapter for the full code of this example
            }
        });
    });
}

$(document).ready(function() {
    
    // Apply js first load
    applyJs($('body'));
    
    // ------------------------------
    // Grap link with data-confirm attribute
    $(document).on('click', 'a[data-confirm]', function(e) {
        var link = $(this);
        
        if (!link.hasClass('confirmed')) {
            e.preventDefault(); // stop link click event
            e.stopImmediatePropagation(); // stop below events            
            
            var message = $(this).attr('data-confirm');
            
            // show modal confirmation
            var html = '<div id="confirmModal" class="modal fade" tabindex="-1">' +
                '<div class="modal-dialog modal-sm">' +
                    '<div class="modal-content">' +
                        '<div class="modal-header">' +
                            '<h5 class="modal-title">Are you sure?</h5>' +
                            '<button type="button" class="close" data-dismiss="modal">&times;</button>' +
                        '</div>' +
    
                        '<div class="modal-body">' +
                            '<p>' + message + '</p>' +
                        '</div>' +
    
                        '<div class="modal-footer">' +
                            '<button type="button" class="btn btn-link" data-dismiss="modal">Close</button>' +
                            '<button type="button" class="btn bg-primary data-confirm-ok">Okay</button>' +
                        '</div>' +
                    '</div>' +
                '</div>' +
            '</div>';
            $('body').append(html);
            var confirmModal = $('#confirmModal');
            
            confirmModal.modal('show');
            
            // data confirm ok
            var okButton = confirmModal.find('.data-confirm-ok');
            
            okButton.click(function() {
                link.addClass('confirmed');
                link.click();                
                confirmModal.modal('hide');
            });
        }
    });
    // Grap link with data-confirm
    // ------------------------------
    
    // ------------------------------
    // Grap link with a.ajax class
    $(document).on('click', 'a.ajax', function(e) {
        e.preventDefault(); // stop link click event
        e.stopImmediatePropagation(); // stop below events
        
        var link = $(this);
        var method = link.attr("data-method");
        var action = link.attr("href");
        
        $.ajax({
            url: action,
            method: method,
            data: {
                authenticity_token: $('meta[name="csrf-token"]').attr('content'),
                format: 'json',
            }
        }).done(function(response) {
            // check message
            if (typeof(response.message) !== 'undefined') {
                showNotification(response.status, response.message);
            }
            
            // Check if link from datalist
            if (link.closest('.datalist').length) {
                // refresh the datalist with id
                datalists[link.closest('.datalist').attr('data-id')].refresh();
            }
        });
    });
    // Grap link with a.ajax class
    // ------------------------------
    
    // ------------------------------
    // Grap link with data-method attribute
    $(document).on('click', 'a[data-method]', function(e) {
        e.preventDefault();
        
        var method = $(this).attr("data-method");
        var action = $(this).attr("href");
    
        var newForm = jQuery('<form>', {
            'action': action,
            'method': 'POST'
        });
        newForm.append(jQuery('<input>', {
            'name': 'authenticity_token',
            'value': $('meta[name="csrf-token"]').attr('content'),
            'type': 'hidden'
        }));
        newForm.append(jQuery('<input>', {
            'name': '_method',
            'value': method,
            'type': 'hidden'
        }));
        $(document.body).append(newForm);
        newForm.submit();
    });
    // Grap link with data-method
    // ------------------------------
});