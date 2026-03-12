#include "routesimulator.h"
#include <QtMath>
#include <QDebug>
#include <QRandomGenerator>

RouteSimulator::RouteSimulator(DashboardData *data, QObject *parent)
    : QObject(parent),
      m_dashboardData(data),
      m_timer(new QTimer(this)),
      m_currentPointIndex(0),
      m_totalDistance(0.0),
      m_traveledDistance(0.0),
      m_interpolationStep(0.0)
{
  // Set start and end coordinates to match the real GPS route
  m_startCoord = QGeoCoordinate(65.012295, 25.470932);
  m_endCoord = QGeoCoordinate(65.026950, 25.470746);
  
  // Generate route points
  generateRoute();
  
  // Set initial position
  m_dashboardData->setLatitude(m_startCoord.latitude());
  m_dashboardData->setLongitude(m_startCoord.longitude());
  
  // Connect timer
  connect(m_timer, &QTimer::timeout, this, &RouteSimulator::updatePosition);
  m_timer->setInterval(100); // Update every 100ms
}

void RouteSimulator::generateRoute()
{
  m_routePoints.clear();
  
  // Define realistic waypoints that follow actual roads (matching QML path)
  QVector<QGeoCoordinate> roadWaypoints;
  
  // Real GPS waypoints following roads in Oulu
  roadWaypoints.append(QGeoCoordinate(65.012295, 25.470932));
  roadWaypoints.append(QGeoCoordinate(65.012615, 25.471401));
  roadWaypoints.append(QGeoCoordinate(65.012653, 25.471447));
  roadWaypoints.append(QGeoCoordinate(65.012691, 25.471509));
  roadWaypoints.append(QGeoCoordinate(65.013001, 25.471958));
  roadWaypoints.append(QGeoCoordinate(65.013068, 25.472055));
  roadWaypoints.append(QGeoCoordinate(65.013216, 25.472270));
  roadWaypoints.append(QGeoCoordinate(65.013343, 25.472452));
  roadWaypoints.append(QGeoCoordinate(65.013442, 25.472598));
  roadWaypoints.append(QGeoCoordinate(65.013515, 25.472695));
  roadWaypoints.append(QGeoCoordinate(65.013837, 25.473170));
  roadWaypoints.append(QGeoCoordinate(65.013920, 25.473296));
  roadWaypoints.append(QGeoCoordinate(65.014118, 25.473597));
  roadWaypoints.append(QGeoCoordinate(65.014168, 25.473674));
  roadWaypoints.append(QGeoCoordinate(65.014197, 25.473560));
  roadWaypoints.append(QGeoCoordinate(65.014213, 25.473502));
  roadWaypoints.append(QGeoCoordinate(65.014335, 25.473057));
  roadWaypoints.append(QGeoCoordinate(65.014369, 25.472934));
  roadWaypoints.append(QGeoCoordinate(65.014384, 25.472880));
  roadWaypoints.append(QGeoCoordinate(65.014395, 25.472839));
  roadWaypoints.append(QGeoCoordinate(65.014628, 25.471988));
  roadWaypoints.append(QGeoCoordinate(65.014660, 25.471870));
  roadWaypoints.append(QGeoCoordinate(65.014684, 25.471783));
  roadWaypoints.append(QGeoCoordinate(65.014729, 25.471843));
  roadWaypoints.append(QGeoCoordinate(65.014809, 25.471806));
  roadWaypoints.append(QGeoCoordinate(65.014857, 25.471892));
  roadWaypoints.append(QGeoCoordinate(65.015095, 25.472248));
  roadWaypoints.append(QGeoCoordinate(65.015187, 25.472384));
  roadWaypoints.append(QGeoCoordinate(65.015247, 25.472458));
  roadWaypoints.append(QGeoCoordinate(65.015286, 25.472520));
  roadWaypoints.append(QGeoCoordinate(65.015702, 25.473147));
  roadWaypoints.append(QGeoCoordinate(65.015758, 25.473207));
  roadWaypoints.append(QGeoCoordinate(65.015795, 25.473260));
  roadWaypoints.append(QGeoCoordinate(65.015891, 25.472904));
  roadWaypoints.append(QGeoCoordinate(65.015992, 25.472527));
  roadWaypoints.append(QGeoCoordinate(65.016094, 25.472350));
  roadWaypoints.append(QGeoCoordinate(65.016297, 25.471599));
  roadWaypoints.append(QGeoCoordinate(65.016319, 25.471491));
  roadWaypoints.append(QGeoCoordinate(65.016342, 25.471010));
  roadWaypoints.append(QGeoCoordinate(65.016388, 25.470851));
  roadWaypoints.append(QGeoCoordinate(65.016942, 25.469930));
  roadWaypoints.append(QGeoCoordinate(65.017204, 25.469516));
  roadWaypoints.append(QGeoCoordinate(65.017578, 25.468907));
  roadWaypoints.append(QGeoCoordinate(65.017590, 25.468887));
  roadWaypoints.append(QGeoCoordinate(65.017734, 25.468710));
  roadWaypoints.append(QGeoCoordinate(65.018824, 25.468114));
  roadWaypoints.append(QGeoCoordinate(65.018935, 25.468126));
  roadWaypoints.append(QGeoCoordinate(65.019000, 25.468175));
  roadWaypoints.append(QGeoCoordinate(65.019100, 25.468305));
  roadWaypoints.append(QGeoCoordinate(65.019206, 25.468208));
  roadWaypoints.append(QGeoCoordinate(65.019235, 25.468192));
  roadWaypoints.append(QGeoCoordinate(65.019264, 25.468177));
  roadWaypoints.append(QGeoCoordinate(65.019322, 25.468162));
  roadWaypoints.append(QGeoCoordinate(65.019362, 25.468155));
  roadWaypoints.append(QGeoCoordinate(65.019401, 25.468155));
  roadWaypoints.append(QGeoCoordinate(65.019441, 25.468199));
  roadWaypoints.append(QGeoCoordinate(65.019558, 25.468117));
  roadWaypoints.append(QGeoCoordinate(65.020496, 25.468252));
  roadWaypoints.append(QGeoCoordinate(65.020549, 25.468260));
  roadWaypoints.append(QGeoCoordinate(65.020688, 25.468214));
  roadWaypoints.append(QGeoCoordinate(65.020765, 25.468213));
  roadWaypoints.append(QGeoCoordinate(65.021662, 25.468349));
  roadWaypoints.append(QGeoCoordinate(65.021716, 25.468390));
  roadWaypoints.append(QGeoCoordinate(65.021834, 25.468480));
  roadWaypoints.append(QGeoCoordinate(65.022046, 25.468507));
  roadWaypoints.append(QGeoCoordinate(65.022091, 25.468513));
  roadWaypoints.append(QGeoCoordinate(65.022145, 25.468518));
  roadWaypoints.append(QGeoCoordinate(65.022171, 25.468520));
  roadWaypoints.append(QGeoCoordinate(65.022298, 25.468541));
  roadWaypoints.append(QGeoCoordinate(65.022316, 25.468544));
  roadWaypoints.append(QGeoCoordinate(65.022427, 25.468561));
  roadWaypoints.append(QGeoCoordinate(65.022527, 25.468491));
  roadWaypoints.append(QGeoCoordinate(65.022554, 25.468484));
  roadWaypoints.append(QGeoCoordinate(65.023118, 25.468574));
  roadWaypoints.append(QGeoCoordinate(65.023135, 25.468595));
  roadWaypoints.append(QGeoCoordinate(65.023221, 25.468701));
  roadWaypoints.append(QGeoCoordinate(65.023409, 25.468901));
  roadWaypoints.append(QGeoCoordinate(65.023430, 25.468924));
  roadWaypoints.append(QGeoCoordinate(65.023528, 25.469031));
  roadWaypoints.append(QGeoCoordinate(65.023571, 25.469197));
  roadWaypoints.append(QGeoCoordinate(65.023591, 25.469201));
  roadWaypoints.append(QGeoCoordinate(65.023615, 25.469210));
  roadWaypoints.append(QGeoCoordinate(65.023689, 25.469234));
  roadWaypoints.append(QGeoCoordinate(65.023739, 25.469255));
  roadWaypoints.append(QGeoCoordinate(65.023765, 25.469259));
  roadWaypoints.append(QGeoCoordinate(65.023815, 25.469231));
  roadWaypoints.append(QGeoCoordinate(65.024034, 25.469405));
  roadWaypoints.append(QGeoCoordinate(65.024226, 25.469568));
  roadWaypoints.append(QGeoCoordinate(65.024380, 25.469949));
  roadWaypoints.append(QGeoCoordinate(65.024397, 25.469919));
  roadWaypoints.append(QGeoCoordinate(65.024406, 25.469853));
  roadWaypoints.append(QGeoCoordinate(65.024437, 25.469924));
  roadWaypoints.append(QGeoCoordinate(65.025045, 25.470413));
  roadWaypoints.append(QGeoCoordinate(65.025442, 25.470742));
  roadWaypoints.append(QGeoCoordinate(65.025492, 25.470801));
  roadWaypoints.append(QGeoCoordinate(65.025815, 25.471060));
  roadWaypoints.append(QGeoCoordinate(65.025853, 25.471090));
  roadWaypoints.append(QGeoCoordinate(65.025879, 25.470899));
  roadWaypoints.append(QGeoCoordinate(65.025899, 25.470752));
  roadWaypoints.append(QGeoCoordinate(65.026015, 25.470853));
  roadWaypoints.append(QGeoCoordinate(65.026279, 25.471060));
  roadWaypoints.append(QGeoCoordinate(65.026427, 25.471114));
  roadWaypoints.append(QGeoCoordinate(65.026626, 25.471166));
  roadWaypoints.append(QGeoCoordinate(65.026867, 25.471137));
  roadWaypoints.append(QGeoCoordinate(65.027114, 25.471035));
  roadWaypoints.append(QGeoCoordinate(65.027360, 25.470852));
  roadWaypoints.append(QGeoCoordinate(65.027637, 25.470579));
  roadWaypoints.append(QGeoCoordinate(65.027720, 25.470498));
  roadWaypoints.append(QGeoCoordinate(65.027701, 25.470169));
  roadWaypoints.append(QGeoCoordinate(65.027639, 25.470241));
  roadWaypoints.append(QGeoCoordinate(65.027324, 25.470527));
  roadWaypoints.append(QGeoCoordinate(65.027189, 25.470625));
  roadWaypoints.append(QGeoCoordinate(65.027070, 25.470689));
  roadWaypoints.append(QGeoCoordinate(65.026950, 25.470746));
  
  // Now interpolate between these waypoints for smooth animation
  // Add intermediate points between each waypoint pair for smooth movement
  int pointsPerSegment = 8; // Smooth animation between waypoints
  
  for (int i = 0; i < roadWaypoints.size() - 1; ++i)
  {
    QGeoCoordinate start = roadWaypoints[i];
    QGeoCoordinate end = roadWaypoints[i + 1];
    
    // Add interpolated points between this waypoint and the next
    for (int j = 0; j < pointsPerSegment; ++j)
    {
      double t = static_cast<double>(j) / pointsPerSegment;
      double lat = start.latitude() + t * (end.latitude() - start.latitude());
      double lon = start.longitude() + t * (end.longitude() - start.longitude());
      m_routePoints.append(QGeoCoordinate(lat, lon));
    }
  }
  
  // Add the final endpoint
  m_routePoints.append(roadWaypoints.last());
  
  // Calculate total distance
  m_totalDistance = 0.0;
  for (int i = 0; i < m_routePoints.size() - 1; ++i)
  {
    m_totalDistance += calculateDistance(m_routePoints[i], m_routePoints[i + 1]);
  }
  
  qDebug() << "Route generated with" << m_routePoints.size() << "points";
  qDebug() << "Total distance:" << m_totalDistance << "meters";
  qDebug() << "Following" << roadWaypoints.size() << "road waypoints";

  // Expose total distance (in km) to dashboard
  m_dashboardData->setTotalDistance(m_totalDistance / 1000.0);
}

double RouteSimulator::calculateDistance(const QGeoCoordinate &from, const QGeoCoordinate &to)
{
  // Use Qt's built-in distance calculation (returns meters)
  return from.distanceTo(to);
}

void RouteSimulator::startRide()
{
  if (!m_dashboardData->isRiding())
  {
    m_dashboardData->setIsRiding(true);
    m_currentPointIndex = 0;
    m_traveledDistance = 0.0;
    m_dashboardData->setDistance(0.0);
    
    // Reset to start position
    m_dashboardData->setLatitude(m_startCoord.latitude());
    m_dashboardData->setLongitude(m_startCoord.longitude());
    
    m_timer->start();
    qDebug() << "Ride started";
  }
}

void RouteSimulator::stopRide()
{
  if (m_dashboardData->isRiding())
  {
    m_dashboardData->setIsRiding(false);
    m_timer->stop();
    qDebug() << "Ride stopped at" << m_traveledDistance << "meters";
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
  if (!m_dashboardData->isRiding() || m_currentPointIndex >= m_routePoints.size())
  {
    // End of route reached
    if (m_currentPointIndex >= m_routePoints.size())
    {
      qDebug() << "Destination reached!";
      stopRide();
      
      // Reset to start for next ride
      m_currentPointIndex = 0;
      m_traveledDistance = 0.0;
    }
    return;
  }
  
  // Update position to current point
  QGeoCoordinate currentPos = m_routePoints[m_currentPointIndex];
  m_dashboardData->setLatitude(currentPos.latitude());
  m_dashboardData->setLongitude(currentPos.longitude());
  
  // Calculate distance traveled
  if (m_currentPointIndex > 0)
  {
    double segmentDistance = calculateDistance(
      m_routePoints[m_currentPointIndex - 1],
      m_routePoints[m_currentPointIndex]
    );
    m_traveledDistance += segmentDistance;
    m_dashboardData->setDistance(m_traveledDistance / 1000.0); // Convert to km
  }
  
  // Calculate and update speed (km/h)
  // Simulate varying speed between 15-25 km/h
  int baseSpeed = 20;
  int speedVariation = 5;
  int currentSpeed = baseSpeed + (QRandomGenerator::global()->bounded(speedVariation * 2 + 1)) - speedVariation;
  currentSpeed = qMax(15, qMin(25, currentSpeed));
  m_dashboardData->setSpeed(currentSpeed);
  
  // Update battery (decrease based on distance)
  // Lose approximately 1% per 500 meters
  int batteryPercent = 100 - static_cast<int>(m_traveledDistance / 500.0);
  batteryPercent = qMax(0, qMin(100, batteryPercent));
  m_dashboardData->setBatteryPercent(batteryPercent);
  
  // Move to next point
  m_currentPointIndex++;
}
