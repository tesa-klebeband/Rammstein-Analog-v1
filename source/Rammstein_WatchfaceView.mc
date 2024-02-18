import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;
using Toybox.Time;
using Toybox.Time.Gregorian;


const NUM_DATAFIELDS = 2;

const logoResourcesRed = {
    208 => Rez.Drawables.Logo208,
    218 => Rez.Drawables.Logo218,        
    240 => Rez.Drawables.Logo240,
    260 => Rez.Drawables.Logo260,
    280 => Rez.Drawables.Logo280,
    360 => Rez.Drawables.Logo360,
    390 => Rez.Drawables.Logo390,
    416 => Rez.Drawables.Logo416,
    454 => Rez.Drawables.Logo454
};

const logoResourcesWhite = {
    208 => Rez.Drawables.Logo208w,
    218 => Rez.Drawables.Logo218w,        
    240 => Rez.Drawables.Logo240w,
    260 => Rez.Drawables.Logo260w,
    280 => Rez.Drawables.Logo280w,
    360 => Rez.Drawables.Logo360w,
    390 => Rez.Drawables.Logo390w,
    416 => Rez.Drawables.Logo416w,
    454 => Rez.Drawables.Logo454w
};

const colorResources = {
    0xFFFFFF => Graphics.COLOR_WHITE,
    0xFF0000 => Graphics.COLOR_RED,
    0x808080 => Graphics.COLOR_LT_GRAY
};

var logo;
var width;
var height;
var settingsChanged;
var logoColor;
var hourColor;
var minuteColor;

var dataFieldPosX;
var dataFieldPosY;
var dataFieldColor as Array<Number> = new [NUM_DATAFIELDS];
var dataField as Array<Number> = new [NUM_DATAFIELDS];
var hourHandRadius as Number = 0;
var minuteHandRadius as Number = 0;
var dataFieldFont = Graphics.FONT_SMALL;
var hourNumberFont = Graphics.FONT_TINY;
var hourNumberColor;

class Rammstein_WatchfaceView extends WatchUi.WatchFace {
    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        width = dc.getWidth();
        height = dc.getHeight();
    }

    function onShow() as Void {
        settingsChanged = true;
    }

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);
        if (settingsChanged) {
            settingsChanged = false;
            loadResources(dc);
        }
        
        dc.drawBitmap(width / 2 - logo.getWidth() / 2, height / 2 - logo.getHeight() / 2, logo);

        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

        for (var i = 0; i < NUM_DATAFIELDS; i++) {
            var dataFieldString = "";

            switch (dataField[i]) {
                case 0: {
                    dataFieldString = today.day.format("%02d") + "." + today.month.format("%02d") + ".";
                    break;
                }
                case 1: {
                    dataFieldString = ActivityMonitor.getInfo().steps.format("%d");
                    break;
                }
                case 2: {
                    var heartRate = Activity.getActivityInfo().currentHeartRate;
                    if (heartRate != null) {
                        dataFieldString = heartRate.format("%d");
                    } else {
                        dataFieldString = "--";
                    }
                    break;
                }
                case 3: {
                    dataFieldString = (System.getSystemStats().battery+.5).format("%d") + "%";
                }
            }

            dc.setColor(colorResources.get(dataFieldColor[i]), Graphics.COLOR_BLACK);
            dc.drawText(dataFieldPosX[i], dataFieldPosY[i], Graphics.FONT_SMALL, dataFieldString, Graphics.TEXT_JUSTIFY_CENTER);
        }

        drawHands(dc, today.hour, today.min);

        if (hourNumberColor != 0) {
            dc.setColor(colorResources.get(hourNumberColor), Graphics.COLOR_BLACK);
            drawHourNumbers(dc);
        }
    }

    function onHide() as Void {
        
    }

    function onExitSleep() as Void {
    }

    function onEnterSleep() as Void {
    }

    function loadResources(dc as Dc) as Void {
        logoColor = Application.Properties.getValue("LogoColor") as Number;
        hourColor = Application.Properties.getValue("HourColor") as Number;
        minuteColor = Application.Properties.getValue("MinuteColor") as Number;
        hourNumberColor = Application.Properties.getValue("HourNumsColor") as Number;
        dataFieldColor[0] = Application.Properties.getValue("BottomFieldColor") as Number;
        dataField[0] = Application.Properties.getValue("BottomField") as Number;
        dataFieldColor[1] = Application.Properties.getValue("TopFieldColor") as Number;
        dataField[1] = Application.Properties.getValue("TopField") as Number;

        var fontHeight = dc.getFontHeight(dataFieldFont);
        
        dataFieldPosX = [width / 2, width / 2];
        dataFieldPosY = [height * 0.83 - (fontHeight / 2), height * 0.17 - (fontHeight / 2)];

        if (logoColor == 0xFF0000) {
            logo = Toybox.WatchUi.loadResource(logoResourcesRed.get(height));
        } else {
            logo = Toybox.WatchUi.loadResource(logoResourcesWhite.get(height));
        }

        if (hourNumberColor == 0) {
            hourHandRadius = width * 0.3;
            minuteHandRadius = width * 0.45;
        } else {
            hourHandRadius = width * 0.25;
            minuteHandRadius = width * 0.4;
        }
    }

    function drawHands(dc, hour, minute) {
        var hourHandAngle = hour * 30 + minute * 0.5;
        var minuteHandAngle = minute * 6;
        
        var hourHandPoly1 = [
            [width / 2, height / 2],
            getPoint(hourHandAngle + 20, hourHandRadius * 0.3),
            getPoint(hourHandAngle, hourHandRadius),
            getPoint(hourHandAngle, hourHandRadius * 0.8),
            getPoint(hourHandAngle + 15, hourHandRadius * 0.3),
            getPoint(hourHandAngle, hourHandRadius * 0.15)
        ];
        var hourHandPoly2 = [
            [width / 2, height / 2],
            getPoint(hourHandAngle - 20, hourHandRadius * 0.3),
            getPoint(hourHandAngle, hourHandRadius),
            getPoint(hourHandAngle, hourHandRadius * 0.8),
            getPoint(hourHandAngle - 15, hourHandRadius * 0.3),
            getPoint(hourHandAngle, hourHandRadius * 0.15)
        ];

        var minuteHandPoly1 = [
            [width / 2, height / 2],
            getPoint(minuteHandAngle + 20, minuteHandRadius * 0.3),
            getPoint(minuteHandAngle, minuteHandRadius),
            getPoint(minuteHandAngle, minuteHandRadius * 0.8),
            getPoint(minuteHandAngle + 15, minuteHandRadius * 0.3),
            getPoint(minuteHandAngle, minuteHandRadius * 0.15)
        ];
        var minuteHandPoly2 = [
            [width / 2, height / 2],
            getPoint(minuteHandAngle - 20, minuteHandRadius * 0.3),
            getPoint(minuteHandAngle, minuteHandRadius),
            getPoint(minuteHandAngle, minuteHandRadius * 0.8),
            getPoint(minuteHandAngle - 15, minuteHandRadius * 0.3),
            getPoint(minuteHandAngle, minuteHandRadius * 0.15)
        ];
    
        dc.setColor(colorResources.get(hourColor), Graphics.COLOR_BLACK);
        dc.fillPolygon(hourHandPoly1);
        dc.fillPolygon(hourHandPoly2);

        dc.setColor(colorResources.get(minuteColor), Graphics.COLOR_BLACK);
        dc.fillPolygon(minuteHandPoly1);
        dc.fillPolygon(minuteHandPoly2);
    }

    function drawHourNumbers(dc) {
        var fontHeight = dc.getFontHeight(hourNumberFont);
        if (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND) {
            for (var i = 1; i <= 12; i++) {
                var angle = i * 30;
                var point = getPoint(angle, width * 0.45);
                dc.drawText(point[0], point[1] - fontHeight / 2, hourNumberFont, i.format("%d"), Graphics.TEXT_JUSTIFY_CENTER);
            }
        } else {
            dc.drawText(width / 2, height * 0.05 - fontHeight / 2, hourNumberFont, "12", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(width * 0.95, height / 2 - fontHeight / 2, hourNumberFont, "3", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(width / 2, height * 0.95 - fontHeight / 2, hourNumberFont, "6", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(width * 0.05, height / 2 - fontHeight / 2, hourNumberFont, "9", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(width * 0.95, height * 0.2 - fontHeight / 2, hourNumberFont, "2", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(width * 0.95, height * 0.8 - fontHeight / 2, hourNumberFont, "4", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(width * 0.05, height * 0.2 - fontHeight / 2, hourNumberFont, "10", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(width * 0.05, height * 0.8 - fontHeight / 2, hourNumberFont, "8", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function getPoint(angle, radius) as Array<Number> {
        angle -= 90;
        var angleInRadians = angle * (Math.PI / 180);
        var x = Math.round(width / 2 + radius * Math.cos(angleInRadians));
        var y = Math.round(height / 2 + radius * Math.sin(angleInRadians));
        return [x, y];
    }
}