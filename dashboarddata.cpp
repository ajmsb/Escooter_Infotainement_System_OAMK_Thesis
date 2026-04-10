#include "dashboarddata.h"

// DashboardData is a QObject that holds all the properties related to the scooter's dashboard,
// such as speed, battery level, navigation instructions, music info, weather conditions, and location data.
// It provides getter and setter methods for each property, along with signals to notify when properties change.
// This class serves as the central data model for the dashboard UI.    
DashboardData::DashboardData(QObject *parent)
    : QObject(parent), m_speed(0), m_batteryPercent(100), m_ridingMode("ECO"),
      m_nextInstruction("In 200m, turn left"), m_songTitle("Riding High"),
      m_artistName("The Highway Band"), m_isPlaying(true), m_temperature("22"),
      m_weatherIcon("☀️"), m_weatherDesc("Sunny"),
      m_latitude(65.06086919646035), m_longitude(25.467637259998213),
      m_isRiding(false), m_distance(0.0), m_totalDistance(0.0), m_heading(0.0)
{
}

// Getter and setter implementations for each property, with change notifications
int DashboardData::speed() const
{
  return m_speed;
}

// Set speed and emit signal if changed
void DashboardData::setSpeed(int speed)
{
  if (m_speed != speed)
  {
    m_speed = speed;
    emit speedChanged();
  }
}

// Getter and setter for battery percentage
int DashboardData::batteryPercent() const
{
  return m_batteryPercent;
}

// Set battery percentage and emit signal if changed
void DashboardData::setBatteryPercent(int percent)
{
  if (m_batteryPercent != percent)
  {
    m_batteryPercent = percent;
    emit batteryPercentChanged();
  }
}

// Getter and setter for riding mode
QString DashboardData::ridingMode() const
{
  return m_ridingMode;
}

// Set riding mode and emit signal if changed
void DashboardData::setRidingMode(const QString &mode)
{
  if (m_ridingMode != mode)
  {
    m_ridingMode = mode;
    emit ridingModeChanged();
  }
}

// Getter and setter for next navigation instruction
QString DashboardData::nextInstruction() const
{
  return m_nextInstruction;
}

// Set next instruction and emit signal if changed
void DashboardData::setNextInstruction(const QString &instruction)
{
  if (m_nextInstruction != instruction)
  {
    m_nextInstruction = instruction;
    emit nextInstructionChanged();
  }
}

// Getter and setter for song title
QString DashboardData::songTitle() const
{
  return m_songTitle;
}

// Set song title and emit signal if changed
void DashboardData::setSongTitle(const QString &title)
{
  if (m_songTitle != title)
  {
    m_songTitle = title;
    emit songTitleChanged();
  }
}

// Getter and setter for artist name
QString DashboardData::artistName() const
{
  return m_artistName;
}

// Set artist name and emit signal if changed
void DashboardData::setArtistName(const QString &artist)
{
  if (m_artistName != artist)
  {
    m_artistName = artist;
    emit artistNameChanged();
  }
}

// Getter and setter for playing status
bool DashboardData::isPlaying() const
{
  return m_isPlaying;
}

// Set playing status and emit signal if changed
void DashboardData::setIsPlaying(bool playing)
{
  if (m_isPlaying != playing)
  {
    m_isPlaying = playing;
    emit isPlayingChanged();
  }
}

// Getter and setter for temperature
QString DashboardData::temperature() const
{
  return m_temperature;
}

// Set temperature and emit signal if changed
void DashboardData::setTemperature(const QString &temp)
{
  if (m_temperature != temp)
  {
    m_temperature = temp;
    emit temperatureChanged();
  }
}

// Getter and setter for weather icon
QString DashboardData::weatherIcon() const
{
  return m_weatherIcon;
}

// Set weather icon and emit signal if changed
void DashboardData::setWeatherIcon(const QString &icon)
{
  if (m_weatherIcon != icon)
  {
    m_weatherIcon = icon;
    emit weatherIconChanged();
  }
}

// Getter and setter for weather description
QString DashboardData::weatherDesc() const
{
  return m_weatherDesc;
}

// Set weather description and emit signal if changed
void DashboardData::setWeatherDesc(const QString &desc)
{
  if (m_weatherDesc != desc)
  {
    m_weatherDesc = desc;
    emit weatherDescChanged();
  }
}

// Getter and setter for latitude
double DashboardData::latitude() const
{
  return m_latitude;
}

// Set latitude and emit signal if changed
void DashboardData::setLatitude(double lat)
{
  if (qAbs(m_latitude - lat) > 0.0000001)
  {
    m_latitude = lat;
    emit latitudeChanged();
  }
}

// Getter and setter for longitude
double DashboardData::longitude() const
{
  return m_longitude;
}

// Set longitude and emit signal if changed
void DashboardData::setLongitude(double lon)
{
  if (qAbs(m_longitude - lon) > 0.0000001)
  {
    m_longitude = lon;
    emit longitudeChanged();
  }
}

// Getter and setter for riding status
bool DashboardData::isRiding() const
{
  return m_isRiding;
}

// Set riding status and emit signal if changed
void DashboardData::setIsRiding(bool riding)
{
  if (m_isRiding != riding)
  {
    m_isRiding = riding;
    emit isRidingChanged();
  }
}

// Getter and setter for distance
double DashboardData::distance() const
{
  return m_distance;
}

// Set distance and emit signal if changed
void DashboardData::setDistance(double dist)
{
  if (qAbs(m_distance - dist) > 0.001)
  {
    m_distance = dist;
    emit distanceChanged();
  }
}

// Getter and setter for total distance
double DashboardData::totalDistance() const
{
  return m_totalDistance;
}

// Set total distance and emit signal if changed
void DashboardData::setTotalDistance(double dist)
{
  if (qAbs(m_totalDistance - dist) > 0.001)
  {
    m_totalDistance = dist;
    emit totalDistanceChanged();
  }
}

// Getter and setter for heading
double DashboardData::heading() const
{
  return m_heading;
}

// Set heading and emit signal if changed
void DashboardData::setHeading(double heading)
{
  if (qAbs(m_heading - heading) > 0.1)
  {
    m_heading = heading;
    emit headingChanged();
  }
}
