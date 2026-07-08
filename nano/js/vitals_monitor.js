(function() {
    var ecgInstances = [];
    var ecgStates = {};

    function ECGSim(canvas, getRhythm, getBpm, getInfarct) {
        this.canvas = canvas;
        this.ctx = canvas.getContext('2d');
        this.getRhythm = getRhythm;
        this.getBpm = getBpm;
        this.getInfarct = getInfarct;
        this.id = canvas.id;
        
        this.width = canvas.width;
        this.height = canvas.height;
        
        // Restore state if it exists to keep animation continuous across NanoUI re-renders
        var saved = ecgStates[this.id];
        if (saved) {
            this.sweepX = saved.sweepX;
            this.history = saved.history;
            this.time = saved.time;
            this.beatTime = saved.beatTime;
            this.skippedBeat = saved.skippedBeat;
            this.beatCount = saved.beatCount;
        } else {
            this.sweepX = 0;
            this.history = [];
            for (var i = 0; i < this.width; i++) {
                this.history.push(0);
            }
            this.time = 0;
            this.beatTime = 0;
            this.skippedBeat = false;
            this.beatCount = 0;
        }
        
        this.lastFrameTime = Date.now();
    }

    ECGSim.prototype.drawGrid = function() {
        var ctx = this.ctx;
        ctx.fillStyle = '#081208';
        ctx.fillRect(0, 0, this.width, this.height);
        
        ctx.strokeStyle = '#153015';
        ctx.lineWidth = 1;
        
        // Vertical grid lines
        for (var x = 0; x < this.width; x += 20) {
            ctx.beginPath();
            ctx.moveTo(x, 0);
            ctx.lineTo(x, this.height);
            ctx.stroke();
        }
        
        // Horizontal grid lines
        for (var y = 0; y < this.height; y += 20) {
            ctx.beginPath();
            ctx.moveTo(0, y);
            ctx.lineTo(this.width, y);
            ctx.stroke();
        }
    };

    ECGSim.prototype.getWaveValue = function(rhythm, bpm, dt, infarct) {
        this.time += dt;
        var y = 0;
        var noise = (Math.random() - 0.5) * 0.05;

        if (rhythm === "Asystole" || !bpm) {
            return noise * 0.3;
        }

        if (rhythm === "Ventricular Fibrillation") {
            y = Math.sin(this.time * 35) * 0.25 + Math.sin(this.time * 63) * 0.15 + noise * 0.8;
            return y;
        }

        // Sinus rhythm beats (NSR, Tachy, Brady, PEA, Block)
        var beatPeriod = 60 / bpm;
        this.beatTime += dt;

        if (this.beatTime >= beatPeriod) {
            this.beatTime = 0;
            this.beatCount++;
            
            // Heart Block simulation: skip QRS complex every 3rd beat
            if (rhythm === "Heart Block") {
                this.skippedBeat = (this.beatCount % 3 === 0);
            } else {
                this.skippedBeat = false;
            }
        }

        var t = this.beatTime;

        // P-Q-R-S-T sequence timing (duration is ~0.5s)
        if (t < 0.08) {
            // P Wave (small bump)
            y = 0.12 * Math.sin(Math.PI * t / 0.08);
        } else if (t < 0.12) {
            // PR segment
            y = 0;
        } else if (t < 0.14) {
            // Q Wave (small dip)
            if (!this.skippedBeat) {
                y = -0.15 * Math.sin(Math.PI * (t - 0.12) / 0.02);
            }
        } else if (t < 0.17) {
            // R Wave (tall spike)
            if (!this.skippedBeat) {
                y = 1.0 * Math.sin(Math.PI * (t - 0.14) / 0.03);
            }
        } else if (t < 0.20) {
            // S Wave (sharp dip)
            if (!this.skippedBeat) {
                y = -0.25 * Math.sin(Math.PI * (t - 0.17) / 0.03);
            }
        } else if (t < 0.28) {
            // ST segment
            if (infarct > 0 && !this.skippedBeat) {
                var stElev = 0.45 * Math.min(infarct / 150, 1.2);
                y = stElev * Math.sin(Math.PI * (t - 0.20) / 0.23);
            } else {
                y = 0;
            }
        } else if (t < 0.43) {
            // T Wave (medium bump)
            if (infarct > 0 && !this.skippedBeat) {
                var stElev = 0.45 * Math.min(infarct / 150, 1.2);
                y = stElev * Math.sin(Math.PI * (t - 0.20) / 0.23) + 0.22 * Math.sin(Math.PI * (t - 0.28) / 0.15);
            } else {
                y = 0.22 * Math.sin(Math.PI * (t - 0.28) / 0.15);
            }
        } else {
            // Isoelectric line
            y = 0;
        }

        return y + noise * 0.2;
    };

    ECGSim.prototype.update = function() {
        var now = Date.now();
        var dt = (now - this.lastFrameTime) / 1000;
        this.lastFrameTime = now;
        
        // Prevent massive dt jumps from tab switching
        if (dt > 0.1) dt = 0.1;

        var rhythm = this.getRhythm();
        var bpm = this.getBpm();
        var infarct = this.getInfarct ? this.getInfarct() : 0;

        // Scroll or sweep speed
        var speed = 2; // Pixels per frame

        // Erase ahead of the next sweep position
        var gap = 15;
        for (var i = 0; i < gap; i++) {
            this.history[(this.sweepX + speed + i) % this.width] = null;
        }

        // Draw new points for all skipped steps (if speed > 1)
        var val = this.getWaveValue(rhythm, bpm, dt, infarct);
        for (var s = 0; s < speed; s++) {
            var idx = (this.sweepX + s) % this.width;
            this.history[idx] = val;
        }

        this.sweepX = (this.sweepX + speed) % this.width;

        // Save state to keep it persistent across NanoUI DOM rebuilds
        ecgStates[this.id] = {
            sweepX: this.sweepX,
            history: this.history,
            time: this.time,
            beatTime: this.beatTime,
            skippedBeat: this.skippedBeat,
            beatCount: this.beatCount
        };
    };

    ECGSim.prototype.draw = function() {
        this.drawGrid();
        
        var ctx = this.ctx;
        var midY = this.height / 2;
        var amp = this.height * 0.4; // scale factor
        
        ctx.strokeStyle = '#00ff66';
        ctx.lineWidth = 2.5;
        ctx.shadowBlur = 6;
        ctx.shadowColor = '#00ff66';
        
        ctx.beginPath();
        var started = false;
        
        for (var x = 0; x < this.width; x++) {
            var val = this.history[x];
            if (val === null) {
                started = false;
                continue;
            }
            
            var y = midY - (val * amp);
            if (!started) {
                ctx.moveTo(x, y);
                started = true;
            } else {
                ctx.lineTo(x, y);
            }
        }
        ctx.stroke();
        
        // Draw the pulse / sweep head point
        var currentVal = this.history[(this.sweepX - 2 + this.width) % this.width];
        if (currentVal !== null) {
            ctx.fillStyle = '#ffffff';
            ctx.shadowBlur = 12;
            ctx.shadowColor = '#ffffff';
            ctx.beginPath();
            ctx.arc((this.sweepX - 2 + this.width) % this.width, midY - (currentVal * amp), 3, 0, 2 * Math.PI);
            ctx.fill();
        }
    };

    function initECG() {
        var canvases = document.getElementsByClassName('ecg-canvas');
        if (canvases.length === 0) return;

        // Clear invalid / dead instances
        ecgInstances = ecgInstances.filter(function(inst) {
            return document.body.contains(inst.canvas);
        });

        for (var i = 0; i < canvases.length; i++) {
            var canvas = canvases[i];
            var found = false;
            for (var j = 0; j < ecgInstances.length; j++) {
                if (ecgInstances[j].canvas === canvas) {
                    found = true;
                    break;
                }
            }
            
            if (!found) {
                (function(c) {
                    var inst = new ECGSim(c, function() {
                        return c.getAttribute('data-rhythm') || 'Asystole';
                    }, function() {
                        return parseInt(c.getAttribute('data-bpm')) || 0;
                    }, function() {
                        return parseInt(c.getAttribute('data-infarct-progress')) || 0;
                    });
                    ecgInstances.push(inst);
                })(canvas);
            }
        }
    }

    // Main animation loop
    function animate() {
        for (var i = 0; i < ecgInstances.length; i++) {
            var inst = ecgInstances[i];
            if (document.body.contains(inst.canvas)) {
                inst.update();
                inst.draw();
            }
        }
        requestAnimationFrame(animate);
    }

    // Hook into receiveUpdateData to update attributes
    function hookNanoStateManager() {
        if (typeof NanoStateManager !== 'undefined' && NanoStateManager.receiveUpdateData) {
            if (NanoStateManager.receiveUpdateData.isHooked) return;
            
            var originalReceive = NanoStateManager.receiveUpdateData;
            NanoStateManager.receiveUpdateData = function(jsonString) {
                originalReceive.apply(this, arguments);
                
                try {
                    initECG();
                } catch (e) {}
            };
            NanoStateManager.receiveUpdateData.isHooked = true;
        }
    }

    // Periodically search for new canvases and make sure we are hooked
    setInterval(function() {
        hookNanoStateManager();
        initECG();
    }, 500);
    
    requestAnimationFrame(animate);
})();
