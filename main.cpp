#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QVariant>
#include "dashboarddata.h"
#include "datasimulator.h"
#include "routesimulator.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    // Create dashboard data object
    DashboardData dashboardData;

    // Create and start simulator
    DataSimulator simulator(&dashboardData);
    simulator.start();
    
    // Create route simulator for GPS tracking
    RouteSimulator routeSimulator(&dashboardData);

    QQmlApplicationEngine engine;

    // Provide dashboardData to QML as a root object property
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    engine.setInitialProperties({
        {"dashboardData", QVariant::fromValue(static_cast<QObject *>(&dashboardData))},
        {"routeSimulator", QVariant::fromValue(static_cast<QObject *>(&routeSimulator))}
    });
#else
    engine.rootContext()->setContextProperty("dashboardData", &dashboardData);
    engine.rootContext()->setContextProperty("routeSimulator", &routeSimulator);
#endif

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, &app, [url](QObject *obj, const QUrl &objUrl)
                     {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
