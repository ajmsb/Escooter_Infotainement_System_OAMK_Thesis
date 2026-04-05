#ifndef DASHBOARDDATA_H
#define DASHBOARDDATA_H

#include <QObject>

class DashboardData : public QObject
{
  Q_OBJECT
  Q_PROPERTY(int speed READ speed WRITE setSpeed NOTIFY speedChanged)
  Q_PROPERTY(int batteryPercent READ batteryPercent WRITE setBatteryPercent NOTIFY batteryPercentChanged)
  Q_PROPERTY(QString ridingMode READ ridingMode WRITE setRidingMode NOTIFY ridingModeChanged)
  Q_PROPERTY(QString nextInstruction READ nextInstruction WRITE setNextInstruction NOTIFY nextInstructionChanged)
  Q_PROPERTY(QString songTitle READ songTitle WRITE setSongTitle NOTIFY songTitleChanged)
  Q_PROPERTY(QString artistName READ artistName WRITE setArtistName NOTIFY artistNameChanged)
  Q_PROPERTY(bool isPlaying READ isPlaying WRITE setIsPlaying NOTIFY isPlayingChanged)
  Q_PROPERTY(QString temperature READ temperature WRITE setTemperature NOTIFY temperatureChanged)
  Q_PROPERTY(QString weatherIcon READ weatherIcon WRITE setWeatherIcon NOTIFY weatherIconChanged)
  Q_PROPERTY(QString weatherDesc READ weatherDesc WRITE setWeatherDesc NOTIFY weatherDescChanged)
  Q_PROPERTY(double latitude READ latitude WRITE setLatitude NOTIFY latitudeChanged)
  Q_PROPERTY(double longitude READ longitude WRITE setLongitude NOTIFY longitudeChanged)
  Q_PROPERTY(bool isRiding READ isRiding WRITE setIsRiding NOTIFY isRidingChanged)
  Q_PROPERTY(double distance READ distance WRITE setDistance NOTIFY distanceChanged)
  Q_PROPERTY(double totalDistance READ totalDistance WRITE setTotalDistance NOTIFY totalDistanceChanged)
  Q_PROPERTY(double heading READ heading WRITE setHeading NOTIFY headingChanged)

public:
  explicit DashboardData(QObject *parent = nullptr);

  int speed() const;
  void setSpeed(int speed);

  int batteryPercent() const;
  void setBatteryPercent(int percent);

  QString ridingMode() const;
  void setRidingMode(const QString &mode);

  QString nextInstruction() const;
  void setNextInstruction(const QString &instruction);

  QString songTitle() const;
  void setSongTitle(const QString &title);

  QString artistName() const;
  void setArtistName(const QString &artist);

  bool isPlaying() const;
  void setIsPlaying(bool playing);

  QString temperature() const;
  void setTemperature(const QString &temp);

  QString weatherIcon() const;
  void setWeatherIcon(const QString &icon);

  QString weatherDesc() const;
  void setWeatherDesc(const QString &desc);

  double latitude() const;
  void setLatitude(double lat);

  double longitude() const;
  void setLongitude(double lon);

  bool isRiding() const;
  void setIsRiding(bool riding);

  double distance() const;
  void setDistance(double dist);

  double totalDistance() const;
  void setTotalDistance(double dist);

  double heading() const;
  void setHeading(double heading);

signals:
  void speedChanged();
  void batteryPercentChanged();
  void ridingModeChanged();
  void nextInstructionChanged();
  void songTitleChanged();
  void artistNameChanged();
  void isPlayingChanged();
  void temperatureChanged();
  void weatherIconChanged();
  void weatherDescChanged();
  void latitudeChanged();
  void longitudeChanged();
  void isRidingChanged();
  void distanceChanged();
  void totalDistanceChanged();
  void headingChanged();

private:
  int m_speed;
  int m_batteryPercent;
  QString m_ridingMode;
  QString m_nextInstruction;
  QString m_songTitle;
  QString m_artistName;
  bool m_isPlaying;
  QString m_temperature;
  QString m_weatherIcon;
  QString m_weatherDesc;
  double m_latitude;
  double m_longitude;
  bool m_isRiding;
  double m_distance;
  double m_totalDistance;
  double m_heading;
};

#endif // DASHBOARDDATA_H
