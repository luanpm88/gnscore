function applyJs(container) {
    // Select initialization
    container.find('.select').select2();
    
    // Multi select initialization
    container.find('.multiselect').multiselect();
}

$(document).ready(function() {
    
    // Apply js first load
    applyJs($('body'));
    
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