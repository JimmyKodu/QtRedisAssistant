#ifndef REDISCONNECTION_H
#define REDISCONNECTION_H

#include <QObject>
#include <QTcpSocket>
#include <QString>

class RedisConnection : public QObject
{
    Q_OBJECT

public:
    explicit RedisConnection(QObject *parent = nullptr);
    ~RedisConnection();
    
    void connectToRedis(const QString &host, int port);
    void disconnect();
    bool isConnected() const;
    QString executeCommand(const QString &command);

signals:
    void connectionStatusChanged(bool connected);
    void errorOccurred(const QString &error);

private slots:
    void onConnected();
    void onDisconnected();
    void onError(QAbstractSocket::SocketError socketError);

private:
    QString sendCommand(const QString &command);
    QString parseRedisResponse();
    
    QTcpSocket *socket;
    bool connected;
};

#endif // REDISCONNECTION_H
