(function() {
    // Monkey-patch the receiver for state synchronization
    if (typeof NanoStateManager !== 'undefined' && NanoStateManager.receiveUpdateData) {
        var originalReceive = NanoStateManager.receiveUpdateData;
        NanoStateManager.receiveUpdateData = function(jsonString) {
            originalReceive.apply(this, arguments);
            
            try {
                var updateData = jQuery.parseJSON(jsonString);
                if (updateData && updateData.data && updateData.data.active_notes) {
                    var activeNotes = updateData.data.active_notes;

                    // Clear previous active states
                    $('.key.active').removeClass('active');
                    // Apply new active states
                    for (var i = 0; i < activeNotes.length; i++) {
                        var keyEl = document.getElementById('note-' + activeNotes[i]);
                        if (keyEl) {
                            if (keyEl.className.indexOf('active') === -1) {
                                keyEl.className += ' active';
                            }
                        }
                    }
                }
            } catch (e) {}
        };
    }
})();
