import 'package:dart_amqp/dart_amqp.dart';
import 'package:flutter/foundation.dart';

class AmqpAuthenticationData {
  final String rmqHost;
  final String rmqPort;
  final String rmqVHost;
  final String rmqUsername;
  final String rmqPassword;
  final int connectionAttempts;
  final int reconnectSecondsDuration;

  AmqpAuthenticationData({
    @required this.rmqHost,
    @required this.rmqPort,
    @required this.rmqUsername,
    @required this.rmqVHost,
    @required this.rmqPassword,
    this.connectionAttempts,
    this.reconnectSecondsDuration,
  });
}

class AmqpBindingData {
  final String exchangeName;
  final ExchangeType exchangeType;
  final List<String> routingKeys;
  final String queueName;
  final bool isDurableQueue;
  final bool needAck;
  AmqpBindingData(
      {@required this.exchangeName,
      @required this.exchangeType,
      this.routingKeys,
      this.isDurableQueue,
      this.queueName,
      this.needAck});
}

class AmqpService {
  Client amqpClient;

  AmqpService({@required AmqpAuthenticationData rmqAuthenticationData}) {
    ConnectionSettings settings = ConnectionSettings(
        host: rmqAuthenticationData.rmqHost,
        authProvider: PlainAuthenticator(rmqAuthenticationData.rmqUsername,
            rmqAuthenticationData.rmqPassword),
        virtualHost: rmqAuthenticationData.rmqVHost);

    if (rmqAuthenticationData.connectionAttempts != null) {
      settings.maxConnectionAttempts = rmqAuthenticationData.connectionAttempts;
    }

    if (rmqAuthenticationData.reconnectSecondsDuration != null) {
      settings.reconnectWaitTime =
          Duration(seconds: rmqAuthenticationData.reconnectSecondsDuration);
    }

    this.amqpClient = Client(settings: settings);
  }

  Future<Consumer> startConsumePrivateQueue(AmqpBindingData binding) async {
    Channel channel = await amqpClient.channel();
    Exchange exchange = await channel
        .exchange(binding.exchangeName, binding.exchangeType, durable: true);
    Consumer consumer =
        await exchange.bindPrivateQueueConsumer(binding.routingKeys);
    return consumer;
  }

  Future<Consumer> startConsumeCustomQueue(AmqpBindingData binding) async {
    Channel channel = await amqpClient.channel();
    Exchange exchange = await channel
        .exchange(binding.exchangeName, binding.exchangeType, durable: true);
    Queue customQueue =
        await channel.queue(binding.queueName, durable: binding.isDurableQueue);
    Consumer consumer = await exchange.bindQueueConsumer(
        customQueue.name, binding.routingKeys,
        noAck: !binding.needAck);
    return consumer;
  }

  Future<void> stopListenBindedQueue(
      Consumer consumer, AmqpBindingData binding) async {
    Channel channel = await amqpClient.channel();
    Exchange exchange =
        await channel.exchange(binding.exchangeName, binding.exchangeType);
    for (String routingKey in binding.routingKeys) {
      consumer.queue.unbind(exchange, routingKey);
    }
  }
}
