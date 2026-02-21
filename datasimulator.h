#ifndef DATASIMULATOR_H
#define DATASIMULATOR_H

#include <QObject>
#include <QTimer>
#include "dashboarddata.h"

class DataSimulator : public QObject
{
  Q_OBJECT

public:
  explicit DataSimulator(DashboardData *data, QObject *parent = nullptr);
  void start();
  void stop();

private slots:
  void updateData();

private:
  DashboardData *m_dashboardData;
  QTimer *m_timer;
  int m_currentSpeed;
  int m_currentBattery;
  bool m_speedIncreasing;
};

#endif // DATASIMULATOR_H
