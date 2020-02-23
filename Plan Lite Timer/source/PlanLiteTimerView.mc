using Toybox.WatchUi;

class PlanLiteTimerView extends WatchUi.SimpleDataField {
    hidden var app;

    hidden var active;

    hidden var selection;
    hidden var position;
    hidden var count;
    hidden var countDown;

    hidden enum {time, repeat}

    hidden var trainingSession = [[[180, 1], [30, 0], [30, 5], [240, 1], [30, 0], [30, 5], [180, 1], [0]],
    [[300, 1], [30, 0], [120, 8], [300, 1], [0]],
    [[240, 1], [300, 0], [15, 3], [15, 1], [0]],
    [[480, 1], [120, 0], [180, 6], [120, 1], [0]],
    [[300, 1], [1260, 1], [240, 1], [1440, 1], [60, 1], [300, 1], [0]]];

    function initialize() {
        SimpleDataField.initialize();
        label = WatchUi.loadResource(Rez.Strings.Label);

        app = Application.getApp();

        active = false;

        selection = app.getProperty("session");
        position = 0;
        count = 0;
        countDown = trainingSession[selection][position][time];
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
    }

    function compute(info) {
        if (active) {
            countDown--;
        }

        if (countDown == 0 && trainingSession[selection][position][time] > 0) {
            startNextInterval();
        }

        return countDown;
    }

    function onTimerStart() {
        active = true;
    }

    function onTimerStop() {
        active = false;
    }
}