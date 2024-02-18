import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class Rammstein_WatchfaceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new Rammstein_WatchfaceView() ] as Array<Views or InputDelegates>;
    }

    function onSettingsChanged() as Void {
        settingsChanged = true;
    }
}