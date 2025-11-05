#include "redisconnection.h"
#include <QDebug>

RedisConnection::RedisConnection(QObject *parent)
    : QObject(parent)
    , socket(new QTcpSocket(this))
    , connected(false)
{
    connect(socket, &QTcpSocket::connected, this, &RedisConnection::onConnected);
    connect(socket, &QTcpSocket::disconnected, this, &RedisConnection::onDisconnected);
    connect(socket, QOverload<QAbstractSocket::SocketError>::of(&QAbstractSocket::errorOccurred),
            this, &RedisConnection::onError);
}

RedisConnection::~RedisConnection()
{
    if (socket->isOpen()) {
        socket->close();
    }
}

void RedisConnection::connectToRedis(const QString &host, int port)
{
    if (connected) {
        return;
    }
    
    socket->connectToHost(host, port);
}

void RedisConnection::disconnect()
{
    if (socket->isOpen()) {
        socket->close();
    }
}

bool RedisConnection::isConnected() const
{
    return connected;
}

QString RedisConnection::executeCommand(const QString &command)
{
    if (!connected) {
        return "Error: Not connected to Redis";
    }
    
    return sendCommand(command);
}

void RedisConnection::onConnected()
{
    connected = true;
    emit connectionStatusChanged(true);
    qDebug() << "Connected to Redis";
}

void RedisConnection::onDisconnected()
{
    connected = false;
    emit connectionStatusChanged(false);
    qDebug() << "Disconnected from Redis";
}

void RedisConnection::onError(QAbstractSocket::SocketError socketError)
{
    QString errorMsg = socket->errorString();
    qDebug() << "Redis connection error:" << errorMsg;
    emit errorOccurred(errorMsg);
    connected = false;
    emit connectionStatusChanged(false);
}

QString RedisConnection::sendCommand(const QString &command)
{
    if (!socket->isWritable()) {
        return "Error: Socket not writable";
    }
    
    // Format command in Redis protocol (RESP)
    QStringList parts = command.split(' ', Qt::SkipEmptyParts);
    QString resp = QString("*%1\r\n").arg(parts.size());
    
    for (const QString &part : parts) {
        resp += QString("$%1\r\n%2\r\n").arg(part.length()).arg(part);
    }
    
    socket->write(resp.toUtf8());
    socket->flush();
    
    // Wait for response
    if (socket->waitForReadyRead(3000)) {
        return parseRedisResponse();
    } else {
        return "Error: Timeout waiting for response";
    }
}

QString RedisConnection::parseRedisResponse()
{
    QByteArray response = socket->readAll();
    QString result = QString::fromUtf8(response);
    
    // Simple parsing of Redis RESP protocol
    if (result.isEmpty()) {
        return "Error: Empty response";
    }
    
    char type = result[0].toLatin1();
    QString content = result.mid(1).trimmed();
    
    switch (type) {
        case '+': // Simple string
            return content;
        case '-': // Error
            return QString("Error: %1").arg(content);
        case ':': // Integer
            return content;
        case '$': // Bulk string
            {
                int pos = content.indexOf("\r\n");
                if (pos > 0) {
                    content = content.mid(pos + 2);
                }
                return content;
            }
        case '*': // Array
            return content;
        default:
            return result;
    }
}
