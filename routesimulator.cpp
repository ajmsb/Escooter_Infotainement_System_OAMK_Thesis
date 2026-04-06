#include "routesimulator.h"
#include <QtMath>
#include <QDebug>
#include <QRandomGenerator>
#include <limits>

RouteSimulator::RouteSimulator(DashboardData *data, QObject *parent)
    : QObject(parent),
      m_dashboardData(data),
      m_timer(new QTimer(this)),
      m_currentPointIndex(0),
      m_totalDistance(0.0),
      m_traveledDistance(0.0),
      m_interpolationStep(0.0),
      m_routeSet(false)
{
  // Connect timer
  connect(m_timer, &QTimer::timeout, this, &RouteSimulator::updatePosition);
  m_timer->setInterval(100); // Update every 100ms
}

double RouteSimulator::calculateDistance(const QGeoCoordinate &from, const QGeoCoordinate &to)
{
  // Use Qt's built-in distance calculation (returns meters)
  return from.distanceTo(to);
}

void RouteSimulator::setRoute(const QVariantList &coordinates)
{
  if (coordinates.size() < 2) {
    qDebug() << "setRoute: need at least 2 coordinates, got" << coordinates.size();
    return;
  }

  m_routePoints.clear();

  // Parse QGeoCoordinate values from QVariantList
  QVector<QGeoCoordinate> waypoints;
  for (const QVariant &v : coordinates) {
    QGeoCoordinate coord = v.value<QGeoCoordinate>();
    if (coord.isValid()) {
      waypoints.append(coord);
    }
  }

  if (waypoints.size() < 2) {
    qDebug() << "setRoute: not enough valid coordinates";
    return;
  }

  // Interpolate between waypoints for smooth animation
  int pointsPerSegment = 8;
  for (int i = 0; i < waypoints.size() - 1; ++i) {
    QGeoCoordinate start = waypoints[i];
    QGeoCoordinate end = waypoints[i + 1];
    for (int j = 0; j < pointsPerSegment; ++j) {
      double t = static_cast<double>(j) / pointsPerSegment;
      double lat = start.latitude() + t * (end.latitude() - start.latitude());
      double lon = start.longitude() + t * (end.longitude() - start.longitude());
      m_routePoints.append(QGeoCoordinate(lat, lon));
    }
  }
  m_routePoints.append(waypoints.last());

  // Update start/end coords
  m_startCoord = waypoints.first();
  m_endCoord = waypoints.last();

  // Recalculate total distance
  m_totalDistance = 0.0;
  for (int i = 0; i < m_routePoints.size() - 1; ++i) {
    m_totalDistance += calculateDistance(m_routePoints[i], m_routePoints[i + 1]);
  }

  m_dashboardData->setTotalDistance(m_totalDistance / 1000.0);
  m_currentPointIndex = 0;
  m_routeSet = true;

  // Set initial position to start of route
  m_dashboardData->setLatitude(m_startCoord.latitude());
  m_dashboardData->setLongitude(m_startCoord.longitude());

  qDebug() << "Route set from QML with" << waypoints.size() << "waypoints,"
           << m_routePoints.size() << "interpolated points,"
           << m_totalDistance << "meters total";
}

void RouteSimulator::startRide()
{
  if (!m_routeSet || m_routePoints.isEmpty()) {
    qDebug() << "Cannot start ride: no route set. Call setRoute() first.";
    return;
  }

  if (!m_dashboardData->isRiding())
  {
    m_dashboardData->setIsRiding(true);
    
    // If this is a fresh start (no progress yet), find nearest route point
    if (m_currentPointIndex == 0 && m_traveledDistance < 0.001) {
      m_traveledDistance = 0.0;
      m_dashboardData->setDistance(0.0);
      
      QGeoCoordinate currentPos(m_dashboardData->latitude(), m_dashboardData->longitude());
      int nearestIndex = 0;
      double minDist = std::numeric_limits<double>::max();
      for (int i = 0; i < m_routePoints.size(); ++i) {
        double dist = currentPos.distanceTo(m_routePoints[i]);
        if (dist < minDist) {
          minDist = dist;
          nearestIndex = i;
        }
      }
      m_currentPointIndex = nearestIndex;
      m_interpolationStep = 0.0;
      qDebug() << "Starting fresh ride from nearest route point index:" << nearestIndex
               << "at" << m_routePoints[nearestIndex].latitude() << m_routePoints[nearestIndex].longitude();
    } else {
      qDebug() << "Resuming ride from point index:" << m_currentPointIndex
               << "traveled:" << m_traveledDistance << "meters";
    }
    
    m_timer->start();
    qDebug() << "Ride started";
  }
}

void RouteSimulator::stopRide()
{
  if (m_dashboardData->isRiding())
  {
    m_dashboardData->setIsRiding(false);
    m_dashboardData->setSpeed(0);
    m_timer->stop();
    qDebug() << "Ride stopped at" << m_traveledDistance << "meters"
             << "(point" << m_currentPointIndex << "/" << m_routePoints.size() << ")";
  }
}

void RouteSimulator::toggleRide()
{
  if (m_dashboardData->isRiding())
  {
    stopRide();
  }
  else
  {
    startRide();
  }
}

void RouteSimulator::updatePosition()
{
  if (!m_dashboardData->isRiding() || m_currentPointIndex >= m_routePoints.size() - 1)
  {
    // End of route reached
    if (m_currentPointIndex >= m_routePoints.size() - 1)
    {
      qDebug() << "Destination reached!";
      m_dashboardData->setSpeed(0);
      m_dashboardData->setDistance(m_totalDistance / 1000.0);
      stopRide();
      
      // Reset for a completely new ride next time
      m_currentPointIndex = 0;
      m_traveledDistance = 0.0;
      m_interpolationStep = 0.0;
      m_dashboardData->setDistance(0.0);
    }
    return;
  }
  
  // E-scooter max speed: 25 km/h = 6.944 m/s
  double timerIntervalSec = m_timer->interval() / 1000.0;
  double maxSpeed_ms = 20.0 * 1000.0 / 3600.0; // 6.944 m/s
  double maxDistPerTick = maxSpeed_ms * timerIntervalSec;
  double remaining = maxDistPerTick;
  double totalMoved = 0.0;
  
  // Walk along route points, consuming up to maxDistPerTick
  while (remaining > 0.0 && m_currentPointIndex < m_routePoints.size() - 1)
  {
    QGeoCoordinate from = m_routePoints[m_currentPointIndex];
    QGeoCoordinate to   = m_routePoints[m_currentPointIndex + 1];
    double segmentLen = from.distanceTo(to);
    
    if (segmentLen < 0.001) {
      // Skip zero-length segments
      m_currentPointIndex++;
      m_interpolationStep = 0.0;
      continue;
    }
    
    double alreadyTraveled = m_interpolationStep * segmentLen;
    double leftInSegment = segmentLen - alreadyTraveled;
    
    if (remaining < leftInSegment) {
      // Stay within this segment
      m_interpolationStep += remaining / segmentLen;
      totalMoved += remaining;
      remaining = 0.0;
    } else {
      // Consume rest of segment, move to next
      totalMoved += leftInSegment;
      remaining -= leftInSegment;
      m_currentPointIndex++;
      m_interpolationStep = 0.0;
    }
  }
  
  m_traveledDistance += totalMoved;
  
  // Calculate real speed from actual distance moved this tick (capped by design)
  double speed_kmh = (totalMoved / timerIntervalSec) * 3.6;
  
  // Interpolate exact position within current segment
  if (m_currentPointIndex < m_routePoints.size() - 1) {
    QGeoCoordinate from = m_routePoints[m_currentPointIndex];
    QGeoCoordinate to   = m_routePoints[m_currentPointIndex + 1];
    double t = m_interpolationStep;
    double lat = from.latitude()  + t * (to.latitude()  - from.latitude());
    double lon = from.longitude() + t * (to.longitude() - from.longitude());
    
    m_dashboardData->setLatitude(lat);
    m_dashboardData->setLongitude(lon);
    
    // Heading toward next point
    QGeoCoordinate currentPos(lat, lon);
    double bearing = currentPos.azimuthTo(to);
    m_dashboardData->setHeading(bearing);
  } else {
    // At the last point
    QGeoCoordinate lastPos = m_routePoints.last();
    m_dashboardData->setLatitude(lastPos.latitude());
    m_dashboardData->setLongitude(lastPos.longitude());
  }
  
  // Update dashboard data
  m_dashboardData->setDistance(m_traveledDistance / 1000.0);
  m_dashboardData->setSpeed(speed_kmh);
  
  // Update battery (decrease ~1% per 500 meters)
  int batteryPercent = 100 - static_cast<int>(m_traveledDistance / 500.0);
  batteryPercent = qMax(0, qMin(100, batteryPercent));
  m_dashboardData->setBatteryPercent(batteryPercent);
}
