import QtQuick

Canvas {
    id: root
    property color ink: "#ff566d"
    property real traced: 1
    property bool ward: false
    onInkChanged: requestPaint()
    onTracedChanged: requestPaint()
    onWardChanged: requestPaint()
    onPaint: {
        const c = getContext("2d");
        c.reset();
        c.translate(width / 2, height / 2);
        c.scale(width / 240, height / 240);
        c.strokeStyle = ink;
        c.lineWidth = 2.3;
        c.lineCap = "round";
        c.lineJoin = "round";
        c.shadowColor = ink;
        c.shadowBlur = 12;
        if (!ward) {
            c.lineWidth = 3.2;
            c.shadowBlur = 5;
            c.beginPath();
            c.arc(0, 0, 78, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * traced);
            c.stroke();
            c.globalAlpha = Math.min(1, traced * 2);
            c.beginPath();
            c.moveTo(-37, -42); c.lineTo(13, -42);
            c.moveTo(-13, -42); c.lineTo(-12, 0); c.lineTo(28, -34);
            c.lineTo(28, 42); c.lineTo(-22, 44);
            c.moveTo(-24, -88); c.lineTo(0, -110); c.lineTo(24, -88); c.closePath();
            c.moveTo(-92, -80); c.lineTo(-79, -68); c.lineTo(-104, -70); c.lineTo(-87, -52);
            c.moveTo(72, -69); c.lineTo(86, -80); c.lineTo(86, -55); c.lineTo(98, -65);
            c.moveTo(86, 44);
            c.bezierCurveTo(65, 63, 85, 65, 96, 53);
            c.bezierCurveTo(116, 34, 123, 59, 105, 59);
            c.bezierCurveTo(99, 59, 96, 55, 94, 51);
            c.moveTo(28, 93); c.lineTo(44, 88); c.lineTo(33, 108); c.lineTo(50, 101);
            c.moveTo(-55, 86);
            c.bezierCurveTo(-43, 82, -36, 94, -46, 97);
            c.bezierCurveTo(-28, 104, -32, 117, -49, 110);
            c.moveTo(-94, 58);
            c.bezierCurveTo(-117, 60, -106, 39, -97, 48);
            c.bezierCurveTo(-87, 59, -101, 68, -113, 71);
            c.stroke();
            return;
        }
        c.beginPath();
        c.arc(0, 0, 91, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * traced);
        c.stroke();
        c.shadowBlur = 3;
        c.globalAlpha = Math.min(1, traced * 2);
        c.beginPath();
        if (ward) {
            for (let i = 0; i <= 5; i++) {
                const angle = -Math.PI / 2 + i * Math.PI * 4 / 5;
                const x = Math.cos(angle) * 69;
                const y = Math.sin(angle) * 69;
                if (i === 0) c.moveTo(x, y); else c.lineTo(x, y);
            }
        }
        c.stroke();
        for (let i = 0; i < 12; i++) {
            const a = i * Math.PI / 6;
            c.save(); c.rotate(a);
            c.beginPath(); c.moveTo(0, -98); c.lineTo(0, -105);
            if (i % 3 === 0) { c.moveTo(-5, -102); c.lineTo(5, -102); }
            c.stroke(); c.restore();
        }
    }
}
