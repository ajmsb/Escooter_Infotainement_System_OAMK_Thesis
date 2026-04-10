#include "datasimulator.h"

// DataSimulator simulates dynamic changes in speed, battery level, navigation instructions, 
// music info, and weather conditions for testing the dashboard UI.
DataSimulator::DataSimulator(DashboardData *data, QObject *parent)
    : QObject(parent), m_dashboardData(data), m_timer(new QTimer(this)), m_currentSpeed(0), m_currentBattery(78), m_speedIncreasing(true)
{
  connect(m_timer, &QTimer::timeout, this, &DataSimulator::updateData);
  m_timer->setInterval(100); // Update every 100ms
}

// Start the data simulation
void DataSimulator::start()
{
  m_timer->start();
}

// Stop the data simulation
void DataSimulator::stop()
{
  m_timer->stop();
}

// Update simulated data on each timer tick
void DataSimulator::updateData()
{
  // Simulate speed: only vary when riding is active
  /*if (m_dashboardData->isRiding())
  {
    if (m_speedIncreasing)
    {
      m_currentSpeed++;
      if (m_currentSpeed >= 25)
      {
        m_speedIncreasing = false;
      }
    }
    else
    {
      m_currentSpeed--;
      if (m_currentSpeed <= 0)
      {
        m_speedIncreasing = true;
      }
    }
  }
  else
  {
    m_currentSpeed = 0;
    m_speedIncreasing = true;
  }
  m_dashboardData->setSpeed(m_currentSpeed); */

  // Simulate battery: decrease slowly every 50 updates (5 seconds), only while riding
  /*static int batteryCounter = 0;
  if (m_dashboardData->isRiding())
  {
    batteryCounter++;
    if (batteryCounter >= 50)
    {
      batteryCounter = 0;
      if (m_currentBattery > 0)
      {
        m_currentBattery--;
        m_dashboardData->setBatteryPercent(m_currentBattery);
      }
      else
      {
        m_currentBattery = 100; // Reset to full
        m_dashboardData->setBatteryPercent(m_currentBattery);
      }
    }
  }
  else
  {
    batteryCounter = 0;
  }*/

  // Cycle navigation instructions every 100 updates (10 seconds)
  static int navCounter = 0;
  static int navIndex = 0;
  navCounter++;
  if (navCounter >= 100)
  {
    navCounter = 0;
    QStringList instructions = {
        "In 200m, turn left",
        "In 500m, turn right",
        "Continue straight for 1km",
        "Take the next exit",
        "Arriving at destination"};
    navIndex = (navIndex + 1) % instructions.size();
    m_dashboardData->setNextInstruction(instructions[navIndex]);
  }

  // Cycle songs every 150 updates (15 seconds)
  static int musicCounter = 0;
  static int songIndex = 0;
  musicCounter++;
  if (musicCounter >= 150)
  {
    musicCounter = 0;
    QStringList songs = {"Riding High", "Electric Dreams", "City Lights", "Freedom Road"};
    QStringList artists = {"The Highway Band", "Neon Riders", "Urban Pulse", "Journey Makers"};
    songIndex = (songIndex + 1) % songs.size();
    m_dashboardData->setSongTitle(songs[songIndex]);
    m_dashboardData->setArtistName(artists[songIndex]);
  }

  // Toggle play/pause every 200 updates (20 seconds)
  static int playCounter = 0;
  playCounter++;
  if (playCounter >= 200)
  {
    playCounter = 0;
    m_dashboardData->setIsPlaying(!m_dashboardData->isPlaying());
  }

  // Cycle weather every 120 updates (12 seconds)
  /*static int weatherCounter = 0;
  static int weatherIndex = 0;
  weatherCounter++;
  if (weatherCounter >= 120)
  {
    weatherCounter = 0;
    QStringList icons = {"☀️", "⛅", "☁️", "🌧️"};
    QStringList descriptions = {"Sunny", "Partly Cloudy", "Cloudy", "Rainy"};
    QStringList temps = {"22", "18", "15", "12"};
    weatherIndex = (weatherIndex + 1) % icons.size();
    m_dashboardData->setWeatherIcon(icons[weatherIndex]);
    m_dashboardData->setWeatherDesc(descriptions[weatherIndex]);
    m_dashboardData->setTemperature(temps[weatherIndex]);
  }*/
}
