pragma Singleton
import QtQuick

// One on-screen keyboard for the whole app. Any screen asks for text through
// open() and gets it back in a callback, without having to reach the sheet that
// draws it.
QtObject {
    property bool   active: false
    property string title: ""
    property string text: ""
    property bool   password: false

    property var doneCallback: null
    property var cancelCallback: null

    // options: { title, text, password }
    function open(options, done, cancelled) {
        title = options.title || ""
        text = options.text || ""
        password = !!options.password
        doneCallback = done || null
        cancelCallback = cancelled || null
        active = true
    }

    // Closes before calling back, so a callback that opens the keyboard again
    // (asking once more for a password, say) gets a fresh session.
    function accept(value) {
        const callback = doneCallback
        close()
        if (callback)
            callback(value)
    }

    function reject() {
        const callback = cancelCallback
        close()
        if (callback)
            callback()
    }

    function close() {
        doneCallback = null
        cancelCallback = null
        active = false
    }
}
