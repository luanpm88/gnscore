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
            // Check if link from datalist
            if (link.closest('.datalist').length) {
                new PNotify({
                    title: 'Success',
                    text: response.message,
                    icon: 'icon-checkmark3',
                    type: 'success'
                });
                
                // refresh all datalist
                if (datalists.length) {
                    datalists.forEach(function(datalist) {
                        datalist.refresh();
                    });
                }
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