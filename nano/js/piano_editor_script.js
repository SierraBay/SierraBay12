(function() {
    /**
     * NanoUI Update Interceptor
     * Prevents the Piano Editor's DOM from being wiped during server pings
     * and synchronizes the playback state in real-time.
     */
    if (typeof NanoStateManager !== 'undefined' && !window._PianoEditorInterrupted) {
        var originalUpdate = NanoStateManager.receiveUpdateData;
        NanoStateManager.receiveUpdateData = function(json) {
            try {
                var update = jQuery.parseJSON(json);
                if (update && update.data) {
                    var overlay = document.getElementById('save-overlay');
                    if (overlay) overlay.style.display = 'none';
                    
                    var editor = window.PianoEditorScriptInstance;
                    if (update.data.playback && editor) {
                        // Detect remote song changes (e.g. from an Import or Start New Song action)
                        // and trigger a local refresh of the note grid.
                        if (update.data.playback.song_version !== undefined && update.data.playback.song_version > editor.songVersion) {
                            if (update.data.chords) {
                                editor.loadFromSong(update.data.chords);
                                if (update.data.tempo) {
                                    editor.tempo = update.data.tempo;
                                    var bpmInp = document.getElementById('bpm-input');
                                    if (bpmInp) bpmInp.value = editor.tempo;
                                }
                                editor.songVersion = update.data.playback.song_version;
                            }
                        }

                        // State Synchronization: Ensure local playhead matches the server's authoritative clock.
                        if (!editor.playing && update.data.playback.playing) {
                            editor.playbackPos = update.data.playback.pos || 0; 
                        } else if (update.data.playback.playing && update.data.playback.pos !== undefined) {
                            var diff = editor.playbackPos - update.data.playback.pos;
                            if (Math.abs(diff) > 2.0) {
                                // Jump to server position if we've drifted significantly (e.g. lag)
                                editor.playbackPos = update.data.playback.pos; 
                            } else if (diff > 0.1) {
                                // Client-side JS timers tend to run slightly faster than the BYOND server tick.
                                // Gently slow down the local playhead to maintain smooth synchronization.
                                editor.playbackPos -= diff * 0.2;
                            }
                        } else if (!update.data.playback.playing && update.data.playback.pos !== undefined) {
                            // Hard-sync the position when playback reaches a complete stop.
                            editor.playbackPos = update.data.playback.pos;
                        }
                        
                        editor.playing = update.data.playback.playing;
                        
                        // Automatically return camera scroll to the start when playback and position reset.
                        if (!editor.playing && update.data.playback.pos === 0 && editor.playbackPos !== 0) {
                            var grid = document.getElementById('grid-container');
                            if (grid) grid.scrollLeft = 0;
                        }
                        
                        // Prevent NanoUI from re-rendering the entire template if the editor is active,
                        // unless a version mismatch was detected above.
                        if (editor.canvas && document.body.contains(editor.canvas) && update.data.playback.song_version <= editor.songVersion) {
                            return; 
                        }
                    }
                    if (update.data.chords) {
                        window.LatestPianoData = update.data;
                        originalUpdate.apply(this, arguments);
                    }
                }
            } catch (e) { originalUpdate.apply(this, arguments); }
        };
        window._PianoEditorInterrupted = true;
    }

    /**
     * PianoEditor Engine
     * Handles note manipulation, rendering, and song generation.
     */
    var PianoEditor = function() {
        this.notes = [];
        this.selectedNotes = []; 
        this.history = [];
        this.isDragging = false;
        this.isSelecting = false;
        this.isResizing = false;
        this.dragData = null;
        this.selectionRect = { x1: 0, y1: 0, x2: 0, y2: 0 };
        this.tempo = 120;
        this.container = document.querySelector('.piano-roll-container');
        this.canvas = document.getElementById('piano-roll-canvas');
        if (!this.canvas) return;
        this.ctx = this.canvas.getContext('2d');
        
        // Visual Constants: 1 cell = 1 Beat (Quarter Note)
        this.cellHeight = 20; 
        this.cellWidth = 40; 
        this.snap = 16;
        this.minNote = 21; this.maxNote = 108; // Standard 88-key piano range
        this.totalNotes = this.maxNote - this.minNote + 1;
        this.resizeEdgeWidth = 8;
        
        // Playback State
        this.playing = false;
        this.playbackPos = 0;
        this.lastFrameTime = 0;
        this.songVersion = 0; // Tracks if the song structure has been modified remotely
        this.init();
    };

    PianoEditor.prototype.pushHistory = function() {
        if (this.history.length > 50) this.history.shift();
        this.history.push(JSON.stringify(this.notes));
    };

    PianoEditor.prototype.undo = function() {
        if (this.history.length === 0) return;
        this.notes = JSON.parse(this.history.pop());
        this.selectedNotes = []; this.updateCanvasSize(); 
    };

    PianoEditor.prototype.init = function() {
        var self = this;
        var sidebar = document.getElementById('sidebar-content');
        if (!sidebar) return;
        var noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];
        
        // Build the piano keyboard labels
        while (sidebar.firstChild) sidebar.removeChild(sidebar.firstChild);
        for (var i = this.maxNote; i >= this.minNote; i--) {
            var div = document.createElement('div');
            var noteInOctave = i % 12;
            var isBlack = [1, 3, 6, 8, 10].indexOf(noteInOctave) !== -1;
            div.className = 'key ' + (isBlack ? 'black' : 'white');
            div.textContent = noteNames[noteInOctave] + Math.floor(i / 12);
            div.style.height = this.cellHeight + 'px';
            sidebar.appendChild(div);
        }
        
        this.updateCanvasSize();
        this.canvas.height = this.totalNotes * this.cellHeight;
        
        // Load initial song data from the page's data attributes or global state
        var data = null;
        if (window.LatestPianoData && window.LatestPianoData.chords) data = window.LatestPianoData;
        else if (typeof jQuery !== 'undefined') {
            var state = jQuery('body').data('initialData');
            if (state && state.data) data = state.data;
        }
        if (data && data.chords) {
            this.tempo = data.tempo || 120;
            var bpmInp = document.getElementById('bpm-input');
            if (bpmInp) bpmInp.value = this.tempo;
            this.loadFromSong(data.chords);
            if (data.playback && data.playback.song_version !== undefined) {
                this.songVersion = data.playback.song_version;
            }
        }

        // Input Listeners
        this.canvas.onmousedown = function(e) { self.onMouseDown(e); };
        window.onmousemove = function(e) { self.onMouseMove(e); };
        window.onmouseup = function(e) { self.onMouseUp(e); };
        document.getElementById('save-btn').onclick = function() { self.save(); };
        document.getElementById('export-btn').onclick = function() { self.export(); };
        document.getElementById('delete-btn').onclick = function() { self.deleteSelected(); };
        document.getElementById('close-export-btn').onclick = function() { document.getElementById('export-modal').style.display = 'none'; };
        document.getElementById('grid-snap').onchange = function(e) { self.snap = parseInt(e.target.value); };
        
        // Manual Tempo Adjustment
        var bpmInp = document.getElementById('bpm-input');
        if (bpmInp) {
            bpmInp.onchange = function(e) {
                var newBpm = parseFloat(e.target.value);
                if (isNaN(newBpm) || newBpm <= 0) { e.target.value = self.tempo; return; }
                self.tempo = newBpm;
            };
        }

        // Sidebar tracking during grid scroll
        var gridContainer = document.getElementById('grid-container');
        if (gridContainer) {
            gridContainer.onscroll = function() {
                var sb = document.getElementById('sidebar-content');
                if (sb) sb.style.marginTop = (-gridContainer.scrollTop) + 'px';
            };
        }

        // Keyboard Shortcuts
        window.onkeydown = function(e) {
            if (e.ctrlKey && e.keyCode === 90) { self.undo(); e.preventDefault(); return; }
            if (e.ctrlKey && e.keyCode === 83) { self.save(); e.preventDefault(); return; }
            if (e.keyCode === 46 || e.keyCode === 8) { 
                self.pushHistory(); self.deleteSelected();
                if (e.target === document.body) e.preventDefault();
            }
        };

        // Start High-Frequency Render Loop
        setInterval(function() { self.draw(); }, 50);
    };

    // Dynamically expand canvas width if notes exceed current bounds
    PianoEditor.prototype.updateCanvasSize = function() {
        var maxT = 200; 
        for(var i=0; i<this.notes.length; i++) {
            var nEnd = this.notes[i].time + this.notes[i].duration;
            if (nEnd > maxT) maxT = nEnd;
        }
        var targetWidth = (maxT + 16) * this.cellWidth;
        if (this.canvas.width !== targetWidth) {
            this.canvas.width = targetWidth;
            this.draw();
        }
    };

    PianoEditor.prototype.midiToNote = function(midiVal) {
        var noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];
        return noteNames[midiVal % 12] + Math.floor(midiVal / 12);
    };

    /**
     * Decodes the server-side text-based chord list into internal note objects.
     */
    PianoEditor.prototype.loadFromSong = function(chords) {
        var noteMap = {"c":0,"d":2,"e":4,"f":5,"g":7,"a":9,"b":11};
        var accidentalMap = {"#":1,"b":-1,"n":0,"s":1};
        var lastOctaves = {"c":3,"d":3,"e":3,"f":3,"g":3,"a":3,"b":3};
        var time = 0; this.notes = [];
        for (var i = 0; i < chords.length; i++) {
            var c = chords[i];
            var duration = 1 / (c.div || 1); 
            if (c.notes) {
                var uniqueNotes = {};
                for (var j = 0; j < c.notes.length; j++) {
                    var n = c.notes[j].toLowerCase();
                    var name = n.charAt(0);
                    var accidental = 0; var octIdx = 1;
                    if (["#","b","n","s"].indexOf(n.charAt(1)) !== -1) { accidental = accidentalMap[n.charAt(1)]; octIdx = 2; }
                    var octStr = n.substring(octIdx);
                    var octave = lastOctaves[name];
                    if (octStr && !isNaN(parseInt(octStr))) { octave = parseInt(octStr); lastOctaves[name] = octave; }
                    var pitch = (octave * 12) + (noteMap[name] || 0) + accidental;
                    if (pitch >= this.minNote && pitch <= this.maxNote) uniqueNotes[pitch] = true;
                }
                for (var pitch in uniqueNotes) { this.notes.push({pitch: parseInt(pitch), time: time, duration: duration}); }
            }
            time += duration;
        }
        this.updateCanvasSize(); 
    };

    PianoEditor.prototype.onMouseDown = function(e) {
        var rect = this.canvas.getBoundingClientRect();
        var x = e.clientX - rect.left; var y = e.clientY - rect.top;
        var pitch = this.maxNote - Math.floor(y / this.cellHeight);
        var time = x / this.cellWidth;
        var hit = this.getNoteAt(x, y);
        
        if (e.shiftKey) {
            // Box Selection
            this.isSelecting = true;
            var grid = document.getElementById('grid-container'); var gRect = grid.getBoundingClientRect();
            this.selectionRect.x1 = e.clientX - gRect.left + grid.scrollLeft;
            this.selectionRect.y1 = e.clientY - gRect.top + grid.scrollTop;
            this.selectedNotes = []; 
        } else if (hit) {
            // Note manipulation (Move or Resize)
            var alreadySelected = (this.selectedNotes.indexOf(hit.index) !== -1);
            if (!alreadySelected) { if (!e.ctrlKey) this.selectedNotes = [hit.index]; else this.selectedNotes.push(hit.index); }
            this.pushHistory();
            if (hit.onEdge) { this.isResizing = true; this.dragData = { pivotIndex: hit.index }; }
            else {
                this.isDragging = true;
                this.dragData = { startPitch: pitch, startTime: time,
                    offsets: this.selectedNotes.map(function(idx) { return { pitch: this.notes[idx].pitch - pitch, time: this.notes[idx].time - time }; }, this)
                };
            }
        } else {
            // Create New Note
            this.pushHistory();
            var snapDiv = this.snap / 4; 
            var snappedTime = Math.floor(time * snapDiv) / snapDiv;
            var defaultDur = 1 / (this.snap / 4);
            if (this.snap === 4) defaultDur = 1;
            this.notes.push({pitch: pitch, time: snappedTime, duration: defaultDur});
            this.selectedNotes = [this.notes.length - 1]; this.updateCanvasSize(); 
        }
    };

    PianoEditor.prototype.onMouseMove = function(e) {
        var rect = this.canvas.getBoundingClientRect();
        var x = e.clientX - rect.left; var y = e.clientY - rect.top;
        if (this.isDragging || this.isResizing || this.isSelecting) {
            var pitch = this.maxNote - Math.floor(y / this.cellHeight);
            var time = x / this.cellWidth;
            if (this.isResizing) {
                var pivot = this.notes[this.dragData.pivotIndex];
                var snapDiv = this.snap / 4;
                var newDuration = Math.max(1/snapDiv, Math.ceil((time - pivot.time) * snapDiv) / snapDiv);
                var delta = newDuration - pivot.duration;
                if (Math.abs(delta) > 0.001) {
                    for (var i = 0; i < this.selectedNotes.length; i++) {
                        var n = this.notes[this.selectedNotes[i]]; n.duration = Math.max(1/snapDiv, n.duration + delta);
                    }
                    this.updateCanvasSize();
                }
            } else if (this.isDragging) {
                var deltaP = pitch - this.dragData.startPitch;
                var deltaT = time - this.dragData.startTime;
                var snapDiv = this.snap / 4;
                deltaT = Math.floor(deltaT * snapDiv) / snapDiv;
                for (var i = 0; i < this.selectedNotes.length; i++) {
                    var idx = this.selectedNotes[i]; var sn = this.notes[idx];
                    sn.pitch = Math.max(this.minNote, Math.min(this.maxNote, this.dragData.startPitch + deltaP + this.dragData.offsets[i].pitch));
                    sn.time = Math.max(0, this.dragData.startTime + deltaT + this.dragData.offsets[i].time);
                }
                this.updateCanvasSize();
            } else if (this.isSelecting) {
                var grid = document.getElementById('grid-container'); var gRect = grid.getBoundingClientRect();
                this.selectionRect.x2 = e.clientX - gRect.left + grid.scrollLeft;
                this.selectionRect.y2 = e.clientY - gRect.top + grid.scrollTop;
                this.updateSelection();
            }
        } else {
            var hit = this.getNoteAt(x, y);
            if (hit && hit.onEdge) {
                this.canvas.style.cursor = 'ew-resize';
            } else if (hit) {
                this.canvas.style.cursor = 'pointer';
            } else {
                this.canvas.style.cursor = 'default';
            }
        }
    };

    PianoEditor.prototype.onMouseUp = function() {
        this.isDragging = false; this.isSelecting = false; this.isResizing = false;
        var box = document.getElementById('selection-box'); if (box) box.style.display = 'none';
        this.dragData = null;
    };

    PianoEditor.prototype.getNoteAt = function(x, y) {
        for (var i = this.notes.length - 1; i >= 0; i--) {
            var n = this.notes[i];
            var nx = n.time * this.cellWidth; var ny = (this.maxNote - n.pitch) * this.cellHeight;
            var nw = n.duration * this.cellWidth;
            if (x >= nx && x <= nx + nw && y >= ny && y <= ny + this.cellHeight) return { index: i, onEdge: (x >= nx + nw - this.resizeEdgeWidth) };
        }
        return null;
    };

    PianoEditor.prototype.updateSelection = function() {
        var box = document.getElementById('selection-box'); if (!box) return;
        var x = Math.min(this.selectionRect.x1, this.selectionRect.x2);
        var y = Math.min(this.selectionRect.y1, this.selectionRect.y2);
        var w = Math.abs(this.selectionRect.x1 - this.selectionRect.x2);
        var h = Math.abs(this.selectionRect.y1 - this.selectionRect.y2);
        box.style.left = x + 'px'; box.style.top = y + 'px'; box.style.width = w + 'px'; box.style.height = h + 'px'; box.style.display = 'block';
        this.selectedNotes = [];
        for (var i = 0; i < this.notes.length; i++) {
            var n = this.notes[i]; var nx = n.time * this.cellWidth; var ny = (this.maxNote - n.pitch) * this.cellHeight;
            if (nx >= x && nx <= x + w && ny >= y && ny <= y + h) this.selectedNotes.push(i);
        }
    };

    PianoEditor.prototype.deleteSelected = function() {
        if (this.selectedNotes.length === 0) return;
        this.notes = this.notes.filter(function(n, idx) { return this.selectedNotes.indexOf(idx) === -1; }, this);
        this.selectedNotes = []; 
    };

    /**
     * Primary Canvas Renderer
     */
    PianoEditor.prototype.draw = function() {
        var ctx = this.ctx; if (!ctx) return;
        var grid = document.getElementById('grid-container'); if (!grid) return;
        
        var now = performance.now();
        if (this.lastFrameTime === 0) this.lastFrameTime = now;
        var dt = (now - this.lastFrameTime) / 1000;
        this.lastFrameTime = now;
        
        if (this.playing) {
            this.playbackPos += dt * (this.tempo / 60);
        }

        var viewL = grid.scrollLeft; var viewR = viewL + grid.clientWidth;
        var viewT = grid.scrollTop; var viewB = viewT + grid.clientHeight;
        ctx.clearRect(viewL, viewT, grid.clientWidth, grid.clientHeight);
        
        // Draw Horizontal Grid Lines
        ctx.strokeStyle = '#333'; ctx.lineWidth = 1;
        for (var i = 0; i <= this.totalNotes; i++) {
            var y = i * this.cellHeight;
            if (y >= viewT && y <= viewB) { ctx.beginPath(); ctx.moveTo(viewL, y); ctx.lineTo(viewR, y); ctx.stroke(); }
        }
        
        // Draw Vertical Grid Lines (Beats and Subdivisions)
        for (var i = Math.floor(viewL / this.cellWidth); i <= Math.ceil(viewR / this.cellWidth); i++) {
            var x = i * this.cellWidth;
            ctx.strokeStyle = (i % 4 == 0) ? '#555' : '#333'; // Thicker lines for major measures
            ctx.beginPath(); ctx.moveTo(x, viewT); ctx.lineTo(x, viewB); ctx.stroke();
            
            ctx.strokeStyle = '#222';
            for (var sub=1; sub<4; sub++) {
                var sx = x + sub * (this.cellWidth / 4);
                if (sx >= viewL && sx <= viewR) {
                    ctx.beginPath(); ctx.moveTo(sx, viewT); ctx.lineTo(sx, viewB); ctx.stroke();
                }
            }
        }
        
        // Render Active Notes
        for (var i = 0; i < this.notes.length; i++) {
            var n = this.notes[i];
            var x = n.time * this.cellWidth; var w = n.duration * this.cellWidth;
            if (x + w < viewL || x > viewR) continue;
            var y = (this.maxNote - n.pitch) * this.cellHeight;
            if (y + this.cellHeight < viewT || y > viewB) continue;
            var isSelected = (this.selectedNotes.indexOf(i) !== -1);
            ctx.fillStyle = isSelected ? '#FFAA00' : '#00AAFF'; ctx.strokeStyle = '#fff';
            ctx.fillRect(x + 1, y + 1, w - 2, this.cellHeight - 2); ctx.strokeRect(x + 1, y + 1, w - 2, this.cellHeight - 2);
            if (!this.isDragging) { ctx.fillStyle = 'rgba(255,255,255,0.3)'; ctx.fillRect(x + w - 4, y + 1, 3, this.cellHeight - 2); }
        }

        // Render Playhead Tracking
        if (this.playing || this.playbackPos >= 0) {
            var phX = this.playbackPos * this.cellWidth;
            
            // Automatic Follow-Scroll logic
            if (this.playing) {
                var rightMargin = 80; 
                if (phX > (viewL + grid.clientWidth - rightMargin) || phX < viewL) {
                    grid.scrollLeft = Math.max(0, phX - (grid.clientWidth * 0.2));
                    viewL = grid.scrollLeft; 
                    viewR = viewL + grid.clientWidth;
                }
            }

            if (phX >= viewL && phX <= viewR) {
                ctx.strokeStyle = '#FF2A55';
                ctx.lineWidth = 2;
                ctx.beginPath(); ctx.moveTo(phX, viewT); ctx.lineTo(phX, viewB); ctx.stroke();
                
                ctx.fillStyle = '#FF2A55';
                ctx.beginPath();
                ctx.moveTo(phX - 6, viewT); ctx.lineTo(phX + 6, viewT); ctx.lineTo(phX, viewT + 8);
                ctx.fill();
                ctx.lineWidth = 1;
            }
        }
    };

    /**
     * Converts the current grid state into server-compatible song text.
     */
    PianoEditor.prototype.generateSongText = function() {
        var bpmInp = document.getElementById('bpm-input');
        var tempo = bpmInp ? bpmInp.value : this.tempo;
        var timePointsSet = {};
        for(var i=0; i<this.notes.length; i++) {
            var n = this.notes[i]; 
            timePointsSet[n.time.toFixed(3)] = 1; 
            timePointsSet[(n.time + n.duration).toFixed(3)] = 1;
        }
        var sortedTimes = Object.keys(timePointsSet).map(parseFloat).sort(function(a,b){return a-b;});
        
        var fullText = "BPM: " + tempo + "\n";
        var currentLine = "";
        
        for(var i=0; i<sortedTimes.length - 1; i++) {
            var start = sortedTimes[i]; var end = sortedTimes[i+1];
            var dur = end - start; if (dur < 0.001) continue;
            var activeNotes = []; var seen = {};
            for(var j=0; j<this.notes.length; j++) {
                var n = this.notes[j];
                if (start >= n.time - 0.005 && start < (n.time + n.duration - 0.005)) {
                    var noteStr = this.midiToNote(n.pitch);
                    if (!seen[noteStr]) { activeNotes.push(noteStr); seen[noteStr] = true; }
                }
            }
            activeNotes.sort();
            var currCh = activeNotes.join("-");
            var divisorText = "";
            var divisor = (1 / dur);
            
            if (Math.abs(divisor - 1) > 0.01) {
                divisorText = "/" + divisor.toFixed(2).replace(/\.00$/, "");
            }
            
            var sliceText = (currCh || "") + divisorText;
            var extraChar = currentLine === "" ? 0 : 1; 
            if (currentLine.length + sliceText.length + extraChar > 49) { 
                fullText += currentLine + "\n"; 
                currentLine = sliceText; 
            } else { 
                currentLine += (currentLine === "" ? "" : ",") + sliceText; 
            }
        }
        fullText += currentLine;
        return fullText;
    }

    /**
     * Fragmentation Save System: Sends the song text to the server in chunks
     * to avoid URL length limitations (typical in old SS13 engines).
     */
    PianoEditor.prototype.save = function() {
        var self = this;
        var ref = this.container.getAttribute('data-src'); if (!ref) return;
        var bpmInp = document.getElementById('bpm-input'); var tempoValue = bpmInp ? bpmInp.value : this.tempo;
        var fullText = this.generateSongText();
        var overlay = document.getElementById('save-overlay'); var progress = document.getElementById('save-progress');
        overlay.style.display = 'flex'; var chunkSize = 1800; var chunks = [];
        for (var i = 0; i < fullText.length; i += chunkSize) { chunks.push(fullText.substring(i, i + chunkSize)); }
        var sendChunk = function(idx) {
            if (idx >= chunks.length) {
                progress.textContent = "COMMITTING...";
                setTimeout(function() { window.location.href = "?src=" + ref + "&save_commit=1&tempo=" + tempoValue; }, 1000); 
                return;
            }
            progress.textContent = Math.round((idx / chunks.length) * 100) + "%";
            window.location.href = "?src=" + ref + "&save_chunk=1&idx=" + idx + "&total=" + chunks.length + "&data=" + encodeURIComponent(chunks[idx]);
            setTimeout(function() { sendChunk(idx + 1); }, 400); 
        };
        sendChunk(0);
    };

    PianoEditor.prototype.export = function() {
        var fullText = this.generateSongText();
        var modal = document.getElementById('export-modal');
        var textarea = document.getElementById('export-textarea');
        if (modal && textarea) {
            textarea.value = fullText;
            modal.style.display = 'flex';
            textarea.select();
        } else {
            window.prompt("Exported Song (Fallback):", fullText);
        }
    };

    /**
     * Initialization Monitor: Ensures the editor instance is recreated
     * if NanoUI re-injects the HTML into the window.
     */
    var initTimer = setInterval(function() {
        var canvas = document.getElementById('piano-roll-canvas');
        if (canvas) {
            if (window.PianoEditorScriptInstance && window.PianoEditorScriptInstance.canvas === canvas) return;
            window.PianoEditorScriptInstance = new PianoEditor();
        }
    }, 200);
})();
