#include "dashboarddata.h"

DashboardData::DashboardData(QObject *parent)
    : QObject(parent), m_speed(0), m_batteryPercent(100), m_ridingMode("ECO MODE"),
      m_nextInstruction("In 200m, turn left"), m_songTitle("Riding High"),
      m_artistName("The Highway Band"), m_isPlaying(true), m_temperature("22"),
      m_weatherIcon("☀️"), m_weatherDesc("Sunny"),
      m_latitude(65.01323660736493), m_longitude(25.466785314663174),
      m_isRiding(false), m_distance(0.0), m_totalDistance(0.0)
{
}

int DashboardData::speed() const
{
  return m_speed;
}

void DashboardData::setSpeed(int speed)
{
  if (m_speed != speed)
  {
    m_speed = speed;
    emit speedChanged();
  }
}

int DashboardData::batteryPercent() const
{
  return m_batteryPercent;
}

void DashboardData::setBatteryPercent(int percent)
{
  if (m_batteryPercent != percent)
  {
    m_batteryPercent = percent;
    emit batteryPercentChanged();
  }
}

QString DashboardData::ridingMode() const
{
  return m_ridingMode;
}

void DashboardData::setRidingMode(const QString &mode)
{
  if (m_ridingMode != mode)
  {
    m_ridingMode = mode;
    emit ridingModeChanged();
  }
}

QString DashboardData::nextInstruction() const
{
  return m_nextInstruction;
}

void DashboardData::setNextInstruction(const QString &instruction)
{
  if (m_nextInstruction != instruction)
  {
    m_nextInstruction = instruction;
    emit nextInstructionChanged();
  }
}

QString DashboardData::songTitle() const
{
  return m_songTitle;
}

void DashboardData::setSongTitle(const QString &title)
{
  if (m_songTitle != title)
  {
    m_songTitle = title;
    emit songTitleChanged();
  }
}

QString DashboardData::artistName() const
{
  return m_artistName;
}

void DashboardData::setArtistName(const QString &artist)
{
  if (m_artistName != artist)
  {
    m_artistName = artist;
    emit artistNameChanged();
  }
}

bool DashboardData::isPlaying() const
{
  return m_isPlaying;
}

void DashboardData::setIsPlaying(bool playing)
{
  if (m_isPlaying != playing)
  {
    m_isPlaying = playing;
    emit isPlayingChanged();
  }
}

QString DashboardData::temperature() const
{
  return m_temperature;
}

void DashboardData::setTemperature(const QString &temp)
{
  if (m_temperature != temp)
  {
    m_temperature = temp;
    emit temperatureChanged();
  }
}

QString DashboardData::weatherIcon() const
{
  return m_weatherIcon;
}

void DashboardData::setWeatherIcon(const QString &icon)
{
  if (m_weatherIcon != icon)
  {
    m_weatherIcon = icon;
    emit weatherIconChanged();
  }
}

QString DashboardData::weatherDesc() const
{
  return m_weatherDesc;
}

void DashboardData::setWeatherDesc(const QString &desc)
{
  if (m_weatherDesc != desc)
  {
    m_weatherDesc = desc;
    emit weatherDescChanged();
  }
}

double DashboardData::latitude() const
{
  return m_latitude;
}

void DashboardData::setLatitude(double lat)
{
  if (qAbs(m_latitude - lat) > 0.0000001)
  {
    m_latitude = lat;
    emit latitudeChanged();
  }
}

double DashboardData::longitude() const
{
  return m_longitude;
}

void DashboardData::setLongitude(double lon)
{
  if (qAbs(m_longitude - lon) > 0.0000001)
  {
    m_longitude = lon;
    emit longitudeChanged();
  }
}

bool DashboardData::isRiding() const
{
  return m_isRiding;
}

void DashboardData::setIsRiding(bool riding)
{
  if (m_isRiding != riding)
  {
    m_isRiding = riding;
    emit isRidingChanged();
  }
}

double DashboardData::distance() const
{
  return m_distance;
}

void DashboardData::setDistance(double dist)
{
  if (qAbs(m_distance - dist) > 0.001)
  {
    m_distance = dist;
    emit distanceChanged();
  }
}

double DashboardData::totalDistance() const
{
  return m_totalDistance;
}

void DashboardData::setTotalDistance(double dist)
{
  if (qAbs(m_totalDistance - dist) > 0.001)
  {
    m_totalDistance = dist;
    emit totalDistanceChanged();
  }
}
