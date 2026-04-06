#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QVariant>
#include <QDir>
#include <QUrl>
#include <QFileInfo>
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

    // Build dynamic playlist by scanning assets/media/ for audio files
    QStringList musicFiles;
    QStringList mediaDirCandidates = {
        QString(SOURCE_DIR) + "/assets/media",
        QCoreApplication::applicationDirPath() + "/assets/media",
        QCoreApplication::applicationDirPath() + "/../../../assets/media"
    };
    for (const QString &candidate : mediaDirCandidates) {
        QDir dir(candidate);
        if (dir.exists()) {
            QStringList filters = {"*.mp3", "*.wav", "*.ogg", "*.flac", "*.m4a"};
            const QFileInfoList entries = dir.entryInfoList(filters, QDir::Files, QDir::Name);
            for (const QFileInfo &fi : entries)
                musicFiles.append(QUrl::fromLocalFile(fi.absoluteFilePath()).toString());
            break;
        }
    }

    QQmlApplicationEngine engine;

    // Provide dashboardData to QML as a root object property
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    engine.setInitialProperties({
        {"dashboardData", QVariant::fromValue(static_cast<QObject *>(&dashboardData))},
        {"routeSimulator", QVariant::fromValue(static_cast<QObject *>(&routeSimulator))},
        {"musicFileList", QVariant::fromValue(musicFiles)}
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
