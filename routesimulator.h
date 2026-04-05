#ifndef ROUTESIMULATOR_H
#define ROUTESIMULATOR_H

#include <QObject>
#include <QTimer>
#include <QGeoCoordinate>
#include <QVector>
#include <QVariantList>
#include "dashboarddata.h"

class RouteSimulator : public QObject
{
  Q_OBJECT

public:
  explicit RouteSimulator(DashboardData *data, QObject *parent = nullptr);
  
  Q_INVOKABLE void startRide();
  Q_INVOKABLE void stopRide();
  Q_INVOKABLE void toggleRide();
  Q_INVOKABLE void setRoute(const QVariantList &coordinates);

private slots:
  void updatePosition();

private:
  void generateRoute();
  double calculateDistance(const QGeoCoordinate &from, const QGeoCoordinate &to);
  
  DashboardData *m_dashboardData;
  QTimer *m_timer;
  QVector<QGeoCoordinate> m_routePoints;
  int m_currentPointIndex;
  double m_totalDistance;
  double m_traveledDistance;
  QGeoCoordinate m_startCoord;
  QGeoCoordinate m_endCoord;
  double m_interpolationStep;
};

#endif // ROUTESIMULATOR_H
