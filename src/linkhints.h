#pragma once

#include <QObject>
#include <QStringList>
#include <QVariantList>

class QQuickItem;
class QQuickWindow;

// Vimium's link hints, for the f key: what in the window can be clicked, a
// label for each, and a click there as if by the mouse.
class LinkHints : public QObject {
    Q_OBJECT

public:
    using QObject::QObject;

    // Labels from the home row, all of one length, so none starts another.
    Q_INVOKABLE QStringList labels(int count) const;
    // What can be clicked and is on screen: buttons, fields, tap handlers
    // and mouse areas that show the pointing hand, as {item, x, y} with
    // where its visible part starts in the window. Popups are left out.
    Q_INVOKABLE QVariantList targets(QQuickWindow *window) const;
    // A field gets the cursor; anything else a left click in its middle.
    Q_INVOKABLE void click(QQuickItem *item) const;
};
