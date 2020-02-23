using Toybox.WatchUi;
using Toybox.Graphics;

class PlanLiteView extends WatchUi.DataField {
    hidden var value;
    hidden var label;

    hidden var app;

    hidden var active;

    hidden var selection;
    hidden var position;
    hidden var count;
    hidden var ticker;
    hidden var countDown;

    hidden enum {time, intensity, cadence, repeat}

    hidden var trainingSession = [[[180, 4, 80, 1], [30, 10, 100, 0], [30, 1, 80, 5], [240, 3, 80, 1], [30, 10, 100, 0], [30, 1, 80, 5], [180, 1, 80, 1], [0]],
    [[300, 5, 80, 1], [30, 10, 100, 0], [120, 1, 80, 8], [300, 1, 80, 1], [0]],
    [[240, 5, 70, 1], [300, 10, 100, 0], [15, 1, 60, 3], [15, 1, 60, 1], [0]],
    [[480, 5, 100, 1], [120, 8, 60, 0], [180, 1, 100, 6], [120, 1, 100, 1], [0]],
    [[300, 5, 80, 1], [1260, 7, 90, 1], [240, 1, 90, 1], [1440, 8, 90, 1], [60, 10, 120, 1], [300, 1, 90, 1], [0]]];

    hidden var labelShown = ["", "", "", ""];
    hidden var valueShown = [0, 0, 0, 0];
    hidden var paramQuantity;

    hidden var intensityShown;
    hidden var speedShown;
    hidden var powerShown;
    hidden var cadenceShown;

    hidden var maxSpeed;
    hidden var maxPower;

    function initialize() {
        DataField.initialize();

        value = 0.0f;

        app = Application.getApp();

        active = false;

        selection = app.getProperty("session");
        position = 0;
        count = 0;
        ticker = 0;
        countDown = trainingSession[selection][position][time];

        intensityShown = app.getProperty("intensityShown");
        speedShown = app.getProperty("speedShown");
        powerShown = app.getProperty("powerShown");
        cadenceShown = app.getProperty("cadenceShown");

        maxSpeed = app.getProperty("maxSpeed");
        maxPower = app.getProperty("maxPower");

        getShownParam();
    }

    function onLayout(dc) {
        var obscurityFlags = DataField.getObscurityFlags();

        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));
            var labelView = View.findDrawableById("label");
            labelView.locY = labelView.locY - 16;
            var valueView = View.findDrawableById("value");
            valueView.locY = valueView.locY + 7;
        }

        View.findDrawableById("label").setText(WatchUi.loadResource(Rez.Strings.Target));

        return true;
    }

    function startNextInterval() {
        if (trainingSession[selection][position][repeat] > 0) {
            if (count == trainingSession[selection][position][repeat]) {
                position++;
                count = 0;
            } else {
                for (; position - 1 >= 0 && trainingSession[selection][position - 1][repeat] == 0; position--) {
                }
                count++;
            }
        } else {
            position++;
        }

        countDown = trainingSession[selection][position][time];

        getShownParam();
    }

    function getShownParam() {
        paramQuantity = 0;
        if (intensityShown) {
            labelShown[paramQuantity] = WatchUi.loadResource(Rez.Strings.TargetIntensity);
            valueShown[paramQuantity] = trainingSession[selection][position][intensity];

            paramQuantity++;
        }
        if (speedShown) {
            labelShown[paramQuantity] = WatchUi.loadResource(Rez.Strings.TargetSpeed);
            valueShown[paramQuantity] = trainingSession[selection][position][intensity] * maxSpeed / 10;

            paramQuantity++;
        }
        if (powerShown) {
            labelShown[paramQuantity] = WatchUi.loadResource(Rez.Strings.TargetPower);
            valueShown[paramQuantity] = trainingSession[selection][position][intensity] * maxPower / 10;

            paramQuantity++;
        }
        if (cadenceShown) {
            labelShown[paramQuantity] = WatchUi.loadResource(Rez.Strings.TargetCadence);
            valueShown[paramQuantity] = trainingSession[selection][position][cadence];
            
            paramQuantity++;
        }
    }

    function compute(info) {
        ticker++;
        if (active) {
            countDown--;
        }

        if (countDown == 0 && trainingSession[selection][position][time] > 0) {
            startNextInterval();
        }

        label = labelShown[ticker % paramQuantity];
        value = valueShown[ticker % paramQuantity];
    }

    function onTimerStart() {
        active = true;
    }

    function onTimerStop() {
        active = false;
    }

    function onUpdate(dc) {
        View.findDrawableById("Background").setColor(getBackgroundColor());

        var Value = View.findDrawableById("value");
        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            Value.setColor(Graphics.COLOR_WHITE);
        } else {
            Value.setColor(Graphics.COLOR_BLACK);
        }
        Value.setText(value.format("%.2f"));

        View.findDrawableById("label").setText(label);

        View.onUpdate(dc);
    }
}
