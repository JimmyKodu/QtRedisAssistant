#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QTextEdit>
#include <QLineEdit>
#include <QPushButton>
#include <QLabel>
#include "redisconnection.h"

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void onConnectClicked();
    void onExecuteClicked();
    void onConnectionStatusChanged(bool connected);

private:
    Ui::MainWindow *ui;
    RedisConnection *redisConnection;
    
    QLineEdit *hostEdit;
    QLineEdit *portEdit;
    QPushButton *connectButton;
    QLabel *statusLabel;
    QLineEdit *commandEdit;
    QPushButton *executeButton;
    QTextEdit *outputEdit;
};

#endif // MAINWINDOW_H
