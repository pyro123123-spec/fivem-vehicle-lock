// FiveM Vehicle Lock Script
// NUI Handler

const lockStatus = document.getElementById('lockStatus');
const statusText = document.getElementById('statusText');

let currentLockStatus = null;

// Lock Status anzeigen
function showLockStatus(isLocked) {
    lockStatus.classList.remove('hidden');
    
    if (isLocked) {
        lockStatus.classList.remove('unlocked');
        statusText.textContent = 'Auto abgeschlossen 🔒';
    } else {
        lockStatus.classList.add('unlocked');
        statusText.textContent = 'Auto entsperrt 🔓';
    }
    
    currentLockStatus = isLocked;
    
    // Nach 2 Sekunden ausblenden
    setTimeout(function() {
        lockStatus.classList.add('hidden');
    }, 2000);
}

// NUI Messages vom Client empfangen
window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.type === 'lockStatus') {
        showLockStatus(data.locked);
    }
});

console.log('%c[Vehicle Lock] NUI Script geladen!', 'color: #00cc00; font-weight: bold;');
