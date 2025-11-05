#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QGroupBox>
#include <QMessageBox>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
    , redisConnection(new RedisConnection(this))
{
    ui->setupUi(this);
    
    setWindowTitle("Qt Redis Assistant v1.0.0");
    
    // Create central widget
    QWidget *centralWidget = new QWidget(this);
    QVBoxLayout *mainLayout = new QVBoxLayout(centralWidget);
    
    // Connection group
    QGroupBox *connectionGroup = new QGroupBox("Redis Connection", this);
    QHBoxLayout *connectionLayout = new QHBoxLayout(connectionGroup);
    
    connectionLayout->addWidget(new QLabel("Host:", this));
    hostEdit = new QLineEdit("127.0.0.1", this);
    connectionLayout->addWidget(hostEdit);
    
    connectionLayout->addWidget(new QLabel("Port:", this));
    portEdit = new QLineEdit("6379", this);
    portEdit->setMaximumWidth(80);
    connectionLayout->addWidget(portEdit);
    
    connectButton = new QPushButton("Connect", this);
    connectionLayout->addWidget(connectButton);
    
    statusLabel = new QLabel("Disconnected", this);
    statusLabel->setStyleSheet("color: red; font-weight: bold;");
    connectionLayout->addWidget(statusLabel);
    
    mainLayout->addWidget(connectionGroup);
    
    // Command group
    QGroupBox *commandGroup = new QGroupBox("Redis Commands", this);
    QVBoxLayout *commandLayout = new QVBoxLayout(commandGroup);
    
    QHBoxLayout *commandInputLayout = new QHBoxLayout();
    commandInputLayout->addWidget(new QLabel("Command:", this));
    commandEdit = new QLineEdit(this);
    commandEdit->setPlaceholderText("Enter Redis command (e.g., PING, INFO)");
    commandInputLayout->addWidget(commandEdit);
    
    executeButton = new QPushButton("Execute", this);
    executeButton->setEnabled(false);
    commandInputLayout->addWidget(executeButton);
    
    commandLayout->addLayout(commandInputLayout);
    
    outputEdit = new QTextEdit(this);
    outputEdit->setReadOnly(true);
    outputEdit->setPlaceholderText("Output will appear here...");
    commandLayout->addWidget(outputEdit);
    
    mainLayout->addWidget(commandGroup);
    
    setCentralWidget(centralWidget);
    
    // Connect signals
    connect(connectButton, &QPushButton::clicked, this, &MainWindow::onConnectClicked);
    connect(executeButton, &QPushButton::clicked, this, &MainWindow::onExecuteClicked);
    connect(redisConnection, &RedisConnection::connectionStatusChanged, 
            this, &MainWindow::onConnectionStatusChanged);
    
    resize(800, 600);
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::onConnectClicked()
{
    if (redisConnection->isConnected()) {
        redisConnection->disconnect();
    } else {
        QString host = hostEdit->text();
        int port = portEdit->text().toInt();
        redisConnection->connectToRedis(host, port);
    }
}

void MainWindow::onExecuteClicked()
{
    QString command = commandEdit->text().trimmed();
    if (command.isEmpty()) {
        QMessageBox::warning(this, "Warning", "Please enter a command");
        return;
    }
    
    QString response = redisConnection->executeCommand(command);
    outputEdit->append(QString("> %1\n%2\n").arg(command, response));
    commandEdit->clear();
}

void MainWindow::onConnectionStatusChanged(bool connected)
{
    if (connected) {
        statusLabel->setText("Connected");
        statusLabel->setStyleSheet("color: green; font-weight: bold;");
        connectButton->setText("Disconnect");
        executeButton->setEnabled(true);
        outputEdit->append("=== Connected to Redis ===\n");
    } else {
        statusLabel->setText("Disconnected");
        statusLabel->setStyleSheet("color: red; font-weight: bold;");
        connectButton->setText("Connect");
        executeButton->setEnabled(false);
        outputEdit->append("=== Disconnected from Redis ===\n");
    }
}
